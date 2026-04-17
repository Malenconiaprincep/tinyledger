## ADDED Requirements

### Requirement: Goals UI matches Stitch M3（存钱目标界面 M3 对齐）
系统 MUST 将存钱目标相关界面（列表、进度、创建/编辑）与 Stitch **「存钱目标 - TinyLedger (M3 Refined)」**（资源 `projects/16236738106685052013/screens/f388fe64a3b84a92843189555c76e8af` 或 `projects/16236738106685052013/screens/27382c3ba4974918b128d54b8323780d`）在**卡片结构、进度可视化与主操作位置**上对齐；不改变既有领域规则（金额合法、进度计算）。

#### Scenario: Goal list card layout
- **WHEN** 用户打开目标 Tab
- **THEN** 目标项以 M3 Refined 稿中的卡片式列表呈现且单手可滚动浏览

#### Scenario: Goal detail or sheet matches draft hierarchy
- **WHEN** 用户创建或编辑目标
- **THEN** 表单字段层级与主按钮与 M3 Refined 稿一致
