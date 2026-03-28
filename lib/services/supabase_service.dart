import 'package:supabase/supabase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';
import 'dart:convert';

class SupabaseService {
  static SupabaseClient? _client;
  static const String _playerKey = 'current_player';

  static Future<void> initialize(String url, String anonKey) async {
    _client = SupabaseClient(url, anonKey);
  }

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  static bool get isInitialized => _client != null;

  static Future<Player?> getCurrentPlayer() async {
    final prefs = await SharedPreferences.getInstance();
    final playerJson = prefs.getString(_playerKey);
    if (playerJson != null) {
      return Player.fromJson(json.decode(playerJson));
    }
    return null;
  }

  static Future<void> saveCurrentPlayer(Player player) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playerKey, json.encode(player.toJson()));
  }

  static Future<void> clearCurrentPlayer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playerKey);
  }

  static Future<List<Player>> getLeaderboard({int limit = 10}) async {
    try {
      final response = await client
          .from('players')
          .select()
          .order('total_score', ascending: false)
          .limit(limit);
      
      return (response as List)
          .map((p) => Player.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> updatePlayerStats({
    required String playerId,
    required int gamesPlayed,
    required int wins,
    required int score,
  }) async {
    try {
      await client.from('players').upsert({
        'id': playerId,
        'total_games_played': gamesPlayed,
        'total_wins': wins,
        'total_score': score,
      });
    } catch (e) {
      // Silently fail for offline mode
    }
  }

  static Future<bool> isOnline() async {
    try {
      await client.from('players').select('id').limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }
}
