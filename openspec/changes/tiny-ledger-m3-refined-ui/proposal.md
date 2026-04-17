## Why

首版 `tiny_ledger` Flutter 已实现核心闭环，但视觉与信息架构尚未与 Google Stitch 上的 **TinyLedger (M3 Refined)** 定稿对齐。需要在不改动财商领域规则的前提下，将 **主题、布局、关键页面与「记一笔」流程** 收敛到已确认的设计稿，并补齐设计中有、应用中缺失或偏弱的界面（如独立流水视图、设置级页面等），以便后续迭代与家长信任叙事一致。

## What Changes

- 以 Stitch 项目为**单一视觉基准**（见 `design.md` 中的项目链接与画板 `name` 映射），更新 `tiny_ledger` 的 `ThemeData` / `ColorScheme` / 排版与组件形态（Material 3 气质、极简留白）。
- **首页/资产**：对齐 M3 Refined 的信息层级（余额主视觉、快捷入口、与资产相关的摘要区块）。
- **记一笔**：收入/支出流程的表单布局、主次按钮与反馈与 M3 Refined 两稿之一一致（两稿语义等价时择一落地）。
- **账本/流水**：提供与设计稿一致的**完整流水列表**体验（可与首页「最近流水」并存：首页为摘要，独立入口进入全列表）。
- **存钱目标 / 增值说明 / 设置**：对齐对应 M3 Refined 画板的版式、教育标注位置与设置项分组；缺页则新增路由或子页。
- **不引入**真实金融、广告或新的后端依赖；动效仍须遵守既有「减弱动效 / 系统信号」规范。

## Capabilities

### New Capabilities

- 无（在既有能力上增量对齐 UI 与导航，不新增独立业务能力包名）。

### Modified Capabilities

- `motion-ui-system`：补充与 Stitch **Design Tokens / Earnest Ledger** 一致的色彩、圆角、字体与表面层级在 Flutter 中的落地要求。
- `virtual-wallet`：首页/资产展示与导航至流水/记一笔的交互与 M3 Refined 对齐。
- `spending-log`：记一笔（收入/支出）与流水列表的 UI 与空状态对齐 M3 Refined。
- `saving-goals`：存钱目标列表与详情/进度视觉对齐 M3 Refined。
- `growth-intro`：增值说明页版式与教育标注可见性与 M3 Refined 对齐。
- `child-guardrails`：设置页中适龄说明、减弱动效、家长占位等分组与 M3 Refined 对齐。

## Impact

- **代码**：主要影响 `tiny_ledger/lib/app/`（主题、`AppShell`、路由或子页）、`features/home`、`features/goals`、`features/growth`、`features/more`；可能新增 `features/ledger` 或等价模块承载全屏流水。
- **依赖**：可选引入 `google_fonts` 等以匹配 Stitch 指定字体（若与 `design.md` 决策一致）。
- **规格**：六份主规格 `openspec/specs/*/spec.md` 将在归档同步时合并本变更中的 **ADDED** 条款。
