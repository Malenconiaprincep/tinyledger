## ADDED Requirements

### Requirement: Create spending entry（创建支出记录）
系统 MUST 允许用户创建支出记录，包含金额、可选分类与可选备注。

#### Scenario: Save valid spending entry
- **WHEN** 用户输入合法支出金额并确认保存
- **THEN** 系统创建支出流水并反映到虚拟钱包余额

#### Scenario: Reject zero or negative spending amount
- **WHEN** 用户输入零或负数作为支出金额
- **THEN** 系统阻止保存并提示金额必须大于零

### Requirement: Lightweight categories（轻量分类）
系统 MUST 提供有限数量的儿童友好支出分类供选择，并允许「未分类」作为默认。

#### Scenario: Default category when none selected
- **WHEN** 用户保存支出但未选择分类
- **THEN** 系统将该笔记录标记为默认未分类且仍可展示在列表中
