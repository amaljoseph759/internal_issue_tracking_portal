import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showLogout;
  final List<Widget>? actions;
  final Widget? leading;
  final bool useGradient;

  const CommonAppBar({
    super.key,
    required this.title,
    this.showLogout = false,
    this.actions,
    this.leading,
    this.useGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: leading,
      titleSpacing: 20,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      flexibleSpace: useGradient
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1E3A8A),
                    Color(0xFF3B82F6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            )
          : null,
      backgroundColor: useGradient ? Colors.transparent : Colors.white,
      foregroundColor: useGradient ? Colors.white : Colors.black87,
      actions: [
        if (actions != null) ...actions!,
        if (showLogout)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _LogoutButton(),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "Logout",
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await FirebaseAuth.instance.signOut();
          if (!context.mounted) return;

          Navigator.pushNamedAndRemoveUntil(
            context,
            "/login",
            (route) => false,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.logout_rounded,
            size: 20,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
