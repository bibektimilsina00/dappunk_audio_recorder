class AudioFilters {
  static const String chipmunk = 'chipmunk';
  static const String deepVoice = 'deep_voice';
  static const String telephone = 'telephone';
  static const String underwater = 'underwater';

  static const List<String> allFilters = [
    chipmunk,
    deepVoice,
    telephone,
    underwater,
  ];

  static String getFilterDisplayName(String filter) {
    switch (filter) {
      case chipmunk:
        return 'Chipmunk Voice';
      case deepVoice:
        return 'Deep Voice';
      case telephone:
        return 'Telephone Effect';
      case underwater:
        return 'Underwater Effect';
      default:
        return 'Unknown';
    }
  }

  // FFmpeg filter commands
  static String getFFmpegFilter(String filterType) {
    switch (filterType) {
      case chipmunk:
        // Speed up and increase pitch
        return 'atempo=1.5,asetrate=44100*1.5,aresample=44100';
      case deepVoice:
        // Slow down and decrease pitch
        return 'atempo=0.8,asetrate=44100*0.8,aresample=44100';
      case telephone:
        // Bandpass filter (300Hz - 3400Hz)
        return 'highpass=f=300,lowpass=f=3400';
      case underwater:
        // Lowpass filter with reverb effect
        return 'lowpass=f=1000,aecho=0.8:0.88:60:0.4';
      default:
        return '';
    }
  }
}
