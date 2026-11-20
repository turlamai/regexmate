# AGENTS.md

## 家族设计（必读入口）

- 设计/UI 任务先加载 `tlai-product`，必读 `references/policy.md` 与 `references/design-standard.md`（理念、决策规则、UI 验收）。技能缺失时读取 ZCode 真源：macOS/Linux `~/Sync/ZCode/skills/tlai-product/`；Windows `D:/ZCode/skills/tlai-product/`。无法读取须报告规范未核验，不凭记忆跳过。
- 家族规范管共性；本仓现有设计、行为与 token 真源管具体值和产品差异。例外记回原契约，不复制家族规则或新增数值表；已有界面按下一次相关切片渐进对齐。
- 改界面先改原型、落账后实现；按家族 UI 清单与本仓当前技术线的既有门禁验收，原型对照和真实交互证据都要保留；对外宣传使用验收后的实物截图。

## 实现路由（agent 按任务读真源）

- 实现界面以 `design/prototype/` 为准：对照 HTML/CSS/JS 与实物截图验收，不依赖散文复述。
- Token/几何值真源 = `design/prototype/shared.css`（亮暗成对；无 shared.css 的仓 = design/prototype/ 各页样式）；`design/DESIGN.md` 只记语义名、用途与决策。
- 行为边界与跨平台一致性以 `design/DESIGN.md` 的不变式与平台差异节为准。
- 改界面先改原型再改实现（tlai-product）；动共享层（design/、shared/）先 issue 声明，同 commit 落契约。

## Current owner decision — 2026-11-18 quality-first

This product is in **non-commercial development**. The prior 2026-10/11 product pricing, trial, paid-feature, Free/Pro and family Permit/Commerce rollout decisions are canceled. Do not introduce checkout, subscriptions, activation, commercial entitlement, paid update windows or a paywall. Do not change source-license terms or release signing and identity verification. Prioritize product correctness, reliable native experience, recovery, bilingual README and truthful website claims. The [current family portfolio](https://github.com/turlamai/turlamai.github.io/blob/master/PORTFOLIO.md) governs every slice.

RegexMate——agent 时代的正则工作台（validate/match/explain/replace/graph/batch-test/lint，版本化 JSON 契约 + MCP server），Racket 引擎 + 三宿主原生 GUI。

## 结构

- `racket/` — Racket 引擎与 CLI：`racket/core/`（引擎核心）、`racket/output-format/`（JSON/人类输出/ANSI/铁路图）、`racket/server/`（MCP/服务侧）、`racket/main.rkt`（CLI 入口）、`racket/version.rkt`、`racket/run-tests.rkt`（测试驱动）
- `app/` — Rivet backend（GUI 的 typed RPC 面）；`tests/` — Racket 测试
- `macos-host/`（SwiftUI）、`windows/`（WinUI3）、`linux/`（GTK4）— 三宿主腿，对应平台机器独占开发
- `scripts/`、`build/`、`assets/branding/`、`docs/`、`site/`（官网，GitHub Pages）；`compiled/`、`dist/` 为本地产物不提交

## 常用命令

```bash
# 引擎测试（CI 同款）
raco pkg install --auto --no-docs 'https://github.com/turlamai/rivet.git#9d766b4acab672844093204cb4845ef4ef933d2c' crypto
raco make racket/main.rkt racket/run-tests.rkt
racket racket/run-tests.rkt
racket scripts/check-version.rkt        # 版本对齐门禁
raco rivet schema check rivet-schema.json --json
raco rivet doctor --release             # rivet 发布门禁（生成物新鲜度/pin/更新API关键词）
raco rivet generate                     # 重生成客户端后: Kotlin 客户端在 .rivet/ 下被 ignore，须 git add -f
bash scripts/smoke.sh                   # 冒烟
raco rivet acceptance --json            # 当前平台完整产品验收
```

## 验证与发版

- CI（`ci.yml`）：多平台 Racket matrix 测试 + 版本检查 + schema check + rivet 发布门禁（`doctor --release`）+ smoke + Linux GTK4 宿主编译门。
- 产品验收（`acceptance.yml`）：三平台分别执行真实 RVT1、原生构建、打包和可访问性驱动的 UI 操作，并把 `acceptance --json` 报告落盘上传；`matrix` 作业用 `raco rivet matrix` 把三份报告折成单一跨平台裁决。只有全绿才能宣称完成。
- 发版（`release.yml`）：tag `v*` 触发；门禁 = `racket scripts/check-version.rkt "$GITHUB_REF_NAME"` + CHANGELOG 必须含 `## [x.y.z]` 小节 + `raco rivet doctor --release`；MSI 走 WiX 5.0.2。
- GUI 无应用内更新器是有意设计（CLI 换装 + 重启），勿当缺口补。

## 仓库特定规矩

- rivet 以不可变提交 pin（当前 `9d766b4acab672844093204cb4845ef4ef933d2c`，即 v0.13 main）消费，三个工作流与本文档同步换 pin；升级 pin 须连动 schema check、生成客户端（重生成后 Kotlin 客户端在 `.rivet/` 下被 ignore，须 `git add -f`）、产品验收与发版工作流。rivet 安装步骤一律字面写 pin，不经 env 间接（doctor 只扫字面文本）。
- 三宿主腿分属对应平台机器；跨平台交互逻辑保持一致是验收项。
- Agent 不得以代码量、单元测试或单个平台截图代替完成证据；涉及 GUI 的改动至少要保留原生控件交互和后端返回值的验收证据。
- 产品不发布到 Racket catalog（家族产品惯例），别把它当库补 pkg 元数据。

## 组合定位（Portfolio placement）

2026-11-18 起，以产品交付质量为目标，不推进收费版、试用、商业授权或结账。既有 LICENSE 和发行签名验证保持不变。当前权威是[产品组合策略](https://github.com/turlamai/turlamai.github.io/blob/master/PORTFOLIO.zh-CN.md)。

## 产品交付与下一步（2026-11-18）

请以当前代码与验收证据推进用户主流程、恢复、跨平台原生体验、签名更新、文档和产品主页，不按任何历史商业规划开发。

## Documentation languages

Public default documentation is English; maintain complete Chinese user paths in `*.zh-CN.md`, with reciprocal links. Update both languages when prices, quotas, installation, recovery, privacy or supported platforms change. API/protocol identifiers and commands remain unchanged; do not maintain a second normative protocol or implementation. Follow the [family language policy](https://github.com/turlamai/turlamai.github.io/blob/master/docs/DOCUMENTATION-LANGUAGES.md). Existing internal notes are not a claim that every document is bilingual.

## Public product documentation

The paired `docs/USER-GUIDE.md` / `docs/USER-GUIDE.zh-CN.md` own the public installation, first-use, data/recovery, privacy and availability path. Keep the homepage and both README entry points aligned with them when behavior changes. Detailed technical contracts and the current implementation queue retain their existing owners. Do not publish target prices, a purchase link or a ready/secure/platform claim before its release evidence exists.
