## 0. MCP 与基准冻结

- [ ] 0.1 对项目 `16236738106685052013` 执行 Stitch MCP **`list_screens`**，确认 **iOS 温馨版** 六帧标题与 `design.md` 表格中 `name` 仍一致
- [ ] 0.2 对 `design.md` 中六个主参考 `name` 各执行一次 **`get_screen`**，将对照结论（或截图）附在 PR / 团队文档

## 1. 主题与设计系统

- [x] 1.1 按 **`get_screen`（首页/资产 - iOS 温馨版）** 与 `get_project` 交叉验证，更新 `tiny_ledger/lib/app/tiny_ledger_theme.dart` 的 `ColorScheme` / 圆角 / 字体
- [x] 1.2 确认 `google_fonts`（或回退方案）与温馨版主帧一致并在 PR 说明

## 2. 导航与壳层

- [x] 2.1 按 **iOS 温馨版** 主帧（首页 + 流水）核对 **底部 Tab 数量与文案**，重构 `app_shell.dart`（若稿为 5 Tab则必须 5 Tab）
- [x] 2.2 记一笔入口位置（FAB / Tab / 顶栏）以 **`get_screen`（记一笔 - iOS 温馨版）** 为准调整

## 3. 首页/资产

- [x] 3.1 重构 `features/home/home_page.dart`，与 **`projects/.../screens/a5b4b391bc434971ae864d3a33b5bd79`** 经 MCP 对照后一致

## 4. 记一笔与流水

- [x] 4.1 实现整页 **记一笔**（或稿面规定形态），对齐 **`projects/.../screens/94955256b20d4357a18267410799f1fe`**
- [x] 4.2 重构 `features/ledger/ledger_list_page.dart`（或等价），对齐 **`projects/.../screens/165291e3c5fd414da980d1e7e7f127d9`**

## 5. 存钱目标

- [x] 5.1 更新 `features/goals/goals_page.dart`，对齐 **`projects/.../screens/52c048a42a604d1f862e19edd7c0dbb6`**

## 6. 增长模拟

- [x] 6.1 更新 `features/growth/growth_page.dart`，对齐 **`projects/.../screens/3adac670e12b4c0bb0b87272d8eb6dfd`**（稿名「增长模拟」）

## 7. 设置

- [x] 7.1 更新 `features/more/more_page.dart`（或独立设置路由），对齐 **`projects/.../screens/d984aae2953d467bb3a03c6cbb01a867`**
- [x] 7.2 确认 `app/motion.dart` / `TinyLedgerApp` builder 在温馨版视觉下仍尊重减弱动效

## 8. 验证

- [x] 8.1 `dart analyze` / `dart format`、`dart test` 通过
- [ ] 8.2 真机或模拟器手测：与 **iOS 温馨版** 六帧主路径一致（含 Tab 与记一笔）
- [ ] 8.3 PR 描述列出本 PR 对照的 **`get_screen` `name` 列表**（与 `design.md` 一致）
