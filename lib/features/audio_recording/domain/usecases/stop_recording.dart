import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/recording_repository.dart';

class StopRecording implements UseCase<String, NoParams> {
  final RecordingRepository repository;

  StopRecording(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await repository.stopRecording();
  }
}
