import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class MediaUtil {
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();

  /// 图像
  /// source: ImageSource.camera (拍照) 或 ImageSource.gallery (相册)
  Future<String?> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    return image?.path;
  }

  /// 录音
  /// 检查并请求麦克风权限
  Future<bool> checkMicPermission() async {
    return await _audioRecorder.hasPermission();
  }

  /// 开始录音
  Future<void> startRecording() async {
    final dir = await getTemporaryDirectory();
    // 使用时间戳命名
    final path =
        '${dir.path}/trace_memo_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

    // 配置录音参数
    const config = RecordConfig(
      encoder: AudioEncoder.aacLc, // 通用格式
      bitRate: 128000,
      sampleRate: 44100,
    );

    await _audioRecorder.start(config, path: path);
  }

  /// 停止录音并返回文件路径
  Future<String?> stopRecording() async {
    return await _audioRecorder.stop();
  }

  /// 获取实时音量（用于 UI 波纹效果）
  Stream<Amplitude> getAmplitudeStream() {
    return _audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 100));
  }

  void dispose() {
    _audioRecorder.dispose();
  }
}
