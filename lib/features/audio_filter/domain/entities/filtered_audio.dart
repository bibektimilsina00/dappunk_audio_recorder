import 'package:equatable/equatable.dart';

class FilteredAudio extends Equatable {
  final String id;
  final String originalPath;
  final String filteredPath;
  final String filterType;
  final DateTime timestamp;

  const FilteredAudio({
    required this.id,
    required this.originalPath,
    required this.filteredPath,
    required this.filterType,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
    id,
    originalPath,
    filteredPath,
    filterType,
    timestamp,
  ];
}
