import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class VideoRecorderApp extends StatelessWidget {
  const VideoRecorderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Dùng Scaffold thay cho MaterialApp để mũi tên Back hoạt động
      appBar: AppBar(title: const Text('Video Recorder & Playback')),
      body: const VideoRecorderHome(),
    );
  }
}

class VideoRecorderHome extends StatefulWidget {
  const VideoRecorderHome({super.key});

  @override
  State<VideoRecorderHome> createState() => _VideoRecorderHomeState();
}

class _VideoRecorderHomeState extends State<VideoRecorderHome> {
  File? _videoFile;
  VideoPlayerController? _videoController;
  final ImagePicker _picker = ImagePicker();

  // Yêu cầu quyền truy cập
  Future<void> _requestPermission(Permission permission) async {
    if (await permission.isDenied) {
      await permission.request();
    }
  }

  // Chọn video từ gallery
  Future<void> _pickVideoFromGallery() async {
    await _requestPermission(Permission.photos);
    final XFile? pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      _loadVideo(File(pickedFile.path));
    }
  }

  // Quay video từ camera
  Future<void> _recordVideoFromCamera() async {
    await _requestPermission(Permission.camera);
    await _requestPermission(Permission.microphone); // Cần thêm quyền thu âm
    final XFile? recordedFile = await _picker.pickVideo(source: ImageSource.camera);
    
    if (recordedFile != null) {
      _loadVideo(File(recordedFile.path));
    }
  }

  // Tải và khởi tạo trình phát video
  void _loadVideo(File videoFile) {
    setState(() {
      _videoFile = videoFile;
      _videoController?.dispose(); // Xóa video cũ nếu có
      _videoController = VideoPlayerController.file(_videoFile!)
        ..initialize().then((_) {
          setState(() {}); // Cập nhật giao diện khi load xong
          _videoController!.play(); // Tự động phát
        });
    });
  }

  @override
  void dispose() {
    _videoController?.dispose(); // Giải phóng bộ nhớ khi thoát màn hình
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          
          // Khu vực hiển thị Video
          _videoController != null && _videoController!.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                )
              : Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: const Text('Chưa có video nào được chọn.'),
                ),
          
          const SizedBox(height: 20),
          
          // Nút Play / Pause (Chỉ hiện khi đã chọn video)
          if (_videoController != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _videoController!.value.isPlaying
                          ? _videoController!.pause()
                          : _videoController!.play();
                    });
                  },
                  child: Icon(
                    _videoController!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                ),
              ],
            ),
            
          const SizedBox(height: 20),
          
          // Các nút chức năng chọn nguồn
          ElevatedButton(
            onPressed: _pickVideoFromGallery,
            child: const Text('Chọn video từ Gallery'),
          ),
          ElevatedButton(
            onPressed: _recordVideoFromCamera,
            child: const Text('Quay video từ Camera'),
          ),
        ],
      ),
    );
  }
}