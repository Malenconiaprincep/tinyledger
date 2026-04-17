## ADDED Requirements

### Requirement: Virtual balance display（虚拟余额展示）
系统 MUST 展示用户当前虚拟余额，并在余额变化后即时更新显示。

#### Scenario: Balance updates after income
- **WHEN** 用户记录一笔入账（如零花钱）
- **THEN** 系统增加虚拟余额并刷新首页或钱包页的余额展示

#### Scenario: Balance updates after expense
- **WHEN** 用户记录一笔支出
- **THEN** 系统减少虚拟余额且余额不为负时完成记账

### Requirement: Non-negative balance rule（非负余额规则）
系统 MUST 阻止导致虚拟余额为负的支出记录，并提示用户调整金额或先入账。

#### Scenario: Reject overspending
- **WHEN** 用户输入大于当前余额的支出金额
- **THEN** 系统拒绝保存该笔支出并展示可理解的错误提示

### Requirement: Transaction history listing（流水列表）
系统 MUST 提供按时间倒序排列的流水列表，并区分入账与支出类型。

#### Scenario: List shows recent activity
- **WHEN** 用户打开流水页面
- **THEN** 系统展示最近记录，且每条记录包含类型、金额、时间与简短备注字段

### Requirement: Home asset matches Playful Explorer edition（首页资产对齐趣味探索版）
系统 MUST 将「首页/资产」主界面布局与 Stitch画板 **「首页/资产 - 趣味探索版」** 在**信息层级与关键控件**上一致；**唯一主参考**资源为 `projects/16236738106685052013/screens/be63fb89830a4850b779356efecb3613`。实现前 MUST 对该资源执行 MCP **`get_screen`**；虚拟余额为首要信息，次要摘要与导航入口可见且不遮挡主余额阅读。

#### Scenario: Balance is primary focal
- **WHEN** 用户进入应用默认首页/资产
- **THEN** 虚拟余额在首屏以最大视觉权重展示且与 `get_screen` 主参考帧层级一致

#### Scenario: Navigation matches draft shell
- **WHEN** 用户查看首页/资产底部或顶部导航
- **THEN** Tab 数量、标签与图标与 **趣味探索版** 主参考帧一致（若稿为 5 Tab，应用 MUST 为 5 Tab，不得以历史4 Tab 交付）

#### Scenario: Entry to ledger matches draft
- **WHEN** 用户需要进入完整流水视图
- **THEN** 入口位置与文案与 **「账本流水 - 趣味探索版」** 主参考帧（`projects/16236738106685052013/screens/a6ee4018760549c9b975d72fdc6d2f76`）经 `get_screen` 核对一致
