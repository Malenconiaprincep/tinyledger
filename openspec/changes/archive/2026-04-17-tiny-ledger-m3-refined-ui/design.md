## Context

- **产品**：TinyLedger（小算盘）Flutter 应用，仓库路径 `tiny_ledger/`。
- **设计基准（当前唯一验收组）**：**TinyLedger - iOS 温馨版界面组（iOS Warm Edition）**，托管于 Google Stitch 项目 [趣学模拟账本](https://stitch.withgoogle.com/projects/16236738106685052013)（`projectId=16236738106685052013`）。
- **MCP 快照**：本文档中的资源 `name` 来自 **Stitch MCP** `list_projects` / `list_screens`（与 Stitch 画布标题 **「… - iOS 温馨版」** 一一对应）。项目级 `designTheme` 可能与单帧「温馨版」视觉有差异，**实现与验收必须以各屏 `get_screen` 返回的 `htmlCode` / `screenshot` 为准**，必要时在 PR 中附对照截图。
- **命名约定**：`name` 为 API 全名，格式 `projects/16236738106685052013/screens/{screenId}`。评审或自动化脚本应使用完整字符串调用 MCP `get_screen`。

## 强制流程：实现前 MUST 经 MCP 读稿

以下规则适用于本变更及后续所有 UI 相关任务（避免再次出现「代码像 M3、稿已是 iOS 温馨版」的漂移）：

1. **开始前**：对 `projects/16236738106685052013` 调用 **`list_screens`**，确认标题含 **「iOS 温馨版」** 的画板仍存在且 `name` 未变。
2. **每屏落地前**：对本节映射表中的 **主参考 `name`** 调用 **`get_screen`**，阅读/对照返回的 **HTML 结构、文案层级、组件形态**（或下载 `screenshot` 做像素级自查）。禁止仅凭本 Markdown 或旧版 M3 记忆写 UI。
3. **主题色与字体**：若 `get_project` 的 `designTheme` 与温馨版单帧不一致，**以该屏 `get_screen` 所体现的视觉为主**，并将最终采用的 `ColorScheme` / 字体决策记在 PR 或 `tiny_ledger_theme.dart` 注释中。
4. **CI/人工**：合并前建议在 PR 描述中列出「本 PR 已对照的 `get_screen` 资源 `name` 列表」。

>说明：MCP **不会**自动生成 Flutter 代码；它提供**权威设计快照**。「重新生成 UI」=以 MCP 拉取的稿为源重做 Widget 树，而不是只改 OpenSpec 文字。

## Stitch 画板映射（**iOS 温馨版** 为唯一验收基准）

以下为本组 **6 个产品面** 与 Stitch 画板标题、**MCP 解析得到的**资源 `name`（2026-04-17 经 `list_screens` 校验）。

| 应用区域 | Stitch 画板标题 | 资源 `name`（主参考，`get_screen` 用） |
|----------|-----------------|----------------------------------------|
| 首页/资产 | 首页/资产 - iOS 温馨版 | `projects/16236738106685052013/screens/a5b4b391bc434971ae864d3a33b5bd79` |
| 记一笔 | 记一笔 - iOS 温馨版 | `projects/16236738106685052013/screens/94955256b20d4357a18267410799f1fe` |
| 存钱目标 | 存钱目标 - iOS 温馨版 | `projects/16236738106685052013/screens/52c048a42a604d1f862e19edd7c0dbb6` |
| 流水列表 | 流水列表 - iOS 温馨版 | `projects/16236738106685052013/screens/165291e3c5fd414da980d1e7e7f127d9` |
| 增长模拟 | 增长模拟 - iOS 温馨版 | `projects/16236738106685052013/screens/3adac670e12b4c0bb0b87272d8eb6dfd` |
| 设置 | 设置 - iOS 温馨版 | `projects/16236738106685052013/screens/d984aae2953d467bb3a03c6cbb01a867` |

**设计令牌（若 Stitch 中单列为参考稿）**：仍以 MCP 列表中 **`TinyLedger 设计令牌 (Design Tokens)`** 等资源为准，资源名示例：`projects/16236738106685052013/screens/ae83d115c05344049265ef261a586fa0`（若温馨版另有独立令牌帧，以 `list_screens` 中含「温馨版」或组内 Design system 实例为准）。

**弃用**：以 **「TinyLedger (M3 Refined)」** 为标题的旧帧 **不再作为验收基准**；若画布仍保留仅作历史对照，不得用于阻塞当前温馨版交付。

## Goals / Non-Goals

**Goals:**

- Flutter 端界面 **与上表 iOS 温馨版主参考帧** 在信息架构、关键组件与视觉气质上一致；主题实现以 **`get_screen` + `get_project`** 交叉验证为准。
- 继续满足「减弱动效」「系统减少动画」「虚拟 /教育模拟、非真实理财」等产品约束。

**Non-Goals:**

- 不声称与 Stitch HTML **像素级**一致而不做 `get_screen` 对照；若需像素级，以截图 diff 为附加流程。
- 不引入真实支付、登录或第三方广告 SDK。

## Decisions

1. **验收源**  
   - **唯一权威**：本节表格中的 **iOS 温馨版** `name` + MCP `get_screen`。  
   - **备选**：沿用旧 M3 Refined。已 **弃用**。

2. **主题与字体**  
   - 以温馨版主帧在 `get_screen` 中的实际呈现为优先；`get_project.designTheme` 作辅助。若冲突，在实现中跟随主帧并文档化。

3. **信息架构**  
   - 若温馨版稿为 **5 Tab**（资产 / 目标 / 账本 / 学习 / 设置等），实现须与稿一致，不得以「此前4 Tab」为借口缩水；具体 Tab 标签以 **首页/资产、流水列表、增长模拟、设置** 四帧底栏与 **记一笔** 入口为准，在 `get_screen` 中核对。

4. **记一笔**  
   - 须与 **「记一笔 - iOS 温馨版」**整屏结构一致（含分段控件、金额区、分类区等）；禁止仅用语义相近的 bottom sheet 替代，除非 `get_screen` 明确为底部弹层（以 HTML 为准）。

## Risks / Trade-offs

- [Stitch 与 Flutter 组件模型不同] → 允许 Widget 实现不同，但 **布局层级、文案、交互路径** 须可对齐 `get_screen`。  
- [同项目并存 M3 与温馨版多帧] → 开发人员 **仅引用本节表格 `name`**，避免复制旧文档中的 M3 id。  
- [MCP 未在实现阶段调用] → 视为流程缺失，应在 code review 中拒绝纯「拍脑袋」UI 改动。

## Migration Plan

- 已按 M3 或简化稿实现的页面：按上表逐屏 **`get_screen` 对照** 后重写或增量改版。  
- 回滚：Git 回退；OpenSpec 以本 `design.md` 为当前真理来源。

## Open Questions

- 温馨版 **底栏 Tab 数量与文案** 以 **首页/资产** 与 **流水列表** 两帧 `get_screen` 为准；若两帧不一致，产品需裁定后更新本表。  
- `google_fonts` 与温馨版稿指定字体的最终映射（在 `get_screen` 确认后写入 `tiny_ledger_theme.dart`）。

## 附录：项目级 `designTheme`（MCP `get_project` 摘要，仅供参考）

- **设备**：`MOBILE`（项目级）。  
- **单帧温馨版**可能使用更偏「iOS 温馨」的圆角与色面；**实现前务必 `get_screen` 主参考帧**。  
- 项目内仍可能保留历史 `designMd`（如 Earnest Ledger）；**温馨版交付不依赖**该长文，除非温馨版令牌稿引用同一策略。
