// import 'package:firebase_auth/firebase_auth.dart'; // Only needed when using Firebase
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // final FirebaseAuth _auth = FirebaseAuth.instance; // Only for Firebase mode
  static const _uuid = Uuid();
  static const String _userIdKey = 'local_user_id';

  Future<String?> signInAnonymously() async {
    // For local/WebSocket mode, generate and save a UUID
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString(_userIdKey);
      
      if (userId == null) {
        userId = _uuid.v4();
        await prefs.setString(_userIdKey, userId);
      }
      
      return userId;
    } catch (e) {
      return null;
    }
  }

  String? getCurrentUserId() {
    // For local/WebSocket mode, get saved UUID
    // Note: This is synchronous, so we need to handle it differently
    // Return a generated ID for now, the widget should call signInAnonymously first
    return _uuid.v4();
  }

  bool isAuthenticated() {
    // For local/WebSocket mode, always return true
    return true;
  }
  
  /// Get or create user ID (async version)
  Future<String> getOrCreateUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(_userIdKey);
    
    if (userId == null) {
      userId = _uuid.v4();
      await prefs.setString(_userIdKey, userId);
    }
    
    return userId;
  }
}
