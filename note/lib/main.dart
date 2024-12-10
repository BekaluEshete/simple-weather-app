import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'weather_provider.dart'; // Import the provider

void main() {
  runApp(const ProviderScope(child: WeatherApp()));
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  // Function to get the appropriate cloud image URL
  String getCloudImage(int cloudiness) {
    if (cloudiness > 75) {
      return 'assets/images/overcast.jpg'; // Overcast
    } else if (cloudiness > 50) {
      return 'assets/images/most.jpg'; // Mostly Cloudy
    } else if (cloudiness > 25) {
      return 'assets/images/partly.jpg'; // Partly Cloudy
    } else {
      return 'assets/images/sunny.jpg'; // Sunny
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cityController =
        TextEditingController(); // Controller for the city input

    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather App"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input Field
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF08A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    hintText: "Enter city to see the weather detail",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    prefixIcon: Icon(Icons.location_city),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Get Weather Button
              ElevatedButton(
                onPressed: () {
                  // Update the city name and refresh the weather provider
                  ref.read(cityProvider.state).state = cityController.text;
                },
                style: ElevatedButton.styleFrom(
                  shape: const ContinuousRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(23))),
                  backgroundColor: const Color.fromARGB(255, 46, 117, 189),
                ),
                child: const Text("Get Weather"),
              ),
              const SizedBox(height: 32),
              // Weather Information
              Consumer(
                builder: (context, ref, child) {
                  // Watching the weatherProvider with the entered city
                  final city = ref.watch(cityProvider.state).state;
                  final weatherAsyncValue = ref.watch(weatherProvider(city));

                  // Handling different states: loading, data, or error
                  return weatherAsyncValue.when(
                    data: (data) {
                      final temperature = data['main']['temp'];
                      final description = data['weather'][0]['description'];
                      final cityName = data['name'];
                      final clouds = data['clouds']['all'];

                      return Column(
                        children: [
                          // Cloud Image
                          Image.asset(
                            getCloudImage(clouds),
                            height: 250,
                            width: 250,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.error,
                                size: 100,
                                color: Colors.red,
                              ); // Show on error
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            cityName,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "$temperature°C",
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Cloudiness: $clouds%",
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stack) => Center(
                      child: Text(
                        "Error: there is no city name ${cityController.text}",
                        style: const TextStyle(
                            color: Color.fromARGB(255, 188, 100, 94)),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
