# 3_TODO（长期待办）

## P0（尽快）

- （已完成）2025-12-25：修复 `scripts/merge_openai.sh` 的非幂等输出（规则行不变不重写 `OpenAi.list`，避免仅更新时间戳导致 CI 重复提交）

## P1（近期）

- 清理 `.DS_Store`：从 Git 中移除并补充 `.gitignore`
- 更新 `README.md`：与现有 GitHub Actions/脚本现状一致

## P2（可选增强）

- 增加规则校验脚本/CI：检查 CRLF、BOM、行尾空白、未知规则类型等
- 复核 `rules/custom/openai_custom.list` 中的第三方域名归属（必要时拆分 Core/Third-party）
