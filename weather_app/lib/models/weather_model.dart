class WeatherModel {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final String condition;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final int visibility;
  final int pressure;
  final double uvIndex;
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime lastUpdated;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;

  WeatherModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.condition,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.visibility,
    required this.pressure,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
    required this.lastUpdated,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  bool get isDay {
    final now = DateTime.now();
    return now.isAfter(sunrise) && now.isBefore(sunset);
  }

  String get temperatureDisplay => '${temperature.round()}°';

  factory WeatherModel.fromJson(
    Map<String, dynamic> current,
    Map<String, dynamic> forecast,
  ) {
    // Parse hourly (next 24h from forecast)
    final List<HourlyForecast> hourly = [];
    final forecastList = forecast['list'] as List;
    for (int i = 0; i < forecastList.length && i < 8; i++) {
      hourly.add(HourlyForecast.fromJson(forecastList[i]));
    }

    // Parse daily (group by day, take min/max)
    final Map<String, DailyForecast> dailyMap = {};
    for (final item in forecastList) {
      final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      final key = '${dt.year}-${dt.month}-${dt.day}';
      if (!dailyMap.containsKey(key)) {
        dailyMap[key] = DailyForecast.fromJson(item);
      } else {
        dailyMap[key] = dailyMap[key]!.mergeWith(item);
      }
    }
    final daily = dailyMap.values.take(5).toList();

    final sys = current['sys'];
    return WeatherModel(
      cityName: current['name'],
      country: sys['country'],
      temperature: (current['main']['temp'] as num).toDouble(),
      feelsLike: (current['main']['feels_like'] as num).toDouble(),
      tempMin: (current['main']['temp_min'] as num).toDouble(),
      tempMax: (current['main']['temp_max'] as num).toDouble(),
      condition: current['weather'][0]['main'],
      description: current['weather'][0]['description'],
      iconCode: current['weather'][0]['icon'],
      humidity: current['main']['humidity'],
      windSpeed: (current['wind']['speed'] as num).toDouble(),
      visibility: current['visibility'] ?? 10000,
      pressure: current['main']['pressure'],
      uvIndex: 0,
      sunrise: DateTime.fromMillisecondsSinceEpoch(sys['sunrise'] * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(sys['sunset'] * 1000),
      lastUpdated: DateTime.now(),
      hourlyForecast: hourly,
      dailyForecast: daily,
    );
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final String iconCode;
  final String description;
  final double windSpeed;
  final int humidity;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.iconCode,
    required this.description,
    required this.windSpeed,
    required this.humidity,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: (json['main']['temp'] as num).toDouble(),
      iconCode: json['weather'][0]['icon'],
      description: json['weather'][0]['description'],
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      humidity: json['main']['humidity'],
    );
  }
}

class DailyForecast {
  final DateTime date;
  double tempMin;
  double tempMax;
  final String iconCode;
  final String description;

  DailyForecast({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.iconCode,
    required this.description,
  });

  DailyForecast mergeWith(Map<String, dynamic> json) {
    final t = (json['main']['temp'] as num).toDouble();
    tempMin = t < tempMin ? t : tempMin;
    tempMax = t > tempMax ? t : tempMax;
    return this;
  }

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final temp = (json['main']['temp'] as num).toDouble();
    return DailyForecast(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      tempMin: temp,
      tempMax: temp,
      iconCode: json['weather'][0]['icon'],
      description: json['weather'][0]['description'],
    );
  }
}
