## ADDED Requirements

### Requirement: Goals UI matches iOS Warm edition（存钱目标对齐 iOS 温馨版）
系统 MUST 将存钱目标相关界面（列表、进度、创建/编辑）与 Stitch **「存钱目标 - iOS 温馨版」** 在**卡片结构、进度可视化与主操作位置**上一致；**唯一主参考**资源为 `projects/16236738106685052013/screens/52c048a42a604d1f862e19edd7c0dbb6`。实现前 MUST **`get_screen`**。不改变既有领域规则（金额合法、进度计算、完成态）。

#### Scenario: Goal list matches get_screen
- **WHEN** 用户打开目标 Tab
- **THEN** 列表与空状态布局与主参考帧一致且可单手滚动

#### Scenario: Create or edit goal
- **WHEN** 用户创建或编辑目标
- **THEN** 表单层级与主按钮位置与 `get_screen` 主参考帧一致
