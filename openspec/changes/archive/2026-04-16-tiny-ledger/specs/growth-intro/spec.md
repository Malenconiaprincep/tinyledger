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
