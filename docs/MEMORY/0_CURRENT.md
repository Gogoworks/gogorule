# 0_CURRENT（当前状态与硬约束）

## 项目目标

- 维护 Surge / Clash 等代理客户端可用的规则 `.list` 文件
- 通过 `raw.githubusercontent.com` 提供远程规则 URL
- 重点对象：`rules/merged/OpenAi.list`（路径与文件名尽量长期稳定）

## 目录与职责

- `rules/base/`：上游规则同步结果（禁止手工编辑）
- `rules/custom/`：手写维护的自定义规则
- `rules/merged/`：最终合并去重结果（由脚本生成，禁止手工编辑）

## 自动化现状

- GitHub Actions：`.github/workflows/openai-rules.yml`
  - 拉取上游：
    - BlackMatrix7：Surge OpenAI list
    - ACL4SSR：Clash OpenAi list
  - 执行合并脚本：`scripts/merge_openai.sh`

## 当前已确认问题（高优先级）

- **工作流幂等性（已修复，2025-12-25）**：`scripts/merge_openai.sh` 已实现“规则行内容不变则不重写 `rules/merged/OpenAi.list`”，因此 `# UPDATED` 表示规则内容最后变化时间（而非脚本运行时间）；远端在 2025-12-10 ~ 2025-12-25 的噪音提交属于历史遗留。
- **仓库卫生**：`.DS_Store` 被纳入 Git 跟踪，`.gitignore` 未覆盖常见 macOS 垃圾文件。

## 协作约束（需要长期遵守）

- 不要手工编辑 `rules/merged/*.list`（必须由脚本生成）
- 任何影响客户端引用路径的变更（文件名/路径）都属于高风险变更
