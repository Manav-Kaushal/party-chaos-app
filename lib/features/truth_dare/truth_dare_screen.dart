import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../models/game_session.dart';
import '../../models/player.dart';
import '../../providers/game_provider.dart';
import '../../widgets/common_widgets.dart';
import 'widgets/widgets.dart';

enum TruthDareLevel { casual, funny, spicy, dirty }

class TruthOrDareScreen extends StatefulWidget {
  const TruthOrDareScreen({super.key});

  @override
  State<TruthOrDareScreen> createState() => _TruthOrDareScreenState();
}

class _TruthOrDareScreenState extends State<TruthOrDareScreen>
    with TickerProviderStateMixin {
  bool _showQuestion = false;
  bool? _selectedTruth;
  late AnimationController _fadeController;
  late AnimationController _spotlightController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _spotlightAnimation;
  bool _showReactions = false;
  String? _currentReaction;
  TruthDareLevel _selectedLevel = TruthDareLevel.funny;
  int? _selectedRating;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _spotlightController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _spotlightAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _spotlightController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _spotlightController.dispose();
    super.dispose();
  }

  void _onShowQuestion(bool isTruth) {
    setState(() {
      _showQuestion = true;
      _selectedTruth = isTruth;
    });
    _fadeController.forward();
    _spotlightController.forward(from: 0);
  }

  void _onNextPlayer(GameProvider gameProvider) {
    _fadeController.reset();
    setState(() {
      _showQuestion = false;
      _selectedRating = null;
    });
    if (_selectedTruth == true) {
      gameProvider.selectTruth();
    } else {
      gameProvider.selectDare();
    }
    gameProvider.nextPlayer();
    _spotlightController.forward(from: 0);
  }

  void _onReaction(String emoji) {
    setState(() {
      _currentReaction = emoji;
      _showReactions = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showReactions = false;
          _currentReaction = null;
        });
      }
    });
  }

  void _onRating(int points, GameProvider gameProvider, Player player) {
    setState(() => _selectedRating = points);
    if (points > 0) {
      gameProvider.addScore(player.id, points);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        final session = gameProvider.currentSession!;
        final currentPlayer = session.currentPlayer;

        return Scaffold(
          body: GradientBackground(
            child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      _buildHeader(context, session, gameProvider),
                      _buildLevelFilter(),
                      const Spacer(),
                      if (!_showQuestion)
                        _buildChoiceScreen(gameProvider)
                      else
                        _buildQuestionScreen(gameProvider, currentPlayer),
                      const Spacer(),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                  if (_showReactions || _currentReaction != null)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: FloatingReactions(
                          show: _showReactions,
                          emojis: _currentReaction != null
                              ? [_currentReaction!]
                              : const ['🔥', '❤️', '😂', '🎉', '👏', '💯'],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, GameSession session, GameProvider gameProvider) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(Icons.close, size: 20),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.primaryGradient.createShader(bounds),
                  child: const Text(
                    'Truth or Dare',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.secondaryGradient,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    'Round ${session.round}/${session.totalRounds}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(Icons.leaderboard_outlined, size: 20),
            ),
            onPressed: () => _showScores(context, session, gameProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelFilter() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: TruthDareLevel.values.map((level) {
          final isSelected = _selectedLevel == level;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(_getLevelLabel(level)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedLevel = level);
              },
              backgroundColor: AppColors.surface,
              selectedColor: _getLevelColor(level),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.full),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : _getLevelColor(level).withValues(alpha: 0.3),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChoiceScreen(GameProvider gameProvider) {
    return Consumer<GameProvider>(
      builder: (context, gp, _) {
        final player = gp.currentSession!.currentPlayer;

        return Column(
          children: [
            _buildSpotlightPlayer(player),
            const SizedBox(height: AppSpacing.xl),
            Text(
              "${player.name}'s turn!",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Choose your challenge',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconGameButton(
                  icon: Icons.psychology_rounded,
                  label: 'TRUTH',
                  color: AppColors.success,
                  onTap: () => _onShowQuestion(true),
                ),
                const SizedBox(width: AppSpacing.lg),
                IconGameButton(
                  icon: Icons.flash_on_rounded,
                  label: 'DARE',
                  color: AppColors.error,
                  onTap: () => _onShowQuestion(false),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpotlightPlayer(Player player) {
    return AnimatedBuilder(
      animation: _spotlightAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_spotlightAnimation.value * 0.2),
          child: Opacity(
            opacity: _spotlightAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              player.avatar.color,
              player.avatar.color.withValues(alpha: 0.6),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: player.avatar.color.withValues(alpha: 0.6),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 3,
            ),
          ),
          child: Center(
            child: Text(
              AvatarPresets.faces[player.avatar.index],
              style: const TextStyle(fontSize: 72),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionScreen(GameProvider gameProvider, Player player) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.lg),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          border: Border.all(
            color: _selectedTruth == true
                ? AppColors.success.withValues(alpha: 0.3)
                : AppColors.error.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  (_selectedTruth == true ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: _selectedTruth == true
                    ? AppColors.success.withValues(alpha: 0.2)
                    : AppColors.error.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(
                _selectedTruth == true
                    ? Icons.psychology_rounded
                    : Icons.flash_on_rounded,
                size: 48,
                color: _selectedTruth == true
                    ? AppColors.success
                    : AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _selectedTruth == true
                  ? gameProvider.currentTruth
                  : gameProvider.currentDare,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_selectedRating == null) ...[
              const Text(
                'How did they do?',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RatingButton(
                    label: 'Slayed!',
                    icon: Icons.star_rounded,
                    color: AppColors.success,
                    points: 3,
                    onTap: () => _onRating(3, gameProvider, player),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  RatingButton(
                    label: 'Okay',
                    icon: Icons.thumb_up_rounded,
                    color: AppColors.tertiary,
                    points: 1,
                    onTap: () => _onRating(1, gameProvider, player),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  RatingButton(
                    label: 'Failed',
                    icon: Icons.sentiment_dissatisfied_rounded,
                    color: AppColors.error,
                    points: 0,
                    onTap: () => _onRating(0, gameProvider, player),
                  ),
                ],
              ),
            ] else ...[
              if (_selectedRating! > 0)
                ScoreChip(
                  score: _selectedRating!,
                  color: _selectedRating! == 3
                      ? AppColors.success
                      : AppColors.tertiary,
                ),
              const SizedBox(height: AppSpacing.lg),
              GameButton(
                label: 'Next Player',
                icon: Icons.arrow_forward_rounded,
                onTap: () => _onNextPlayer(gameProvider),
                fullWidth: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReactionBar() {
    return Center(
      child: ReactionBar(
        onReaction: _onReaction,
      ),
    );
  }

  void _showScores(
      BuildContext context, GameSession session, GameProvider gameProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          child: ScoreBoard(
            players: session.players,
            expanded: true,
          ),
        ),
      ),
    );
  }

  String _getLevelLabel(TruthDareLevel level) {
    switch (level) {
      case TruthDareLevel.casual:
        return 'Casual';
      case TruthDareLevel.funny:
        return 'Funny';
      case TruthDareLevel.spicy:
        return 'Spicy';
      case TruthDareLevel.dirty:
        return '18+';
    }
  }

  Color _getLevelColor(TruthDareLevel level) {
    switch (level) {
      case TruthDareLevel.casual:
        return AppColors.primary;
      case TruthDareLevel.funny:
        return AppColors.success;
      case TruthDareLevel.spicy:
        return AppColors.secondary;
      case TruthDareLevel.dirty:
        return AppColors.error;
    }
  }
}
