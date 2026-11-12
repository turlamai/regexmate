# RegexMate DESIGN.md — 视觉与交互契约（单一真源）

原型（`design/prototype/`）与三宿主实现（`macos-host/`、`windows/`、`linux/`）都遵循本文件；改视觉先改这里，再同步实现。
Tokens 逐值提取自 `macos-host/Sources/RivetHost/DesignSystem.swift`（其上游是 `docs/styles.css` 家族站点体系，macOS 注释原文「Neutrals first, one accent, generous whitespace, hairline structure」），匹配高亮值取自 `ContentView.swift` 的 highlightColor；标注（推导）的值是原型为补齐实现尚未覆盖的状态所设，实现落地时回填实现。

## Brief（2026-11-11）

- **现状**：GUI 已成型（v0.8.0）：单窗口双列工作台——工具栏模式栏 + Test text 实时高亮 + Matches + Explanation / Lint / Railroad + 状态栏，交互契约见 `docs/interaction-contract.md`（含七条宿主共享状态规则）。本原型**不是从零设计**：在既有中性色 + 单 accent 体系上做 HIG 级打磨，并把引擎已有而 GUI 未及的能力（replace / test）与检查增强（捕获组分解）提案成界面。
- **目标**：让「模式编辑 + 实时匹配高亮」这个主角在界面上站出来；错误态（非法模式 / 灾难性回溯警告）反馈即时明确；三宿主共用一套语义 tokens，跨平台交互逻辑保持一致（验收项）。
- **原型范围**（6 屏 × 亮/暗）：① Workbench 英雄屏（ready 态全貌）② 匹配检查 + 捕获组分解（含旗标 chips 激活态）③ 替换预览（diff 态）④ 测试用例管理 ⑤ 错误态全集（非法模式错误态 + 合法零匹配空态 + 灾难性回溯警告态，三窗并陈）⑥ 设置（外观 / 语言 / 方言信息 / 更新 / 关于）。
- **RPC 差距（如实标注）**：捕获组分解、替换预览、测试用例三屏需要扩展 `app/backend.rkt` RPC 面——现 `match-rows` 只返回 group 数量（引擎数据已含 group 值，见 JSON 契约 `matches[].groups`），且无 replace / test RPC。原型先于 RPC 定型交互；落地顺序 = 先扩 RPC 再做 UI，不动 `rivet-schema.json` 之外的契约。
- **Exit 条件**：6 屏关键状态齐（含错误态 / 空态）+ 交互逻辑定稿（与 `docs/interaction-contract.md` 七条状态规则一致）+ HIG 清单全过 + 用户评审通过；实物截图验收后才能作为对外宣传素材。
- **不在范围**：新引擎能力（方言切换、命名组 `(?<name>…)`）、CLI 输出改造、`rivet-schema.json` 变更、商业 / 定价 UI、官网页面、应用内更新器（GUI 只有只读 Check for Updates，是有意设计）。

## 设计原则（HIG 内核）

- **匹配可视化是内容主角**：高亮 pill 既是内容色也是状态色——普通匹配、当前检查、错误输入各占一种语义色（`--match` / `--match-strong` / `--danger`），其余 chrome 全部退后；高亮永远画在样文里，不另开浮层。
- **方言诚实**：引擎固定 Racket pregexp，UI 永不伪装成 PCRE / JS；不做方言切换器，不支持的语法（命名组、`\A`/`\z`、`\x41`）在设置 Flavor 卡与 explain 中明示。旗标 chips（i / m / s）只是把旗标写进模式文本的糖（`(?i:…)`），chips 状态与模式文本可互相回溯。
- **错误态不是零结果**（契约规则 4）：非法模式是错误态（danger 点 + 计数让位为 `—` + 「Fix the pattern to match」占位，explanation 保留上一模式的解释）；合法零匹配是普通空态（No matches）。两者永不混用。
- **一个选择语义**（契约规则 1–2）：无论指针、键盘、⌘G 还是辅助技术，选中即检查——列表行与样文同一 span 同步；结果集变化即清空选择，选择永不指向过期列表。
- **输入不是运行**（契约规则 3）：模式键入只更新草稿；提交走 Return / ⌘R；样文编辑是唯一自动运行路径（300ms 防抖）。
- **键盘一等公民**：三表面 Tab 循环（pattern field → match list → sample editor）；⌘R 运行、⌘G / ⇧⌘G 检查导航、⇧⌘U 检查更新、⌘A 全选；鼠标不嗨也能完整操作。

## Tokens（与实现 1:1，来源 `DesignSystem.swift`）

