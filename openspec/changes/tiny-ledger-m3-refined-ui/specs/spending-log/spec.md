## ADDED Requirements

### Requirement: Quick entry matches Stitch「记一笔」（记一笔流程对齐）
系统 MUST 提供与 Stitch **「记一笔 - TinyLedger (M3 Refined)」**（资源 `projects/16236738106685052013/screens/47cd52d945964b76836d05c16eb952e8` 或 `projects/16236738106685052013/screens/f2c463f8c4e54109961211224c623552`）一致的 **收入与支出** 记账路径：主次操作可辨、金额输入区显著、保存后有可感知成功反馈（须遵守既有减弱动效规范）。

#### Scenario: Income and expense paths both styled
- **WHEN** 用户从首页发起记收入与记支出
- **THEN** 两路径的版式、主按钮与字段顺序与选定基准 M3 Refined 稿一致

### Requirement: Full ledger list screen（全屏流水列表）
系统 MUST 提供全屏 **流水列表** 视图，其版式与 Stitch **「流水列表 - TinyLedger (M3 Refined)」**（资源 `projects/16236738106685052013/screens/978cf6b8f6f34a6db5fb2e24c58d99a3` 或 `projects/16236738106685052013/screens/e14bea521da248fd94c4b19b9a209781`）一致：按时间分组或等价层级清晰、单条流水展示类型/金额/时间/备注字段。

#### Scenario: Navigate to full list
- **WHEN** 用户从首页选择「查看全部流水」或等价入口
- **THEN** 系统展示完整流水列表且支持下拉或分页加载（若数据量大，至少不丢失既有列表能力）

#### Scenario: Empty state on full list
- **WHEN** 用户进入全屏流水列表且无任何记录
- **THEN** 系统展示与 M3 Refined 稿一致气质的空状态引导（文案可本地化，结构对齐）
