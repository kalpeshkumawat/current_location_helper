import 'package:flutter/material.dart';

class PermissionRequiredView extends StatelessWidget {
  const PermissionRequiredView({
    super.key,
    required this.onAllow,
    required this.permanentlyDenied,
    required this.onOpenSettings,
    required this.onNotNow,
  });

  final VoidCallback onAllow;
  final bool permanentlyDenied;
  final VoidCallback onOpenSettings;
  final VoidCallback onNotNow;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 100),
              const _PermissionIllustration(),
              const SizedBox(height: 20),
              Text(
                permanentlyDenied
                    ? 'Location Permission Required'
                    : 'Location Permission Required',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                permanentlyDenied
                    ? 'Turn on location to quickly check your current location. To enable, go to Settings and turn on Location Permission.'
                    : 'Please allow system to detect your current location.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.2,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              if (permanentlyDenied) ...[
                _BlackActionButton(label: 'OPEN SETTINGS', onTap: onOpenSettings),
                const SizedBox(height: 16),
                _BlackActionButton(label: 'NOT NOW', onTap: onNotNow),
              ] else
                _BlackActionButton(label: 'ALLOW', onTap: onAllow),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlackActionButton extends StatelessWidget {
  const _BlackActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.black,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFFBB33),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionIllustration extends StatelessWidget {
  const _PermissionIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              height: 28,
              color: const Color(0xFF424A60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  7,
                  (_) => Container(width: 10, height: 4, color: Colors.white),
                ),
              ),
            ),
          ),
          const Icon(Icons.location_on, size: 72, color: Color(0xFF23A24D)),
        ],
      ),
    );
  }
}
