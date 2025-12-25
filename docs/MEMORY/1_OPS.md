# 1_OPS（常用命令 / SOP）

## 本地生成 OpenAI 合并规则

在仓库根目录执行：

```bash
chmod +x scripts/merge_openai.sh
./scripts/merge_openai.sh
```

预期输出：打印合并输入文件列表；当规则行有变化时提示已生成 `rules/merged/OpenAi.list`，当规则行无变化时提示“规则内容未变化，保持现有文件不更新”。

## 本地手动同步上游（与 CI 同源）

在仓库根目录执行：

```bash
curl -fsSL "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Surge/OpenAI/OpenAI.list" \
  -o rules/base/openai_blackmatrix.list

curl -fsSL "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/Ruleset/OpenAi.list" \
  -o rules/base/openai_acl4ssr.list
```

然后再运行合并脚本。

## 规则文件快速自检（格式/卫生）

在仓库根目录执行：

```bash
# 检查 CRLF
rg -n "\r" rules || echo "OK: no CRLF"

# 检查行尾空白
rg -n "[ \t]+$" rules || echo "OK: no trailing whitespace"

# 检查 UTF-8 BOM（应为 '# ' 开头）
for f in rules/**/*.list; do printf "== %s: " "$f"; xxd -g 1 -l 4 "$f"; done
```
