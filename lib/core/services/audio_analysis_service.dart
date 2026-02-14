import 'dart:math';

class AudioAnalysisService {
  // Simulate Cloud Function for BPM detection
  Future<double> detectBPM(String filePath) async {
    // In a real app, this would call a Cloud Function or native library (e.g., using ffmpeg/librosa)
    // Here we simulate detection with a delay.
    await Future.delayed(const Duration(seconds: 1));

    // Generate a consistent pseudo-random BPM based on file path
    final hash = filePath.hashCode;
    final random = Random(hash);

    // BPM range 70-160
    final bpm = 70.0 + random.nextInt(90);

    return double.parse(bpm.toStringAsFixed(1));
  }

  // Returns a list of changes: {timestamp_seconds: bpm}
  Future<Map<double, double>> analyzeFluidBeatgrid(String filePath) async {
    // Simulate complex analysis
    await Future.delayed(const Duration(milliseconds: 500));

    final hash = filePath.hashCode;
    final random = Random(hash);
    final baseBpm = 70.0 + random.nextInt(90);

    final Map<double, double> bpmMap = {};
    bpmMap[0.0] = double.parse(baseBpm.toStringAsFixed(1));

    // Simulate drift every 30-60 seconds
    double currentBpm = baseBpm;
    double time = 0.0;

    // Generate up to 5 minutes of data
    for (int i = 0; i < 10; i++) {
      time += 30 + random.nextInt(30);
      // Drift by +/- 2 BPM
      currentBpm += (random.nextDouble() * 4) - 2;
      bpmMap[time] = double.parse(currentBpm.toStringAsFixed(1));
    }

    return bpmMap;
  }
}
