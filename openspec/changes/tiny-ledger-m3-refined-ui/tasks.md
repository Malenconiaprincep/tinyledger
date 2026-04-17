## 1. 主题与设计系统

- [ ] 1.1 在 `tiny_ledger/pubspec.yaml` 添加 `google_fonts`（若团队接受依赖），否则在 `design.md` Open Questions 中记录回退方案并仍完成色板对齐
- [ ] 1.2 在 `tiny_ledger/lib/app/tiny_ledger_theme.dart`（或等价）用 Stitch `namedColors` 构建 `ColorScheme` / `ThemeData`，统一卡片、按钮、输入框圆角
- [ ] 1.3 校验浅色对比度与 `AppBar`/`NavigationBar` 与 M3 Refined 气质一致

## 2. 导航与信息架构

- [ ] 2.1 在 `app_shell.dart` 调整 Tab 标签/图标（若稿与现名不一致则对齐文案）
- [ ] 2.2 从首页增加「查看全部流水」入口，导航至新全屏流水页（或等价命名）

## 3. 首页/资产

- [ ] 3.1 重构 `features/home/home_page.dart`：余额主视觉、摘要区、快捷「记一笔」布局对齐 Stitch「首页/资产 - TinyLedger (M3 Refined)」
- [ ] 3.2 首页「最近流水」与全屏流水的数据一致性与跳转后状态保持

## 4. 记一笔与流水

- [ ] 4.1 更新 `home_page.dart`（或拆出组件）中收入/支出 sheet：字段顺序、主按钮、错误态对齐「记一笔 - TinyLedger (M3 Refined)」
- [ ] 4.2 新增 `features/ledger/ledger_list_page.dart`（或等价）实现全屏流水列表与空状态
- [ ] 4.3 在 `tiny_ledger_app.dart` 或 `app_shell` 注册路由（如 `Navigator.push`）并完成返回栈体验

## 5. 存钱目标

- [ ] 5.1 更新 `features/goals/goals_page.dart` 列表与创建/编辑流程的卡片与进度展示，对齐「存钱目标 - TinyLedger (M3 Refined)」

## 6. 增值说明

- [ ] 6.1 更新 `features/growth/growth_page.dart` 版式与教育标注位置，对齐「增值说明 - TinyLedger (M3 Refined)」

## 7. 设置 / 更多

- [ ] 7.1 更新 `features/more/more_page.dart`：分组、开关、入口对齐「设置 - TinyLedger (M3 Refined)」；保留减弱动效与适龄说明
- [ ] 7.2 确认 `app/motion.dart` 与用户设置在 M3 视觉下仍生效（无装饰动画泄漏）

## 8. 验证

- [ ] 8.1 `dart analyze` / `dart format`（或项目约定命令）无新增错误
- [ ] 8.2 在 iOS 模拟器与 Android（其一即可）手测：四 Tab + 全屏流水 + 记一笔闭环
- [ ] 8.3 在 PR 或提交说明中写明择定的 Stitch 屏幕 `name`（主参考帧）
