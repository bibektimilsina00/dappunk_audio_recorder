import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/recording_repository.dart';

class PlayRecording implements UseCase<void, PlayRecordingParams> {
  final RecordingRepository repository;

  PlayRecording(this.repository);

  @override
  Future<Either<Failure, void>> call(PlayRecordingParams params) async {
    return await repository.playRecording(params.path);
  }
}

class PlayRecordingParams extends Equatable {
  final String path;

  const PlayRecordingParams({required this.path});

  @override
  List<Object> get props => [path];
}
