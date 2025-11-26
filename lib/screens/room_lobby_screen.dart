import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/colors.dart';
import '../core/services/auth_service.dart';
import '../core/services/room_service.dart';
import '../core/models/room.dart';

class RoomLobbyScreen extends StatefulWidget {
  final String roomId;
  final String username;
  final String avatar;

  const RoomLobbyScreen({
    super.key,
    required this.roomId,
    required this.username,
    required this.avatar,
  });

  @override
  State<RoomLobbyScreen> createState() => _RoomLobbyScreenState();
}

class _RoomLobbyScreenState extends State<RoomLobbyScreen> {
  final _roomService = RoomService();
  final _authService = AuthService();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initUserId();
  }

  Future<void> _initUserId() async {
    final userId = await _authService.getOrCreateUserId();
    setState(() {
      _userId = userId;
    });
  }

  Future<void> _toggleReady(Room room) async {
    final userId = _userId;
    if (userId == null) return;

    final currentPlayer = room.players.firstWhere((p) => p.userId == userId);
    await _roomService.toggleReady(
      roomId: widget.roomId,
      userId: userId,
      isReady: !currentPlayer.isReady,
    );
  }

  Future<void> _leaveRoom() async {
    final userId = _userId;
    if (userId == null) return;

    final success = await _roomService.leaveRoom(
      roomId: widget.roomId,
      userId: userId,
    );

    if (success && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _copyRoomCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Oda kodu kopyalandı!'),
        backgroundColor: AppColors.successColor,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _leaveRoom();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Oda Lobby'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: _leaveRoom,
          ),
        ),
        body: StreamBuilder<Room?>(
          stream: _roomService.listenToRoom(widget.roomId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              });
              return const SizedBox.shrink();
            }

            final room = snapshot.data!;
            final userId = _userId;
            if (userId == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final currentPlayer =
                room.players.firstWhere((p) => p.userId == userId);
            final isHost = currentPlayer.isHost;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    room.roomName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _copyRoomCode(room.roomCode),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            room.roomCode,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.copy,
                            color: AppColors.textPrimary,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${room.players.length}/${room.maxPlayers} oyuncu',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: room.players.length,
                    itemBuilder: (context, index) {
                      final player = room.players[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: player.isReady
                                ? AppColors.successColor
                                : AppColors.textSecondary.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  player.avatar,
                                  style: const TextStyle(fontSize: 40),
                                ),
                                if (player.isHost)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Text(
                                      '👑',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              player.username,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: player.isReady
                                    ? AppColors.successColor
                                    : AppColors.dangerColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                player.isReady ? 'Hazır ✓' : 'Bekliyor ✗',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: currentPlayer.isReady
                          ? AppColors.dangerGradient
                          : AppColors.successGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _toggleReady(room),
                        borderRadius: BorderRadius.circular(12),
                        child: Center(
                          child: Text(
                            currentPlayer.isReady
                                ? 'Hazır Değilim'
                                : 'Hazırım',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isHost) ...[
                    const SizedBox(height: 16),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: room.allPlayersReady
                            ? AppColors.primaryGradient
                            : null,
                        color: room.allPlayersReady
                            ? null
                            : AppColors.textSecondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: room.allPlayersReady
                              ? () {
                                  // TODO: Start game
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Oyun başlatma özelliği yakında...'),
                                      backgroundColor: AppColors.primaryColor,
                                    ),
                                  );
                                }
                              : null,
                          borderRadius: BorderRadius.circular(12),
                          child: Center(
                            child: Text(
                              room.allPlayersReady
                                  ? 'Oyunu Başlat'
                                  : 'Herkes hazır olmalı',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _leaveRoom,
                    child: const Text(
                      'Odadan Çık',
                      style: TextStyle(
                        color: AppColors.dangerColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
