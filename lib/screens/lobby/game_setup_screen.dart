import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../models/game_session.dart';
import '../../models/player.dart';
import '../../providers/player_provider.dart';
import '../../providers/game_provider.dart';
import '../games/game_screen.dart';
import '../../widgets/common_widgets.dart';

class GameSetupScreen extends StatefulWidget {
  final GameMode mode;
  final Function(GameType) onGameSelected;
  final GameType? preselectedGame;
  final List<Player>? previousPlayers;

  const GameSetupScreen({
    super.key,
    required this.mode,
    required this.onGameSelected,
    this.preselectedGame,
    this.previousPlayers,
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
  void initState() {
    super.initState();
    if (widget.preselectedGame != null) {
      _selectedGame = widget.preselectedGame;
    }
    if (widget.previousPlayers != null) {
      for (var player in widget.previousPlayers!) {
        final playerColor = player.avatar.color;
        final colorIndex = AvatarPresets.colors
            .indexWhere((c) => c.value == playerColor.value);
        _players.add(PlayerSetup(
          name: player.name,
          avatarIndex: player.avatar.index,
          colorIndex: colorIndex >= 0 ? colorIndex : 0,
        ));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
              widget.mode == GameMode.local ? 'Local Game' : 'Online Game'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_selectedGame == null) ...[
                _buildGameSelection(),
              ] else ...[
                _buildPlayerSetup(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select a Game',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Choose the party game you want to play',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...GameType.values.map((type) => _buildGameOption(type)),
      ],
    );
  }

  Color _getGameColor(GameType type) {
    switch (type) {
      case GameType.truthOrDare:
        return AppColors.success;
      case GameType.wouldYouRather:
        return AppColors.secondary;
      case GameType.neverHaveIEver:
        return AppColors.primary;
      case GameType.quickFireTrivia:
        return AppColors.tertiary;
      case GameType.oddOneOut:
        return AppColors.tertiary;
    }
  }

  Widget _buildGameOption(GameType type) {
    final isSelected = _selectedGame == type;
    final color = _getGameColor(type);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GestureDetector(
        onTap: () => setState(() => _selectedGame = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.1)
                    ],
                  )
                : null,
            color: isSelected ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isSelected ? color : AppColors.surfaceLight,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: Text(
                    type.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
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
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerSetup() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _selectedGame = null),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedGame?.displayName ?? 'Setup',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_players.length} of 4+ players added',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (_players.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    gradient:
                        _players.length >= 4 ? AppColors.primaryGradient : null,
                    color: _players.length >= 4 ? null : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _players.length >= 4
                            ? Icons.check_circle_rounded
                            : Icons.hourglass_empty_rounded,
                        size: 16,
                        color: _players.length >= 4
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _players.length >= 4
                            ? 'Ready!'
                            : 'Need ${4 - _players.length} more',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _players.length >= 4
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          if (_players.isNotEmpty) ...[
            const Text(
              'Players',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _players.length,
                itemBuilder: (context, index) {
                  final player = _players[index];
                  return Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: AppSpacing.md),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AvatarPresets.colors[player.colorIndex],
                            boxShadow: [
                              BoxShadow(
                                color: AvatarPresets.colors[player.colorIndex]
                                    .withValues(alpha: 0.4),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              AvatarPresets.faces[player.avatarIndex],
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          player.name.length > 6
                              ? '${player.name.substring(0, 6)}...'
                              : player.name,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          _buildPlayerPreviewCard(),
        ],
      ),
    );
  }

  Widget _buildPlayerPreviewCard() {
    final selectedColor = AvatarPresets.colors[_selectedColorIndex];
    final selectedAvatar = AvatarPresets.faces[_selectedAvatarIndex];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            selectedColor.withValues(alpha: 0.15),
            selectedColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: selectedColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: selectedColor.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  selectedColor,
                  selectedColor.withValues(alpha: 0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: selectedColor.withValues(alpha: 0.5),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(
                selectedAvatar,
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'Player name',
              hintStyle: TextStyle(
                color: AppColors.textMuted.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: BorderSide(
                  color: selectedColor,
                  width: 2,
                ),
              ),
            ),
            onSubmitted: (_) => _addPlayer(),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Text(
                'Avatar',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${_selectedAvatarIndex + 1}/8',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 8,
              itemBuilder: (context, index) {
                final isSelected = _selectedAvatarIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAvatarIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? selectedColor.withValues(alpha: 0.2)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: isSelected ? selectedColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        AvatarPresets.faces[index],
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Text(
                'Color',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${_selectedColorIndex + 1}/${AvatarPresets.colors.length}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.start,
            children: List.generate(AvatarPresets.colors.length, (index) {
              final isSelected = _selectedColorIndex == index;
              final color = AvatarPresets.colors[index];
              return GestureDetector(
                onTap: () => setState(() => _selectedColorIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.6),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _nameController.text.trim().isNotEmpty ? _addPlayer : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.surfaceLight,
                disabledForegroundColor: AppColors.textMuted,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add_rounded),
                  const SizedBox(width: 8),
                  Text(
                    _players.isEmpty ? 'Add First Player' : 'Add Player',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_players.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            if (_players.length >= 4)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded),
                      const SizedBox(width: 8),
                      Text(
                        'Start Game (${_players.length} players)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_players.length < 8)
              TextButton(
                onPressed: () {
                  _nameController.clear();
                  setState(() {});
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline_rounded,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Add Another Player',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  void _addPlayer() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a name'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
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
            GestureDetector(
              onTap: () => setState(() => _players.clear()),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Players (${_players.length})',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _players.length >= 4
                        ? 'Ready to play!'
                        : 'Add ${4 - _players.length} more players',
                    style: TextStyle(
                      color: _players.length >= 4
                          ? AppColors.success
                          : AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        ...List.generate(_players.length, (index) {
          final player = _players[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.surfaceLight,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AvatarPresets.colors[player.colorIndex],
                      boxShadow: [
                        BoxShadow(
                          color: AvatarPresets.colors[player.colorIndex]
                              .withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        AvatarPresets.faces[player.avatarIndex],
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      player.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
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
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      'P${index + 1}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (index > 0 && _players.length > 2)
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Icon(
                          Icons.remove_circle_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                      ),
                      onPressed: () => setState(() => _players.removeAt(index)),
                    ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.md),
        if (_players.length < 8)
          OutlinedNeonButton(
            label: 'Add More Players',
            icon: Icons.person_add_rounded,
            onPressed: () => setState(() {}),
            fullWidth: true,
          ),
        if (_players.length >= 4)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: NeonButton(
              label: 'Start Game',
              icon: Icons.play_arrow_rounded,
              onPressed: _startGame,
              fullWidth: true,
            ),
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
