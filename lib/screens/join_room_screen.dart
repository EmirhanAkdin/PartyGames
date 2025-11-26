import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/colors.dart';
import '../core/services/auth_service.dart';
import '../core/services/service_locator.dart';
import '../core/models/player.dart';
import 'room_lobby_screen.dart';

class JoinRoomScreen extends StatefulWidget {
  final String username;
  final String avatar;

  const JoinRoomScreen({
    super.key,
    required this.username,
    required this.avatar,
  });

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _authService = AuthService();
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;

  Future<void> _joinRoom() async {
    final code = _controllers.map((c) => c.text).join().toUpperCase();

    if (code.length != 6) {
      _showError('Lütfen 6 haneli kodu girin');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = await _authService.getOrCreateUserId();

      final room = await ServiceLocator.repository.joinRoom(
        roomCode: code,
        userId: userId,
        username: widget.username,
        avatar: widget.avatar,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RoomLobbyScreen(
            roomId: room.roomId,
            username: widget.username,
            avatar: widget.avatar,
          ),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Oda bulunamadı: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.dangerColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Odaya Katıl'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppColors.successGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    '🔑',
                    style: TextStyle(fontSize: 60),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Oda Kodunu Gir',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '6 haneli oda kodunu girin',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 50,
                  height: 60,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                    ],
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.primaryColor.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryColor,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.textSecondary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      }
                      if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),
            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: _isLoading ? null : AppColors.successGradient,
                color: _isLoading ? AppColors.textSecondary : null,
                borderRadius: BorderRadius.circular(12),
                boxShadow: _isLoading
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.successColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isLoading ? null : _joinRoom,
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.textPrimary,
                          )
                        : const Text(
                            'Katıl',
                            style: TextStyle(
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
