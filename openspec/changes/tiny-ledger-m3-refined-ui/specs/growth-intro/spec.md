## ADDED Requirements

### Requirement: Growth simulation matches iOS Warm edition（增长模拟对齐 iOS 温馨版）
系统 MUST 将增长/学习模拟主界面与 Stitch **「增长模拟 - iOS 温馨版」** 在**教育说明位置、内容卡片层级、模拟控件与主 CTA** 上一致；**唯一主参考**资源为 `projects/16236738106685052013/screens/3adac670e12b4c0bb0b87272d8eb6dfd`。实现前 MUST **`get_screen`**。既有的「学习用模拟 /非真实收益」标注 MUST 保持 **首屏或固定顶区可见**，可见性不得弱于当前主规格其它条款。

#### Scenario: Disclaimer visible
- **WHEN** 用户打开增长模拟 Tab
- **THEN** 教育标注与 `get_screen` 主参考帧不冲突且用户无需进入深层菜单即可看到

#### Scenario: No real market data
- **WHEN** 系统展示任一应于应用内规则计算的模拟结果
- **THEN** 不调用外部金融市场接口（与既有 `growth-intro` 要求一致）
