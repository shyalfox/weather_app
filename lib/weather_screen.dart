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
  final TextEditingController textEditingController = TextEditingController();
  bool showSuggestions = false;
  String weatherCity = 'Kathmandu';
  late Future<Map<String, dynamic>> weather = getCurrentWeather();
  bool isAvailable = true;

  String capitalize(String s) {
    return s.substring(0, 1).toUpperCase() + s.substring(1);
  }

  void updateCity(String newCity) {
    var city = newCity.toLowerCase();
    city = capitalize(city);

    if (suggestions.contains(city)) {
      setState(() {
        weatherCity = city;
        isAvailable = true;
      });
    } else {
      setState(() {
        isAvailable = false;
      });
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree
    textEditingController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      final res = await http.get(
        Uri.parse(
            'http://api.openweathermap.org/data/2.5/forecast?q=$weatherCity&APPID=$secretKey'),
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
      body: isAvailable
          ? SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  FutureBuilder(
                      future: weather,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: Text(
                                  //snapshot.toString(),
                                  'Please check youror Internet\nOR\nUnexpected Error has Occoured',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          );
                        }

                        final data = snapshot.data!;
                        final currentWeatherData = data['list'][0];
                        final currentCityData = data['city'];
                        String currentCity = currentCityData['name'];
                        final currentCountry = currentCityData['country'];

                        final currentTemp = currentWeatherData['main']['temp'];
                        final currentSky =
                            currentWeatherData['weather'][0]['main'];
                        final currentHumidity =
                            currentWeatherData['main']['humidity'];
                        final currentWind = currentWeatherData['wind']['speed'];
                        final currentPressure =
                            currentWeatherData['main']['pressure'];

                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  elevation: 10,
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: textEditingController,
                                        decoration: InputDecoration(
                                          hintText: 'Enter City',
                                          filled: false,
                                          border: InputBorder.none,
                                          prefixIcon:
                                              const Icon(Icons.location_city),
                                          suffixIcon: IconButton(
                                              onPressed: () {
                                                updateCity(
                                                    textEditingController.text);
                                                // checkCountry(
                                                //     textEditingController.text);

                                                weather = getCurrentWeather();
                                                textEditingController.clear();
                                              },
                                              icon: const Icon(Icons.search)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    elevation: 10,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 10, sigmaY: 10),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            children: [
                                              Text(
                                                '$currentCity,$currentCountry',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 26,
                                                ),
                                              ),
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
                                                style: const TextStyle(
                                                    fontSize: 20),
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
                                      final hourelyForecast =
                                          data['list'][index + 1];
                                      final skyClouds =
                                          hourelyForecast['weather'][0]['main'];
                                      final hourlyTemp =
                                          hourelyForecast['main']['temp'];
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
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
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ],
              ),
            )
          : Center(
              child: Column(
              children: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        updateCity('Kathmandu');
                        getCurrentWeather();
                        isAvailable = true;
                      });
                    },
                    icon: const Icon(Icons.refresh)),
                const Text('No City Found With That Name'),
              ],
            )),
    );
  }
}
