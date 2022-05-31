import 'dart:math';

int rng(int min, int max) {
  if (min == max) return min;
  return Random().nextInt(max - min) + min;
}

String durationFormat(Duration duration) {
  return duration.toString().split('.').first.padLeft(8, "0");
}
