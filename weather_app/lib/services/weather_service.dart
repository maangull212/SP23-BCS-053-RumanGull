import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ⚠️  REPLACE THIS WITH YOUR OPENWEATHERMAP API KEY
// Get it free from: https://openweathermap.org/api
// ─────────────────────────────────────────────────────────────────────────────
const String _apiKey = 'c3051ff91121e05aa4a500c0ca3b490e';
// ─────────────────────────────────────────────────────────────────────────────

enum WeatherErrorType {
  networkError,
  cityNotFound,
  invalidApiKey,
  serverError,
  unknownError,
}

class WeatherException implements Exception {
  final WeatherErrorType type;
  final String message;
  WeatherException(this.type, this.message);

  @override
  String toString() => message;
}

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const Duration _timeout = Duration(seconds: 15);

  Future<WeatherModel> fetchWeatherByCity(String city) async {
    if (city.trim().isEmpty) {
      throw WeatherException(
        WeatherErrorType.cityNotFound,
        'Please enter a city name.',
      );
    }
    return _fetchWeather(cityQuery: 'q=${Uri.encodeComponent(city.trim())}');
  }

  Future<WeatherModel> fetchWeatherByCoordinates(
    double lat,
    double lon,
  ) async {
    return _fetchWeather(cityQuery: 'lat=$lat&lon=$lon');
  }

  Future<WeatherModel> _fetchWeather({required String cityQuery}) async {
    try {
      final currentUri = Uri.parse(
        '$_baseUrl/weather?$cityQuery&appid=$_apiKey&units=metric',
      );
      final forecastUri = Uri.parse(
        '$_baseUrl/forecast?$cityQuery&appid=$_apiKey&units=metric&cnt=40',
      );

      final responses = await Future.wait([
        http.get(currentUri).timeout(_timeout),
        http.get(forecastUri).timeout(_timeout),
      ]);

      final currentRes = responses[0];
      final forecastRes = responses[1];

      // Handle current weather
      if (currentRes.statusCode == 200 && forecastRes.statusCode == 200) {
        final currentData = json.decode(currentRes.body);
        final forecastData = json.decode(forecastRes.body);
        return WeatherModel.fromJson(currentData, forecastData);
      }

      // Handle errors
      _handleHttpError(currentRes.statusCode, currentRes.body);
      _handleHttpError(forecastRes.statusCode, forecastRes.body);
      throw WeatherException(
        WeatherErrorType.unknownError,
        'Something went wrong. Please try again.',
      );
    } on SocketException {
      throw WeatherException(
        WeatherErrorType.networkError,
        'No internet connection. Please check your network.',
      );
    } on HttpException {
      throw WeatherException(
        WeatherErrorType.networkError,
        'Network error occurred. Please try again.',
      );
    } on WeatherException {
      rethrow;
    } catch (e) {
      throw WeatherException(
        WeatherErrorType.unknownError,
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  void _handleHttpError(int statusCode, String body) {
    if (statusCode == 200) return;
    if (statusCode == 401) {
      throw WeatherException(
        WeatherErrorType.invalidApiKey,
        'Invalid API key. Please check your OpenWeatherMap API key.',
      );
    }
    if (statusCode == 404) {
      throw WeatherException(
        WeatherErrorType.cityNotFound,
        'City not found. Please check the spelling and try again.',
      );
    }
    if (statusCode >= 500) {
      throw WeatherException(
        WeatherErrorType.serverError,
        'Weather service is temporarily unavailable. Please try later.',
      );
    }
    throw WeatherException(
      WeatherErrorType.unknownError,
      'Request failed with status $statusCode.',
    );
  }
}
