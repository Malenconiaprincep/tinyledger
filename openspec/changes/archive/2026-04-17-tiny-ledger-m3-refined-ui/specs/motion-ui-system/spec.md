## ADDED Requirements

### Requirement: MCP-verified theme from iOS Warm frames（以 MCP 校验的 iOS 温馨版主题）
系统 MUST 在落地主题前对 `design.md` 中 **「首页/资产 - iOS 温馨版」** 主参考资源调用 Stitch MCP **`get_screen`**（`projects/16236738106685052013/screens/a5b4b391bc434971ae864d3a33b5bd79`），并以返回内容所体现的色彩层级、圆角与排版气质驱动 **`ColorScheme` / `ThemeData`**；若项目级 `get_project.designTheme` 与 `get_screen` 冲突，MUST 以 **`get_screen`** 为准并在实现处注释说明。

#### Scenario: Theme matches warm edition focal screen
- **WHEN** 用户冷启动应用进入任意主界面
- **THEN** 表面、主色与强调色角色与上述主参考帧经 MCP 对照后的约定一致（对比度可读），且不再以 **M3 Refined** 旧帧为验收依据

### Requirement: Typography per iOS Warm edition（字体随 iOS 温馨版）
系统 MUST 将标题与正文主字体与 **iOS 温馨版** 主参考帧（同上 `get_screen`）一致；若该帧使用 **Plus Jakarta Sans** 或其它字体族，MUST 通过 `google_fonts` 或已批准方式加载；失败时 MUST 回退到平台无衬线并记录回退。

#### Scenario: Headline font matches get_screen
- **WHEN** 用户查看首页/资产大标题或余额区
- **THEN** 字体族与字重层级与 `get_screen` 所体现的风格一致（允许 Flutter 等价实现）

### Requirement: Soft sectioning without harsh dividers（柔和分区）
系统 MUST NOT 使用连续 1px 实线作为主内容区的主要分区手段；MUST 优先使用 **卡片表面、间距与 tonal container**，并与 **iOS 温馨版** 主参考帧（`get_screen`）的分区方式一致。

#### Scenario: Home uses tonal grouping
- **WHEN** 用户查看首页/资产主内容区
- **THEN** 主叙事区块之间无贯穿全宽的生硬实线分割（列表行内弱分隔除外）

### Requirement: UI implementation MUST use Stitch MCP before merge（合并前须用 MCP 读稿）
对任一影响全局主题或壳层导航的 PR，作者 MUST 在描述中列出本 PR 已对照的 **`get_screen` 资源 `name`**；若未对 `design.md` 规定的 iOS 温馨版主帧执行 MCP读稿，该 PR MUST NOT 合并为「温馨版对齐」交付。

#### Scenario: PR cites screen names
- **WHEN** 评审者检查标称为 iOS 温馨版对齐的 UI PR
- **THEN** PR 说明中包含至少一个 `projects/16236738106685052013/screens/...` 主参考 `name` 及对照结论
