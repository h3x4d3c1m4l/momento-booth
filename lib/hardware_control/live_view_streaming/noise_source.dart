import 'package:momento_booth/hardware_control/live_view_streaming/live_view_source.dart';
import 'package:momento_booth/rust_bridge/library_api.generated.dart';
import 'package:momento_booth/rust_bridge/library_bridge.dart';

class NoiseSource extends LiveViewSource {

  @override
  final String id = '';

  @override
  final String friendlyName = '';

  late int _handleId;

  NoiseSource();

  @override
  Future<void> openStream({
    required int texturePtr,
    List<ImageOperation> operations = const [], // TODO: Implement
  }) async {
    _handleId = await rustLibraryApi.noiseOpen(
      texturePtr: texturePtr,
    );
  }

  @override
  Future<void> setOperations(List<ImageOperation> operations) async {}

  @override
  Future<RawImage> getLastFrame() => rustLibraryApi.noiseGetFrame();

  @override
  Future<CameraState?> getCameraState() async => null;

  @override
  Future<void> dispose() => rustLibraryApi.noiseClose(handleId: _handleId);

}
