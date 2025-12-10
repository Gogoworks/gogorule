#!/usr/bin/env bash

# OpenAI 规则合并脚本
# 作用：
# - 读取 rules/base/ 与 rules/custom/ 中的 OpenAI 相关规则
# - 合并并去重，生成 rules/merged/OpenAi.list
# 使用方式：
# - 请在仓库根目录执行： ./scripts/merge_openai.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

BASE_DIR="${ROOT_DIR}/rules/base"
CUSTOM_DIR="${ROOT_DIR}/rules/custom"
MERGED_DIR="${ROOT_DIR}/rules/merged"
OUTPUT_FILE="${MERGED_DIR}/OpenAi.list"

# 仓库信息（用于注释头）
REPO_OWNER="Gogoworks"
REPO_NAME="gogorule"

INPUT_FILES=(
  "${BASE_DIR}/openai_blackmatrix.list"
  "${BASE_DIR}/openai_acl4ssr.list"
  "${CUSTOM_DIR}/openai_custom.list"
)

mkdir -p "${MERGED_DIR}"

TMP_FILE="$(mktemp)"
DEDUP_FILE="$(mktemp)"
DOMAIN_FILE="$(mktemp)"
IP_FILE="$(mktemp)"
trap 'rm -f "${TMP_FILE}" "${DEDUP_FILE}" "${DOMAIN_FILE}" "${IP_FILE}"' EXIT

> "${TMP_FILE}"

for file in "${INPUT_FILES[@]}"; do
  if [[ -f "${file}" ]]; then
    rel_path="${file#${ROOT_DIR}/}"
    echo "合并文件: ${rel_path}"
    # 过滤掉注释行和空行，只保留真实规则行
    awk 'NF && $1 !~ /^#/' "${file}" >> "${TMP_FILE}"
  else
    rel_path="${file#${ROOT_DIR}/}"
    echo "警告: 未找到文件 ${rel_path}，已跳过" >&2
  fi
done

# 去重并统计规则数量
COUNTS="$(
  awk -v dedup_file="${DEDUP_FILE}" '
  !seen[$0]++ {
    print > dedup_file
    total++
    if ($1 ~ /^DOMAIN,/) domain++
    else if ($1 ~ /^DOMAIN-KEYWORD,/) dkw++
    else if ($1 ~ /^DOMAIN-SUFFIX,/) dsf++
    else if ($1 ~ /^IP-ASN,/) asn++
    else if ($1 ~ /^IP-CIDR,/) cidr++
  }
  END {
    printf("DOMAIN_COUNT=%d\n", domain+0);
    printf("DOMAIN_KEYWORD_COUNT=%d\n", dkw+0);
    printf("DOMAIN_SUFFIX_COUNT=%d\n", dsf+0);
    printf("IP_ASN_COUNT=%d\n", asn+0);
    printf("IP_CIDR_COUNT=%d\n", cidr+0);
    printf("TOTAL_COUNT=%d\n", total+0);
  }' "${TMP_FILE}"
)"

eval "${COUNTS}"

# 写入规范化注释头
{
  echo "# NAME: OpenAI"
  echo "# AUTHOR: GogoRule"
  echo "# REPO: https://github.com/${REPO_OWNER}/${REPO_NAME}"
  echo "# UPDATED: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "# DOMAIN: ${DOMAIN_COUNT}"
  echo "# DOMAIN-KEYWORD: ${DOMAIN_KEYWORD_COUNT}"
  echo "# DOMAIN-SUFFIX: ${DOMAIN_SUFFIX_COUNT}"
  echo "# IP-ASN: ${IP_ASN_COUNT}"
  echo "# IP-CIDR: ${IP_CIDR_COUNT}"
  echo "# TOTAL: ${TOTAL_COUNT}"
  echo "#"
  echo "# SOURCES:"
  echo "# - rules/base/openai_blackmatrix.list"
  echo "# - rules/base/openai_acl4ssr.list"
  echo "# - rules/custom/openai_custom.list"
  echo
} > "${OUTPUT_FILE}"

# 将去重后的规则拆分为「域名类」和「IP 类」，IP 类聚合到末尾
awk '
  $1 ~ /^IP-ASN,/ || $1 ~ /^IP-CIDR,/ { print > ip_file; next }
  { print > domain_file }
' domain_file="${DOMAIN_FILE}" ip_file="${IP_FILE}" "${DEDUP_FILE}"

cat "${DOMAIN_FILE}" >> "${OUTPUT_FILE}"

if [[ -s "${IP_FILE}" ]]; then
  {
    echo
    echo "# === IP 规则（自动聚合） ==="
  } >> "${OUTPUT_FILE}"
  cat "${IP_FILE}" >> "${OUTPUT_FILE}"
fi

rel_output="${OUTPUT_FILE#${ROOT_DIR}/}"
echo "已生成合并规则文件: ${rel_output}"
