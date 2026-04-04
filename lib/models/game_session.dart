import 'package:equatable/equatable.dart';
import 'player.dart';

enum GameType {
  truthOrDare,
  wouldYouRather,
  neverHaveIEver,
  quickFireTrivia,
  oddOneOut
}

enum GameMode { local, online }

enum GameStatus { waiting, playing, finished }

class GameSession extends Equatable {
  final String id;
  final GameType type;
  final GameMode mode;
  final GameStatus status;
  final List<Player> players;
  final int currentPlayerIndex;
  final Map<String, int> scores;
  final int round;
  final int totalRounds;
  final DateTime createdAt;

  const GameSession({
    required this.id,
    required this.type,
    required this.mode,
    this.status = GameStatus.waiting,
    required this.players,
    this.currentPlayerIndex = 0,
    this.scores = const {},
    this.round = 1,
    this.totalRounds = 10,
    required this.createdAt,
  });

  Player get currentPlayer => players[currentPlayerIndex];

  GameSession copyWith({
    String? id,
    GameType? type,
    GameMode? mode,
    GameStatus? status,
    List<Player>? players,
    int? currentPlayerIndex,
    Map<String, int>? scores,
    int? round,
    int? totalRounds,
    DateTime? createdAt,
  }) {
    return GameSession(
      id: id ?? this.id,
      type: type ?? this.type,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      players: players ?? this.players,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      scores: scores ?? this.scores,
      round: round ?? this.round,
      totalRounds: totalRounds ?? this.totalRounds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'mode': mode.name,
      'status': status.name,
      'players': players.map((p) => p.toJson()).toList(),
      'current_player_index': currentPlayerIndex,
      'scores': scores,
      'round': round,
      'total_rounds': totalRounds,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      id: json['id'] as String,
      type: GameType.values.firstWhere((e) => e.name == json['type']),
      mode: GameMode.values.firstWhere((e) => e.name == json['mode']),
      status: GameStatus.values.firstWhere((e) => e.name == json['status']),
      players: (json['players'] as List)
          .map((p) => Player.fromJson(p as Map<String, dynamic>))
          .toList(),
      currentPlayerIndex: json['current_player_index'] as int? ?? 0,
      scores: Map<String, int>.from(json['scores'] ?? {}),
      round: json['round'] as int? ?? 1,
      totalRounds: json['total_rounds'] as int? ?? 10,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        mode,
        status,
        players,
        currentPlayerIndex,
        scores,
        round,
        totalRounds,
        createdAt
      ];
}

extension GameTypeExtension on GameType {
  String get displayName {
    switch (this) {
      case GameType.truthOrDare:
        return 'Truth or Dare';
      case GameType.wouldYouRather:
        return 'Would You Rather';
      case GameType.neverHaveIEver:
        return 'Never Have I Ever';
      case GameType.quickFireTrivia:
        return 'Quick Fire Trivia';
      case GameType.oddOneOut:
        return 'Odd One Out';
    }
  }

  String get description {
    switch (this) {
      case GameType.truthOrDare:
        return 'Answer truthfully or complete a dare!';
      case GameType.wouldYouRather:
        return 'Choose between two impossible options!';
      case GameType.neverHaveIEver:
        return 'Share what you have or haven\'t done!';
      case GameType.quickFireTrivia:
        return 'Answer questions fast to win!';
      case GameType.oddOneOut:
        return 'Find the odd one or hide as the odd one!';
    }
  }

  String get icon {
    switch (this) {
      case GameType.truthOrDare:
        return '🎭';
      case GameType.wouldYouRather:
        return '🤔';
      case GameType.neverHaveIEver:
        return '🙈';
      case GameType.quickFireTrivia:
        return '🧠';
      case GameType.oddOneOut:
        return '🔍';
    }
  }
}
