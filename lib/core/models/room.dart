// import 'package:cloud_firestore/cloud_firestore.dart'; // Only needed when using Firebase
import 'player.dart';

class Room {
  final String roomId;
  final String roomCode;
  final String roomName;
  final String hostId;
  final List<Player> players;
  final int maxPlayers;
  final String status;
  final String? selectedGame;
  final DateTime createdAt;

  Room({
    required this.roomId,
    required this.roomCode,
    required this.roomName,
    required this.hostId,
    required this.players,
    required this.maxPlayers,
    required this.status,
    this.selectedGame,
    required this.createdAt,
  });

  factory Room.fromMap(Map<String, dynamic> map, String docId) {
    return Room(
      roomId: docId,
      roomCode: map['roomCode'] ?? '',
      roomName: map['roomName'] ?? '',
      hostId: map['hostId'] ?? '',
      players: (map['players'] as List<dynamic>?)
              ?.map((p) => Player.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
      maxPlayers: map['maxPlayers'] ?? 10,
      status: map['status'] ?? 'waiting',
      selectedGame: map['selectedGame'],
      createdAt: map['createdAt'] is int 
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomCode': roomCode,
      'roomName': roomName,
      'hostId': hostId,
      'players': players.map((p) => p.toMap()).toList(),
      'maxPlayers': maxPlayers,
      'status': status,
      'selectedGame': selectedGame,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  Room copyWith({
    String? roomId,
    String? roomCode,
    String? roomName,
    String? hostId,
    List<Player>? players,
    int? maxPlayers,
    String? status,
    String? selectedGame,
    DateTime? createdAt,
  }) {
    return Room(
      roomId: roomId ?? this.roomId,
      roomCode: roomCode ?? this.roomCode,
      roomName: roomName ?? this.roomName,
      hostId: hostId ?? this.hostId,
      players: players ?? this.players,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      status: status ?? this.status,
      selectedGame: selectedGame ?? this.selectedGame,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isFull => players.length >= maxPlayers;
  bool get allPlayersReady =>
      players.isNotEmpty && players.every((p) => p.isReady);
  Player? get host => players.firstWhere((p) => p.isHost);
}
