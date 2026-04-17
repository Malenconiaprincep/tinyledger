## ADDED Requirements

### Requirement: Stitch M3 theme tokens in Flutter（Stitch M3 主题在 Flutter 落地）
系统 MUST 使用与 Stitch 项目 `16236738106685052013` 的 `designTheme.namedColors` 语义一致的 **Material 3 `ColorScheme`**（含 primary / secondary / tertiary / surface / on_* 等关键角色），并在应用根 `ThemeData` 中挂载；圆角策略 MUST 与稿中 **大圆角卡片 + 全圆角主按钮** 气质一致（允许以 `ThemeData` 的 `cardTheme`、`filledButtonTheme` 等等价实现）。

#### Scenario: Theme uses Stitch palette roles
- **WHEN** 用户冷启动应用进入任意主界面
- **THEN** 表面背景、主色按钮与强调文本的颜色角色与 Stitch M3 Refined 设计令牌稿（`TinyLedger 设计令牌 (Design Tokens)`）无肉眼冲突级偏差（对比度保持可读）

### Requirement: Plus Jakarta Sans typography（Plus Jakarta Sans 排版）
系统 MUST 在支持范围内将 **Plus Jakarta Sans** 作为标题与正文主字体（与 Stitch `designTheme` 中字体枚举一致）；若字体加载失败，MUST 回退到平台无衬线且不改变颜色角色。

#### Scenario: Headline uses primary font family
- **WHEN** 用户查看首页余额标题或页面大标题
- **THEN** 文本使用 Plus Jakarta Sans（或已文档化的回退字体）且字重与层级可辨

### Requirement: No harsh 1px section dividers（避免生硬分割线）
系统 MUST NOT 使用连续的 1px 实线分割主内容区块作为主要分区手段；分区 MUST 优先通过 **卡片表面、间距与 tonal container** 完成，与 Stitch `designMd` 中「No-Line」原则一致。

#### Scenario: Home content uses tonal cards
- **WHEN** 用户查看首页/资产主内容区
- **THEN** 主要区块之间无贯穿全宽的 1px 实线分隔主叙事（列表行内细分允许弱化分隔或留白）
