import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/game_session.dart';
import '../models/player.dart';
import '../data/game_content.dart';
import '../data/trivia_questions.dart';

class GameProvider extends ChangeNotifier {
  GameSession? _currentSession;
  final Random _random = Random();

  // Truth or Dare specific
  int _truthIndex = 0;
  int _dareIndex = 0;
  List<String> _truths = [];
  List<String> _dares = [];

  // Would You Rather specific
  int _wyrIndex = 0;
  List<Map<String, String>> _wyrQuestions = [];

  // Never Have I Ever specific
  int _nhieIndex = 0;
  List<String> _nhieStatements = [];
  Map<int, bool> _nhiePlayerChoices = {};

  // Trivia specific
  int _triviaIndex = 0;
  List<TriviaQuestion> _triviaQuestions = [];
  int? _selectedAnswer;
  bool _answered = false;
  int _timeRemaining = 15;

  GameSession? get currentSession => _currentSession;
  int get selectedAnswer => _selectedAnswer ?? -1;
  bool get answered => _answered;
  int get timeRemaining => _timeRemaining;

  String get currentQuestion {
    switch (_currentSession?.type) {
      case GameType.truthOrDare:
        return '';
      case GameType.wouldYouRather:
        if (_wyrQuestions.isEmpty || _wyrIndex >= _wyrQuestions.length)
          return '';
        return _wyrQuestions[_wyrIndex]['question']!;
      case GameType.neverHaveIEver:
        if (_nhieStatements.isEmpty || _nhieIndex >= _nhieStatements.length)
          return '';
        return _nhieStatements[_nhieIndex];
      case GameType.quickFireTrivia:
        if (_triviaQuestions.isEmpty || _triviaIndex >= _triviaQuestions.length)
          return '';
        return _triviaQuestions[_triviaIndex].question;
      default:
        return '';
    }
  }

  List<String> get currentOptions {
    switch (_currentSession?.type) {
      case GameType.truthOrDare:
        return ['Truth', 'Dare'];
      case GameType.wouldYouRather:
        if (_wyrQuestions.isEmpty || _wyrIndex >= _wyrQuestions.length)
          return ['', ''];
        return [
          _wyrQuestions[_wyrIndex]['option1']!,
          _wyrQuestions[_wyrIndex]['option2']!
        ];
      case GameType.quickFireTrivia:
        if (_triviaQuestions.isEmpty || _triviaIndex >= _triviaQuestions.length)
          return [];
        return _triviaQuestions[_triviaIndex].options;
      default:
        return [];
    }
  }

  String get currentTruth => _truths.isNotEmpty && _truthIndex < _truths.length
      ? _truths[_truthIndex]
      : '';
  String get currentDare =>
      _dares.isNotEmpty && _dareIndex < _dares.length ? _dares[_dareIndex] : '';

  TriviaQuestion? get currentTriviaQuestion =>
      _triviaQuestions.isNotEmpty && _triviaIndex < _triviaQuestions.length
          ? _triviaQuestions[_triviaIndex]
          : null;

  Map<int, bool> get nhiePlayerChoices => _nhiePlayerChoices;

  void createSession({
    required GameType type,
    required GameMode mode,
    required List<Player> players,
    int totalRounds = 10,
  }) {
    _currentSession = GameSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      mode: mode,
      players: players,
      totalRounds: totalRounds,
      createdAt: DateTime.now(),
      scores: {for (var p in players) p.id: 0},
    );

