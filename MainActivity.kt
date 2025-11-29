// Register method handlers
methodChannel.setMethodCallHandler { call, result ->
    when (call.method) {
        "getWaveformData" -> {
            val deck = call.argument<String>("deck") ?: "A"
            result.success(audioEngine.getWaveformData(deck))
        }
        "getBeatPositions" -> {
            val deck = call.argument<String>("deck") ?: "A"
            result.success(audioEngine.getBeatPositions(deck))
        }
        // ...other methods...
    }
}

// Register EventChannel for playback position
val playbackPositionChannel = EventChannel(flutterEngine.dartExecutor, "com.djpro.audio/playbackPosition")
audioEngine.setupPlaybackPositionChannel(playbackPositionChannel)