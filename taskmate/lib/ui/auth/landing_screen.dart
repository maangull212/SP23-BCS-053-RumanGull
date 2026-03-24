import 'dart:math';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: [
          const _AuthBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  _HeroCluster(color: cs.primary),
                  const SizedBox(height: 48),
                  Text(
                    'Plan & Track',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Organize tasks, build consistency, and keep daily progress visible.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: cs.onSurface.withOpacity(.75),
                    ),
                  ),
                  const Spacer(),
                  _PrimaryAuthButton(
                    label: 'Log In',
                    filled: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _PrimaryAuthButton(
                    label: 'Sign Up',
                    filled: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryAuthButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const _PrimaryAuthButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: filled ? cs.primary : cs.surface.withOpacity(.15),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: filled ? cs.primary : cs.outline.withOpacity(.5),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: filled ? cs.onPrimary : cs.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCluster extends StatelessWidget {
  final Color color;
  const _HeroCluster({required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // A simple abstract “task” cluster using icons in circles (no images needed)
    final baseCircles = [
      Icons.check_circle,
      Icons.alarm,
      Icons.today,
      Icons.repeat,
      Icons.note_alt,
    ];
    return SizedBox(
      height: 140,
      child: Stack(
        children: List.generate(baseCircles.length, (i) {
          final angle = (i / baseCircles.length) * pi * 2;
          final radius = 48.0;
          final dx = radius * cos(angle) + 70;
          final dy = radius * sin(angle) + 40;
          return Positioned(
            left: dx,
            top: dy,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.primary.withOpacity(.9),
                    cs.primary.withOpacity(.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withOpacity(.35),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Icon(
                baseCircles[i],
                size: 24,
                color: cs.onPrimary,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _AuthBackground extends StatelessWidget {
  const _AuthBackground();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.surface,
            cs.surfaceContainerHigh,
            cs.surfaceContainerHighest,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
