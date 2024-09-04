library audio_offset;

import 'dart:io';

import 'calculators.dart';

class AudioOffset {
  String file1;
  String file2;

  AudioOffset(this.file1, this.file2);

  Future<Map<String, dynamic>> findOffsetBetweenFiles(
      {int fs = 8000,
      int? trim,
      int hopLength = 128,
      int winLength = 256,
      int nfft = 512,
      int maxFrames = 2000}) async {
    var tmp1 = await convertAndTrim(file1, fs, trim: trim);
    var tmp2 = await convertAndTrim(file2, fs, trim: trim);
    var a1 = wavRead(tmp1).toList().map((e) => e.toDouble()).toList();
    var a2 = wavRead(tmp2).toList().map((e) => e.toDouble()).toList();
    var offsetDict = await findOffsetBetweenBuffers(a1, a2, fs,
        hopLength: hopLength, winLength: winLength, nfft: nfft);
    await File(tmp1).delete();
    await File(tmp2).delete();
    return offsetDict;
  }
}
