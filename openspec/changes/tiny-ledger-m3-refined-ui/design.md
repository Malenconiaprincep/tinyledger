## Context

- **产品**：TinyLedger（小算盘）Flutter 应用，仓库路径 `tiny_ledger/`。
- **设计基准**：Google Stitch 项目 [趣学模拟账本](https://stitch.withgoogle.com/projects/16236738106685052013)（`projectId=16236738106685052013`）。本项目变更启动时已通过 **Stitch MCP**（`get_project`、`list_screens`）拉取：`designTheme`（色板、圆角、字体枚举、`designMd` 长文设计策略）、各屏 `title` 与资源 `name`。
- **命名约定**：下表中的 `name` 为 API 资源全名，格式 `projects/16236738106685052013/screens/{screenId}`，供实现或评审时与 MCP `get_screen` 对齐。

## Stitch 画板映射（M3 Refined 为验收基准）

| 应用区域 | Stitch 画板标题 | 资源 `name`（节选） |
|----------|------------------|----------------------|
| 首页/资产 | 首页/资产 - TinyLedger (M3 Refined) | `projects/16236738106685052013/screens/1665c8c578d7470ba482a79575a2a2e5`、`projects/16236738106685052013/screens/364b30d252294300b49db9fa23af4335` |
| 记一笔（收入/支出） | 记一笔 - TinyLedger (M3 Refined) | `projects/16236738106685052013/screens/47cd52d945964b76836d05c16eb952e8`、`projects/16236738106685052013/screens/f2c463f8c4e54109961211224c623552` |
| 账本/流水 | 流水列表 - TinyLedger (M3 Refined) | `projects/16236738106685052013/screens/978cf6b8f6f34a6db5fb2e24c58d99a3`、`projects/16236738106685052013/screens/e14bea521da248fd94c4b19b9a209781` |
| 存钱目标 | 存钱目标 - TinyLedger (M3 Refined) | `projects/16236738106685052013/screens/f388fe64a3b84a92843189555c76e8af`、`projects/16236738106685052013/screens/27382c3ba4974918b128d54b8323780d` |
| 增值说明 | 增值说明 - TinyLedger (M3 Refined) | `projects/16236738106685052013/screens/978f36303f8943329bf1cf78f96a3b87`、`projects/16236738106685052013/screens/26b632f3903e428f82361881e38515a3` |
| 设置 | 设置 - TinyLedger (M3 Refined) | `projects/16236738106685052013/screens/ca471ee373c541b69e40c8de9bf24aae`、`projects/16236738106685052013/screens/7c1debd873fa4553916826f61c798e88` |
| 设计令牌（参考） | TinyLedger 设计令牌 (Design Tokens) | `projects/16236738106685052013/screens/ae83d115c05344049265ef261a586fa0` |

**多稿处理**：同一功能存在两帧 M3 Refined 时，以实现阶段**择一完整稿**为「主参考」，另一帧用于校验间距/组件状态；若两帧结构冲突，以 `design.md` 本条表格自上而下第一个 `name` 为主参考，并在 PR 说明中写明择稿理由。

## Goals / Non-Goals

**Goals:**

- Flutter 端 **ColorScheme / 表面层级 / 圆角 / 主字体** 与 Stitch `designTheme` 一致或刻意等价（见下节决策）。
- 各 Tab / 子路由承载的界面在**信息架构与关键控件**上与上表 M3 Refined 画板一致；缺失路由则补齐。
- 继续满足既有「减弱动效」「系统减少动画」「非真实理财」等约束。

**Non-Goals:**

- 不追求 HTML 导出像素级复刻；以 Flutter Widget 语义等价为准。
- 不引入 Stitch 设计稿中的任何真实支付、登录或第三方 SDK。

## Decisions

1. **主题来源**  
   - 以 MCP 返回的 `designTheme.namedColors` 与 `customColor` / `overridePrimaryColor` 等为 **Flutter `ColorScheme` 种子**，在 `tiny_ledger_theme.dart`（或等价）集中定义；组件使用 `Theme.of(context)` 消费，避免硬编码散落。  
   - **备选**：手写另一套色板。未采纳：与已定 Stitch 稿不一致，评审成本高。

2. **字体**  
   - Stitch 标注为 **Plus Jakarta Sans**（`designTheme` 中 `bodyFont`/`headlineFont`）。Flutter 侧优先使用 `google_fonts` 包加载该字体；若包体或构建约束不可接受，再退化为平台默认无衬线并在 `design.md` 勘误。  
   - **备选**：仅用系统字体。未采纳：与 M3 Refined 气质偏差明显。

3. **流水与首页关系**  
   - 首页保留「最近流水」摘要；另提供 **全屏流水列表**（新 `Route` 或独立页），布局对齐「流水列表 - TinyLedger (M3 Refined)」，从首页或底部导航可达（具体 IA 以实现择一：若保持四 Tab，则首页入口进入全屏流水；若未来改为五 Tab 不在本变更强制）。  
   - **备选**：仅首页滚动列表。未采纳：与定稿「流水列表」全屏稿不一致。

4. **记一笔**  
   - 继续使用 bottom sheet / 全屏表单均可，但 **字段顺序、主按钮位置、成功反馈** 须与 M3 Refined「记一笔」稿一致；收入与支出各一流程。  
   - **备选**：合并为单页切换。未采纳：与两帧记一笔稿的叙事不一致。

5. **设置**  
   - 「更多」Tab 内承载设置分组，版式对齐「设置 - TinyLedger (M3 Refined)」；适龄说明、减弱动效、家长占位按稿中分组呈现。  
   - **备选**：独立「设置」Tab。未采纳：当前壳层为四 Tab，减少导航重构范围。

## Risks / Trade-offs

- [Stitch 与 Flutter 组件模型差异] → 以 **Scenario 可测** 的版式与文案为准，允许 Widget 树不同。  
- [google_fonts 增加依赖或首帧延迟] → 可缓存字体；若不可接受再记录为 Open Question。  
- [多帧 M3 稿细微不一致] → 择一主参考并在 PR 固定。

## Migration Plan

- 纯客户端 UI 变更：无数据迁移。发布前在 iOS/Android 各验证一遍主题对比度与 Tab 导航。  
- 回滚：Git 回退主题与页面文件即可。

## Open Questions

- 全屏流水入口是否放在 **AppBar 动作**、**首页内链** 或 **底部导航扩展**？首版建议首页显著按钮「查看全部流水」。  
- `google_fonts` 是否接受为正式依赖（包大小与许可）？

## 附录：Stitch `designTheme` 摘要（MCP 拉取）

- **设备**：`MOBILE`。  
- **圆角**：`ROUND_FULL`。  
- **主色倾向**：Indigo 系（如 `namedColors.primary` `#24389c`、`primary_container` `#3f51b5`）；次要 Sage `#40674f`、 tertiary Coral `#772821`；背景 `#f8fafb`。  
- **设计叙事**：`designMd` 中 **「The Earnest Ledger」** — 极简、无低龄贴纸、避免 1px 硬分割线，优先表面层级与留白；实现时以本摘要 + 画板为准，全文以 Stitch 项目内 `designMd` 资源为权威。
