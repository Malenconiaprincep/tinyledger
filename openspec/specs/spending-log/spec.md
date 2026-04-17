## ADDED Requirements

### Requirement: Create spending entry（创建支出记录）
系统 MUST 允许用户创建支出记录，包含金额、可选分类与可选备注。

#### Scenario: Save valid spending entry
- **WHEN** 用户输入合法支出金额并确认保存
- **THEN** 系统创建支出流水并反映到虚拟钱包余额

#### Scenario: Reject zero or negative spending amount
- **WHEN** 用户输入零或负数作为支出金额
- **THEN** 系统阻止保存并提示金额必须大于零

### Requirement: Lightweight categories（轻量分类）
系统 MUST 提供有限数量的儿童友好支出分类供选择，并允许「未分类」作为默认。

#### Scenario: Default category when none selected
- **WHEN** 用户保存支出但未选择分类
- **THEN** 系统将该笔记录标记为默认未分类且仍可展示在列表中

### Requirement: Add record screen matches Playful Explorer edition（记一笔对齐趣味探索版）
系统 MUST 提供与 Stitch **「记一笔 - 趣味探索版」** 一致的记账界面；**唯一主参考**资源为 `projects/16236738106685052013/screens/2179535b089d48a68f8bb19a0614073d`。实现前 MUST **`get_screen`**。界面 MUST 包含稿中所示的 **收入/支出切换语义**（如分段控件或等价可访问实现）、**显著金额区**、**分类/日期/备注** 等关键区块及主保存动作；不得以与 `get_screen` 结构明显不符的简易 bottom sheet 作为最终交付，除非 `get_screen` 的 HTML 明确为底部弹层。

#### Scenario: Structure from get_screen
- **WHEN** 用户打开记一笔
- **THEN** 控件区块顺序与主次关系与 `get_screen` 主参考帧一致

#### Scenario: Save feedback
- **WHEN** 用户成功保存一笔收入或支出
- **THEN** 系统提供可感知成功反馈且遵守减弱动效与系统「减少动画」约束

### Requirement: Full ledger list matches Playful Explorer edition（账本流水对齐趣味探索版）
系统 MUST 提供 **账本流水** 视图，其版式与 Stitch **「账本流水 - 趣味探索版」** 一致；**唯一主参考**资源为 `projects/16236738106685052013/screens/a6ee4018760549c9b975d72fdc6d2f76`。实现前 MUST **`get_screen`**。列表 MUST 支持按日期分组或等价清晰层级，单条展示类型、金额、时间与备注（或稿中同等字段）。

#### Scenario: Navigate to ledger per draft
- **WHEN** 用户从稿面规定的入口进入流水
- **THEN** 系统展示完整流水列表且空状态与 `get_screen` 气质一致（文案可本地化）

#### Scenario: Data consistency
- **WHEN** 用户在首页摘要与全屏流水间切换
- **THEN** 数据一致且无未解释的缓存分裂
