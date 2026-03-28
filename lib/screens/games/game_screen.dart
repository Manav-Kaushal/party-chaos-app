import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../models/game_session.dart';
import '../../models/player.dart';
import '../../providers/game_provider.dart';
import '../../widgets/player_avatar.dart';
import '../../widgets/game_card.dart';

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
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (gameProvider.isGameOver) {
          return _GameOverScreen(gameType: gameType);
        }

        return switch (gameType) {
          GameType.truthOrDare => const _TruthOrDareScreen(),
          GameType.wouldYouRather => const _WouldYouRatherScreen(),
          GameType.neverHaveIEver => const _NeverHaveIEverScreen(),
          GameType.quickFireTrivia => const _TriviaScreen(),
        };
      },
    );
  }
}

class _TruthOrDareScreen extends StatefulWidget {
  const _TruthOrDareScreen();

  @override
  State<_TruthOrDareScreen> createState() => _TruthOrDareScreenState();
}

class _TruthOrDareScreenState extends State<_TruthOrDareScreen> {
  bool _showQuestion = false;
  bool _selectedTruth = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        final session = gameProvider.currentSession!;
        final currentPlayer = session.currentPlayer;

        return Scaffold(
          appBar: AppBar(
            title: Text('Round ${session.round}/${session.totalRounds}'),
            actions: [
              TextButton(
                onPressed: () => _showScores(context, session),
                child: const Text('Scores'),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  PlayerAvatar(
                    player: currentPlayer,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentPlayer.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (!_showQuestion) ...[
                    Text(
                      '${currentPlayer.name}, what will you choose?',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: _ChoiceButton(
                            label: 'Truth',
                            icon: Icons.psychology,
                            color: AppColors.success,
                            onTap: () {
                              setState(() {
                                _selectedTruth = true;
                                _showQuestion = true;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _ChoiceButton(
                            label: 'Dare',
                            icon: Icons.flash_on,
                            color: AppColors.error,
                            onTap: () {
                              setState(() {
                                _selectedTruth = false;
                                _showQuestion = true;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    GameCard(
                      child: Column(
                        children: [
                          Icon(
                            _selectedTruth ? Icons.psychology : Icons.flash_on,
                            size: 48,
                            color: _selectedTruth ? AppColors.success : AppColors.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedTruth ? gameProvider.currentTruth : gameProvider.currentDare,
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _showQuestion = false);
                        if (_selectedTruth) {
                          gameProvider.selectTruth();
                        } else {
                          gameProvider.selectDare();
                        }
                        gameProvider.nextPlayer();
                      },
                      child: const Text('Next Player'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showScores(BuildContext context, GameSession session) {
    showModalBottomSheet(
      context: context,
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

        return Scaffold(
          appBar: AppBar(
            title: Text('Round ${session.round}/${session.totalRounds}'),
            actions: [
              TextButton(
                onPressed: () => _showScores(context, session),
                child: const Text('Scores'),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  PlayerAvatar(
                    player: currentPlayer,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentPlayer.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  GameCard(
                    child: Text(
                      gameProvider.currentQuestion,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _OptionButton(
                          label: options[0],
                          onTap: () => _handleChoice(context, gameProvider, 0),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _OptionButton(
                          label: options[1],
                          onTap: () => _handleChoice(context, gameProvider, 1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleChoice(BuildContext context, GameProvider provider, int choice) {
    provider.addScore(provider.currentSession!.currentPlayer.id, 10);
    provider.nextWyrQuestion();
  }

  void _showScores(BuildContext context, GameSession session) {
    showModalBottomSheet(
      context: context,
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

        return Scaffold(
          appBar: AppBar(
            title: Text('Round ${session.round}/${session.totalRounds}'),
            actions: [
              TextButton(
                onPressed: () => _showScores(context, session),
                child: const Text('Scores'),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Never Have I Ever...',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GameCard(
                    child: Text(
                      gameProvider.currentQuestion,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'If you HAVE done this, raise your hand!',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: session.players.length,
                      itemBuilder: (context, index) {
                        final player = session.players[index];
                        final hasDone = choices[index] ?? false;
                        return GestureDetector(
                          onTap: () => gameProvider.setNhieChoice(index, !hasDone),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: hasDone ? AppColors.success.withOpacity(0.2) : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: hasDone ? AppColors.success : AppColors.surfaceLight,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AvatarPresets.getAvatarEmoji(player.avatar),
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  player.name,
                                  style: TextStyle(
                                    fontWeight: hasDone ? FontWeight.bold : FontWeight.normal,
                                    color: hasDone ? AppColors.success : null,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => gameProvider.nextNhieStatement(),
                    child: const Text('Next Statement'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showScores(BuildContext context, GameSession session) {
    showModalBottomSheet(
      context: context,
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

        return Scaffold(
          appBar: AppBar(
            title: Text('Round ${session.round}/${session.totalRounds}'),
            actions: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: gameProvider.timeRemaining <= 5
                      ? AppColors.error
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${gameProvider.timeRemaining}s',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => _showScores(context, session),
                child: const Text('Scores'),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  PlayerAvatar(
                    player: currentPlayer,
                    size: 60,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentPlayer.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.tertiary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      question.category,
                      style: TextStyle(
                        color: AppColors.tertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GameCard(
                    child: Text(
                      question.question,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(question.options.length, (index) {
                    final isSelected = gameProvider.selectedAnswer == index;
                    final isCorrect = index == question.correctIndex;
                    final showResult = gameProvider.answered;

                    Color? bgColor;
                    if (showResult) {
                      if (isCorrect) {
                        bgColor = AppColors.success.withOpacity(0.3);
                      } else if (isSelected && !isCorrect) {
                        bgColor = AppColors.error.withOpacity(0.3);
                      }
                    } else if (isSelected) {
                      bgColor = AppColors.primary.withOpacity(0.3);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: showResult
                            ? null
                            : () => gameProvider.selectAnswer(index),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: bgColor ?? AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
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
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  question.options[index],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              if (showResult && isCorrect)
                                const Icon(Icons.check_circle, color: AppColors.success),
                              if (showResult && isSelected && !isCorrect)
                                const Icon(Icons.cancel, color: AppColors.error),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const Spacer(),
                  if (!gameProvider.answered)
                    ElevatedButton(
                      onPressed: gameProvider.selectedAnswer >= 0
                          ? () {
                              gameProvider.submitTriviaAnswer();
                              _timer?.cancel();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: const Text('Submit Answer'),
                    )
                  else
                    ElevatedButton(
                      onPressed: () {
                        gameProvider.nextTriviaQuestion();
                        _startTimer();
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: const Text('Next Question'),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showScores(BuildContext context, GameSession session) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ScoresSheet(session: session),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OptionButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
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
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Leaderboard',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...sortedPlayers.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            final score = session.scores[player.id] ?? 0;
            final isLeading = index == 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isLeading
                    ? AppColors.tertiary.withOpacity(0.2)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: isLeading
                    ? Border.all(color: AppColors.tertiary, width: 2)
                    : null,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      '#${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isLeading ? AppColors.tertiary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: player.avatar.color,
                    child: Text(
                      AvatarPresets.getAvatarEmoji(player.avatar),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      player.name,
                      style: TextStyle(
                        fontWeight: isLeading ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Text(
                    '$score pts',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isLeading ? AppColors.tertiary : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),
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

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '🎉',
                  style: TextStyle(fontSize: 80),
                ),
                const SizedBox(height: 24),
                Text(
                  'Game Over!',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                if (winner != null) ...[
                  Text(
                    'Winner',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: winner.avatar.color,
                    child: Text(
                      AvatarPresets.getAvatarEmoji(winner.avatar),
                      style: const TextStyle(fontSize: 50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    winner.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${session.scores[winner.id] ?? 0} points',
                    style: TextStyle(
                      color: AppColors.tertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {
                    gameProvider.resetGame();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 56),
                  ),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
