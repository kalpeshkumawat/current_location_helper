import 'package:flutter/material.dart';

class GpsOffView extends StatelessWidget {
  const GpsOffView({
    super.key,
    required this.onTurnOnGps,
    required this.onNotNow,
  });

  final VoidCallback onTurnOnGps;
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
              const Icon(Icons.map_outlined, size: 96, color: Color(0xFF44C868)),
              const SizedBox(height: 20),
              const Text(
                'GPS turned off',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Allow Application to turn on your phone GPS for your accurate current location.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.2,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              _GpsButton(label: 'TURN ON GPS', onTap: onTurnOnGps),
              const SizedBox(height: 16),
              _GpsButton(label: 'NOT NOW', onTap: onNotNow),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _GpsButton extends StatelessWidget {
  const _GpsButton({required this.label, required this.onTap});

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
