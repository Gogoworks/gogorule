# 2_DECISIONS（决策记录）

## 2025-12-25：OpenAI 规则合并策略

- **合并定义**：`rules/merged/OpenAi.list = rules/base/openai_*.list + rules/custom/openai_custom.list` 的去重合集
- **编辑边界**：只手工编辑 `rules/custom/*`；`rules/base/*` 与 `rules/merged/*` 由自动化生成
- **关键域名**：`challenges.cloudflare.com` 必须出现在不会被阻断的规则集合中（当前包含在 `OpenAi.list`）

## 2025-12-25：自动化幂等性要求（待落地）

- 目标：同一份上游内容多次执行合并，不应产生无意义 commit
- 候选方案：当合并后的“规则行内容”未变化时，不重写 `rules/merged/OpenAi.list`（避免仅 `# UPDATED` 时间变化造成 diff）

## 2025-12-25：自动化幂等性落地

- `scripts/merge_openai.sh` 会在写出前对比“规则行内容”（忽略注释头）；若规则行序列一致则直接退出，不改动 `rules/merged/OpenAi.list`
- `rules/merged/OpenAi.list` 的 `# UPDATED` 语义：规则行最后一次变化时间
