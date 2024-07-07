import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Weather {
  final String cityName;
  final double temperature;
  final String condition;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final double feelsLike;
  final int visibility;
  final String sunrise;
  final String sunset;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.feelsLike,
    required this.visibility,
    required this.sunrise,
    required this.sunset,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      condition: json['weather'][0]['main'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      pressure: json['main']['pressure'],
      feelsLike: json['main']['feels_like'].toDouble(),
      visibility: json['visibility'],
      sunrise:
          DateTime.fromMillisecondsSinceEpoch(json['sys']['sunrise'] * 1000)
              .toLocal()
              .toString(),
      sunset: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunset'] * 1000)
          .toLocal()
          .toString(),
    );
  }
}

class WeatherProvider with ChangeNotifier {
  Weather? _weather;
  String _lastSearchedCity = '';

  Weather? get weather => _weather;
  String get lastSearchedCity => _lastSearchedCity;

  Future<void> fetchWeather(String cityName) async {
    const apiKey = 'e9fafa1a9c97966fa2bea255b07084bf';
    final url =
        'http://api.openweathermap.org/data/2.5/weather?q=$cityName&units=metric&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final weatherJson = json.decode(response.body);
        _weather = Weather.fromJson(weatherJson);
        _lastSearchedCity = cityName;
        notifyListeners();
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (error) {
      rethrow;
    }
  }
}
