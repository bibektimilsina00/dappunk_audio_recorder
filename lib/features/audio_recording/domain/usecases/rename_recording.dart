import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/recording_repository.dart';

class RenameRecording implements UseCase<void, RenameRecordingParams> {
  final RecordingRepository repository;

  RenameRecording(this.repository);

  @override
  Future<Either<Failure, void>> call(RenameRecordingParams params) {
    return repository.renameRecording(params.id, params.newName);
  }
}

class RenameRecordingParams {
  final String id;
  final String newName;

  RenameRecordingParams({required this.id, required this.newName});
}
