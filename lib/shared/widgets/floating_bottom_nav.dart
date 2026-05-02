import 'package:flutter/material.dart';

class FloatingBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<FloatingBottomNav> createState() => _FloatingBottomNavState();
}

class _FloatingBottomNavState extends State<FloatingBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const _items = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Beranda'),
    _NavItem(icon: Icons.sports_soccer_outlined, activeIcon: Icons.sports_soccer, label: 'Match'),
    _NavItem(icon: Icons.groups_outlined, activeIcon: Icons.groups_rounded, label: 'Skuad'),
    _NavItem(icon: Icons.shopping_bag_outlined, activeIcon: Icons.shopping_bag_rounded, label: 'Shop'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FloatingBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_items.length, (i) {
              final isCenter = i == 2;
              final isActive = widget.currentIndex == i;
              return Expanded(
                child: _NavItemWidget(
                  item: _items[i],
                  isActive: isActive,
                  isCenter: isCenter,
                  animation: _controller,
                  onTap: () => widget.onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItemWidget extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final bool isCenter;
  final Animation<double> animation;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.item,
    required this.isActive,
    required this.isCenter,
    required this.animation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final liftAnim = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutBack,
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: liftAnim,
        builder: (context, child) {
          final liftOffset = isActive ? (1 - liftAnim.value) * 12.0 : 0.0;
          return Transform.translate(
            offset: Offset(0, liftOffset),
            child: child,
          );
        },
        child: isCenter
            ? _CenterItem(item: item, isActive: isActive)
            : _DefaultItem(item: item, isActive: isActive),
      ),
    );
  }
}

/// Item tengah — lebih menonjol, terasa seperti FAB mini
class _CenterItem extends StatelessWidget {
  final _NavItem item;
  final bool isActive;

  const _CenterItem({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          width: isActive ? 52 : 46,
          height: isActive ? 52 : 46,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFCC0000) : const Color(0xFF2A2A2A),
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFFCC0000).withOpacity(0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Icon(
            isActive ? item.activeIcon : item.icon,
            color: Colors.white,
            size: isActive ? 26 : 22,
          ),
        ),
      ],
    );
  }
}

/// Item biasa — ikon + label dengan animasi warna dan naik
class _DefaultItem extends StatelessWidget {
  final _NavItem item;
  final bool isActive;

  const _DefaultItem({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: anim,
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Icon(
            isActive ? item.activeIcon : item.icon,
            key: ValueKey(isActive),
            color: isActive ? const Color(0xFFCC0000) : const Color(0xFF888888),
            size: isActive ? 24 : 22,
          ),
        ),
        const SizedBox(height: 3),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 220),
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? const Color(0xFFCC0000) : const Color(0xFF666666),
            letterSpacing: 0.2,
          ),
          child: Text(item.label),
        ),
      ],
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
