import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../providers/weather_provider.dart';

class WeatherDetailsScreen extends StatefulWidget {
  const WeatherDetailsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WeatherDetailsScreenState createState() => _WeatherDetailsScreenState();
}

class _WeatherDetailsScreenState extends State<WeatherDetailsScreen> {
  late VideoPlayerController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/background_two.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _refreshWeather(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final weatherProvider =
        Provider.of<WeatherProvider>(context, listen: false);
    final cityName = weatherProvider.lastSearchedCity;

    await weatherProvider.fetchWeather(cityName);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final weather = weatherProvider.weather;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Weather Details'),
        titleTextStyle: const TextStyle(
          fontFamily: 'CustomFont',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(235, 255, 255, 255),
        ),
      ),
      body: Stack(
        children: [
          // Video Background
          _controller.value.isInitialized
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                )
              : Container(color: Colors.black),
          // Foreground Content
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Container(
                  color: const Color.fromARGB(
                      20, 0, 0, 0), // Semi-transparent overlay
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 120),
                      if (weather != null)
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.all(20.0),
                            children: [
                              _buildWeatherDetailCard('City', weather.cityName),
                              _buildWeatherDetailCard(
                                  'Temperature', '${weather.temperature}°C'),
                              _buildWeatherDetailCard(
                                  'Condition', weather.condition),
                              _buildWeatherDetailCard(
                                  'Humidity', '${weather.humidity}%'),
                              _buildWeatherDetailCard(
                                  'Wind Speed', '${weather.windSpeed} m/s'),
                              _buildWeatherDetailCard(
                                  'Feels Like', '${weather.feelsLike}°C'),
                              _buildWeatherDetailCard(
                                  'Sunrise', weather.sunrise),
                              _buildWeatherDetailCard('Sunset', weather.sunset),
                            ],
                          ),
                        ),
                      ElevatedButton(
                        onPressed: () => _refreshWeather(context),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue[700],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 20),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('Refresh'),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetailCard(String title, String value) {
    return Card(
      color: Colors.white.withOpacity(0.8),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
