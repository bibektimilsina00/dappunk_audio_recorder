import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/repositories/filter_repository.dart';
import '../entities/filter_type.dart';

class ApplyFilter implements UseCase<String, ApplyFilterParams> {
  final FilterRepository repository;

  ApplyFilter(this.repository);

  @override
  Future<Either<Failure, String>> call(ApplyFilterParams params) async {
    return await repository.applyFilter(
      inputPath: params.inputPath,
      outputPath: params.outputPath,
      type: params.type,
    );
  }
}

class ApplyFilterParams {
  final String inputPath;
  final String outputPath;
  final FilterType type;

  ApplyFilterParams({
    required this.inputPath,
    required this.outputPath,
    required this.type,
  });
}
