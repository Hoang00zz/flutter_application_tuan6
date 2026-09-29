import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class MediaPickerHome extends StatefulWidget {
  const MediaPickerHome({super.key});

  @override
  _MediaPickerHomeState createState() => _MediaPickerHomeState();
}

class _MediaPickerHomeState extends State<MediaPickerHome> {
  File? _mediaFile; // lưu trữ file media (image hoặc video)
  VideoPlayerController? _videoController; // điều khiển phát video
  final ImagePicker _picker = ImagePicker(); // khởi tạo ImagePicker để chọn ảnh hoặc video

  // Kiểm tra và yêu cầu quyền truy cập
  Future<void> _requestPermission(Permission permission) async {
    // Kiểm tra xem quyền cụ thể có bị từ chối hay không (VD: bộ nhớ, camera...)
    if (await permission.isDenied) {
      // Nếu quyền bị từ chối, phương thức này sẽ hiển thị hộp thoại yêu cầu cấp quyền
      await permission.request();
    }
  }

  // Chọn ảnh hoặc video từ gallery
  Future<void> _pickMedia(ImageSource source, bool isVideo) async {
    await _requestPermission(
      isVideo ? Permission.storage : Permission.photos,
    ); // yêu cầu quyền truy cập bộ nhớ hoặc ảnh

    // Thực hiện việc chọn một tệp media (ảnh hoặc video) từ nguồn được chỉ định.
    // Nếu không chọn được ảnh (pickImage trả về null), nó sẽ thử chọn video.
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 100, // bỏ tham số này thì ảnh được hiển thị theo kích thước gốc
      maxWidth: 1920,
      maxHeight: 1080,
    ) ?? await _picker.pickVideo(
      source: source,
    ); // chọn ảnh hoặc video từ nguồn (camera hoặc thư viện)

    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path); // lưu trữ file media đã chọn
        
        if (_mediaFile!.path.endsWith('.mp4')) {
          // Nếu file là video
          _videoController?.dispose(); // giải phóng bộ nhớ của video controller trước đó (nếu có)
          _videoController = VideoPlayerController.file(_mediaFile!); // tạo controller mới

          _videoController!.initialize().then((_) {
            setState(() {}); // cập nhật giao diện sau khi video được khởi tạo
            _videoController!.play(); // phát video
          });
        } else {
          // Nếu file là ảnh
          _videoController?.dispose(); // giải phóng bộ nhớ video controller cũ
          _videoController = null; // đặt về null
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No media selected'))
      );
    }
  }

  // Chụp ảnh hoặc quay video từ camera
  Future<void> _captureMedia(bool isVideo) async {
    await _requestPermission(Permission.camera); // yêu cầu quyền truy cập camera
    
    if (isVideo) {
      await _requestPermission(Permission.microphone); // yêu cầu quyền micro nếu quay video
    }

    final XFile? capturedFile = isVideo
        ? await _picker.pickVideo(source: ImageSource.camera) // chọn video từ camera
        : await _picker.pickImage(source: ImageSource.camera); // chọn ảnh từ camera

    if (capturedFile != null) {
      setState(() {
        _mediaFile = File(capturedFile.path); // lưu trữ file media đã chọn
        
        if (isVideo) {
          _videoController?.dispose(); // giải phóng bộ nhớ cũ (nếu có)
          _videoController = VideoPlayerController.file(_mediaFile!); 
          
          _videoController!.initialize().then((_) {
            setState(() {}); 
            _videoController!.play(); 
          });
        } else {
          _videoController?.dispose(); 
          _videoController = null; 
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No media captured'))
      );
    }
  }

  @override
  void dispose() {
    _videoController?.dispose(); // giải phóng bộ nhớ của video controller khi widget bị hủy
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media Picker App')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30, width: 30),
            
            // Hiển thị giao diện ảnh hoặc video
            _mediaFile == null
                ? const Text('Chưa chọn ảnh hoặc video.')
                : _videoController != null && _videoController!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      )
                    : Image.file(_mediaFile!, height: 300),
            
            const SizedBox(height: 20),
            
            // Các nút chức năng
            ElevatedButton(
              onPressed: () => _pickMedia(ImageSource.gallery, false),
              child: const Text('Chọn ảnh từ Gallery'),
            ),
            ElevatedButton(
              onPressed: () => _captureMedia(false),
              child: const Text('Chụp ảnh từ Camera'),
            ),
            ElevatedButton(
              onPressed: () => _pickMedia(ImageSource.gallery, true),
              child: const Text('Chọn video từ Gallery'),
            ),
            ElevatedButton(
              onPressed: () => _captureMedia(true),
              child: const Text('Quay video từ Camera'),
            ),
          ],
        ),
      ),
    );
  }
}