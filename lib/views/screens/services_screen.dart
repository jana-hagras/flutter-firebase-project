import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../services/firestore_services.dart';
import '../../theme/app_theme.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final FirestoreServices _firestoreService = FirestoreServices();

  String? _fcmToken;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFCMToken();
  }

  Future<void> _loadFCMToken() async {
    _fcmToken = await FirebaseMessaging.instance.getToken();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.accentColors[0].color;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Services Dashboard'),
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Premium Gradient Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF020617)]
                      : [const Color(0xFFF1F5F9), const Color(0xFFFFFFFF)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildServiceCard(
                    'Firestore Service',
                    'Database operations for user management',
                    Icons.cloud,
                    accent,
                    isDark,
                    _buildFirestoreActions(accent),
                  ),
                  const SizedBox(height: 24),
                  _buildServiceCard(
                    'Notification Service',
                    'Firebase Cloud Messaging & local notifications',
                    Icons.notifications,
                    accent,
                    isDark,
                    _buildNotificationActions(accent),
                  ),
                  const SizedBox(height: 24),
                  _buildTokenCard(accent, isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String title, String description, IconData icon,
      Color accent, bool isDark, List<Widget> actions) {
    return Container(
      decoration:
          AppTheme.glassDecoration(isDark: isDark, accent: accent, radius: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: accent, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(description,
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.7))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFirestoreActions(Color accent) {
    return [
      _buildServiceActionButton(
        'Get Users Count',
        Icons.people,
        accent,
        () => _testFirestoreOperation('count'),
      ),
      _buildServiceActionButton(
        'Query Adults',
        Icons.search,
        accent,
        () => _testFirestoreOperation('query'),
      ),
      _buildServiceActionButton(
        'Test Increment',
        Icons.add,
        accent,
        () => _testFirestoreOperation('increment'),
      ),
      _buildServiceActionButton(
        'Test Decrement',
        Icons.remove,
        accent,
        () => _testFirestoreOperation('decrement'),
      ),
    ];
  }

  List<Widget> _buildNotificationActions(Color accent) {
    return [
      _buildServiceActionButton(
        'Print FCM Token',
        Icons.token,
        accent,
        () => _testNotificationOperation('token'),
      ),
      _buildServiceActionButton(
        'Send Test Notification',
        Icons.send,
        accent,
        () => _testNotificationOperation('test'),
      ),
      _buildServiceActionButton(
        'Check Permissions',
        Icons.settings,
        accent,
        () => _testNotificationOperation('permissions'),
      ),
    ];
  }

  Widget _buildServiceActionButton(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w600, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTokenCard(Color accent, bool isDark) {
    return Container(
      decoration:
          AppTheme.glassDecoration(isDark: isDark, opacity: 0.06, radius: 24),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(Icons.key_rounded, color: accent, size: 20),
        ),
        title: const Text("FCM DEVICE TOKEN",
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        subtitle: Text(_fcmToken ?? "Loading...",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Colors.white54)),
        trailing: IconButton(
          icon: const Icon(Icons.copy_all_rounded, color: Colors.white54),
          onPressed: _fcmToken != null
              ? () {
                  Clipboard.setData(ClipboardData(text: _fcmToken!));
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Token copied!")));
                }
              : null,
        ),
      ),
    );
  }

  Future<void> _testFirestoreOperation(String operation) async {
    setState(() => _isLoading = true);
    try {
      switch (operation) {
        case 'count':
          final users = await _firestoreService.getUsers();
          _showResult('Users Count', '${users.length} users found');
          break;
        case 'query':
          final adults = await _firestoreService.queryUsers();
          _showResult('Adult Users', '${adults.length} users over 18');
          break;
        case 'increment':
          // Test increment on first user if exists
          final users = await _firestoreService.getUsers();
          if (users.isNotEmpty) {
            await _firestoreService.incrementAge(users.first.id);
            _showResult(
                'Increment Test', 'Age incremented for user ${users.first.id}');
          } else {
            _showResult('Increment Test', 'No users found to test');
          }
          break;
        case 'decrement':
          // Test decrement on first user if exists
          final users = await _firestoreService.getUsers();
          if (users.isNotEmpty) {
            await _firestoreService.decrementAge(users.first.id);
            _showResult(
                'Decrement Test', 'Age decremented for user ${users.first.id}');
          } else {
            _showResult('Decrement Test', 'No users found to test');
          }
          break;
      }
    } catch (e) {
      _showResult('Error', e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _testNotificationOperation(String operation) async {
    setState(() => _isLoading = true);
    try {
      switch (operation) {
        case 'token':
          final token = await FirebaseMessaging.instance.getToken();
          _showResult('FCM Token', token ?? 'No token available');
          break;
        case 'test':
          // This would require server-side implementation
          _showResult('Test Notification',
              'Server-side implementation needed for test notifications');
          break;
        case 'permissions':
          final settings =
              await FirebaseMessaging.instance.getNotificationSettings();
          _showResult(
              'Permissions',
              'Authorization: ${settings.authorizationStatus}\n'
                  'Alert: ${settings.alert}\n'
                  'Sound: ${settings.sound}\n'
                  'Badge: ${settings.badge}');
          break;
      }
    } catch (e) {
      _showResult('Error', e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showResult(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131720),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK", style: TextStyle(color: Colors.cyan)),
          ),
        ],
      ),
    );
  }
}
