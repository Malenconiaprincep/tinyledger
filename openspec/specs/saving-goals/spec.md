## ADDED Requirements

### Requirement: Create savings goal（创建储蓄目标）
系统 MUST 允许用户创建储蓄目标，包含目标名称、目标金额与可选图标或颜色标识。

#### Scenario: Goal appears in goal list
- **WHEN** 用户填写合法目标名称与目标金额并保存
- **THEN** 系统在目标列表中展示该目标且初始进度为零

#### Scenario: Reject invalid goal amount
- **WHEN** 用户输入非正数作为目标金额
- **THEN** 系统阻止保存并提示目标金额必须大于零

### Requirement: Allocate savings to goal（向目标转入虚拟储蓄）
系统 MUST 允许用户从虚拟余额向目标转入金额以增加进度，且转入不得超过当前余额。

#### Scenario: Progress increases after allocation
- **WHEN** 用户从余额向目标转入不超过余额的金额
- **THEN** 系统减少余额、增加目标已存金额并更新进度展示

#### Scenario: Prevent allocation beyond balance
- **WHEN** 用户尝试转入超过当前虚拟余额的金额
- **THEN** 系统拒绝操作并提示余额不足

### Requirement: Goal completion state（目标完成状态）
系统 MUST 在目标已存金额达到目标金额时将目标标记为已完成，并展示庆祝性反馈（不含真实金钱奖励）。

#### Scenario: Mark goal complete at threshold
- **WHEN** 目标已存金额达到或超过目标金额
- **THEN** 系统将目标标记为已完成并展示完成反馈

### Requirement: Goals UI matches Playful Explorer edition（存钱目标对齐趣味探索版）
系统 MUST 将存钱目标相关界面（列表、进度、创建/编辑）与 Stitch **「存钱目标 - 趣味探索版」** 在**卡片结构、进度可视化与主操作位置**上一致；**唯一主参考**资源为 `projects/16236738106685052013/screens/9cf1e7eebf6d44d8a23040fdee3cd49d`。实现前 MUST **`get_screen`**。不改变既有领域规则（金额合法、进度计算、完成态）。

#### Scenario: Goal list matches get_screen
- **WHEN** 用户打开目标 Tab
- **THEN** 列表与空状态布局与主参考帧一致且可单手滚动

#### Scenario: Create or edit goal
- **WHEN** 用户创建或编辑目标
- **THEN** 表单层级与主按钮位置与 `get_screen` 主参考帧一致
