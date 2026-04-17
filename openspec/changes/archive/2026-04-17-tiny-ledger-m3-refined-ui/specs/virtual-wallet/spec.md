## ADDED Requirements

### Requirement: Home asset matches iOS Warm edition（首页资产对齐 iOS 温馨版）
系统 MUST 将「首页/资产」主界面布局与 Stitch画板 **「首页/资产 - iOS 温馨版」** 在**信息层级与关键控件**上一致；**唯一主参考**资源为 `projects/16236738106685052013/screens/a5b4b391bc434971ae864d3a33b5bd79`。实现前 MUST 对该资源执行 MCP **`get_screen`**；虚拟余额为首要信息，次要摘要与导航入口可见且不遮挡主余额阅读。

#### Scenario: Balance is primary focal
- **WHEN** 用户进入应用默认首页/资产
- **THEN** 虚拟余额在首屏以最大视觉权重展示且与 `get_screen` 主参考帧层级一致

#### Scenario: Navigation matches draft shell
- **WHEN** 用户查看首页/资产底部或顶部导航
- **THEN** Tab 数量、标签与图标与 **iOS 温馨版** 主参考帧一致（若稿为 5 Tab，应用 MUST 为 5 Tab，不得以历史4 Tab 交付）

#### Scenario: Entry to ledger matches draft
- **WHEN** 用户需要进入完整流水视图
- **THEN** 入口位置与文案与 **「流水列表 - iOS 温馨版」** 主参考帧（`projects/16236738106685052013/screens/165291e3c5fd414da980d1e7e7f127d9`）经 `get_screen` 核对一致
