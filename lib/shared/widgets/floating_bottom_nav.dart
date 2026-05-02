import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    with TickerProviderStateMixin {
  late AnimationController _pillController;
  late Animation<double> _pillAnim;
  int _prevIndex = 0;

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
    _prevIndex = widget.currentIndex;
    _pillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _pillAnim = CurvedAnimation(
      parent: _pillController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didUpdateWidget(FloatingBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _prevIndex = oldWidget.currentIndex;
      _pillController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding + 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final itemWidth = totalWidth / _items.length;

          return SizedBox(
            height: 64,
            child: Stack(
              children: [
                // ── Background dock ──────────────────────────────────
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.07),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Sliding pill ─────────────────────────────────────
                AnimatedBuilder(
                  animation: _pillAnim,
                  builder: (context, _) {
                    final fromX = _prevIndex * itemWidth;
                    final toX = widget.currentIndex * itemWidth;
                    final x = fromX + (toX - fromX) * _pillAnim.value;
                    final isCenter = widget.currentIndex == 2;

                    return Positioned(
                      left: x + 8,
                      top: isCenter ? 6 : 8,
                      child: Container(
                        width: itemWidth - 16,
                        height: isCenter ? 52 : 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCC0000).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFCC0000).withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // ── Items ────────────────────────────────────────────
                Row(
                  children: List.generate(_items.length, (i) {
                    final isActive = widget.currentIndex == i;
                    final isCenter = i == 2;
                    return SizedBox(
                      width: itemWidth,
                      child: _NavItemWidget(
                        item: _items[i],
                        isActive: isActive,
                        isCenter: isCenter,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onTap(i);
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Per-item bounce widget ───────────────────────────────────────────────────
class _NavItemWidget extends StatefulWidget {
  final _NavItem item;
  final bool isActive;
  final bool isCenter;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.item,
    required this.isActive,
    required this.isCenter,
    required this.onTap,
  });

  @override
  State<_NavItemWidget> createState() => _NavItemWidgetState();
}

class _NavItemWidgetState extends State<_NavItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late Animation<double> _liftAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _liftAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -10.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -10.0, end: -3.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 55,
      ),
    ]).animate(_bounceCtrl);

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_bounceCtrl);
  }

  @override
  void didUpdateWidget(_NavItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _bounceCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 64,
        child: AnimatedBuilder(
          animation: _bounceCtrl,
          builder: (context, _) {
            final lift = widget.isActive ? _liftAnim.value : 0.0;
            final scale = widget.isActive ? _scaleAnim.value : 1.0;

            return Transform.translate(
              offset: Offset(0, lift),
              child: Transform.scale(
                scale: scale,
                child: widget.isCenter
                    ? _CenterItem(item: widget.item, isActive: widget.isActive)
                    : _DefaultItem(item: widget.item, isActive: widget.isActive),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Item tengah (Skuad) ──────────────────────────────────────────────────────
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
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          width: isActive ? 52 : 46,
          height: isActive ? 52 : 46,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFCC0000) : const Color(0xFF2A2A2A),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? const Color(0xFFFF3333).withOpacity(0.4)
                  : Colors.transparent,
              width: 1.5,
            ),
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

// ─── Item biasa ───────────────────────────────────────────────────────────────
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
          duration: const Duration(milliseconds: 200),
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
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            color: isActive ? const Color(0xFFCC0000) : const Color(0xFF666666),
            letterSpacing: isActive ? 0.3 : 0.1,
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