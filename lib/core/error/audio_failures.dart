import '../error/failures.dart';

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

class RecordingFailure extends Failure {
  const RecordingFailure(super.message);
}

class PlaybackFailure extends Failure {
  const PlaybackFailure(super.message);
}

class FilterFailure extends Failure {
  const FilterFailure(super.message);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}
