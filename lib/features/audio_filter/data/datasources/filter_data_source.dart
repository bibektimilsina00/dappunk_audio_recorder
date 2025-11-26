import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

abstract class FilterDataSource {
  Future<String> applyFilter({
    required String inputPath,
    required String outputPath,
    required String filterCommand,
  });

  Future<bool> isFFmpegAvailable();
}

class FilterDataSourceImpl implements FilterDataSource {
  @override
  Future<String> applyFilter({
    required String inputPath,
    required String outputPath,
    required String filterCommand,
  }) async {
    final command = '-y -i "$inputPath" -af "$filterCommand" "$outputPath"';
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return outputPath;
    } else {
      final output = await session.getOutput();
      final failStackTrace = await session.getFailStackTrace();
      throw Exception('FFmpeg failed: $output\n$failStackTrace');
    }
  }

  @override
  Future<bool> isFFmpegAvailable() async {
    try {
      final session = await FFmpegKit.execute('-version');
      final returnCode = await session.getReturnCode();
      return ReturnCode.isSuccess(returnCode);
    } catch (e) {
      return false;
    }
  }
}
