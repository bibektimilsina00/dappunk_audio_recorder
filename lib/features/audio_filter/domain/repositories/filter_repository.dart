import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/filter_type.dart';

abstract class FilterRepository {
  /// Applies a FFmpeg filter of [type] to [inputPath] and writes the output file to [outputPath].
  /// Returns the path of the filtered output file.
  Future<Either<Failure, String>> applyFilter({
    required String inputPath,
    required String outputPath,
    required FilterType type,
  });
}
