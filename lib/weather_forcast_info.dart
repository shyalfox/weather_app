import 'package:flutter/material.dart';

class HourelyForecast extends StatelessWidget {
  final String date;
  final IconData weather;
  final String temperature;
  const HourelyForecast({
    super.key,
    required this.date,
    required this.weather,
    required this.temperature,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              date,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(
              height: 8,
            ),
            Icon(
              weather,
              size: 32,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(temperature),
          ],
        ),
      ),
    );
  }
}
