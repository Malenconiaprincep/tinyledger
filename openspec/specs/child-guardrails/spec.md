## ADDED Requirements

### Requirement: Age band declaration（适龄声明）
系统 MUST 在首次使用前要求确认使用者处于 8–10 岁适用区间，并展示简短、可理解的适龄说明。

#### Scenario: First launch shows age guidance
- **WHEN** 用户首次启动应用且尚未完成适龄确认
- **THEN** 系统展示适龄说明并要求用户完成确认后才能进入主功能

#### Scenario: Age guidance can be reviewed later
- **WHEN** 用户从设置或帮助入口选择查看适龄说明
- **THEN** 系统再次展示与首次一致的适龄说明内容

### Requirement: No third-party ads in core flows（核心流程无第三方广告）
系统 MUST NOT 在记账、目标与增值演示等核心学习流程中展示第三方广告或外链营销内容。

#### Scenario: Core ledger screen stays ad-free
- **WHEN** 用户查看虚拟余额或流水列表
- **THEN** 系统不展示第三方广告组件或跳转至外部营销页面

### Requirement: Parent visibility placeholder（家长可见占位）
系统 MUST 提供「家长可见摘要」入口或占位说明，用于未来展示非敏感汇总信息（如本周储蓄次数），首版可仅展示说明而不展示真实数据。

#### Scenario: Parent section exists as placeholder
- **WHEN** 用户打开家长相关入口
- **THEN** 系统展示占位说明或未来能力介绍，且不要求儿童提供敏感个人信息

### Requirement: Settings matches iOS Warm edition（设置对齐 iOS 温馨版）
系统 MUST 将设置界面与 Stitch **「设置 - iOS 温馨版」** 在**分组标题、列表行样式、开关与入口布局**上一致；**唯一主参考**资源为 `projects/16236738106685052013/screens/d984aae2953d467bb3a03c6cbb01a867`。实现前 MUST **`get_screen`**。MUST 包含 **减弱动效** 开关与 **适龄说明** 入口（可复用既有文案）；家长可见占位 MUST 出现在与主参考帧一致的分组内且不收集敏感个人信息。

#### Scenario: Reduce motion and age guidance discoverable
- **WHEN** 用户打开设置
- **THEN** 减弱动效开关与适龄说明入口易于发现，且分组与 `get_screen` 主参考帧一致

#### Scenario: Parent placeholder grouped
- **WHEN** 用户浏览设置列表
- **THEN** 家长可见占位说明出现在与稿一致的分组中
