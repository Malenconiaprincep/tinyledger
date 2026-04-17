## ADDED Requirements

### Requirement: Home asset matches Stitch M3（首页资产对齐 M3 Refined）
系统 MUST 将「首页/资产」主界面布局与 Stitch 画板 **「首页/资产 - TinyLedger (M3 Refined)」**（资源 `projects/16236738106685052013/screens/1665c8c578d7470ba482a79575a2a2e5` 或 `projects/16236738106685052013/screens/364b30d252294300b49db9fa23af4335` 中择一为基准，见变更 `design.md`）在**信息层级**上一致：虚拟余额为首要信息、次要摘要与快捷入口可见且不遮挡余额阅读。

#### Scenario: Balance is primary focal
- **WHEN** 用户进入应用默认首页
- **THEN** 虚拟余额在首屏以最大视觉权重展示且无需滚动即可阅读

#### Scenario: Entry to full ledger exists
- **WHEN** 用户需要查看完整流水而非仅最近若干条
- **THEN** 系统提供明确入口导航至全屏流水列表（见 `spending-log` 能力新增场景）
