enum FilterType {
  chipmunk,
  deep,
  telephone,
  underwater,
}

extension FilterTypeExtensions on FilterType {
  String get name {
    switch (this) {
      case FilterType.chipmunk:
        return 'Chipmunk';
      case FilterType.deep:
        return 'Deep Voice';
      case FilterType.telephone:
        return 'Telephone';
      case FilterType.underwater:
        return 'Underwater';
    }
  }
}
