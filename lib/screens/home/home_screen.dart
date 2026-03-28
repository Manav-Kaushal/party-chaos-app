import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../../core/constants/app_theme.dart';
import '../../models/player.dart';
import '../../models/game_session.dart';
import '../lobby/game_setup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              _buildQuickPlay(context),
              const SizedBox(height: 32),
              _buildGamesGrid(context),
              const SizedBox(height: 32),
              _buildLeaderboardPreview(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, _) {
        final player = playerProvider.currentPlayer;
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    player?.name ?? 'Player',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (player != null)
              GestureDetector(
                onTap: () {
                  DefaultTabController.of(context).animateTo(2);
                },
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: player.avatar.color,
                  child: Text(
                    AvatarPresets.getAvatarEmoji(player.avatar),
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildQuickPlay(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ready to Play?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a quick game with your friends!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showGameModeDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
            ),
            child: const Text('Start Game'),
          ),
        ],
      ),
    );
  }

  void _showGameModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Game Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('Local Multiplayer'),
              subtitle: const Text('Play together on one device'),
              onTap: () {
                Navigator.pop(context);
                _selectGame(context, GameMode.local);
              },
            ),
            ListTile(
              leading: const Icon(Icons.wifi),
              title: const Text('Online Multiplayer'),
              subtitle: const Text('Play with friends remotely'),
              onTap: () {
                Navigator.pop(context);
                _selectGame(context, GameMode.online);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectGame(BuildContext context, GameMode mode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameSetupScreen(
          mode: mode,
          onGameSelected: (type) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => _getGameScreen(type, mode),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _getGameScreen(GameType type, GameMode mode) {
    return GameSetupScreen(
      mode: mode,
      onGameSelected: (selectedType) {},
    );
  }

  Widget _buildGamesGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Party Games',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: GameType.values.map((type) {
            return _GameCard(
              type: type,
              onTap: () => _showGameModeDialog(context),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLeaderboardPreview(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Leaderboard',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      DefaultTabController.of(context).animateTo(2);
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (playerProvider.leaderboard.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No scores yet. Play a game!'),
                  ),
                )
              else
                ...playerProvider.leaderboard.take(3).map((player) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
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
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          '${player.totalScore} pts',
                          style: TextStyle(
                            color: AppColors.tertiary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

class _GameCard extends StatelessWidget {
  final GameType type;
  final VoidCallback onTap;

  const _GameCard({required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceLight, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              type.icon,
              style: const TextStyle(fontSize: 36),
            ),
            const SizedBox(height: 8),
            Text(
              type.displayName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
