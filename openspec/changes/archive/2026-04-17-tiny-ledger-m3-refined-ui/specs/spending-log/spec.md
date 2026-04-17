## ADDED Requirements

### Requirement: Add record screen matches iOS Warm edition（记一笔对齐 iOS 温馨版）
系统 MUST 提供与 Stitch **「记一笔 - iOS 温馨版」** 一致的记账界面；**唯一主参考**资源为 `projects/16236738106685052013/screens/94955256b20d4357a18267410799f1fe`。实现前 MUST **`get_screen`**。界面 MUST 包含稿中所示的 **收入/支出切换语义**（如分段控件或等价可访问实现）、**显著金额区**、**分类/日期/备注** 等关键区块及主保存动作；不得以与 `get_screen` 结构明显不符的简易 bottom sheet 作为最终交付，除非 `get_screen` 的 HTML 明确为底部弹层。

#### Scenario: Structure from get_screen
- **WHEN** 用户打开记一笔
- **THEN** 控件区块顺序与主次关系与 `get_screen` 主参考帧一致

#### Scenario: Save feedback
- **WHEN** 用户成功保存一笔收入或支出
- **THEN** 系统提供可感知成功反馈且遵守减弱动效与系统「减少动画」约束

### Requirement: Full ledger list matches iOS Warm edition（流水列表对齐 iOS 温馨版）
系统 MUST 提供 **流水列表** 视图，其版式与 Stitch **「流水列表 - iOS 温馨版」** 一致；**唯一主参考**资源为 `projects/16236738106685052013/screens/165291e3c5fd414da980d1e7e7f127d9`。实现前 MUST **`get_screen`**。列表 MUST 支持按日期分组或等价清晰层级，单条展示类型、金额、时间与备注（或稿中同等字段）。

#### Scenario: Navigate to ledger per draft
- **WHEN** 用户从稿面规定的入口进入流水
- **THEN** 系统展示完整流水列表且空状态与 `get_screen` 气质一致（文案可本地化）

#### Scenario: Data consistency
- **WHEN** 用户在首页摘要与全屏流水间切换
- **THEN** 数据一致且无未解释的缓存分裂
