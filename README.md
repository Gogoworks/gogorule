## GogoRule

GogoRule 是一个用于维护个人网络规则列表的仓库，主要面向 Surge、Clash 等代理客户端使用。

本仓库的目标：

- 通过清晰的目录结构管理上游规则与自定义规则
- 自动合并并去重，生成可供客户端直接引用的远程规则文件
- 重点维护 OpenAI 相关规则，例如 `rules/merged/OpenAi.list`

### 目录结构（初始版本）

```text
GogoRule/
  rules/
    base/      # 上游项目同步下来的原始规则文件（禁止手工编辑）
    custom/    # 自定义维护的个人规则
    merged/    # 合并并去重后的最终规则（供客户端引用）
  .github/
    workflows/ # GitHub Actions 工作流（后续添加）
  AGENTS.md    # Codex 协作规范（当前文件）
  README.md    # 项目说明（本文件）
  开发文档/进展与计划.md # 开发日志（后续用于记录进展）
```

### 后续规划（简要）

- 设计 OpenAI 专用规则文件的整体方案（上游 + 自定义 + 合并）
- 编写本地或 CI 中的合并脚本，自动生成 `rules/merged/OpenAi.list`
- 增加 GitHub Actions 工作流，实现定时同步与自动提交

