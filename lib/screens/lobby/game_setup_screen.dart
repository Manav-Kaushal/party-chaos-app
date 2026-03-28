import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../models/game_session.dart';
import '../../models/player.dart';
import '../../providers/player_provider.dart';
import '../../providers/game_provider.dart';
import '../games/game_screen.dart';

class GameSetupScreen extends StatefulWidget {
  final GameMode mode;
  final Function(GameType) onGameSelected;

  const GameSetupScreen({
    super.key,
    required this.mode,
    required this.onGameSelected,
  });

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  GameType? _selectedGame;
  final List<PlayerSetup> _players = [];
  final TextEditingController _nameController = TextEditingController();
  int _selectedAvatarIndex = 0;
  int _selectedColorIndex = 0;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode == GameMode.local ? 'Local Game' : 'Online Game'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedGame == null) ...[
              _buildGameSelection(),
            ] else if (_players.isEmpty) ...[
              _buildPlayerSetup(),
            ] else ...[
              _buildPlayersList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGameSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select a Game',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        ...GameType.values.map((type) => _buildGameOption(type)),
      ],
    );
  }

  Widget _buildGameOption(GameType type) {
    final isSelected = _selectedGame == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedGame = type),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceLight,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(
              type.icon,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type.description,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerSetup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => _selectedGame = null),
            ),
            Text(
              'Add Players',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Player ${_players.length + 1}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Enter player name',
          ),
        ),
        const SizedBox(height: 24),
        const Text('Select Avatar'),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 8,
            itemBuilder: (context, index) {
              final isSelected = _selectedAvatarIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedAvatarIndex = index),
                child: Container(
                  width: 56,
                  height: 56,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      AvatarPresets.faces[index],
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        const Text('Select Color'),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AvatarPresets.colors.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedColorIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedColorIndex = index),
                child: Container(
                  width: 46,
                  height: 46,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AvatarPresets.colors[index],
                    borderRadius: BorderRadius.circular(23),
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _addPlayer,
          child: const Text('Add Player'),
        ),
        const SizedBox(height: 16),
        if (_players.length >= 4)
          TextButton(
            onPressed: _startGame,
            child: Text('Start with ${_players.length} players'),
          ),
      ],
    );
  }

  void _addPlayer() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    final player = PlayerSetup(
      name: _nameController.text.trim(),
      avatarIndex: _selectedAvatarIndex,
      colorIndex: _selectedColorIndex,
    );

    setState(() {
      _players.add(player);
      _nameController.clear();
      _selectedAvatarIndex = (_selectedAvatarIndex + 1) % 8;
    });
  }

  Widget _buildPlayersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => _players.clear()),
            ),
            Text(
              'Players (${_players.length})',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ...List.generate(_players.length, (index) {
          final player = _players[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AvatarPresets.colors[player.colorIndex],
                  child: Text(
                    AvatarPresets.faces[player.avatarIndex],
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    player.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                if (index > 0)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                    onPressed: () => setState(() => _players.removeAt(index)),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        if (_players.length < 8)
          OutlinedButton.icon(
            onPressed: () => setState(() => _players.clear()),
            icon: const Icon(Icons.add),
            label: const Text('Add More Players'),
          ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _players.length >= 4 ? _startGame : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Start Game'),
        ),
      ],
    );
  }

  void _startGame() {
    if (_selectedGame == null || _players.length < 4) return;

    final gameProvider = context.read<GameProvider>();
    final playerProvider = context.read<PlayerProvider>();

    final playerModels = _players.asMap().entries.map((entry) {
      final setup = entry.value;
      return Player(
        id: 'player_${entry.key}',
        name: setup.name,
        avatar: AvatarData(
          type: AvatarType.face,
          index: setup.avatarIndex,
          color: AvatarPresets.colors[setup.colorIndex],
        ),
        createdAt: DateTime.now(),
      );
    }).toList();

    if (playerProvider.currentPlayer != null) {
      final currentPlayerIndex = playerModels.indexWhere(
        (p) => p.name == playerProvider.currentPlayer!.name,
      );
      if (currentPlayerIndex == -1) {
        playerModels.insert(0, playerProvider.currentPlayer!);
      }
    }

    gameProvider.createSession(
      type: _selectedGame!,
      mode: widget.mode,
      players: playerModels,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          gameType: _selectedGame!,
          mode: widget.mode,
        ),
      ),
    );
  }
}

class PlayerSetup {
  final String name;
  final int avatarIndex;
  final int colorIndex;

  PlayerSetup({
    required this.name,
    required this.avatarIndex,
    required this.colorIndex,
  });
}
