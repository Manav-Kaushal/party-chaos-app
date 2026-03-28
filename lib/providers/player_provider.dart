import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';
import '../services/supabase_service.dart';

class PlayerProvider extends ChangeNotifier {
  Player? _currentPlayer;
  List<Player> _leaderboard = [];
  bool _isLoading = false;

  Player? get currentPlayer => _currentPlayer;
  List<Player> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  bool get hasPlayer => _currentPlayer != null;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _currentPlayer = await SupabaseService.getCurrentPlayer();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createPlayer({
    required String name,
    required AvatarData avatar,
  }) async {
    _isLoading = true;
    notifyListeners();

    _currentPlayer = Player(
      id: const Uuid().v4(),
      name: name,
      avatar: avatar,
      createdAt: DateTime.now(),
    );

    await SupabaseService.saveCurrentPlayer(_currentPlayer!);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updatePlayer({
    String? name,
    AvatarData? avatar,
  }) async {
    if (_currentPlayer == null) return;

    _currentPlayer = _currentPlayer!.copyWith(
      name: name ?? _currentPlayer!.name,
      avatar: avatar ?? _currentPlayer!.avatar,
    );

    await SupabaseService.saveCurrentPlayer(_currentPlayer!);
    notifyListeners();
  }

  Future<void> updateStats({
    required int gamesPlayed,
    required int wins,
    required int score,
    List<String>? achievements,
  }) async {
    if (_currentPlayer == null) return;

    _currentPlayer = _currentPlayer!.copyWith(
      totalGamesPlayed: gamesPlayed,
      totalWins: wins,
      totalScore: score,
      achievements: achievements ?? _currentPlayer!.achievements,
    );

    await SupabaseService.saveCurrentPlayer(_currentPlayer!);
    await SupabaseService.updatePlayerStats(
      playerId: _currentPlayer!.id,
      gamesPlayed: gamesPlayed,
      wins: wins,
      score: score,
    );
    notifyListeners();
  }

  Future<void> addGamePlayed() async {
    if (_currentPlayer == null) return;
    await updateStats(
      gamesPlayed: _currentPlayer!.totalGamesPlayed + 1,
      wins: _currentPlayer!.totalWins,
      score: _currentPlayer!.totalScore,
    );
  }

  Future<void> addWin(int score) async {
    if (_currentPlayer == null) return;
    await updateStats(
      gamesPlayed: _currentPlayer!.totalGamesPlayed,
      wins: _currentPlayer!.totalWins + 1,
      score: _currentPlayer!.totalScore + score,
    );
  }

  Future<void> addScore(int score) async {
    if (_currentPlayer == null) return;
    await updateStats(
      gamesPlayed: _currentPlayer!.totalGamesPlayed,
      wins: _currentPlayer!.totalWins,
      score: _currentPlayer!.totalScore + score,
    );
  }

  Future<void> refreshLeaderboard() async {
    _leaderboard = await SupabaseService.getLeaderboard();
    notifyListeners();
  }

  Future<void> logout() async {
    await SupabaseService.clearCurrentPlayer();
    _currentPlayer = null;
    notifyListeners();
  }
}