    _shuffleGameContent();
    notifyListeners();
  }

  void _shuffleGameContent() {
    switch (_currentSession?.type) {
      case GameType.truthOrDare:
        _truths = List.from(TruthOrDareData.truths)..shuffle(_random);
        _dares = List.from(TruthOrDareData.dares)..shuffle(_random);
        _truthIndex = 0;
        _dareIndex = 0;
        break;
      case GameType.wouldYouRather:
        _wyrQuestions = List.from(WouldYouRatherData.questions)
          ..shuffle(_random);
        _wyrIndex = 0;
        break;
      case GameType.neverHaveIEver:
        _nhieStatements = List.from(NeverHaveIEverData.statements)
          ..shuffle(_random);
        _nhieIndex = 0;
        _nhiePlayerChoices = {};
        break;
      case GameType.quickFireTrivia:
        _triviaQuestions = List.from(TriviaData.questions)..shuffle(_random);
        _triviaIndex = 0;
        _selectedAnswer = null;
        _answered = false;
        _timeRemaining = 15;
        break;
      default:
        break;
    }
  }

  void nextPlayer({bool incrementRound = true}) {
    if (_currentSession == null) return;

    final nextIndex = (_currentSession!.currentPlayerIndex + 1) %
        _currentSession!.players.length;
    int nextRound = _currentSession!.round;

    if (incrementRound && nextIndex == 0) {
      nextRound++;
    }

    if (incrementRound && nextRound > _currentSession!.totalRounds) {
      endGame();
      return;
    }

    _currentSession = _currentSession!.copyWith(
      currentPlayerIndex: nextIndex,
      round: nextRound,
    );

    notifyListeners();
  }

  void setCurrentPlayerIndex(int index) {
    if (_currentSession == null) return;
    _currentSession = _currentSession!.copyWith(currentPlayerIndex: index);
    notifyListeners();
  }

  void addScore(String playerId, int points) {
    if (_currentSession == null) return;

    final newScores = Map<String, int>.from(_currentSession!.scores);
    newScores[playerId] = (newScores[playerId] ?? 0) + points;

    _currentSession = _currentSession!.copyWith(scores: newScores);
    notifyListeners();
  }

  void selectTruth() {
    _truthIndex = (_truthIndex + 1) % _truths.length;
    notifyListeners();
  }

  void selectDare() {
    _dareIndex = (_dareIndex + 1) % _dares.length;
    notifyListeners();
  }

  void selectAnswer(int index) {
    if (_answered) return;
    _selectedAnswer = index;
    notifyListeners();
  }

  void submitTriviaAnswer() {
    if (_selectedAnswer == null || _currentSession == null) return;
    _answered = true;

    final isCorrect = _selectedAnswer == currentTriviaQuestion?.correctIndex;
    if (isCorrect) {
      final bonusPoints =
          _timeRemaining > 10 ? 50 : (_timeRemaining > 5 ? 25 : 0);
      addScore(_currentSession!.currentPlayer.id, 100 + bonusPoints);
    }
    notifyListeners();
  }

  void setTimeRemaining(int seconds) {
    _timeRemaining = seconds;
    notifyListeners();
  }

  void nextTriviaQuestion() {
    _triviaIndex++;
    _selectedAnswer = null;
    _answered = false;
    _timeRemaining = 15;

    if (_triviaIndex >= _triviaQuestions.length) {
      _triviaQuestions.shuffle(_random);
      _triviaIndex = 0;
    }

    nextPlayer();
  }

  void setNhieChoice(int playerIndex, bool hasDone) {
    _nhiePlayerChoices[playerIndex] = hasDone;
    notifyListeners();
  }

  void nextNhieStatement() {
    _nhieIndex++;
    _nhiePlayerChoices = {};
    if (_nhieIndex >= _nhieStatements.length) {
      _nhieStatements.shuffle(_random);
      _nhieIndex = 0;
    }
    nextPlayer();
  }

  void nextWyrQuestion() {
    _wyrIndex++;
    if (_wyrIndex >= _wyrQuestions.length) {
      _wyrQuestions.shuffle(_random);
      _wyrIndex = 0;
    }
    nextPlayer();
  }

  Player? getWinner() {
    if (_currentSession == null || _currentSession!.players.isEmpty)
      return null;

    String? winnerId;
    int maxScore = -1;

    for (final player in _currentSession!.players) {
      final score = _currentSession!.scores[player.id] ?? 0;
      if (score > maxScore) {
        maxScore = score;
        winnerId = player.id;
      }
    }

    return _currentSession!.players.firstWhere((p) => p.id == winnerId);
  }

  void endGame() {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(status: GameStatus.finished);
    }
    notifyListeners();
  }

  void resetGame() {
    _currentSession = null;
    _truths = [];
    _dares = [];
    _wyrQuestions = [];
    _nhieStatements = [];
    _triviaQuestions = [];
    _selectedAnswer = null;
    _answered = false;
    _nhiePlayerChoices = {};
    notifyListeners();
  }

  List<Player>? getPreviousPlayers() {
    final players = _currentSession?.players;
    return players;
  }

  bool get isGameOver => _currentSession?.status == GameStatus.finished;
}