| Token | Light | Dark | 用途 |
|---|---|---|---|
| `--bg` | `#FAFAF8` | `#0A0A0B` | 画布 |
| `--bg-soft` | `#F3F3F0` | `#121214` | 工具栏 / 状态栏 / 分区底 |
| `--surface` | `#FFFFFF` | `#17171A` | 卡片 / 浮层 / 输入 |
| `--ink` | `#1D1D1F` | `#F5F5F7` | 主文字 |
| `--ink-2` | `#55555A` | `#A1A1A6` | 次级文字 |
| `--ink-3` | `#86868B` | `#6E6E73` | 辅助文字 / 图标 / 占位 |
| `--hairline` | `rgb(0 0 0 / .10)` | `rgb(255 255 255 / .12)` | 分隔线 / 描边 |
| `--accent` | `#037A55` | `#3ECF8E` | 选中 / 检查 / 进行态 / 主按钮 / ok |
| `--accent-tint` | `rgb(3 122 85 / .10)` | `rgb(62 207 142 / .12)` | chip / 徽标弱底 |
| `--match` | `rgb(3 122 85 / .18)` | `rgb(62 207 142 / .26)` | 匹配高亮 pill（内容主角色） |
| `--match-strong`（推导） | `rgb(3 122 85 / .38)` | `rgb(62 207 142 / .50)` | 当前检查 pill |
| `--danger` | `#D92D20` | `#FF6369` | 错误态 / 非法模式 / fail |
| `--warning` | `#B54708` | `#FFB35C` | lint 警告 / 灾难性回溯 |
| `--canvas` | `#FFFFFF` | `#FFFFFF` | railroad 画布（两主题恒白，品牌规则） |

- **字体**：界面 `system-ui, -apple-system, "Segoe UI", "PingFang SC", "Hiragino Sans GB", "Microsoft YaHei"`；模式 / 样文 / 跨度 / 计数一律等宽 `"SF Mono", ui-monospace, "JetBrains Mono", "Cascadia Mono", Consolas`。正文 13px/1.55；节标题 11px/600/0.06em 全大写；模式栏 13.5px 等宽；状态栏 11.5px。
- **圆角**：窗口 12（原型壳）· 卡片 10（radiusS）· 模式栏 8 · 控件 6。**间距节奏**：4/8/12/16。**动效**：120ms ease，不过度，尊重 `prefers-reduced-motion`。
- **语言**：界面文案英文（跟随三宿主现状）；中文路径 = CLI `--lang zh` 与设置页语言项（引擎 `racket/core/i18n.rkt` 已支持）；match / span / group 等术语保留英文不硬翻。

## 组件词汇

`PatternBar`（chevron + 等宽模式输入 + 旗标 chips i/m/s + Run ⌘R + Export）· `SampleEditor`（匹配 pill 高亮 + 检查强 pill）· `MatchList`（序号 / 值 / span / groups 徽标 / zero-width 行 `∅`）· `CapturesPanel`（$n 分解 + 值 + span，提案）· `SectionHeader`（icon + 大写小字 + 计数）· `SeverityChip`（error / warning / info）· `LintRow`（rule @pos + message）· `RailroadCard`（白底画布）· `ReplaceBar`（replacement 模板 + Apply…）· `DiffRow`（− 原文 / + 替换）· `CaseRow`（用例 / 期望 chip / 证据 / ✓✗）· `SettingsRow` + `FlavorCard` · `StatusBar`（后端相位：starting / failed / ready，busy 显示 Running… + 计数让位规则）。

## 不变式

1. `accent` 只用于：当前检查 / 选中、旗标激活、主按钮、进行态与 ok；匹配 pill 的 accent 弱底是全产品唯一允许的大面积 tint，其余禁止大面积色块。
2. 错误态与空态永远可区分：非法模式 = danger 红点 + 计数 `—` + 「Fix the pattern to match」+ explanation 保留上一模式；合法零匹配 = 「No matches」普通空态。lint 警告不阻断匹配（样文照常高亮），错误才阻断。
3. 亮暗主题成对设计，不存在只有暗态的界面；railroad 画布两主题恒白。
4. 数字、跨度、模式、匹配文本一律等宽字体；UI 文案英文，中文经语言设置提供；破坏性 / 批量操作（Apply replacement）必须显式确认（按钮带 …，先预览后应用），永不静默执行。
5. 键盘提示统一 `kbd` 样式（surface 底、hairline 边、ink-3 字）；三宿主交互语义一致（契约跨平台规则：语义是产品契约，呈现归各腿）。
6. zero-width 匹配是一等行（`∅` + 「zero-width at N」），检查它把光标放到该偏移；检查选择永不落在已消失的匹配上。


## 平台映射与差异声明（预钉 · 宿主实现时升级为落点表）

统一层（三平台必须一致，`design/prototype/` 原型已锁定）：信息架构、核心流程、快捷键语义、
语义色与层级词汇。因地制宜层（按平台惯例落地，不预画像素）：

| 维度 | macOS | Windows | Linux |
|---|---|---|---|
| 修饰键 | ⌘ | Ctrl | Ctrl |
| 命令入口 | 原生菜单栏 | 菜单栏/命令行内 | 菜单栏 |
| 字体 | 系统栈 + PingFang SC | 系统栈 + Microsoft YaHei | 系统栈 + Noto Sans CJK |
| 原生控件 | SwiftUI 控件 | WinUI 3 控件 | GTK4 控件 |

差异声明纪律：宿主特例必须先写进本节才能实现；未声明的宿主差异按违约处理
（案例：taskly 漂移台账 D8）。
