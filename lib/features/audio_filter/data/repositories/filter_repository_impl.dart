import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/audio_failures.dart';
import '../../domain/entities/filter_type.dart';
import '../../domain/repositories/filter_repository.dart';
import '../datasources/filter_data_source.dart';

class FilterRepositoryImpl implements FilterRepository {
  final FilterDataSource dataSource;

  FilterRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, String>> applyFilter({
    required String inputPath,
    required String outputPath,
    required FilterType type,
  }) async {
    try {
      String filterCommand;

      switch (type) {
        case FilterType.chipmunk:
          filterCommand = 'asetrate=44100*1.5,aresample=44100,atempo=1.0';
          break;
        case FilterType.deep:
          filterCommand = 'asetrate=44100*0.75,aresample=44100,atempo=1.0';
          break;
        case FilterType.telephone:
          filterCommand = 'highpass=f=300,lowpass=f=3400';
          break;
        case FilterType.underwater:
          filterCommand = 'lowpass=f=800,aecho=0.8:0.9:1000:0.3';
          break;
      }

      final resultPath = await dataSource.applyFilter(
        inputPath: inputPath,
        outputPath: outputPath,
        filterCommand: filterCommand,
      );
      return Right(resultPath);
    } catch (e) {
      return Left(FilterFailure(e.toString()));
    }
  }
}
