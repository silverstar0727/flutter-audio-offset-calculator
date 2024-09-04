import 'dart:io';
import 'dart:math';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:path/path.dart' as path;
import 'mfcc.dart';

class InsufficientAudioException implements Exception {
  final String message;

  InsufficientAudioException(this.message);
}

Future<Map<String, dynamic>> findOffsetBetweenBuffers(
    List<double> buffer1, List<double> buffer2, int fs,
    {int hopLength = 128,
    int winLength = 256,
    int nfft = 512,
    int maxFrames = 2000}) async {
  var mfcc1 = MFCC.mfccFeats(buffer1, fs, winLength, hopLength, nfft, 26, 26);
  var mfcc2 = MFCC.mfccFeats(buffer2, fs, winLength, hopLength, nfft, 26, 26);

  mfcc1 = stdMfcc(mfcc1);
  mfcc2 = stdMfcc(mfcc2);

  var correlNframes =
      min((mfcc1.length / 3).floor(), min(mfcc2.length, maxFrames));
  if (correlNframes < 10) {
    throw InsufficientAudioException(
        "Not enough audio to analyse - try longer clips, less trimming, or higher resolution.");
  }

  var result = await crossCorrelation(mfcc1, mfcc2, nframes: correlNframes);
  var c = result[0];
  var earliestFrameOffset = result[1];
  var latestFrameOffset = result[2];

  var maxKIndex = c.indexOf(c.reduce(max));
  var maxKFrameOffset = maxKIndex;
  if (maxKFrameOffset > latestFrameOffset) {
    maxKFrameOffset -= c.length;
  }
  var timeScale = hopLength / fs;
  var timeOffset = maxKFrameOffset * timeScale;

  var score = c.reduce((a, b) => a + b) < 1e-10
      ? double.infinity
      : (c[maxKIndex] - c.reduce((a, b) => a + b)) / c.reduce((a, b) => a + b);
  return {
    "time_offset": timeOffset,
    "frame_offset": maxKFrameOffset,
    "standard_score": score,
    "correlation": c,
    "time_scale": timeScale,
    "earliest_frame_offset": earliestFrameOffset,
    "latest_frame_offset": latestFrameOffset,
  };
}

Future<List<dynamic>> crossCorrelation(
    List<List<double>> mfcc1, List<List<double>> mfcc2,
    {required int nframes}) async {
  var n1 = mfcc1.length;
  var n2 = mfcc2.length;
  var oMin = nframes - n2;
  var oMax = n1 - nframes + 1;
  var n = oMax - oMin;
  var c = List<double>.filled(n, 0);
  for (var k = oMin; k < 0; k++) {
    var cc =
        dotProduct(mfcc1.sublist(0, nframes), mfcc2.sublist(-k, nframes - k));
    c[k] = norm(cc);
  }
  for (var k = 0; k < oMax; k++) {
    var cc =
        dotProduct(mfcc1.sublist(k, k + nframes), mfcc2.sublist(0, nframes));
    c[k] = norm(cc);
  }
  return [c, oMin, oMax];
}

List<List<double>> stdMfcc(List<List<double>> array) {
  var meanArray =
      array.map((row) => row.reduce((a, b) => a + b) / row.length).toList();
  var stdArray = array
      .map((row) => sqrt(row
              .map((val) => pow(val - meanArray[array.indexOf(row)], 2))
              .reduce((a, b) => a + b) /
          row.length))
      .toList();
  return array
      .map((row) => List<double>.generate(
          row.length,
          (i) =>
              (row[i] - meanArray[array.indexOf(row)]) /
              stdArray[array.indexOf(row)]))
      .toList();
}

Future<String> convertAndTrim(String afile, int fs, {int? trim}) async {
  var tmpDir = Directory.systemTemp.createTempSync();
  var tmpPath = path.join(
      tmpDir.path, 'offset_${DateTime.now().millisecondsSinceEpoch}.wav');

  var ffmpegCommand = [
    '-loglevel',
    'error',
    '-i',
    afile,
    '-ac',
    '1',
    '-ar',
    '$fs',
    '-ss',
    '0'
  ];
  if (trim != null) {
    ffmpegCommand.addAll(['-t', '$trim']);
  }
  ffmpegCommand.addAll(['-acodec', 'pcm_s16le', tmpPath]);

  await FFmpegKit.execute(ffmpegCommand.join(' '));
  return tmpPath;
}

List<int> wavRead(String filePath) {
  // 다트에서 WAV 파일을 읽는 방법입니다. WAV 파일 읽기 라이브러리 또는 직접 파싱해야 합니다.
  var file = File(filePath);
  var bytes = file.readAsBytesSync();
  // WAV 파일의 샘플 데이터를 읽는다고 가정합니다.
  return bytes.buffer.asInt16List().toList();
}

List<double> dotProduct(List<List<double>> a, List<List<double>> b) {
  var result = List<double>.filled(a[0].length, 0);
  for (var i = 0; i < a.length; i++) {
    for (var j = 0; j < a[0].length; j++) {
      result[j] += a[i][j] * b[i][j];
    }
  }
  return result;
}

double norm(List<double> a) {
  return sqrt(a.map((x) => pow(x, 2)).reduce((a, b) => a + b));
}
