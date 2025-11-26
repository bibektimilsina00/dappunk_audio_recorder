import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/filter_repository.dart';

class ApplyAudioFilter implements UseCase<String, ApplyAudioFilterParams> {
  final FilterRepository repository;

  ApplyAudioFilter(this.repository);

  @override
  Future<Either<Failure, String>> call(ApplyAudioFilterParams params) async {
    return await repository.applyFilter(
      inputPath: params.inputPath,
      filterType: params.filterType,
    );
  }
}

class ApplyAudioFilterParams extends Equatable {
  final String inputPath;
  final String filterType;

  const ApplyAudioFilterParams({
    required this.inputPath,
    required this.filterType,
  });

  @override
  List<Object> get props => [inputPath, filterType];
}
