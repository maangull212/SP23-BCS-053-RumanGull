import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/weather_widgets.dart';
import '../widgets/search_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();

  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  String _currentCity = 'Lahore'; // default fallback

  @override
  void initState() {
    super.initState();
    _fetchWithLocation();
  }

  Future<void> _fetchWithLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        final weather = await _weatherService.fetchWeatherByCoordinates(
          position.latitude,
          position.longitude,
        );
        setState(() {
          _weather = weather;
          _currentCity = weather.cityName;
          _isLoading = false;
        });
      } else {
        await _fetchByCity(_currentCity);
      }
    } catch (e) {
      await _fetchByCity(_currentCity);
    }
  }

  Future<void> _fetchByCity(String city) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final weather = await _weatherService.fetchWeatherByCity(city);
      setState(() {
        _weather = weather;
        _currentCity = city;
        _isLoading = false;
      });
    } on WeatherException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _openSearch() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Search',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => SearchOverlay(onSearch: _fetchByCity),
      transitionBuilder: (_, anim, __, child) {
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _weather != null
        ? AppTheme.getWeatherGradient(
            _weather!.condition, _weather!.isDay)
        : AppTheme.dayGradient;

    final accent = _weather != null
        ? AppTheme.getWeatherAccent(_weather!.condition, _weather!.isDay)
        : AppTheme.sunYellow;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          decoration: BoxDecoration(gradient: gradient),
          child: SafeArea(
            child: _isLoading
                ? const WeatherLoadingShimmer()
                : _errorMessage != null
                    ? WeatherErrorWidget(
                        message: _errorMessage!,
                        onRetry: () => _fetchByCity(_currentCity),
                      )
                    : _weather != null
                        ? _buildWeatherContent(_weather!, accent)
                        : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherContent(WeatherModel weather, Color accent) {
    return RefreshIndicator(
      onRefresh: () => _fetchByCity(_currentCity),
      color: Colors.white,
      backgroundColor: Colors.transparent,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(weather, accent)),
          SliverToBoxAdapter(child: _buildMainTemp(weather)),
          SliverToBoxAdapter(child: _buildHourlySection(weather)),
          SliverToBoxAdapter(child: _buildDetailsGrid(weather, accent)),
          SliverToBoxAdapter(child: _buildSunSection(weather)),
          SliverToBoxAdapter(child: _buildDailySection(weather)),
          SliverToBoxAdapter(child: _buildFooter(weather)),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader(WeatherModel weather, Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          // Location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${weather.cityName}, ${weather.country}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ).animate().fadeIn(duration: 400.ms),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('EEEE, MMMM d').format(DateTime.now()),
                  style: const TextStyle(fontSize: 12, color: Colors.white60),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              ],
            ),
          ),
          // Action buttons
          Row(
            children: [
              _headerButton(
                icon: Icons.my_location_rounded,
                onTap: _fetchWithLocation,
              ),
              const SizedBox(width: 10),
              _headerButton(icon: Icons.search_rounded, onTap: _openSearch),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  // ── Main Temp ─────────────────────────────────────────────────────────────
  Widget _buildMainTemp(WeatherModel weather) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Big emoji + temp
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppTheme.getWeatherEmoji(weather.condition),
                style: const TextStyle(fontSize: 64),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(begin: const Offset(0.6, 0.6), duration: 500.ms),
              const SizedBox(width: 8),
              Text(
                '${weather.temperature.round()}°',
                style: const TextStyle(
                  fontSize: 88,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                  height: 1,
                ),
              ).animate().fadeIn(duration: 500.ms),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            weather.description
                .split(' ')
                .map((w) => w[0].toUpperCase() + w.substring(1))
                .join(' '),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _miniTag('H: ${weather.tempMax.round()}°', Colors.white.withOpacity(0.2)),
              const SizedBox(width: 10),
              _miniTag('L: ${weather.tempMin.round()}°', Colors.white.withOpacity(0.2)),
              const SizedBox(width: 10),
              _miniTag(
                'Feels ${weather.feelsLike.round()}°',
                Colors.white.withOpacity(0.2),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _miniTag(String text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  // ── Hourly Forecast ──────────────────────────────────────────────────────
  Widget _buildHourlySection(WeatherModel weather) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Hourly Forecast', Icons.access_time_rounded),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: weather.hourlyForecast.length,
              itemBuilder: (_, i) => HourlyForecastCard(
                data: weather.hourlyForecast[i],
                index: i,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Details Grid ──────────────────────────────────────────────────────────
  Widget _buildDetailsGrid(WeatherModel weather, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Weather Details', Icons.dashboard_rounded),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              WeatherInfoCard(
                label: 'Humidity',
                value: '${weather.humidity}',
                unit: '%',
                icon: Icons.water_drop_rounded,
                accentColor: const Color(0xFF4FC3F7),
                animationDelay: 0,
              ),
              WeatherInfoCard(
                label: 'Wind Speed',
                value: weather.windSpeed.toStringAsFixed(1),
                unit: 'm/s',
                icon: Icons.air_rounded,
                accentColor: const Color(0xFFB2DFDB),
                animationDelay: 80,
              ),
              WeatherInfoCard(
                label: 'Visibility',
                value: '${(weather.visibility / 1000).toStringAsFixed(1)}',
                unit: 'km',
                icon: Icons.visibility_rounded,
                accentColor: const Color(0xFFFFF9C4),
                animationDelay: 160,
              ),
              WeatherInfoCard(
                label: 'Pressure',
                value: '${weather.pressure}',
                unit: 'hPa',
                icon: Icons.speed_rounded,
                accentColor: const Color(0xFFCE93D8),
                animationDelay: 240,
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Sun Section ────────────────────────────────────────────────────────────
  Widget _buildSunSection(WeatherModel weather) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Sun & Moon', Icons.wb_twilight_rounded),
          const SizedBox(height: 12),
          SunriseWidget(sunrise: weather.sunrise, sunset: weather.sunset),
        ],
      ),
    );
  }

  // ── Daily Forecast ─────────────────────────────────────────────────────────
  Widget _buildDailySection(WeatherModel weather) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('5-Day Forecast', Icons.calendar_month_rounded),
          const SizedBox(height: 12),
          ...weather.dailyForecast.asMap().entries.map(
                (e) => DailyForecastRow(
                  data: e.value,
                  index: e.key,
                  isToday: e.key == 0,
                ),
              ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────────
  Widget _buildFooter(WeatherModel weather) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.refresh, color: Colors.white54, size: 13),
            const SizedBox(width: 6),
            Text(
              'Updated ${DateFormat('h:mm a').format(weather.lastUpdated)}  •  Pull to refresh',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white54,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white70,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
