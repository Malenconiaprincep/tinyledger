import '../../domain/ledger_models.dart';

/// 与 Stitch「存钱目标 - iOS 温馨版」进度条配色一致：绿色系 / 珊瑚强调系。
enum GoalProgressTone { secondary, tertiary }

/// 目标页展示行：真实 `SavingsGoal` 或本地演示数据（接服务器后可移除演示段）。
class GoalListItem {
  const GoalListItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageAsset,
    required this.savedCents,
    required this.targetCents,
    required this.tone,
    required this.isSample,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String? imageAsset;
  final int savedCents;
  final int targetCents;
  final GoalProgressTone tone;
  final bool isSample;
  final bool isCompleted;

  double get progress =>
      targetCents <= 0 ? 0 : (savedCents / targetCents).clamp(0.0, 1.0);

  int get percentRounded => (progress * 100).round().clamp(0, 100);

  factory GoalListItem.fromSavingsGoal(SavingsGoal g, GoalProgressTone tone) {
    return GoalListItem(
      id: g.id,
      title: g.name,
      subtitle: g.isCompleted ? '已经完成啦，真棒！' : '离目标更近一点点～',
      imageAsset: _imageHeuristic(g.name),
      savedCents: g.savedCents,
      targetCents: g.targetCents,
      tone: tone,
      isSample: false,
      isCompleted: g.isCompleted,
    );
  }

  static String? _imageHeuristic(String name) {
    final n = name.toLowerCase();
    if (name.contains('车') || n.contains('bike') || n.contains('bicycle')) {
      return 'assets/images/goal_demo_bicycle.png';
    }
    if (n.contains('switch') || name.contains('游戏机') || n.contains('任天堂')) {
      return 'assets/images/goal_demo_console.png';
    }
    return null;
  }
}

/// 设计稿中的两条演示心愿（不接钱包，仅展示样式与文案）。
final List<GoalListItem> kStitchSampleGoals = [
  GoalListItem(
    id: '_sample_bicycle',
    title: '一辆新自行车',
    subtitle: '还能载着朋友去兜风！',
    imageAsset: 'assets/images/goal_demo_bicycle.png',
    savedCents: 80000,
    targetCents: 100000,
    tone: GoalProgressTone.secondary,
    isSample: true,
  ),
  GoalListItem(
    id: '_sample_console',
    title: 'Switch 游戏机',
    subtitle: '周末的快乐源泉 \u{1F3AE}',
    imageAsset: 'assets/images/goal_demo_console.png',
    savedCents: 70000,
    targetCents: 200000,
    tone: GoalProgressTone.tertiary,
    isSample: true,
  ),
];
