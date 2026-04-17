## ADDED Requirements

### Requirement: Settings matches iOS Warm edition（设置对齐 iOS 温馨版）
系统 MUST 将设置界面与 Stitch **「设置 - iOS 温馨版」** 在**分组标题、列表行样式、开关与入口布局**上一致；**唯一主参考**资源为 `projects/16236738106685052013/screens/d984aae2953d467bb3a03c6cbb01a867`。实现前 MUST **`get_screen`**。MUST 包含 **减弱动效** 开关与 **适龄说明** 入口（可复用既有文案）；家长可见占位 MUST 出现在与主参考帧一致的分组内且不收集敏感个人信息。

#### Scenario: Reduce motion and age guidance discoverable
- **WHEN** 用户打开设置
- **THEN** 减弱动效开关与适龄说明入口易于发现，且分组与 `get_screen` 主参考帧一致

#### Scenario: Parent placeholder grouped
- **WHEN** 用户浏览设置列表
- **THEN** 家长可见占位说明出现在与稿一致的分组中
