import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum AvatarType { face, animal, emoji }

class Player extends Equatable {
  final String id;
  final String name;
  final AvatarData avatar;
  final int totalGamesPlayed;
  final int totalWins;
  final int totalScore;
  final List<String> achievements;
  final DateTime createdAt;

  const Player({
    required this.id,
    required this.name,
    required this.avatar,
    this.totalGamesPlayed = 0,
    this.totalWins = 0,
    this.totalScore = 0,
    this.achievements = const [],
    required this.createdAt,
  });

  Player copyWith({
    String? id,
    String? name,
    AvatarData? avatar,
    int? totalGamesPlayed,
    int? totalWins,
    int? totalScore,
    List<String>? achievements,
    DateTime? createdAt,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalWins: totalWins ?? this.totalWins,
      totalScore: totalScore ?? this.totalScore,
      achievements: achievements ?? this.achievements,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar.toJson(),
      'total_games_played': totalGamesPlayed,
      'total_wins': totalWins,
      'total_score': totalScore,
      'achievements': achievements,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: AvatarData.fromJson(json['avatar'] as Map<String, dynamic>),
      totalGamesPlayed: json['total_games_played'] as int? ?? 0,
      totalWins: json['total_wins'] as int? ?? 0,
      totalScore: json['total_score'] as int? ?? 0,
      achievements: List<String>.from(json['achievements'] ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, name, avatar, totalGamesPlayed, totalWins, totalScore, achievements, createdAt];
}

class AvatarData extends Equatable {
  final AvatarType type;
  final int index;
  final Color color;

  const AvatarData({
    required this.type,
    required this.index,
    required this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'index': index,
      'color': color.value,
    };
  }

  factory AvatarData.fromJson(Map<String, dynamic> json) {
    return AvatarData(
      type: AvatarType.values.firstWhere((e) => e.name == json['type']),
      index: json['index'] as int,
      color: Color(json['color'] as int),
    );
  }

  @override
  List<Object?> get props => [type, index, color];
}

class AvatarPresets {
  static const List<String> faces = ['😊', '😎', '🤪', '😈', '🥳', '🤩', '😴', '🤗'];
  static const List<String> animals = ['🐶', '🐱', '🐼', '🦊', '🦁', '🐸', '🐰', '🐻'];
  static const List<String> emojis = ['🎮', '🎯', '🎨', '🎭', '🎪', '🎢', '🎡', '🎠'];

  static const List<Color> colors = [
    Color(0xFFEF4444),
    Color(0xFFF97316),
    Color(0xFFF59E0B),
    Color(0xFF84CC16),
    Color(0xFF22C55E),
    Color(0xFF14B8A6),
    Color(0xFF06B6D4),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
  ];

  static IconData getAvatarIcon(AvatarData avatar) {
    final icons = [
      Icons.face, Icons.sentiment_very_satisfied, Icons.mood, Icons.emoji_emotions,
      Icons.face_2, Icons.face_3, Icons.face_4, Icons.face_5, Icons.face_6,
    ];
    return icons[avatar.index % icons.length];
  }

  static String getAvatarEmoji(AvatarData avatar) {
    switch (avatar.type) {
      case AvatarType.face:
        return faces[avatar.index % faces.length];
      case AvatarType.animal:
        return animals[avatar.index % animals.length];
      case AvatarType.emoji:
        return emojis[avatar.index % emojis.length];
    }
  }
}
