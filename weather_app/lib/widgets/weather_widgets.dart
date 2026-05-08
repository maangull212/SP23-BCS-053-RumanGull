import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';

// ── Glass Info Card ──────────────────────────────────────────────────────────
class WeatherInfoCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color accentColor;
  final int animationDelay;

  const WeatherInfoCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.accentColor,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(delay: Duration(milliseconds: animationDelay), duration: 400.ms),
        SlideEffect(
          delay: Duration(milliseconds: animationDelay),
          duration: 400.ms,
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hourly Forecast Card ─────────────────────────────────────────────────────
class HourlyForecastCard extends StatelessWidget {
  final HourlyForecast data;
  final int index;

  const HourlyForecastCard({super.key, required this.data, required this.index});

  @override
  Widget build(BuildContext context) {
    final isNow = index == 0;
    return Animate(
      effects: [
        FadeEffect(delay: Duration(milliseconds: index * 60), duration: 350.ms),
        SlideEffect(
          delay: Duration(milliseconds: index * 60),
          duration: 350.ms,
          begin: const Offset(0.3, 0),
          end: Offset.zero,
        ),
      ],
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isNow
              ? Colors.white.withOpacity(0.25)
              : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isNow
                ? Colors.white.withOpacity(0.5)
                : Colors.white.withOpacity(0.15),
            width: isNow ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isNow ? 'Now' : DateFormat('HH:mm').format(data.time),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isNow ? FontWeight.w700 : FontWeight.w400,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Image.network(
              'https://openweathermap.org/img/wn/${data.iconCode}@2x.png',
              width: 36,
              height: 36,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.cloud,
                color: Colors.white70,
                size: 28,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${data.temperature.round()}°',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Daily Forecast Row ───────────────────────────────────────────────────────
class DailyForecastRow extends StatelessWidget {
  final DailyForecast data;
  final int index;
  final bool isToday;

  const DailyForecastRow({
    super.key,
    required this.data,
    required this.index,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(delay: Duration(milliseconds: index * 80), duration: 400.ms),
        SlideEffect(
          delay: Duration(milliseconds: index * 80),
          duration: 400.ms,
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ),
      ],
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(
                isToday ? 'Today' : DateFormat('EEEE').format(data.date),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            Image.network(
              'https://openweathermap.org/img/wn/${data.iconCode}@2x.png',
              width: 36,
              height: 36,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.cloud, color: Colors.white70, size: 28),
            ),
            const Spacer(),
            Text(
              '${data.tempMin.round()}°',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white60,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 8),
            // Temp bar
            SizedBox(
              width: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: data.tempMax > 0
                      ? (data.tempMax - data.tempMin) / 40
                      : 0.5,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation(Colors.white54),
                  minHeight: 4,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${data.tempMax.round()}°',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sun Timeline ─────────────────────────────────────────────────────────────
class SunriseWidget extends StatelessWidget {
  final DateTime sunrise;
  final DateTime sunset;

  const SunriseWidget({super.key, required this.sunrise, required this.sunset});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final totalDuration = sunset.difference(sunrise).inMinutes.toDouble();
    final elapsed = now.difference(sunrise).inMinutes.toDouble();
    final progress = (elapsed / totalDuration).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.wb_sunny_outlined, color: Colors.white70, size: 16),
              SizedBox(width: 8),
              Text(
                'SUN POSITION',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white60,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Positioned(
                left: progress * (MediaQuery.of(context).size.width - 80) - 8,
                top: -6,
                child: const Text('☀️', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _timeLabel(
                  '🌅 Sunrise', DateFormat('h:mm a').format(sunrise)),
              _timeLabel('🌇 Sunset', DateFormat('h:mm a').format(sunset)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeLabel(String title, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: Colors.white60),
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ── Shimmer Loading ───────────────────────────────────────────────────────────
class WeatherLoadingShimmer extends StatelessWidget {
  const WeatherLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 20),
          Text(
            'Fetching weather data...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────
class WeatherErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const WeatherErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Try Again',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
