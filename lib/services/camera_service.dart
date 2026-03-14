import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CameraService {
  final ImagePicker _imagePicker = ImagePicker();
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  Future<void> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras!.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
      }
    } catch (e) {
      throw Exception('Failed to initialize camera: $e');
    }
  }

  Future<String?> captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }

    try {
      final XFile image = await _cameraController!.takePicture();
      return image.path;
    } catch (e) {
      throw Exception('Failed to capture image: $e');
    }
  }

  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image?.path;
    } catch (e) {
      throw Exception('Failed to pick image from gallery: $e');
    }
  }

  Future<String?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image?.path;
    } catch (e) {
      throw Exception('Failed to pick image from camera: $e');
    }
  }

  Future<String> saveImageToAppDirectory(String imagePath) async {
    try {
      final File originalFile = File(imagePath);
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String savedImagePath = path.join(appDir.path, fileName);
      
      await originalFile.copy(savedImagePath);
      return savedImagePath;
    } catch (e) {
      throw Exception('Failed to save image: $e');
    }
  }

  CameraController? get cameraController => _cameraController;
  List<CameraDescription>? get cameras => _cameras;

  Future<void> dispose() async {
    await _cameraController?.dispose();
    _cameraController = null;
  }
}
