# audio_offset

The `audio_offset` package helps you to find the time offset between two audio files. This is
particularly useful when synchronizing audio tracks or identifying alignment differences between two
sound recordings. The package utilizes features like Mel Frequency Cepstral Coefficients (MFCC) to
compute correlations and identify the time delay between the two audio inputs.

## Features

- **Audio Offset Detection**: Find the time offset between two audio files, even when recorded in
  different environments or with different devices.
- **Support for WAV Files**: Processes `.wav` files by converting them using FFmpeg, ensuring
  compatibility with various audio formats.
- **Highly Configurable**: Customize parameters like sample rate (`fs`), trimming duration, hop
  length, window length, and FFT size to tune the analysis.
- **Efficient MFCC Computation**: Leverages MFCC features to detect patterns and align the audio
  signals accurately.
- **Cross-Correlation for Audio Analysis**: Utilizes cross-correlation techniques to determine the
  best time alignment between audio signals.

## Getting Started

### Prerequisites

Before using this package, ensure the following dependencies are set up in your project:

- Add the necessary dependencies in your `pubspec.yaml` file:

  ```yaml
  dependencies:
    ffmpeg_kit_flutter: ^4.5.1
    path: ^1.8.0
    fftea: ^0.3.3
  ```

    - **FFmpeg**: This package relies on FFmpeg for audio conversion, so ensure it is installed and
      integrated into your environment.

### Installation

Add the following to your pubspec.yaml:

```yaml
dependencies:
  audio_offset: ^0.1.0
```

### Usage

Here's how you can use the package to compute the offset between two audio files:
```dart
import 'package:audio_offset/audio_offset.dart';

void main() async {
  // Path to two audio files
  String file1 = "path/to/first/audio.wav";
  String file2 = "path/to/second/audio.wav";
  
  // Create an instance of AudioOffset
  AudioOffset audioOffset = AudioOffset(file1, file2);
  
  // Find the offset between the two files
  Map<String, dynamic> result = await audioOffset.findOffsetBetweenFiles(
    fs: 16000, // Sample rate
    hopLength: 256, // Hop length for MFCC analysis
    winLength: 512, // Window length for MFCC analysis
    nfft: 1024, // FFT size for MFCC computation
    trim: 10, // Optional trim duration in seconds
  );
  
  // Print the result
  print("Time offset: ${result['time_offset']} seconds");
  print("Frame offset: ${result['frame_offset']}");
  print("Correlation score: ${result['standard_score']}");
}
  
```

- **Contributing**: Contributions are welcome! Feel free to submit pull requests or open issues.
- **Bug Reports**: If you encounter any issues, please file them here.
- **Contact**: For any questions or support, reach out via email at dojm0727@gmail.com.