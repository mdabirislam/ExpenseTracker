
import 'package:flutter/material.dart';
// import '../screens/home_screen.dart';

class FabMenu extends StatefulWidget {
  final VoidCallback onStartNewMonth;
  final VoidCallback onAddTransaction;

  const FabMenu({
    super.key,
    required this.onAddTransaction,
    required this.onStartNewMonth,
  });

  @override
  State<FabMenu> createState() => _FabMenuState();
}

class _FabMenuState extends State<FabMenu> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      _isOpen ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (_isOpen)
          GestureDetector(
            onTap: _toggle,
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
        Positioned(
          bottom: 90,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _fabOption(
                label: 'Add New Transaction',
                icon: Icons.receipt_long,
                onTap: widget.onAddTransaction,
                index: 0,
              ),
              const SizedBox(height: 10),
              _fabOption(
                label: 'Start New Month',
                icon: Icons.calendar_month_outlined,
                onTap: widget.onStartNewMonth,
                index: 1,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FloatingActionButton(
            heroTag: 'main_fab',
            onPressed: _toggle,
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _animation,
            ),
          ),
        ),
      ],
    );
  }

  Widget _fabOption({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _animation.value) * 20 * index),
          child: Opacity(
            opacity: _animation.value,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black26)],
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 6),
                FloatingActionButton(
                  heroTag: label,
                  mini: true,
                  onPressed: () {
                    _toggle();
                    onTap();
                  },
                  child: Icon(icon, size: 20),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
