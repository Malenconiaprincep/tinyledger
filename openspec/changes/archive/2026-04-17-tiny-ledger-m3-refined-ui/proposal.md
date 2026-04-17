## Why

首版 `tiny_ledger` Flutter 已实现核心闭环，但视觉与信息架构尚未与 Google Stitch 上的 **TinyLedger - iOS 温馨版界面组（iOS Warm Edition）** 定稿对齐（此前以 M3 Refined 为参照的交付已过时）。需要在不改动财商领域规则的前提下，将 **主题、布局、关键页面与「记一笔」流程** 收敛到 **iOS 温馨版**已确认的设计稿，并补齐设计中有、应用中缺失或偏弱的界面；**实现前与迭代中须通过 Stitch MCP `list_screens` / `get_screen` 读稿**（见 `design.md` 强制流程），避免代码与画布脱节。

## What Changes

- 以 Stitch 项目为**单一视觉基准**（见 `design.md` 中的项目链接与 **iOS 温馨版** 画板 `name` 映射），更新 `tiny_ledger` 的 `ThemeData` / `ColorScheme` / 排版与组件形态。
- **首页/资产**：对齐 **「首页/资产 - iOS 温馨版」** 的信息层级与导航。
- **记一笔**：与 **「记一笔 - iOS 温馨版」**整屏结构一致（以 MCP `get_screen` 为准）。
- **流水列表**：与 **「流水列表 - iOS 温馨版」** 一致（含 Tab/入口以稿为准）。
- **存钱目标 / 增长模拟 / 设置**：分别对齐 **「存钱目标 - iOS 温馨版」**、**「增长模拟 - iOS 温馨版」**、**「设置 - iOS 温馨版」**；缺页则新增路由或子页。
- **不引入**真实金融、广告或新的后端依赖；动效仍须遵守既有「减弱动效 / 系统信号」规范。

## Capabilities

### New Capabilities

- 无（在既有能力上增量对齐 UI 与导航，不新增独立业务能力包名）。

### Modified Capabilities

- `motion-ui-system`：补充与 **iOS 温馨版** 主参考帧（MCP `get_screen`）一致的色彩、圆角、字体与表面层级在 Flutter 中的落地要求。
- `virtual-wallet`：首页/资产展示与导航与 **iOS 温馨版** 对齐。
- `spending-log`：记一笔与流水列表的 UI 与空状态与 **iOS 温馨版** 对齐。
- `saving-goals`：存钱目标列表与详情/进度视觉与 **iOS 温馨版** 对齐。
- `growth-intro`：增长模拟页版式与教育标注可见性与 **iOS 温馨版**对齐（稿名「增长模拟」）。
- `child-guardrails`：设置页中适龄说明、减弱动效、家长占位等分组与 **iOS 温馨版** 对齐。

## Impact

- **代码**：主要影响 `tiny_ledger/lib/app/`（主题、`AppShell`、路由或子页）、`features/home`、`features/goals`、`features/growth`、`features/more`、`features/ledger` 等。
- **依赖**：`google_fonts` 等以 **iOS 温馨版** `get_screen` 实际字体为准。
- **规格**：六份主规格 `openspec/specs/*/spec.md` 将在归档同步时合并本变更中的 **ADDED** 条款；条文中的画板名应更新为 **iOS 温馨版**（若仍为 M3 字样需在后续 apply 中修订）。
