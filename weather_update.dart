import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_unit.dart';
import 'package:weather_app/hour_forecast_unit.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherUpdate extends StatefulWidget {
  const WeatherUpdate({super.key});

  @override
  State<WeatherUpdate> createState() => _WeatherUpdateState();
}

class _WeatherUpdateState extends State<WeatherUpdate> {
  late Future<Map<String, dynamic>> weather;

  Future<Map<String, dynamic>> getLatestWeather() async {
    try {
      String cityName = 'London';
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey',
        ),
      );

      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'An unexpected error occured';
      }

      return data;

      //
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getLatestWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getLatestWeather();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
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
              child: Text(snapshot.error.toString()),
            );
          }
          final data = snapshot.data!;
          final currentWeatherData = snapshot.data?['list'][0];

          final currentTemp = currentWeatherData['main']['temp'];
          final currentSky = currentWeatherData['weather'][0]['main'];
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentWind = currentWeatherData['wind']['speed'];
          final currentHumidity = currentWeatherData['main']['humidity'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 10,
                          sigmaY: 10,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$currentTemp K',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Icon(
                                currentSky == 'Clouds' || currentSky == 'Rain'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 62,
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                currentSky,
                                style: const TextStyle(fontSize: 22),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Hourly Forecast',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       for (int i = 0; i < 8; i++)
                //         HourForecastUnit(
                //           time: data['list'][i + 1]['dt'].toString(),
                //           icon: data['list'][i + 1]['weather'][0]['main'] ==
                //                       'Clouds' ||
                //                   data['list'][i + 1]['weather'][0]['main'] ==
                //                       'Rain'
                //               ? Icons.cloud
                //               : Icons.sunny,
                //           temp: data['list'][i + 1]['main']['temp'].toString(),
                //         ),
                //     ],
                //   ),
                // ),

                SizedBox(
                  height: 120,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        final hourlyForecast = data['list'][index + 1];
                        final hourlySky =
                            data['list'][index + 1]['weather'][0]['main'];
                        final hourlyTemp =
                            hourlyForecast['main']['temp'].toString();
                        final time = DateTime.parse(hourlyForecast['dt_txt']);

                        return HourForecastUnit(
                          time: DateFormat.jm().format(time),
                          temp: hourlyTemp,
                          icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                              ? Icons.cloud
                              : Icons.sunny,
                        );
                      }),
                ),

                //weather forcast cards
                const SizedBox(
                  height: 20,
                ),

                const Text(
                  'Additional Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfoUnit(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: currentHumidity.toString(),
                    ),
                    AdditionalInfoUnit(
                      icon: Icons.air,
                      label: 'Wind Speed',
                      value: currentWind.toString(),
                    ),
                    AdditionalInfoUnit(
                      icon: Icons.speed_sharp,
                      label: 'Pressure',
                      value: currentPressure.toString(),
                    ),
                  ],
                ),
                //additional information
              ],
            ),
          );
        },
      ),
    );
  }
}
