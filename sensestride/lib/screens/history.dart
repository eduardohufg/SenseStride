import 'package:flutter/material.dart';
import 'dart:math';
import 'package:sizer/sizer.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  // Generar una lista de datos de entrenamiento aleatorios
  List<TrainingData> generateTrainingData(int count) {
    Random random = Random();
    List<TrainingData> data = [];

    for (int i = 0; i < count; i++) {
      double averageSpeed = double.parse(((random.nextDouble() * 10) + 5)
          .toStringAsFixed(2)); // Entre 5 y 15 km/h
      double maxSpeed = double.parse(((random.nextDouble() * 15) + 10)
          .toStringAsFixed(2)); // Entre 10 y 25 km/h
      double maxAcceleration = double.parse(((random.nextDouble() * 5) + 1)
          .toStringAsFixed(2)); // Entre 1 y 6 m/s²
      double distance = double.parse(((random.nextDouble() * 10) + 1)
          .toStringAsFixed(2)); // Entre 1 y 11 km
      String time =
          '${random.nextInt(3)}:${random.nextInt(60).toString().padLeft(2, '0')}:${random.nextInt(60).toString().padLeft(2, '0')}'; // Tiempo aleatorio

      data.add(
        TrainingData(
          averageSpeed: averageSpeed,
          maxSpeed: maxSpeed,
          maxAcceleration: maxAcceleration,
          distance: distance,
          time: time,
        ),
      );
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    // Generar 10 entradas de datos de entrenamiento
    List<TrainingData> trainingDataList = generateTrainingData(10);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Entrenamientos'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: ListView.builder(
          itemCount: trainingDataList.length,
          itemBuilder: (context, index) {
            final data = trainingDataList[index];
            return Card(
              color: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Entrenamiento ${index + 1}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Divider(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withOpacity(0.5),
                      thickness: 1,
                    ),
                    SizedBox(height: 1.h),
                    InfoRow(
                      label: 'Velocidad Promedio',
                      value: '${data.averageSpeed} km/h',
                    ),
                    SizedBox(height: 0.5.h),
                    InfoRow(
                      label: 'Velocidad Máxima',
                      value: '${data.maxSpeed} km/h',
                    ),
                    SizedBox(height: 0.5.h),
                    InfoRow(
                      label: 'Aceleración Máxima',
                      value: '${data.maxAcceleration} m/s²',
                    ),
                    SizedBox(height: 0.5.h),
                    InfoRow(
                      label: 'Distancia Recorrida',
                      value: '${data.distance} km',
                    ),
                    SizedBox(height: 0.5.h),
                    InfoRow(
                      label: 'Tiempo',
                      value: data.time,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Widget personalizado para mostrar una fila de información
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onPrimary,
            )),
        Text(value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onPrimary,
            )),
      ],
    );
  }
}

class TrainingData {
  final double averageSpeed;
  final double maxSpeed;
  final double maxAcceleration;
  final double distance;
  final String time;

  TrainingData({
    required this.averageSpeed,
    required this.maxSpeed,
    required this.maxAcceleration,
    required this.distance,
    required this.time,
  });
}
