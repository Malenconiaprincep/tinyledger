## ADDED Requirements

### Requirement: Settings layout matches Stitch M3（设置页对齐）
系统 MUST 将设置相关界面（当前实现中位于「更多」Tab 内亦可）与 Stitch **「设置 - TinyLedger (M3 Refined)」**（资源 `projects/16236738106685052013/screens/ca471ee373c541b69e40c8de9bf24aae` 或 `projects/16236738106685052013/screens/7c1debd873fa4553916826f61c798e88`）在**分组标题、列表行样式与开关位置**上对齐；须包含 **减弱动效** 开关与 **适龄说明** 入口（可复用既有文案）。

#### Scenario: Reduce motion toggle visible in settings
- **WHEN** 用户打开设置/更多中的设置区
- **THEN** 减弱动效开关与适龄说明入口在单屏内易于发现（与 M3 Refined 稿分组一致）

#### Scenario: Parent placeholder grouped
- **WHEN** 用户浏览设置列表
- **THEN** 家长可见占位说明出现在与稿一致的分组中且不收集敏感个人信息
