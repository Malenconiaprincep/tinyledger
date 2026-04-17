# TinyLedger（小算盘）

面向 8–10 岁儿童的财商启蒙虚拟账本（Flutter）。OpenSpec 变更见仓库 `openspec/changes/tiny-ledger/`。

## 开发

```bash
cd tiny_ledger
flutter pub get
flutter analyze
dart test
flutter run
```

### iOS 模拟器：`ShaderCompilerException` / `ink_sparkle.frag` / `exit code -9`

若在 `flutter run` 构建阶段卡在 **编译 Material 着色器**（`impellerc` 被系统杀掉），本项目已在 `ios/Runner/Info.plist` 设置 **`FLTEnableImpeller` = `false`**，使用 **Skia** 渲染，一般即可恢复在 **iPhone 模拟器** 上运行。

改完后建议清一次构建再跑：

```bash
cd tiny_ledger
flutter clean
flutter pub get
flutter run
```

若仍失败：关闭其它占内存应用、换一台已 boot 的模拟器机型，或升级 Flutter/Xcode 后再试。

说明：部分 macOS/沙箱环境下 `flutter test` 可能在编译 Material shader（`ink_sparkle.frag` / `impellerc`）时失败；本项目已提供纯 Dart 领域单测，可用 `dart test` 作为 CI/本地验证入口。

## 产品约束（摘要）

- 记账为**虚拟练习**，非真实资金。
- 核心路径**不含第三方广告**（实现上亦无广告 SDK）。
- 「增值」为**学习用模拟**，不连接外部金融市场数据。
