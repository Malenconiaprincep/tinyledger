## ADDED Requirements

### Requirement: Modern minimal visual baseline（现代极简视觉基线）
系统 MUST 采用现代极简视觉风格，优先使用排版、留白与柔和色彩层级，避免低俗卡通贴纸化主视觉。

#### Scenario: Home screen follows minimal layout
- **WHEN** 用户进入应用首页
- **THEN** 系统展示简洁的信息层级与有限装饰元素，且主要信息在首屏可读

### Requirement: Motion feedback on key actions（关键操作动效反馈）
系统 MUST 在成功记账、目标进度变化等关键操作后提供简短动效或过渡反馈，时长不超过两秒且不阻断必要信息阅读。

#### Scenario: Success feedback after save
- **WHEN** 用户成功保存一笔入账或支出
- **THEN** 系统展示简短成功反馈动画或过渡且用户仍可继续浏览流水

### Requirement: Reduce motion support（减弱动效支持）
系统 MUST 提供减弱动效开关，开启后关键路径仍以静态或极短过渡完成反馈。

#### Scenario: Reduce motion disables nonessential animations
- **WHEN** 用户开启减弱动效
- **THEN** 系统禁用装饰性动画并保留必要的状态变化提示（如颜色或文案）

### Requirement: Honor system reduced motion signal（遵循系统减弱动效信号）
系统 MUST 识别并遵循操作系统或设备提供的减弱动效（或等价的「减少动画」无障碍）信号；当该信号为开启状态时，系统 MUST 禁用装饰性动画，且仍 MUST 提供非动画形式的关键反馈（如文案、颜色或极短且不依赖位移的过渡）。

#### Scenario: System reduced motion disables decorative animations
- **WHEN** 设备系统级「减弱动效 / 减少动画」类无障碍选项已开启
- **THEN** 系统禁用装饰性动画，且不因未打开应用内减弱动效开关而继续播放装饰性动画

#### Scenario: Essential feedback without decorative motion under system signal
- **WHEN** 系统级减弱动效已开启且用户成功保存一笔入账或支出
- **THEN** 系统提供可感知的成功反馈且不依赖持续位移动画或循环装饰动画
