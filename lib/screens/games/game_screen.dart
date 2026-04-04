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
import '../lobby/game_setup_screen.dart';

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
                    GameType.oddOneOut =>
                      _OddOneOutScreen(gameType: gameType, mode: mode),
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
              _buildHeader(context, session, gameProvider),
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
                        "${currentPlayer.name}'s Turn",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ChoiceButton(
                            label: 'Truth',
                            icon: Icons.psychology_alt_rounded,
                            gradient: AppColors.primaryGradient,
                            onTap: () {
                              setState(() {
                                _selectedTruth = true;
                                _showQuestion = true;
                              });
                              _animationController.forward(from: 0);
                            },
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          _ChoiceButton(
                            label: 'Dare',
                            icon: Icons.sports_martial_arts_rounded,
                            gradient: AppColors.secondaryGradient,
                            onTap: () {
                              setState(() {
                                _selectedTruth = false;
                                _showQuestion = true;
                              });
                              _animationController.forward(from: 0);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.lg),
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            decoration: BoxDecoration(
                              gradient: _selectedTruth
                                  ? AppColors.primaryGradient
                                  : AppColors.secondaryGradient,
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                              boxShadow: [
                                BoxShadow(
                                  color: (_selectedTruth
                                          ? AppColors.primary
                                          : AppColors.secondary)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _selectedTruth ? 'TRUTH' : 'DARE',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  _selectedTruth
                                      ? gameProvider.currentTruth
                                      : gameProvider.currentDare,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Row(
                          children: [
                            Expanded(
                              child: NeonButton(
                                label: 'Next',
                                icon: Icons.arrow_forward_rounded,
                                onPressed: () {
                                  if (_selectedTruth) {
                                    gameProvider.selectTruth();
                                  } else {
                                    gameProvider.selectDare();
                                  }
                                  gameProvider.nextPlayer();
                                },
                                fullWidth: true,
                              ),
                            ),
                          ],
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

  Widget _buildHeader(
      BuildContext context, GameSession session, GameProvider gameProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Truth or Dare',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
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
            onPressed: () => _showScores(context, gameProvider.currentSession!),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(Icons.flag_outlined,
                  size: 20, color: AppColors.error),
            ),
            onPressed: () {
              gameProvider.endGame();
              Navigator.pop(context);
            },
          ),
        ],
      ),
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
              _buildHeader(context, session, gameProvider),
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
                      "${currentPlayer.name}'s Turn",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Would you rather...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildOption(
                      context,
                      options[0],
                      AppColors.primaryGradient,
                      () => _handleChoice(context, gameProvider, 0),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildOption(
                      context,
                      options[1],
                      AppColors.secondaryGradient,
                      () => _handleChoice(context, gameProvider, 1),
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

  Widget _buildOption(
    BuildContext context,
    String text,
    LinearGradient gradient,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
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
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _handleChoice(BuildContext context, GameProvider provider, int choice) {
    provider.addScore(provider.currentSession!.currentPlayer.id, 10);
    provider.nextWyrQuestion();
  }

  Widget _buildHeader(
      BuildContext context, GameSession session, GameProvider gameProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Would You Rather',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
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
            onPressed: () => _showScores(context, gameProvider.currentSession!),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(Icons.flag_outlined,
                  size: 20, color: AppColors.error),
            ),
            onPressed: () {
              gameProvider.endGame();
              Navigator.pop(context);
            },
          ),
        ],
      ),
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
              _buildHeader(context, session, gameProvider),
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
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PlayerAvatar(
                              player: player,
                              size: 48,
                              showGlow: hasDone,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              player.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color:
                                    hasDone ? AppColors.success : Colors.white,
                              ),
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

  Widget _buildHeader(
      BuildContext context, GameSession session, GameProvider gameProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Never Have I Ever',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
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
            onPressed: () => _showScores(context, gameProvider.currentSession!),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(Icons.flag_outlined,
                  size: 20, color: AppColors.error),
            ),
            onPressed: () {
              gameProvider.endGame();
              Navigator.pop(context);
            },
          ),
        ],
      ),
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
      if (gameProvider.timeRemaining > 0) {
        gameProvider.setTimeRemaining(gameProvider.timeRemaining - 1);
      } else {
        gameProvider.submitTriviaAnswer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        final session = gameProvider.currentSession!;
        final question = gameProvider.currentTriviaQuestion;
        final currentPlayer = session.currentPlayer;

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              _buildHeader(context, session, gameProvider),
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
                      "${currentPlayer.name}'s Turn",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (question != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          gradient: AppColors.tertiaryGradient,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.tertiary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Quick Fire Trivia',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              question.question,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      ...question.options.asMap().entries.map((entry) {
                        final index = entry.key;
                        final option = entry.value;
                        final isSelected = gameProvider.selectedAnswer == index;
                        final isCorrect = gameProvider.answered &&
                            index == question.correctIndex;
                        final isWrong =
                            gameProvider.answered && isSelected && !isCorrect;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: GestureDetector(
                            onTap: gameProvider.answered
                                ? null
                                : () => gameProvider.selectAnswer(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: isCorrect
                                    ? AppColors.success.withValues(alpha: 0.3)
                                    : isWrong
                                        ? AppColors.error.withValues(alpha: 0.3)
                                        : isSelected
                                            ? AppColors.tertiary
                                                .withValues(alpha: 0.3)
                                            : AppColors.surface,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.lg),
                                border: Border.all(
                                  color: isCorrect
                                      ? AppColors.success
                                      : isWrong
                                          ? AppColors.error
                                          : isSelected
                                              ? AppColors.tertiary
                                              : AppColors.surfaceLight,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected || isCorrect || isWrong
                                          ? (isCorrect
                                              ? AppColors.success
                                              : isWrong
                                                  ? AppColors.error
                                                  : AppColors.tertiary)
                                          : AppColors.surfaceLight,
                                    ),
                                    child: Center(
                                      child: Text(
                                        String.fromCharCode(65 + index),
                                        style: TextStyle(
                                          color:
                                              isSelected || isCorrect || isWrong
                                                  ? Colors.white
                                                  : AppColors.textSecondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  if (isCorrect || (isWrong && isSelected))
                                    Icon(
                                      isCorrect
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: isCorrect
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      if (gameProvider.answered) ...[
                        const SizedBox(height: AppSpacing.md),
                        NeonButton(
                          label: 'Next Question',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: () => gameProvider.nextTriviaQuestion(),
                          fullWidth: true,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, GameSession session, GameProvider gameProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Quick Fire Trivia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
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
            onPressed: () => _showScores(context, gameProvider.currentSession!),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(Icons.flag_outlined,
                  size: 20, color: AppColors.error),
            ),
            onPressed: () {
              gameProvider.endGame();
              Navigator.pop(context);
            },
          ),
        ],
      ),
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
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xl,
          horizontal: AppSpacing.lg,
        ),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        final session = gameProvider.currentSession!;
        final winner = gameProvider.getWinner();

        return GradientBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
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
                    Text(
                      winner != null ? '${winner.name} Wins!' : 'Game Over',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '${session.scores[winner?.id] ?? 0} points',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Final Scores',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ...session.players.map((player) {
                            final score = session.scores[player.id] ?? 0;
                            final isWinner = player.id == winner?.id;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: player.avatar.color,
                                    ),
                                    child: Center(
                                      child: Text(
                                        AvatarPresets.getAvatarEmoji(
                                            player.avatar),
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Text(
                                      player.name,
                                      style: TextStyle(
                                        fontWeight: isWinner
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '$score pts',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isWinner
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
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
        );
      },
    );
  }
}

class _OddOneOutScreen extends StatefulWidget {
  final GameType gameType;
  final GameMode mode;

  const _OddOneOutScreen({required this.gameType, required this.mode});

  @override
  State<_OddOneOutScreen> createState() => _OddOneOutScreenState();
}

class _OddOneOutScreenState extends State<_OddOneOutScreen> {
  int _currentRound = 1;
  late int _totalRounds;
  int? _oddPlayerIndex;
  String? _oddWord;
  String? _normalWord;
  bool _oddPlayerAssigned = false;
  final Map<int, String> _hints = {};
  final Map<int, int> _votes = {};
  final Set<int> _playersWhoVoted = {};
  final Set<int> _eliminatedPlayers = {};
  bool _hintsSubmitted = false;
  bool _roundEnded = false;
  Player? _eliminatedPlayer;
  final TextEditingController _hintController = TextEditingController();
  bool _gameEnded = false;
  int _hintSubmissionIndex = 0;
  int _voteSubmissionIndex = 0;

  static const List<List<String>> _wordPairs = [
    ['Cricket', 'Football'],
    ['Dog', 'Cat'],
    ['Chocolate', 'Ice Cream'],
    ['Summer', 'Winter'],
    ['Coffee', 'Tea'],
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<GameProvider>().currentSession!;
      _totalRounds = session.players.length - 2;
      _startRound();
    });
  }

  @override
  void dispose() {
    _hintController.dispose();
    super.dispose();
  }

  void _startRound() {
    final gameProvider = context.read<GameProvider>();
    final session = gameProvider.currentSession!;
    if (session.players.length < 2) return;

    final pairIndex = ((_currentRound - 1) % _wordPairs.length);
    final wordPair = _wordPairs[pairIndex];
    final oddWordIndex = DateTime.now().millisecondsSinceEpoch % 2;

    setState(() {
      if (!_oddPlayerAssigned) {
        _oddPlayerIndex =
            DateTime.now().millisecondsSinceEpoch % session.players.length;
        _oddWord = wordPair[oddWordIndex];
        _normalWord = wordPair[1 - oddWordIndex];
        _oddPlayerAssigned = true;
      }
      _hints.clear();
      _votes.clear();
      _playersWhoVoted.clear();
      _hintsSubmitted = false;
      _roundEnded = false;
      _eliminatedPlayer = null;
      _hintSubmissionIndex = _getNextActivePlayerIndex(0);
      _voteSubmissionIndex = _hintSubmissionIndex;
    });

    gameProvider.setCurrentPlayerIndex(_hintSubmissionIndex);
  }

  int _getNextActivePlayerIndex(int fromIndex) {
    final session = context.read<GameProvider>().currentSession!;
    for (int i = 0; i < session.players.length; i++) {
      final index = (fromIndex + i) % session.players.length;
      if (!_eliminatedPlayers.contains(index)) {
        return index;
      }
    }
    return 0;
  }

  bool _isPlayerActive(int index) {
    return !_eliminatedPlayers.contains(index);
  }

  void _submitHint() {
    if (_hintController.text.trim().isEmpty) return;
    final gameProvider = context.read<GameProvider>();
    final session = gameProvider.currentSession!;
    final activePlayersCount =
        session.players.length - _eliminatedPlayers.length;

    setState(() {
      _hints[_hintSubmissionIndex] = _hintController.text.trim();
      _hintController.clear();
    });

    if (_hints.length >= activePlayersCount) {
      final votingStartsAt = _getNextActivePlayerIndex(0);
      setState(() {
        _hintsSubmitted = true;
        _voteSubmissionIndex = votingStartsAt;
      });
      gameProvider.setCurrentPlayerIndex(votingStartsAt);
    } else {
      final nextPlayerIndex =
          _getNextActivePlayerIndex(_hintSubmissionIndex + 1);
      _hintSubmissionIndex = nextPlayerIndex;
      gameProvider.setCurrentPlayerIndex(_hintSubmissionIndex);
      setState(() {});
    }
  }

  void _castVote(int playerIndex) {
    final gameProvider = context.read<GameProvider>();
    final session = gameProvider.currentSession!;
    final currentPlayerIndex = session.currentPlayerIndex;

    if (playerIndex == currentPlayerIndex) return;
    if (_playersWhoVoted.contains(currentPlayerIndex)) return;

    setState(() {
      _votes[playerIndex] = (_votes[playerIndex] ?? 0) + 1;
      _playersWhoVoted.add(currentPlayerIndex);
    });

    final activePlayersCount =
        session.players.length - _eliminatedPlayers.length;

    if (_playersWhoVoted.length >= activePlayersCount) {
      setState(() {});
      _finishVoting();
    } else {
      final nextVoterIndex =
          _getNextActivePlayerIndex(_voteSubmissionIndex + 1);
      _voteSubmissionIndex = nextVoterIndex;
      gameProvider.setCurrentPlayerIndex(_voteSubmissionIndex);
      setState(() {});
    }
  }

  void _finishVoting() {
    final session = context.read<GameProvider>().currentSession!;

    int maxVotes = 0;
    List<int> topVoted = [];

    for (var entry in _votes.entries) {
      if (entry.value > maxVotes) {
        maxVotes = entry.value;
        topVoted = [entry.key];
      } else if (entry.value == maxVotes) {
        topVoted.add(entry.key);
      }
    }

    setState(() {
      _roundEnded = true;
      if (topVoted.length == 1) {
        _eliminatedPlayer = session.players[topVoted[0]];
        _eliminatedPlayers.add(topVoted[0]);
      }
    });
  }

  void _endGame() {
    final gameProvider = context.read<GameProvider>();
    final session = gameProvider.currentSession!;
    final eliminatedIsOddOne = _eliminatedPlayer != null &&
        session.players.indexOf(_eliminatedPlayer!) == _oddPlayerIndex;
    final oddWon = _eliminatedPlayer == null || !eliminatedIsOddOne;

    for (int i = 0; i < session.players.length; i++) {
      if (i == _oddPlayerIndex) {
        if (oddWon) gameProvider.addScore(session.players[i].id, 100);
      } else {
        if (!oddWon) gameProvider.addScore(session.players[i].id, 50);
      }
    }

    setState(() {
      _gameEnded = true;
    });
  }

  void _nextRound() {
    final session = context.read<GameProvider>().currentSession!;
    final eliminatedIsOddOne = _eliminatedPlayer != null &&
        session.players.indexOf(_eliminatedPlayer!) == _oddPlayerIndex;

    if (_currentRound >= _totalRounds || eliminatedIsOddOne) {
      _endGame();
    } else {
      setState(() => _currentRound++);
      _startRound();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        final session = gameProvider.currentSession!;
        final isOddOne = session.currentPlayerIndex == _oddPlayerIndex;
        final currentWord = isOddOne ? _oddWord : _normalWord;

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              _buildHeader(context, session, gameProvider),
              const SizedBox(height: AppSpacing.lg),
              if (_gameEnded)
                _buildGameEndResults(session,
                    oddWon: _eliminatedPlayer == null ||
                        session.players.indexOf(_eliminatedPlayer!) !=
                            _oddPlayerIndex)
              else if (!_hintsSubmitted)
                _buildHintPhase(session, currentWord ?? '')
              else if (!_roundEnded)
                _buildVotingPhase(session)
              else
                _buildRoundResultPhase(session),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHintPhase(GameSession session, String currentWord) {
    final isMyTurn = session.currentPlayerIndex == _hintSubmissionIndex;

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                  gradient: AppColors.secondaryGradient,
                  borderRadius: BorderRadius.circular(AppRadius.xl)),
              child: Column(children: [
                const Text('🎭 Your Word (Keep Secret!)',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.md),
                Text(currentWord,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold)),
                Text('Round $_currentRound/$_totalRounds',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14)),
              ]),
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildPlayerStatus(session, _hints.length, session.players.length,
                _hintSubmissionIndex),
            const SizedBox(height: AppSpacing.lg),
            if (isMyTurn)
              _buildHintInput()
            else
              _buildWaitingMessage(session.players[_hintSubmissionIndex].name),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerStatus(
      GameSession session, int submitted, int total, int currentIndex) {
    final activeCount = session.players.length - _eliminatedPlayers.length;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Players: $submitted/$activeCount',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(height: AppSpacing.sm),
        Row(
            children: session.players.asMap().entries.map((entry) {
          final index = entry.key;
          final player = entry.value;
          final isEliminated = _eliminatedPlayers.contains(index);
          final hasSubmitted = _hints.containsKey(index);
          final isCurrent = index == currentIndex;
          return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isEliminated
                      ? AppColors.error.withValues(alpha: 0.2)
                      : hasSubmitted
                          ? AppColors.success.withValues(alpha: 0.3)
                          : isCurrent
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : AppColors.surfaceLight,
                  border: isEliminated
                      ? Border.all(
                          color: AppColors.error.withValues(alpha: 0.5),
                          width: 2)
                      : hasSubmitted
                          ? Border.all(color: AppColors.success, width: 2)
                          : isCurrent
                              ? Border.all(color: AppColors.primary, width: 2)
                              : null,
                ),
                child: Text(AvatarPresets.getAvatarEmoji(player.avatar),
                    style: TextStyle(
                        fontSize: 16,
                        color: isEliminated ? Colors.white38 : null)),
              ));
        }).toList()),
      ]),
    );
  }

  Widget _buildHintInput() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Give a hint:',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(height: AppSpacing.md),
        TextField(
            controller: _hintController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
                hintText: 'Type your hint here...',
                hintStyle: TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none))),
        const SizedBox(height: AppSpacing.md),
        NeonButton(
            label: 'Submit Hint',
            icon: Icons.send_rounded,
            onPressed: _submitHint,
            fullWidth: true),
      ]),
    );
  }

  Widget _buildWaitingMessage(String playerName) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Column(children: [
        const Icon(Icons.hourglass_empty, size: 48, color: AppColors.textMuted),
        const SizedBox(height: AppSpacing.md),
        Text('Waiting for $playerName...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
      ]),
    );
  }

  Widget _buildVotingPhase(GameSession session) {
    final isMyTurn = session.currentPlayerIndex == _voteSubmissionIndex;
    final hasVoted = _playersWhoVoted.contains(session.currentPlayerIndex);

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                  gradient: AppColors.tertiaryGradient,
                  borderRadius: BorderRadius.circular(AppRadius.xl)),
              child: const Column(children: [
                Text('🔍 Who has the DIFFERENT word?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                SizedBox(height: AppSpacing.sm),
                Text('Vote for the player you think is the Odd One!',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center),
              ]),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hints:',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 14)),
                    const SizedBox(height: AppSpacing.sm),
                    ...(_hints.entries.map((e) {
                      final isEliminated = _eliminatedPlayers.contains(e.key);
                      return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(children: [
                            Text(
                                AvatarPresets.getAvatarEmoji(
                                    session.players[e.key].avatar),
                                style: TextStyle(
                                    fontSize: 20,
                                    color:
                                        isEliminated ? Colors.white38 : null)),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(
                                    isEliminated
                                        ? '${session.players[e.key].name} (Eliminated): ${e.value}'
                                        : e.value,
                                    style: TextStyle(
                                        color: isEliminated
                                            ? AppColors.textMuted
                                            : Colors.white))),
                          ]));
                    })),
                  ]),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg)),
              child: Row(
                children: session.players.asMap().entries.map((entry) {
                  final index = entry.key;
                  final player = entry.value;
                  final isEliminated = _eliminatedPlayers.contains(index);
                  final hasVotedThis = _playersWhoVoted.contains(index);
                  final isCurrent = index == _voteSubmissionIndex;
                  return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isEliminated
                              ? AppColors.error.withValues(alpha: 0.2)
                              : hasVotedThis
                                  ? AppColors.success.withValues(alpha: 0.3)
                                  : isCurrent
                                      ? AppColors.primary.withValues(alpha: 0.3)
                                      : AppColors.surfaceLight,
                          border: isEliminated
                              ? Border.all(
                                  color: AppColors.error.withValues(alpha: 0.5),
                                  width: 2)
                              : hasVotedThis
                                  ? Border.all(
                                      color: AppColors.success, width: 2)
                                  : isCurrent
                                      ? Border.all(
                                          color: AppColors.primary, width: 2)
                                      : null,
                        ),
                        child: Text(AvatarPresets.getAvatarEmoji(player.avatar),
                            style: const TextStyle(fontSize: 16)),
                      ));
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (isMyTurn && !hasVoted) ...[
              Text('Tap a player to vote:',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: AppSpacing.md),
              ...session.players.asMap().entries.map((entry) {
                final index = entry.key;
                final player = entry.value;
                final isSelf = index == session.currentPlayerIndex;
                final isEliminated = _eliminatedPlayers.contains(index);
                return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: GestureDetector(
                      onTap: isSelf || isEliminated
                          ? null
                          : () => _castVote(index),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                            color: isEliminated
                                ? AppColors.surface.withValues(alpha: 0.3)
                                : isSelf
                                    ? AppColors.surface.withValues(alpha: 0.5)
                                    : AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                                color: isEliminated
                                    ? AppColors.error.withValues(alpha: 0.5)
                                    : isSelf
                                        ? AppColors.textMuted
                                        : AppColors.surfaceLight,
                                width: 2)),
                        child: Row(children: [
                          Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isEliminated
                                      ? player.avatar.color
                                          .withValues(alpha: 0.5)
                                      : player.avatar.color),
                              child: Center(
                                  child: Text(
                                      AvatarPresets.getAvatarEmoji(
                                          player.avatar),
                                      style: TextStyle(
                                          fontSize: 24,
                                          color: isEliminated
                                              ? Colors.white38
                                              : null)))),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                              child: Text(
                                  isSelf
                                      ? '${player.name} (You)'
                                      : isEliminated
                                          ? '${player.name} (Eliminated)'
                                          : player.name,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isEliminated
                                          ? AppColors.textMuted
                                          : null))),
                          Icon(
                              isEliminated
                                  ? Icons.person_remove
                                  : isSelf
                                      ? Icons.block
                                      : Icons.how_to_vote_outlined,
                              color: AppColors.textMuted),
                        ]),
                      ),
                    ));
              }),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg)),
                child: Column(children: [
                  const Icon(Icons.hourglass_empty,
                      size: 48, color: AppColors.textMuted),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                      hasVoted
                          ? 'You voted! Waiting...'
                          : 'Waiting for ${session.players[_voteSubmissionIndex].name}...',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 16)),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoundResultPhase(GameSession session) {
    final eliminatedIsOddOne = _eliminatedPlayer != null &&
        session.players.indexOf(_eliminatedPlayer!) == _oddPlayerIndex;
    final gameEndsNow = _currentRound >= _totalRounds || eliminatedIsOddOne;

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: eliminatedIsOddOne
                    ? AppColors.secondaryGradient
                    : AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [
                  BoxShadow(
                      color: (eliminatedIsOddOne
                              ? AppColors.secondary
                              : AppColors.primary)
                          .withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 10)
                ],
              ),
              child: Column(children: [
                Text(
                    eliminatedIsOddOne
                        ? '👥 Odd One Caught!'
                        : '🎭 Round $_currentRound Complete!',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                if (_eliminatedPlayer != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                      '${_eliminatedPlayer?.name ?? "A player"} was eliminated!',
                      style: const TextStyle(color: Colors.white, fontSize: 16))
                ],
              ]),
            ),
            if (gameEndsNow) ...[
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg)),
                child: Column(children: [
                  Text('The Odd One Was:',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: AppSpacing.md),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                session.players[_oddPlayerIndex!].avatar.color),
                        child: Center(
                            child: Text(
                                AvatarPresets.getAvatarEmoji(
                                    session.players[_oddPlayerIndex!].avatar),
                                style: const TextStyle(fontSize: 32)))),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(session.players[_oddPlayerIndex!].name,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Word: $_oddWord',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14)),
                        ]),
                  ]),
                ]),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg)),
              child: Column(children: [
                Text('Vote Results:',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: AppSpacing.md),
                ...session.players.asMap().entries.map((entry) {
                  final index = entry.key;
                  final player = entry.value;
                  final votes = _votes[index] ?? 0;
                  final isOdd = index == _oddPlayerIndex;
                  return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [
                        Text(AvatarPresets.getAvatarEmoji(player.avatar),
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(player.name,
                                style: const TextStyle(color: Colors.white))),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.xs),
                            decoration: BoxDecoration(
                                color: isOdd && votes > 0
                                    ? AppColors.error
                                    : AppColors.surfaceLight,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full)),
                            child: Text('$votes vote${votes != 1 ? 's' : ''}',
                                style: TextStyle(
                                    color: isOdd && votes > 0
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.bold))),
                      ]));
                }),
              ]),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (eliminatedIsOddOne) ...[
              NeonButton(
                  label: 'Play Again',
                  icon: Icons.replay_rounded,
                  onPressed: () {
                    final gameProvider = context.read<GameProvider>();
                    final previousPlayers = gameProvider.getPreviousPlayers();
                    gameProvider.resetGame();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => GameSetupScreen(
                          mode: widget.mode,
                          onGameSelected: (gameType) {},
                          preselectedGame: widget.gameType,
                          previousPlayers: previousPlayers,
                        ),
                      ),
                    );
                  },
                  fullWidth: true),
            ] else ...[
              NeonButton(
                  label: _currentRound >= _totalRounds
                      ? 'Play Again'
                      : 'Next Round',
                  icon: _currentRound >= _totalRounds
                      ? Icons.replay_rounded
                      : Icons.arrow_forward_rounded,
                  onPressed: _currentRound >= _totalRounds
                      ? () {
                          final gameProvider = context.read<GameProvider>();
                          final previousPlayers =
                              gameProvider.getPreviousPlayers();
                          gameProvider.resetGame();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => GameSetupScreen(
                                mode: widget.mode,
                                onGameSelected: (gameType) {},
                                preselectedGame: widget.gameType,
                                previousPlayers: previousPlayers,
                              ),
                            ),
                          );
                        }
                      : _nextRound,
                  fullWidth: true),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGameEndResults(GameSession session, {required bool oddWon}) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: oddWon
                    ? AppColors.primaryGradient
                    : AppColors.secondaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [
                  BoxShadow(
                      color: (oddWon ? AppColors.primary : AppColors.secondary)
                          .withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 10)
                ],
              ),
              child: Column(children: [
                Text(oddWon ? '🎉 Odd One Wins!' : '👥 Players Win!',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.md),
                Text(
                    oddWon
                        ? 'The odd one survived!'
                        : 'The players caught the odd one!',
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
              ]),
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg)),
              child: Column(children: [
                Text('The Odd One:',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: AppSpacing.md),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: session.players[_oddPlayerIndex!].avatar.color,
                          boxShadow: [
                            BoxShadow(
                                color: session
                                    .players[_oddPlayerIndex!].avatar.color
                                    .withValues(alpha: 0.5),
                                blurRadius: 20)
                          ]),
                      child: Center(
                          child: Text(
                              AvatarPresets.getAvatarEmoji(
                                  session.players[_oddPlayerIndex!].avatar),
                              style: const TextStyle(fontSize: 36)))),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(session.players[_oddPlayerIndex!].name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('Odd: $_oddWord',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 14)),
                        Text('Normal: $_normalWord',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 14)),
                      ]),
                ]),
              ]),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rounds: $_currentRound',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 14)),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Results on leaderboard!',
                        style: TextStyle(
                            color: AppColors.tertiary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ]),
            ),
            const SizedBox(height: AppSpacing.xl),
            NeonButton(
                label: 'View Leaderboard',
                icon: Icons.leaderboard_rounded,
                onPressed: () => _showScores(context, session),
                fullWidth: true),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, GameSession session, GameProvider gameProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              icon: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(AppRadius.sm)),
                  child: const Icon(Icons.close, size: 20)),
              onPressed: () => Navigator.pop(context)),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Odd One Out',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
                RoundTransition(
                    roundNumber: _currentRound,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                          color: AppColors.tertiary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppRadius.full)),
                      child: Text('Round $_currentRound/$_totalRounds',
                          style: const TextStyle(
                              color: AppColors.tertiary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    )),
              ],
            ),
          ),
          if (_gameEnded)
            IconButton(
                icon: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(AppRadius.sm)),
                    child: const Icon(Icons.leaderboard_outlined, size: 20)),
                onPressed: () =>
                    _showScores(context, gameProvider.currentSession!)),
          IconButton(
              icon: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.sm)),
                  child: const Icon(Icons.flag_outlined,
                      size: 20, color: AppColors.error)),
              onPressed: () {
                gameProvider.endGame();
                Navigator.pop(context);
              }),
        ],
      ),
    );
  }

  void _showScores(BuildContext context, GameSession session) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => _ScoresSheet(session: session));
  }
}
