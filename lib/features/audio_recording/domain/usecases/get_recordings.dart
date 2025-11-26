import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/recording.dart';
import '../repositories/recording_repository.dart';

class GetRecordings implements UseCase<List<Recording>, NoParams> {
  final RecordingRepository repository;

  GetRecordings(this.repository);

  @override
  Future<Either<Failure, List<Recording>>> call(NoParams params) async {
    return await repository.getRecordings();
  }
}
