import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/filtered_audio.dart';

abstract class FilterRepository {
  Future<Either<Failure, String>> applyFilter({
    required String inputPath,
    required String filterType,
  });

  Future<Either<Failure, List<FilteredAudio>>> getFilteredAudios();
  Future<Either<Failure, void>> deleteFilteredAudio(String id);
}
