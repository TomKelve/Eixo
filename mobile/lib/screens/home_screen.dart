import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/analyze_response.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  XFile? _mediaFile;
  bool _isVideo = false;
  bool _analyzing = false;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final controller = CameraController(
          cameras.first,
          ResolutionPreset.medium,
          enableAudio: true,
        );
        _initializeControllerFuture = controller.initialize();
        await _initializeControllerFuture;
        setState(() {
          _cameraController = controller;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera unavailable: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.camera);
      if (file != null) {
        setState(() {
          _mediaFile = file;
          _isVideo = false;
        });
      }
    } catch (e) {
      _showError('Failed to capture photo: $e');
    }
  }

  Future<void> _recordVideo() async {
    if (_cameraController == null) {
      await _setupCamera();
      if (_cameraController == null) {
        _showError('Camera is not ready.');
        return;
      }
    }

    try {
      await _initializeControllerFuture;
      if (_cameraController!.value.isRecordingVideo) {
        return;
      }
      await _cameraController!.startVideoRecording();
      await Future.delayed(const Duration(seconds: 3));
      final XFile file = await _cameraController!.stopVideoRecording();
      setState(() {
        _mediaFile = file;
        _isVideo = true;
      });
    } catch (e) {
      _showError('Failed to record video: $e');
    }
  }

  Future<void> _analyzeMedia() async {
    if (_mediaFile == null) {
      _showError('Capture media before analyzing.');
      return;
    }

    setState(() {
      _analyzing = true;
    });

    try {
      final file = File(_mediaFile!.path);
      final AnalyzeResponse response =
          _isVideo ? await _apiService.analyzeVideo(file) : await _apiService.analyzeImage(file);

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(response: response),
        ),
      );
    } catch (e) {
      _showError('Analysis failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _analyzing = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildPreview() {
    if (_mediaFile == null) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No media selected'),
        ),
      );
    }

    if (_isVideo) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _mediaFile!.path.split('/').last,
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(_mediaFile!.path),
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EIXO'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Capture your meal to estimate portions and nutrition with AI.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _analyzing ? null : _takePhoto,
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('Take Photo'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _analyzing ? null : _recordVideo,
                    icon: const Icon(Icons.videocam),
                    label: const Text('Record Video (3s)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPreview(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _analyzing ? null : _analyzeMedia,
                child: _analyzing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Analyze'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
