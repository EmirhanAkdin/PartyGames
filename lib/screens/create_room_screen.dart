import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/services/auth_service.dart';
import '../core/services/service_locator.dart';
import 'room_lobby_screen.dart';

class CreateRoomScreen extends StatefulWidget {
  final String username;
  final String avatar;

  const CreateRoomScreen({
    super.key,
    required this.username,
    required this.avatar,
  });

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _authService = AuthService();
  final _roomNameController = TextEditingController();
  double _maxPlayers = 10;
  bool _isLoading = false;

  Future<void> _createRoom() async {
    if (_roomNameController.text.trim().isEmpty) {
      _showError('Lütfen bir oda adı girin');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = _authService.getCurrentUserId();
      if (userId == null) {
        _showError('Kimlik doğrulama hatası');
        setState(() => _isLoading = false);
        return;
      }

      final room = await ServiceLocator.repository.createRoom(
        roomName: _roomNameController.text.trim(),
        hostId: userId,
        hostUsername: widget.username,
        hostAvatar: widget.avatar,
        gameType: 'vampire_villager',
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
      _showError('Oda oluşturulamadı: ${e.toString()}');
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
        title: const Text('Oda Oluştur'),
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
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    '🏠',
                    style: TextStyle(fontSize: 60),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _roomNameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Oda Adı',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                hintText: 'Oda için bir isim gir',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.primaryColor.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(
                  Icons.home,
                  color: AppColors.primaryColor,
                ),
              ),
              maxLength: 30,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Maksimum Oyuncu Sayısı',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_maxPlayers.toInt()} oyuncu',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  Slider(
                    value: _maxPlayers,
                    min: 4,
                    max: 20,
                    divisions: 16,
                    activeColor: AppColors.primaryColor,
                    inactiveColor: AppColors.textSecondary.withValues(alpha: 0.3),
                    onChanged: (value) {
                      setState(() => _maxPlayers = value);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '4',
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        '20',
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: _isLoading ? null : AppColors.primaryGradient,
                color: _isLoading ? AppColors.textSecondary : null,
                borderRadius: BorderRadius.circular(12),
                boxShadow: _isLoading
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isLoading ? null : _createRoom,
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.textPrimary,
                          )
                        : const Text(
                            'Oluştur',
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
    _roomNameController.dispose();
    super.dispose();
  }
}
