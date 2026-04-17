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
