## ADDED Requirements

### Requirement: Educational growth simulation label（增值模拟教育标注）
系统 MUST 在增值相关界面显著标注内容为「学习用模拟」，并说明不产生真实收益。

#### Scenario: Growth screen shows disclaimer
- **WHEN** 用户打开增值演示或相关说明
- **THEN** 系统展示固定可见的教育标注文案且不可被隐藏于二级菜单之外

### Requirement: Simple periodic bonus simulation（简单周期奖励模拟）
系统 MUST 提供一种可理解的增值演示，例如按设定周期向虚拟余额发放小额「学习奖励」，并记录奖励来源。

#### Scenario: Apply scheduled learning bonus
- **WHEN** 到达配置的演示周期且功能处于开启状态
- **THEN** 系统向虚拟余额增加标注为学习奖励的金额并写入流水

### Requirement: No real market or investment linkage（无真实市场或投资关联）
系统 MUST NOT 将增值演示绑定真实市场指数、基金净值或证券价格数据源。

#### Scenario: Growth uses internal rules only
- **WHEN** 系统计算一次增值演示结果
- **THEN** 系统仅依据应用内配置规则生成结果且不调用外部金融市场接口

### Requirement: Growth simulation matches iOS Warm edition（增长模拟对齐 iOS 温馨版）
系统 MUST 将增长/学习模拟主界面与 Stitch **「增长模拟 - iOS 温馨版」** 在**教育说明位置、内容卡片层级、模拟控件与主 CTA** 上一致；**唯一主参考**资源为 `projects/16236738106685052013/screens/3adac670e12b4c0bb0b87272d8eb6dfd`。实现前 MUST **`get_screen`**。既有的「学习用模拟 /非真实收益」标注 MUST 保持 **首屏或固定顶区可见**，可见性不得弱于当前主规格其它条款。

#### Scenario: Disclaimer visible
- **WHEN** 用户打开增长模拟 Tab
- **THEN** 教育标注与 `get_screen` 主参考帧不冲突且用户无需进入深层菜单即可看到

#### Scenario: No real market data
- **WHEN** 系统展示任一应于应用内规则计算的模拟结果
- **THEN** 不调用外部金融市场接口（与既有 `growth-intro` 要求一致）
