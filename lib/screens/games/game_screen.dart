import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../models/game_session.dart';
import '../../models/player.dart';
import '../../providers/game_provider.dart';
import '../../widgets/player_avatar.dart';
import '../../widgets/common_widgets.dart';
import '../../components/animated_gradient_background.dart';
import '../../components/pulsing_widget.dart';
import '../../components/floating_emoji_reaction.dart';

class GameScreen extends StatelessWidget {
  final GameType gameType;
  final GameMode mode;

  const GameScreen({
    super.key,
    required this.gameType,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        final session = gameProvider.currentSession;
        if (session == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (gameProvider.isGameOver) {
          return _GameOverScreen(gameType: gameType);
        }

        return GradientBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Stack(
                children: [
                  switch (gameType) {
                    GameType.truthOrDare => const _TruthOrDareScreen(),
                    GameType.wouldYouRather => const _WouldYouRatherScreen(),
                    GameType.neverHaveIEver => const _NeverHaveIEverScreen(),
                    GameType.quickFireTrivia => const _TriviaScreen(),
                  },
                  const Positioned.fill(
                    child: FloatingEmojiReaction(show: false),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TruthOrDareScreen extends StatefulWidget {
  const _TruthOrDareScreen();

  @override
  State<_TruthOrDareScreen> createState() => _TruthOrDareScreenState();
}

class _TruthOrDareScreenState extends State<_TruthOrDareScreen>
    with SingleTickerProviderStateMixin {
  bool _showQuestion = false;
  bool _selectedTruth = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        final session = gameProvider.currentSession!;
        final currentPlayer = session.currentPlayer;

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              _buildHeader(context, session),
              const SizedBox(height: AppSpacing.lg),
              if (!_showQuestion) ...[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PlayerAvatar(
                        player: currentPlayer,
                        size: 100,
                        showGlow: true,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        currentPlayer.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        '${currentPlayer.name}, what will you choose?',
                        style: const TextStyle(
                          fontSize: 20,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        children: [
                          Expanded(
                            child: _ChoiceButton(
                              label: 'Truth',
                              icon: Icons.psychology,
                              gradient: AppColors.successGradient,
                              onTap: () {
                                setState(() {
                                  _selectedTruth = true;
                                  _showQuestion = true;
                                });
                                _animationController.forward();
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _ChoiceButton(
                              label: 'Dare',
                              icon: Icons.flash_on,
                              gradient: AppColors.errorGradient,
                              onTap: () {
                                setState(() {
                                  _selectedTruth = false;
                                  _showQuestion = true;
                                });
                                _animationController.forward();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _selectedTruth
                                  ? [
                                      AppColors.success.withValues(alpha: 0.2),
                                      AppColors.success.withValues(alpha: 0.05)
                                    ]
                                  : [
                                      AppColors.error.withValues(alpha: 0.2),
                                      AppColors.error.withValues(alpha: 0.05)
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(
                              color: _selectedTruth
                                  ? AppColors.success.withValues(alpha: 0.3)
                                  : AppColors.error.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: _selectedTruth
                                      ? AppColors.success
                                      : AppColors.error,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                ),
                                child: Icon(
                                  _selectedTruth
                                      ? Icons.psychology
                                      : Icons.flash_on,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                _selectedTruth
                                    ? gameProvider.currentTruth
                                    : gameProvider.currentDare,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        NeonButton(
                          label: 'Next Player',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: () {
                            _animationController.reset();
                            setState(() => _showQuestion = false);
                            if (_selectedTruth) {
                              gameProvider.selectTruth();
                            } else {
                              gameProvider.selectDare();
                            }
                            gameProvider.nextPlayer();
                          },
                          fullWidth: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, GameSession session) {
    return Row(
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
              const Text(
                'Truth or Dare',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              RoundTransition(
                roundNumber: session.round,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    'Round ${session.round}/${session.totalRounds}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
          onPressed: () => _showScores(context, session),
        ),
      ],
    );
  }

  void _showScores(BuildContext context, GameSession session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ScoresSheet(session: session),
    );
  }
}

class _WouldYouRatherScreen extends StatelessWidget {
  const _WouldYouRatherScreen();

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        final session = gameProvider.currentSession!;
        final currentPlayer = session.currentPlayer;
        final options = gameProvider.currentOptions;

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              _buildHeader(context, session),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PlayerAvatar(
                      player: currentPlayer,
                      size: 80,
                      showGlow: true,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      currentPlayer.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(
                          color: AppColors.surfaceLight,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Would you rather...',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            gameProvider.currentQuestion,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _OptionCard(
                      label: options[0],
                      color: AppColors.primary,
                      onTap: () => _handleChoice(context, gameProvider, 0),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Row(
                        children: [
                          Expanded(
                              child: Divider(color: AppColors.surfaceLight)),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            child: Text('OR',
                                style: TextStyle(color: AppColors.textMuted)),
                          ),
                          Expanded(
                              child: Divider(color: AppColors.surfaceLight)),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _OptionCard(
                      label: options[1],
                      color: AppColors.secondary,
                      onTap: () => _handleChoice(context, gameProvider, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, GameSession session) {
    return Row(
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
              const Text(
                'Would You Rather',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              RoundTransition(
                roundNumber: session.round,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    'Round ${session.round}/${session.totalRounds}',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
          onPressed: () => _showScores(context, session),
        ),
      ],
    );
  }

  void _handleChoice(BuildContext context, GameProvider provider, int choice) {
    provider.addScore(provider.currentSession!.currentPlayer.id, 10);
    provider.nextWyrQuestion();
  }

  void _showScores(BuildContext context, GameSession session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ScoresSheet(session: session),
    );
  }
}

class _NeverHaveIEverScreen extends StatelessWidget {
  const _NeverHaveIEverScreen();

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        final session = gameProvider.currentSession!;
        final choices = gameProvider.nhiePlayerChoices;

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              _buildHeader(context, session),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: AppColors.secondaryGradient,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Never Have I Ever...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      gameProvider.currentQuestion,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Tap players who have done this!',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  itemCount: session.players.length,
                  itemBuilder: (context, index) {
                    final player = session.players[index];
                    final hasDone = choices[index] ?? false;
                    return GestureDetector(
                      onTap: () => gameProvider.setNhieChoice(index, !hasDone),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: hasDone
                              ? AppColors.success.withValues(alpha: 0.2)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: hasDone
                                ? AppColors.success
                                : AppColors.surfaceLight,
                            width: 2,
                          ),
                          boxShadow: hasDone
                              ? [
                                  BoxShadow(
                                    color: AppColors.success
                                        .withValues(alpha: 0.3),
                                    blurRadius: 15,
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: player.avatar.color,
                              ),
                              child: Center(
                                child: Text(
                                  AvatarPresets.getAvatarEmoji(player.avatar),
                                  style: const TextStyle(fontSize: 30),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              player.name,
                              style: TextStyle(
                                fontWeight: hasDone
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: hasDone
                                    ? AppColors.success
                                    : AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (hasDone)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              NeonButton(
                label: 'Next Statement',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => gameProvider.nextNhieStatement(),
                fullWidth: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, GameSession session) {
    return Row(
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
              const Text(
                'Never Have I Ever',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              RoundTransition(
                roundNumber: session.round,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    'Round ${session.round}/${session.totalRounds}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
          onPressed: () => _showScores(context, session),
        ),
      ],
    );
  }

  void _showScores(BuildContext context, GameSession session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ScoresSheet(session: session),
    );
  }
}

class _TriviaScreen extends StatefulWidget {
  const _TriviaScreen();

  @override
  State<_TriviaScreen> createState() => _TriviaScreenState();
}

class _TriviaScreenState extends State<_TriviaScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final gameProvider = context.read<GameProvider>();
      if (gameProvider.answered) return;

      final remaining = gameProvider.timeRemaining - 1;
      if (remaining <= 0) {
        timer.cancel();
        gameProvider.submitTriviaAnswer();
      } else {
        gameProvider.setTimeRemaining(remaining);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        final session = gameProvider.currentSession!;
        final currentPlayer = session.currentPlayer;
        final question = gameProvider.currentTriviaQuestion;

        if (question == null) {
          return const Scaffold(
            body: Center(child: Text('No questions available')),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              _buildHeader(context, session, gameProvider),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PlayerAvatar(player: currentPlayer, size: 50),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    currentPlayer.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  question.category,
                  style: const TextStyle(
                    color: AppColors.tertiary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(
                    color: AppColors.surfaceLight,
                    width: 1,
                  ),
                ),
                child: Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView.builder(
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    final isSelected = gameProvider.selectedAnswer == index;
                    final isCorrect = index == question.correctIndex;
                    final showResult = gameProvider.answered;

                    Color? bgColor;
                    Color borderColor = AppColors.surfaceLight;
                    if (showResult) {
                      if (isCorrect) {
                        bgColor = AppColors.success.withValues(alpha: 0.2);
                        borderColor = AppColors.success;
                      } else if (isSelected && !isCorrect) {
                        bgColor = AppColors.error.withValues(alpha: 0.2);
                        borderColor = AppColors.error;
                      }
                    } else if (isSelected) {
                      bgColor = AppColors.primary.withValues(alpha: 0.2);
                      borderColor = AppColors.primary;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: GestureDetector(
                        onTap: showResult
                            ? null
                            : () => gameProvider.selectAnswer(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: bgColor ?? AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isSelected || (showResult && isCorrect)
                                      ? borderColor
                                      : AppColors.surfaceLight,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ||
                                              (showResult && isCorrect)
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  question.options[index],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              if (showResult && isCorrect)
                                const Icon(Icons.check_circle,
                                    color: AppColors.success),
                              if (showResult && isSelected && !isCorrect)
                                const Icon(Icons.cancel,
                                    color: AppColors.error),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              NeonButton(
                label:
                    gameProvider.answered ? 'Next Question' : 'Submit Answer',
                icon: gameProvider.answered
                    ? Icons.arrow_forward_rounded
                    : Icons.check_rounded,
                onPressed: () {
                  if (gameProvider.answered) {
                    gameProvider.nextTriviaQuestion();
                    _startTimer();
                  } else if (gameProvider.selectedAnswer >= 0) {
                    gameProvider.submitTriviaAnswer();
                    _timer?.cancel();
                  }
                },
                fullWidth: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, GameSession session, GameProvider gameProvider) {
    return Row(
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
              const Text(
                'Quick Fire Trivia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              RoundTransition(
                roundNumber: session.round,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    'Round ${session.round}/${session.totalRounds}',
                    style: const TextStyle(
                      color: AppColors.tertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedCountdown(
          seconds: gameProvider.timeRemaining,
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
          onPressed: () => _showScores(context, session),
        ),
      ],
    );
  }

  void _showScores(BuildContext context, GameSession session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ScoresSheet(session: session),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 56, color: Colors.white),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _OptionCard({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _ScoresSheet extends StatelessWidget {
  final GameSession session;

  const _ScoresSheet({required this.session});

  @override
  Widget build(BuildContext context) {
    final sortedPlayers = [...session.players];
    sortedPlayers.sort((a, b) {
      final scoreA = session.scores[a.id] ?? 0;
      final scoreB = session.scores[b.id] ?? 0;
      return scoreB.compareTo(scoreA);
    });

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: AppColors.tertiaryGradient,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.leaderboard,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Text(
                'Leaderboard',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...sortedPlayers.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            final score = session.scores[player.id] ?? 0;
            final isLeading = index == 0;

            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isLeading
                    ? AppColors.tertiary.withValues(alpha: 0.15)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: isLeading
                    ? Border.all(color: AppColors.tertiary, width: 2)
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isLeading ? AppColors.tertiary : AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '#${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isLeading
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: player.avatar.color,
                      boxShadow: [
                        BoxShadow(
                          color: player.avatar.color.withValues(alpha: 0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        AvatarPresets.getAvatarEmoji(player.avatar),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      player.name,
                      style: TextStyle(
                        fontWeight:
                            isLeading ? FontWeight.bold : FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      gradient: isLeading ? AppColors.secondaryGradient : null,
                      color: isLeading ? null : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      '$score pts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isLeading ? Colors.white : AppColors.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _GameOverScreen extends StatelessWidget {
  final GameType gameType;

  const _GameOverScreen({required this.gameType});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    final winner = gameProvider.getWinner();
    final session = gameProvider.currentSession!;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Text('🎉', style: TextStyle(fontSize: 64)),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.primaryGradient.createShader(bounds),
                    child: const Text(
                      'GAME OVER!',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  if (winner != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(
                          color: AppColors.tertiary,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.tertiary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              gradient: AppColors.secondaryGradient,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.emoji_events,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Text(
                            'Winner',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: winner.avatar.color,
                              boxShadow: [
                                BoxShadow(
                                  color: winner.avatar.color
                                      .withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                AvatarPresets.getAvatarEmoji(winner.avatar),
                                style: const TextStyle(fontSize: 40),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            winner.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.tertiaryGradient,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              '${session.scores[winner.id] ?? 0} points',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                  NeonButton(
                    label: 'Back to Home',
                    icon: Icons.home_rounded,
                    onPressed: () {
                      gameProvider.resetGame();
                      Navigator.pop(context);
                    },
                    fullWidth: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
