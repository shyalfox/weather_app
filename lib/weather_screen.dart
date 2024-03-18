import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weather_app/secret.dart';
import 'package:weather_app/weather_additional_info.dart';
import 'package:weather_app/weather_forcast_info.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather = getCurrentWeather();
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'Kathmandu';
      final res = await http.get(
        Uri.parse(
            'http://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$secretKey'),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw 'An unexoected error occoured';
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather();
              });
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: FutureBuilder(
          future: weather,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  snapshot.toString(),
                ),
              );
            }

            final data = snapshot.data!;
            final currentWeatherData = data['list'][0];

            final currentTemp = currentWeatherData['main']['temp'];
            final currentSky = currentWeatherData['weather'][0]['main'];
            final currentHumidity = currentWeatherData['main']['humidity'];
            final currentWind = currentWeatherData['wind']['speed'];
            final currentPressure = currentWeatherData['main']['pressure'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  '$currentTemp °K',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Icon(
                                  currentSky == 'Clouds'
                                      ? Icons.cloud
                                      : currentSky == 'Rain'
                                          ? Icons.grain
                                          : Icons.wb_sunny,
                                  size: 64,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '$currentSky',
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Hourly Forcast',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // SingleChildScrollView(
                  //   scrollDirection: Axis.horizontal,
                  //   child: Row(
                  //     children: [
                  //       //   for (int i = 0; i < 5; i++)
                  //       //     HourelyForecast(
                  //       //       date: data['list'][i + 1]['dt_txt'],
                  //       //       weather: data['list'][i + 1]['weather'][0]
                  //       //                       ['main'] ==
                  //       //                   'Clouds' ||
                  //       //               data['list'][i + 1]['weather'][0]['main'] ==
                  //       //                   'Rain'
                  //       //           ? Icons.cloud
                  //       //           : Icons.sunny,
                  //       //       temperature:
                  //       //           '${data['list'][i + 1]['main']['temp']}°K',
                  //       //     ),
                  //     ],
                  //   ),
                  // ),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      itemCount: 10,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final hourelyForecast = data['list'][index + 1];
                        final skyClouds = hourelyForecast['weather'][0]['main'];
                        final hourlyTemp = hourelyForecast['main']['temp'];
                        final hourlyTime = DateTime.parse(
                          hourelyForecast['dt_txt'],
                        );
                        return HourelyForecast(
                          date: DateFormat.j().format(hourlyTime),
                          weather: skyClouds == 'Clouds'
                              ? Icons.cloud
                              : skyClouds == 'Rain'
                                  ? Icons.grain
                                  : Icons.wb_sunny,
                          temperature: '$hourlyTemp°K',
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Additional Information',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AdditionalInfo(
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        value: currentHumidity.toString(),
                      ),
                      AdditionalInfo(
                        icon: Icons.air,
                        label: 'Wind Speed',
                        value: currentWind.toString(),
                      ),
                      AdditionalInfo(
                        icon: Icons.beach_access,
                        label: 'Pressure',
                        value: currentPressure.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }
}
