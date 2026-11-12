# RegexMate

**为 agent 时代打造的正则工作台——用一条跨平台 CLI 完成正则的校验、匹配、解释、替换、绘图、批量测试与风险分析。**
版本化 JSON 契约、原生 MCP server、永不撒谎的退出码、在线自更新。三平台独立二进制，免装运行时，Racket 实现。

[![CI](https://github.com/turlamai/regexmate/actions/workflows/ci.yml/badge.svg)](https://github.com/turlamai/regexmate/actions/workflows/ci.yml) ![macOS](https://img.shields.io/badge/macOS-SwiftUI-000000?logo=apple&logoColor=white) ![Windows](https://img.shields.io/badge/Windows-WinUI_3-0078D4?logo=windows11&logoColor=white) ![Linux](https://img.shields.io/badge/Linux-GTK4-F9A03C?logo=linux&logoColor=white) [![License](https://img.shields.io/badge/license-BUSL--1.1-blue)](LICENSE) ![Version](https://img.shields.io/badge/version-0.8.0-037A55)

[English](README.md) · **中文**

## 开始使用

按现行 BUSL-1.1 条款提供的免费开发者与 agent 工具，包含仓库许可的内部使用。许可证不是 MIT，免费定位不改变许可条款。 提供 macOS、Windows、Linux 桌面与 CLI 发布附件。引擎使用 Racket pregexp，不能据此认定 JavaScript、PCRE 或其他生产引擎语义相同。

[安装、首次使用、隐私与备份恢复](docs/USER-GUIDE.zh-CN.md) · [English](docs/USER-GUIDE.md)

## 为什么做这个

RegexMate 提供确定性的正则校验、测试、解释与审查流程，并输出结构化 JSON：

- **validate** —— 按 Racket `pregexp` 方言校验语法，报错保持单行
- **match** —— 对文本或 stdin 执行匹配；终端里高亮，管道里结构化
- **explain** —— 用平实的英文或中文逐部分讲解正则
- **replace** —— 带反向引用的替换，并报告替换次数
- **graph** —— 渲染 SVG 铁路图，用于规格文档和代码评审
- **test** —— 对 JSON 用例批量断言并给出逐条证据：agent 迭代正则的「写→测→改」闭环
- **lint** —— 确定性静态发现（灾难性回溯嵌套、量化断言、空/重复/被遮蔽的交替分支），`--strict` 可做 CI 门禁
- **mcp** —— stdio MCP server，把全部七个工具原生暴露给编码智能体
- **schema** —— 机器可读契约，由工具自我描述

所有平台都提供独立二进制——目标机器无需安装 Racket。仓库自带 [`SKILL.md`](SKILL.md)，供加载技能卡的 agent 平台使用。

## 安装

第一次接触？双语[用户手册](https://regexmate.jrtx.site/guide.html)用真实输出逐个讲每个命令——源文件在 [site/guide.html](site/guide.html)。

从 [Releases](https://github.com/turlamai/regexmate/releases/latest) 下载——每个平台都有人类安装器与便携压缩包，压缩包带 CLI 和原生桌面应用：

| 平台 | 安装器 | 便携压缩包（CLI + GUI） |
|---|---|---|
| macOS 14+（Apple Silicon） | `regexmate-<version>-macos-arm64.dmg` | `regexmate-<version>-macos-arm64.tar.gz`——CLI + `gui/regexmate-gui.app` |
| macOS 14+（Intel） | `regexmate-<version>-macos-x64.dmg` | `regexmate-<version>-macos-x64.tar.gz`——CLI + `gui/regexmate-gui.app` |
| Windows 10+ x64 | `regexmate-<version>-windows-x64.msi` | `regexmate-<version>-windows-x86_64.zip`——CLI + `gui\regexmate-gui.exe` |
| Linux x64 | `regexmate-<version>-linux-amd64.deb` · `.rpm` · `.AppImage`，或 `regexmate-<version>-linux-x86_64.flatpak`（仅 GUI 的 Flatpak 包，app id 为 `site.jrtx.regexmate`；用 `flatpak --user install` 安装） | `regexmate-<version>-linux-x86_64.tar.gz`——CLI + `gui/RivetHost`（GTK4） |
| Linux arm64 | `regexmate-<version>-linux-arm64.deb` · `.rpm` · `.AppImage`，或 `regexmate-<version>-linux-arm64.flatpak`（仅 GUI 的 Flatpak 包，app id 为 `site.jrtx.regexmate`；用 `flatpak --user install` 安装） | `regexmate-<version>-linux-arm64.tar.gz`——CLI + `gui/RivetHost`（GTK4） |

每个发布都带逐文件 `.sha256` 校验和与 `SHA256SUMS` 清单。CLI 使用独立的 Ed25519 签名更新清单自更新——见[自更新](#自更新)。

**发布可信度：** 当前 macOS 程序使用 **ad-hoc 签名**，不等同于 Apple Developer ID 签名或苹果公证；Windows MSI、便携 ZIP 和独立 EXE 默认**没有代码签名**，SmartScreen 可能提示发布者无法识别。发布 Windows 安装包不需要购买付费签名证书。请从官方 Releases 获取文件，并核对公布的 SHA-256 校验值；校验和只能验证文件完整性，不能证明发布者身份。未来接入 Apple Developer ID 公证或可选 Windows Authenticode 时，需要配置相应证书并通过真实发布验收；当前不声称已经完成。

**Windows 单文件 exe**（仅 CLI，无 GUI）：从发布页取 `regexmate-<version>-windows-x86_64-standalone.exe`，下载即用。

**Racket 包：**

```bash
raco pkg install https://github.com/turlamai/regexmate.git
```

**从源码构建**（Racket 9.x）：

```bash
git clone https://github.com/turlamai/regexmate
cd regexmate
raco make racket/main.rkt
racket racket/run-tests.rkt          # 测试套件
raco exe -o regexmate racket/main.rkt  # 产出本地二进制
```

## 快速上手

```console
$ regexmate validate '^\d{3}-\d{4}$' --lang zh
正则表达式: ^\d{3}-\d{4}$
✓ 语法有效

$ regexmate match '\d+' 'abc 123 def 456'
Found 2 match(es):
  at 4-7: "123"
  at 12-15: "456"

$ regexmate explain '(?:\d{2,4}|[a-z]+)(?=x)' --lang zh
正则表达式: (?:\d{2,4}|[a-z]+)(?=x)

组成部分:
  1. [group] (?:\d{2,4}|[a-z]+)
       ← 非捕获组 (?:...): 数字 (\d) × {2,4} | 字符类: [a-z] × +
  2. [lookaround] (?=x)
       ← 正向先行断言 (?=...): 字面量: x

$ regexmate replace '(\w+)@(\w+)' '\1 AT \2' 'mail a@b'
Replaced 1 occurrence(s).
Result: mail a AT b

$ regexmate graph 'ab(c|d)*' -o diagram.svg
SVG 已保存到: diagram.svg
```

## 自更新

```console
$ regexmate update --check
Latest release: v0.8.0 (installed: 0.7.0)

$ regexmate update
Downloading regexmate-0.6.2-macos-arm64.tar.gz (signature and checksum verified) …
Installing …
Updated to v0.8.0. Run `regexmate --version` to confirm; restart the RegexMate app if it was running.
```

安装版可原地自更新：先用内嵌公钥验证 Ed25519 签名的更新清单（key id `regexmate-2026-10`），再把下载包的字节数与 SHA-256 对照该签名清单核对，最后运行中的二进制安全换装（改名移开、下次启动清理残留）。GUI 与 CLI 同包发布，随同更新——更新后请重启应用。GUI 里另有只读的**检查更新**入口（应用菜单，macOS 上 ⇧⌘U），查询的是同一份签名清单；应用更新仍由 CLI 完成。`--json` 输出标准信封供 agent 与脚本使用。源码与 `raco pkg` 安装会提示改用 `git pull` / `raco pkg update`。

**更新模型——对家族基线的有意偏离。** 家族更新契约（`turlamai/taskly` 的 `shared/spec/UPDATE.md`）规定启动后静默检查一次、至多每 4 小时节流。RegexMate 有意偏离：它是 CLI 工具，采用完全用户发起的更新模型——`regexmate update`、`regexmate update --check` 与 GUI 的只读**检查更新**是仅有的触发点，后台不做任何检查（无守护进程、无启动期探测、无定时器）。家族契约的 4 小时静默节流条款对 RegexMate 豁免；其余条款——Ed25519 清单验证、按签名清单核对字节数与 SHA-256、二进制安全换装——原样继承。

## 桌面 GUI

每个平台的发布包都带 `regexmate-gui`——原生应用（SwiftUI / WinUI 3 / GTK4），跑在同一套 Racket 核心上（经 [Rivet](https://github.com/turlamai/rivet) 嵌入，无 WebView、无 Electron）。pattern 常驻工具栏，边打边算：匹配直接高亮在样本文字里，匹配列表、人话解释、lint 发现与铁路图实时更新：

**无需截图的验收方法：** 输入样本文字及能够匹配的正则表达式，匹配位置应高亮，匹配列表应随之更新。若无匹配结果，请检查正则语法及样本文字。

## Agent 工作流

完整实战教程见 [docs/agents-guide.md](docs/agents-guide.md)：write → validate → test → lint → ship 循环、MCP 工具参考、lint 规则含义与完整示例。逐命令参考（含真实输出）见[用户手册](https://regexmate.jrtx.site/guide.html)。

## MCP server

```json
{
  "mcpServers": {
    "regexmate": {
      "command": "regexmate",
      "args": ["mcp"]
    }
  }
}
```

stdio 上的换行分隔 JSON-RPC 2.0，协议版本 `2024-11-05`。工具：`regexmate_validate`、`regexmate_match`、`regexmate_explain`、`regexmate_replace`、`regexmate_graph`、`regexmate_test`、`regexmate_lint`，均带输入 schema，可经 `tools/list` 发现。

## 测试与 lint

```console
$ printf '{"cases":[{"text":"2026-09-28","expect":"match","contains":"2026"},{"text":"2026-13-01","expect":"no-match"}]}' | regexmate test '\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])'
  ✓ "2026-09-28"
  ✓ "2026-13-01"
Passed 2 of 2 case(s).

$ regexmate lint '(a+)+|a|'
2 finding(s):
  [warning] nested-quantifier at 0: nested quantifiers over a group can backtrack catastrophically on non-matching input
  [warning] empty-branch at 8: alternative 2 is empty — it matches the empty string, usually a bug

$ regexmate schema --json   # 契约由工具自我描述
```

## JSON 契约（`regexmate/v1`）

所有命令都接受 `--json`，输出单行信封，字段稳定：`schema`、`command`、`ok`。

```console
$ regexmate match '(\w+)@(\w+)' 'mail a@b' --json
{"command":"match","count":1,"matches":[{"end":8,"groups":[{"end":6,"index":1,"name":null,"start":5,"value":"a"},{"end":8,"index":2,"name":null,"start":7,"value":"b"}],"start":5,"value":"a@b"}],"ok":true,"pattern":"(\\w+)@(\\w+)","schema":"regexmate/v1","text":"mail a@b"}
```

契约规则：

- 区间为绝对下标，`[start, end)` 半开——`end` 不含。
- 捕获组从 1 计数；`name` 字段为将来命名组预留；未参与的组是 `null`，绝不缺键。
- 错误信息是单行字符串（不含换行）。
- `graph --json` 把 SVG 以字符串嵌入；`graph -o FILE --json` 报告 `output` 与 `bytes`。

### 退出码

| 退出码 | 含义 |
|--------|------|
| `0` | 成功——有匹配 / 语法有效 / 完成替换 |
| `1` | 正则表达式无效 |
| `2` | 用法错误（未知命令或选项） |
| `3` | 语法有效但零匹配 / 零替换 |

## 正则方言

RegexMate 用 Racket 的 `pregexp` 引擎校验与匹配。支持：`. ^ $ * + ? {n,m}`（贪婪与懒惰）、`( ) (?: )`、四种断言 `(?=) (?!) (?<=) (?<!)`、原子组 `(?>)`、标志组 `(?i:…) (?is:…) (?-i:…)`、字符类（区间 / 取反 / POSIX 名 `[:alpha:]`）、转义 `\d \D \w \W \s \S \b \B`、反向引用 `\1`–`\9`、Unicode 类 `\p{…}` / `\P{…}`。

引擎不支持（`validate` 会判为无效）：命名组 `(?<name>…)`、`\A`/`\z` 锚点、`\x41` 十六进制转义。对合法但可视化器尚未覆盖的语法，`explain` 与 `graph` 会优雅降级并提示。

## 本地化

人类可读输出默认英文。`--lang zh` 或环境变量 `REGEXMATE_LANG=zh` 切换全部消息，包括 `explain` 的描述。`NO_COLOR` 关闭 ANSI 高亮。

## 开发

```bash
racket racket/run-tests.rkt  # 单元测试
bash scripts/smoke.sh     # CLI 端到端冒烟
racket scripts/check-version.rkt v1.0.0   # 发布门禁
```

CI 在 Ubuntu、Windows、macOS 三平台 × Racket 9.2 上运行单元测试与冒烟测试，并对 GTK4 宿主做编译检查；推送 `v*` 标签会构建三平台的 CLI 与原生 GUI，发布带 SHA-256 校验和的 GitHub Release。

## 项目结构

```
regexmate/
├── racket/                  # Racket 引擎 + CLI
│   ├── main.rkt             # CLI 入口
│   ├── version.rkt          # 运行时版本（须与 info.rkt 一致）
│   ├── run-tests.rkt        # 测试驱动
│   ├── core/                # 正则 AST、解析器、引擎、i18n
│   ├── output-format/       # JSON 信封、人类输出、ANSI、铁路图
│   └── server/mcp.rkt       # stdio MCP server
├── info.rkt                 # Racket 包元数据
├── app/
│   └── backend.rkt          # Rivet 后端（GUI 的类型化 RPC 面）
├── macos-host/              # SwiftUI 宿主（SwiftPM）
├── windows/                 # WinUI 3 宿主（C++/WinRT）
├── linux/                   # GTK4 宿主（CMake）
├── assets/branding/         # 应用图标（分平台源、.icns、.ico、.png）
├── tests/                   # rackunit 测试套件
├── scripts/                 # smoke.sh、check-version.rkt
├── docs/                    # 产品指南与契约文档
├── site/                    # 产品主页（GitHub Pages）
└── .github/workflows/       # ci.yml、release.yml
```

## 路线图

- 签名安装包与公证（macOS GUI 目前为 ad-hoc 签名）
- 命名捕获组 `(?<name>…)`（等引擎支持后跟进）

## 许可证

[BUSL-1.1](LICENSE)（source-available）——任何用途均可免费使用，含内部生产使用、CI 管线与 AI agent 调用；每个版本在首次公开发布四年后自动转为 MIT（2030-10-22 以先到者为准）；0.7.0 及之前的已发布版本保持 MIT。
