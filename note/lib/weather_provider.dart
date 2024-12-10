import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

// Create a provider for fetching weather data
final cityProvider = StateProvider<String>((ref) => '');
final weatherProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, city) async {
    if (city.isEmpty) {
      throw Exception("City name cannot be empty");
    }

    //  API key
    const apiKey = '50da5fe8f25e1d65788a4ed8cf98b984';
    const baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

    final dio = Dio();

    // API request
    final response = await dio.get(
      baseUrl,
      queryParameters: {
        'q': city,
        'appid': apiKey,
        'units': 'metric', // To get temperature in Celsius
      },
    );

    // Check response status and return data
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to fetch weather data');
    }
  },
);
