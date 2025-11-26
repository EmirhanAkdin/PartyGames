// import 'package:cloud_firestore/cloud_firestore.dart'; // Only needed when using Firebase

class GameState {
  final String roomId;
  final String currentPhase;
  final int roundNumber;
  final int timeRemaining;
  final Map<String, dynamic> roles;
  final Map<String, dynamic> nightActions;
  final Map<String, String> votes;
  final List<String> eliminatedPlayers;
  final String? winner;
  final DateTime lastUpdate;

  GameState({
    required this.roomId,
    required this.currentPhase,
    this.roundNumber = 1,
    this.timeRemaining = 0,
    required this.roles,
    Map<String, dynamic>? nightActions,
    Map<String, String>? votes,
    List<String>? eliminatedPlayers,
    this.winner,
    DateTime? lastUpdate,
  })  : nightActions = nightActions ?? {},
        votes = votes ?? {},
        eliminatedPlayers = eliminatedPlayers ?? [],
        lastUpdate = lastUpdate ?? DateTime.now();

  factory GameState.fromMap(Map<String, dynamic> map, String docId) {
    return GameState(
      roomId: docId,
      currentPhase: map['currentPhase'] ?? 'role_reveal',
      roundNumber: map['roundNumber'] ?? 1,
      timeRemaining: map['timeRemaining'] ?? 0,
      roles: Map<String, dynamic>.from(map['roles'] ?? {}),
      nightActions: Map<String, dynamic>.from(map['nightActions'] ?? {}),
      votes: Map<String, String>.from(map['votes'] ?? {}),
      eliminatedPlayers: List<String>.from(map['eliminatedPlayers'] ?? []),
      winner: map['winner'],
      lastUpdate: map['lastUpdate'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['lastUpdate'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentPhase': currentPhase,
      'roundNumber': roundNumber,
      'timeRemaining': timeRemaining,
      'roles': roles,
      'nightActions': nightActions,
      'votes': votes,
      'eliminatedPlayers': eliminatedPlayers,
      'winner': winner,
      'lastUpdate': lastUpdate.millisecondsSinceEpoch,
    };
  }

  GameState copyWith({
    String? roomId,
    String? currentPhase,
    int? roundNumber,
    int? timeRemaining,
    Map<String, dynamic>? roles,
    Map<String, dynamic>? nightActions,
    Map<String, String>? votes,
    List<String>? eliminatedPlayers,
    String? winner,
    DateTime? lastUpdate,
  }) {
    return GameState(
      roomId: roomId ?? this.roomId,
      currentPhase: currentPhase ?? this.currentPhase,
      roundNumber: roundNumber ?? this.roundNumber,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      roles: roles ?? this.roles,
      nightActions: nightActions ?? this.nightActions,
      votes: votes ?? this.votes,
      eliminatedPlayers: eliminatedPlayers ?? this.eliminatedPlayers,
      winner: winner ?? this.winner,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}
