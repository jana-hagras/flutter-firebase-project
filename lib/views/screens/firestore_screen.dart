import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../models/user_model.dart';
import '../../services/firestore_services.dart';
import '../../theme/app_theme.dart';
import '../../main.dart';
import 'order.dart';

class FirestoreDemoScreen extends StatefulWidget {
  const FirestoreDemoScreen({super.key});

  @override
  State<FirestoreDemoScreen> createState() => _FirestoreDemoScreenState();
}

class _FirestoreDemoScreenState extends State<FirestoreDemoScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipController = TextEditingController();
  final TextEditingController filterController = TextEditingController();

  final FirestoreServices service = FirestoreServices();

  int _selectedIndex = 0;
  String? _fcmToken;

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
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipController.dispose();
    filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.accentColors[0].color; // Cyan
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Data Center'),
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            tooltip: 'Logout',
          ),
        ],
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
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _selectedIndex == 0
                  ? _buildInputTab(accent, isDark)
                  : _buildUserTab(accent, isDark),
            ),
          ),
          // Floating Bottom Navigation
          _buildFloatingBottomNav(accent, isDark),
        ],
      ),
    );
  }

  Widget _buildFloatingBottomNav(Color accent, bool isDark) {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color:
                  (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.add_circle_outline_rounded,
                    Icons.add_circle_rounded, "Input", accent),
                _buildNavItem(1, Icons.folder_open_rounded,
                    Icons.folder_rounded, "Directory", accent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData filledIcon,
      String label, Color accent) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected ? accent.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? filledIcon : outlineIcon,
              color: isSelected ? accent : Colors.white60,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                    color: accent, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputTab(Color accent, bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey(0),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: AppTheme.glassDecoration(
                isDark: isDark, accent: accent, radius: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                    accent, "PRIMARY DETAILS", Icons.person_add_rounded),
                const SizedBox(height: 16),
                _buildField(nameController, "Full Name", Icons.badge_outlined),
                _buildField(ageController, "Age", Icons.calendar_month_outlined,
                    isNumeric: true),
                const Divider(height: 48, color: Colors.white12),
                _buildSectionHeader(
                    accent, "LOCATION DATA", Icons.explore_outlined),
                const SizedBox(height: 16),
                _buildField(
                    streetController, "Street Address", Icons.home_outlined),
                Row(
                  children: [
                    Expanded(
                        child: _buildField(cityController, "City",
                            Icons.location_city_outlined)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildField(
                            stateController, "State", Icons.public_outlined)),
                  ],
                ),
                _buildField(zipController, "Zip Code", Icons.pin_drop_outlined,
                    isNumeric: true),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildActionButton(
                        label: "ADD (NORMAL)",
                        icon: Icons.add_task_rounded,
                        color: accent,
                        onPressed: () => _performAction(ActionType.add)),
                    _buildActionButton(
                        label: "ADD W/ TIMESTAMP",
                        icon: Icons.history_rounded,
                        color: Colors.orangeAccent,
                        onPressed: () =>
                            _performAction(ActionType.addTimestamp)),
                    _buildActionButton(
                        label: "SET FIXED ID",
                        icon: Icons.push_pin_rounded,
                        color: Colors.purpleAccent,
                        onPressed: () => _performAction(ActionType.setFixed)),
                    _buildActionButton(
                        label: "UPDATE PARTIAL",
                        icon: Icons.published_with_changes_rounded,
                        color: Colors.blueAccent,
                        onPressed: () =>
                            _performAction(ActionType.updatePartial)),
                    _buildActionButton(
                        label: "TEST ORDER PAGE",
                        icon: Icons.shopping_cart_checkout_rounded,
                        color: Colors.redAccent,
                        onPressed: () => _performAction(ActionType.order)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(Color accent, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: accent, size: 16),
        const SizedBox(width: 10),
        Text(title,
            style: TextStyle(
                color: accent,
                letterSpacing: 2,
                fontWeight: FontWeight.w900,
                fontSize: 10)),
      ],
    );
  }

  Widget _buildActionButton(
      {required String label,
      required IconData icon,
      required Color color,
      required VoidCallback onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 10),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
      TextEditingController controller, String label, IconData icon,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18, color: Colors.white38),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.03),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildUserTab(Color accent, bool isDark) {
    return Column(
      key: const ValueKey(1),
      children: [
        if (_fcmToken != null) _buildTokenCard(accent, isDark),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: TextFormField(
            controller: filterController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: "Search in workspace...",
              prefixIcon:
                  const Icon(Icons.search_rounded, color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<UserModel>>(
            stream: service.streamUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              final users = snapshot.data
                      ?.where((u) =>
                          u.name
                              ?.toLowerCase()
                              .contains(filterController.text.toLowerCase()) ??
                          false)
                      .toList() ??
                  [];
              if (users.isEmpty) return _buildEmptyState();

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                itemCount: users.length,
                itemBuilder: (context, index) =>
                    _buildEnhancedUserCard(users[index], accent, isDark),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTokenCard(Color accent, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(20),
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
        subtitle: Text(_fcmToken!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Colors.white54)),
        trailing: IconButton(
          icon: const Icon(Icons.copy_all_rounded, color: Colors.white54),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: _fcmToken!));
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Token copied!")));
          },
        ),
      ),
    );
  }

  Widget _buildEnhancedUserCard(UserModel user, Color accent, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131720),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      accent.withValues(alpha: 0.2),
                      accent.withValues(alpha: 0.05)
                    ]),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                      child:
                          Icon(Icons.person_rounded, color: accent, size: 28)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name ?? "Anonymous",
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                              letterSpacing: -0.5)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.cake_outlined, size: 14, color: accent),
                          const SizedBox(width: 6),
                          Text("Age ${user.age}",
                              style: TextStyle(
                                  color: accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => service.deleteUser(user.id!),
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.redAccent, size: 22),
                  style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
              ],
            ),
            if (user.address != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 16, color: Colors.white38),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "${user.address!['street'] ?? ''}, ${user.address!['city'] ?? ''}, ${user.address!['state'] ?? ''}",
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white60, height: 1.4),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded,
              size: 64, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          const Text("Workspace is empty",
              style: TextStyle(
                  color: Colors.white24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _performAction(ActionType type) {
    if (nameController.text.isEmpty && type == ActionType.add) return;

    if (type == ActionType.order) {
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (_) => const OrderScreen(orderId: "FCM_REDIRECT_TEST_123"),
      ));
      return;
    }

    final user = UserModel(
      name: nameController.text.trim(),
      age: int.tryParse(ageController.text) ?? 0,
      address: {
        'street': streetController.text.trim(),
        'city': cityController.text.trim(),
        'state': stateController.text.trim(),
        'zip': zipController.text.trim(),
      },
    );

    Future<void> future;
    switch (type) {
      case ActionType.add:
        future = service.addUser(user);
        break;
      case ActionType.addTimestamp:
        future = service.addUserTimeStamp(user);
        break;
      case ActionType.setFixed:
        future = service.setUser("fixed_id", user);
        break;
      case ActionType.updatePartial:
        future = service.updatePartial("fixed_id", {"age": user.age});
        break;
      case ActionType.order:
        // TODO: Handle this case.
        throw UnimplementedError();
    }

    future.then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${type.name.toUpperCase()} Complete")));
    });
  }
}

enum ActionType { add, addTimestamp, setFixed, updatePartial, order }
