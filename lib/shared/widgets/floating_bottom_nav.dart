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
  late AnimationController _entryController;
  late AnimationController _pillController;
  late Animation<double> _pillAnim;

  int _prevIndex = 0;

  static const _items = [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Beranda',
    ),
    _NavItem(
      icon: Icons.sports_soccer_outlined,
      activeIcon: Icons.sports_soccer,
      label: 'Match',
    ),
    _NavItem(
      icon: Icons.groups_outlined,
      activeIcon: Icons.groups_rounded,
      label: 'Skuad',
    ),
    _NavItem(
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag_rounded,
      label: 'Shop',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profil',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _prevIndex = widget.currentIndex;

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    _pillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _pillAnim = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _pillController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pillController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FloatingBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _entryController.forward(from: 0);

      final from = _prevIndex.toDouble();
      final to = widget.currentIndex.toDouble();
      _pillAnim = Tween<double>(begin: from, end: to).animate(
        CurvedAnimation(parent: _pillController, curve: Curves.easeOutCubic),
      );
      _pillController.forward(from: 0);
      _prevIndex = widget.currentIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: SizedBox(
          height: 72,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // === Dock utama ===
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _DockBar(
                  items: _items,
                  currentIndex: widget.currentIndex,
                  entryController: _entryController,
                  pillAnim: _pillAnim,
                  onTap: (i) {
                    HapticFeedback.selectionClick();
                    widget.onTap(i);
                  },
                ),
              ),

              // === Tombol tengah mengambang (index 2 = Skuad) ===
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: _FloatingCenterButton(
                    item: _items[2],
                    isActive: widget.currentIndex == 2,
                    entryController: _entryController,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      widget.onTap(2);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Dock bar background + items
// ──────────────────────────────────────────────────────────────
class _DockBar extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final AnimationController entryController;
  final Animation<double> pillAnim;
  final ValueChanged<int> onTap;

  const _DockBar({
    required this.items,
    required this.currentIndex,
    required this.entryController,
    required this.pillAnim,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / items.length;

          return Stack(
            children: [
              // Sliding pill indicator
              AnimatedBuilder(
                animation: pillAnim,
                builder: (context, _) {
                  if (currentIndex == 2) return const SizedBox.shrink();
                  final pillLeft =
                      pillAnim.value * itemWidth + itemWidth / 2 - 28;
                  return Positioned(
                    top: 10,
                    left: pillLeft,
                    child: Container(
                      width: 56,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCC0000).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                },
              ),

              // Nav items
              Row(
                children: List.generate(items.length, (i) {
                  if (i == 2) {
                    // Slot tengah dikosongkan — diisi floating button
                    return const Expanded(child: SizedBox.shrink());
                  }
                  return Expanded(
                    child: _NavItemWidget(
                      item: items[i],
                      isActive: currentIndex == i,
                      entryController: entryController,
                      onTap: () => onTap(i),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Tombol tengah mengambang
// ──────────────────────────────────────────────────────────────
class _FloatingCenterButton extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final AnimationController entryController;
  final VoidCallback onTap;

  const _FloatingCenterButton({
    required this.item,
    required this.isActive,
    required this.entryController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: entryController,
      builder: (context, child) {
        final liftAnim = CurvedAnimation(
          parent: entryController,
          curve: Curves.easeOutBack,
        );
        final liftOffset = isActive ? (1 - liftAnim.value) * 14.0 : 0.0;
        return Transform.translate(
          offset: Offset(0, liftOffset),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: isActive ? 58 : 52,
          height: isActive ? 58 : 52,
          decoration: BoxDecoration(
            color:
                isActive ? const Color(0xFFCC0000) : const Color(0xFF2A2A2A),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? const Color(0xFFFF3333).withOpacity(0.4)
                  : Colors.white.withOpacity(0.08),
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFFCC0000).withOpacity(0.5),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: const Color(0xFFCC0000).withOpacity(0.25),
                      blurRadius: 32,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              isActive ? item.activeIcon : item.icon,
              key: ValueKey(isActive),
              color: Colors.white,
              size: isActive ? 28 : 24,
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Item navigasi biasa — StatefulWidget untuk bounce animation
// ──────────────────────────────────────────────────────────────
class _NavItemWidget extends StatefulWidget {
  final _NavItem item;
  final bool isActive;
  final AnimationController entryController;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.item,
    required this.isActive,
    required this.entryController,
    required this.onTap,
  });

  @override
  State<_NavItemWidget> createState() => _NavItemWidgetState();
}

class _NavItemWidgetState extends State<_NavItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late Animation<double> _liftAnim;

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
        tween: Tween(begin: -10.0, end: 0.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 55,
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
      child: AnimatedBuilder(
        animation: _liftAnim,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, widget.isActive ? _liftAnim.value : 0.0),
            child: child,
          );
        },
        child: SizedBox(
          height: 62,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: CurvedAnimation(
                    parent: anim,
                    curve: Curves.easeOutBack,
                  ),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Icon(
                  widget.isActive ? widget.item.activeIcon : widget.item.icon,
                  key: ValueKey(widget.isActive),
                  color: widget.isActive
                      ? const Color(0xFFCC0000)
                      : const Color(0xFF777777),
                  size: widget.isActive ? 24 : 22,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                      widget.isActive ? FontWeight.w700 : FontWeight.w400,
                  color: widget.isActive
                      ? const Color(0xFFCC0000)
                      : const Color(0xFF555555),
                  letterSpacing: 0.3,
                ),
                child: Text(widget.item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Data model
// ──────────────────────────────────────────────────────────────
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