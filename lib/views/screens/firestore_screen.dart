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
import 'services_screen.dart';

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
  final TextEditingController tagsController = TextEditingController();

  final FirestoreServices service = FirestoreServices();

  int _selectedIndex = 0;
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
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipController.dispose();
    filterController.dispose();
    tagsController.dispose();
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
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => navigatorKey.currentState?.push(
              MaterialPageRoute(builder: (_) => const ServicesScreen()),
            ),
            tooltip: 'Services',
          ),
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
                _buildField(tagsController, "Tags", Icons.tag_outlined),
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
                        onPressed: _isLoading
                            ? null
                            : () => _performAction(ActionType.add)),
                    // _buildActionButton(
                    //     label: "ADD W/ TIMESTAMP",
                    //     icon: Icons.history_rounded,
                    //     color: Colors.orangeAccent,
                    //     onPressed: () =>
                    //         _performAction(ActionType.addTimestamp)),
                    _buildActionButton(
                        label: "SET FIXED ID",
                        icon: Icons.push_pin_rounded,
                        color: Colors.purpleAccent,
                        onPressed: _isLoading
                            ? null
                            : () => _performAction(ActionType.setFixed)),
                    _buildActionButton(
                        label: "UPDATE PARTIAL",
                        icon: Icons.published_with_changes_rounded,
                        color: Colors.blueAccent,
                        onPressed: _isLoading
                            ? null
                            : () => _performAction(ActionType.updatePartial)),
                    // _buildActionButton(
                    //     label: "TEST ORDER PAGE",
                    //     icon: Icons.shopping_cart_checkout_rounded,
                    //     color: Colors.redAccent,
                    //     onPressed: () => _performAction(ActionType.order)),
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
      required VoidCallback? onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: onPressed == null
                ? color.withValues(alpha: 0.05)
                : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isLoading && onPressed != null)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(icon,
                    size: 18,
                    color: onPressed == null
                        ? color.withValues(alpha: 0.5)
                        : color),
              const SizedBox(width: 10),
              Text(label,
                  style: TextStyle(
                      color: onPressed == null
                          ? color.withValues(alpha: 0.5)
                          : color,
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
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final users = snapshot.data?.where((u) {
                    final query = filterController.text.toLowerCase();
                    if (query.isEmpty) return true;
                    return (u.name?.toLowerCase().contains(query) ?? false) ||
                        (u.age?.toString().contains(query) ?? false) ||
                        (u.tags?.any(
                                (tag) => tag.toLowerCase().contains(query)) ??
                            false) ||
                        (u.address?['city']?.toLowerCase().contains(query) ??
                            false) ||
                        (u.address?['state']?.toLowerCase().contains(query) ??
                            false);
                  }).toList() ??
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
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      service.decrementAge(user.id!),
                                  icon: Icon(Icons.remove,
                                      size: 16, color: accent),
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      service.incrementAge(user.id!),
                                  icon:
                                      Icon(Icons.add, size: 16, color: accent),
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _confirmDelete(user),
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
            if (user.tags != null && user.tags!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    const Icon(Icons.tag_rounded,
                        size: 16, color: Colors.white38),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: user.tags!
                            .map((tag) => Chip(
                                  label: Text(tag,
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.white)),
                                  backgroundColor:
                                      accent.withValues(alpha: 0.2),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ))
                            .toList(),
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
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inbox_rounded,
                size: 48, color: Colors.white.withValues(alpha: 0.3)),
          ),
          const SizedBox(height: 24),
          const Text("Workspace is empty",
              style: TextStyle(
                  color: Colors.white24,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          const SizedBox(height: 8),
          const Text("Add your first user to get started",
              style: TextStyle(color: Colors.white12, fontSize: 14)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => setState(() => _selectedIndex = 0),
            icon: const Icon(Icons.add),
            label: const Text("Add User"),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  AppTheme.accentColors[0].color.withValues(alpha: 0.2),
              foregroundColor: AppTheme.accentColors[0].color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131720),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete User", style: TextStyle(color: Colors.white)),
        content: Text(
            "Are you sure you want to delete ${user.name ?? 'this user'}?",
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child:
                const Text("Cancel", style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () {
              service.deleteUser(user.id!);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("User deleted")));
            },
            child:
                const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _performAction(ActionType type) {
    if (type == ActionType.add) {
      if (nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Name is required")));
        return;
      }
      final age = int.tryParse(ageController.text);
      if (age == null || age < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter a valid age")));
        return;
      }
    }

    if (type == ActionType.order) {
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (_) => const OrderScreen(orderId: "FCM_REDIRECT_TEST_123"),
      ));
      return;
    }

    setState(() => _isLoading = true);

    final user = UserModel(
      name: nameController.text.trim(),
      age: int.tryParse(ageController.text) ?? 0,
      address: {
        'street': streetController.text.trim(),
        'city': cityController.text.trim(),
        'state': stateController.text.trim(),
        'zip': zipController.text.trim(),
      },
      tags: tagsController.text.isNotEmpty
          ? tagsController.text.split(',').map((e) => e.trim()).toList()
          : null,
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
        throw UnimplementedError();
    }

    future.then((_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      // Clear controllers after successful add
      if (type == ActionType.add) {
        nameController.clear();
        ageController.clear();
        streetController.clear();
        cityController.clear();
        stateController.clear();
        zipController.clear();
        tagsController.clear();
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${type.name.toUpperCase()} Complete")));
    }).catchError((error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: ${error.toString()}")));
    });
  }
}

enum ActionType { add, addTimestamp, setFixed, updatePartial, order }
