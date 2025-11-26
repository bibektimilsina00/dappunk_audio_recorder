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

 
}
