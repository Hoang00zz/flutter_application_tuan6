import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const PhotoCaptureApp());
}

class PhotoCaptureApp extends StatelessWidget {
  const PhotoCaptureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Capture & Preview',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const PhotoCaptureHome(),
      debugShowCheckedModeBanner: false, // Tắt chữ debug góc phải
    );
  }
}

class PhotoCaptureHome extends StatefulWidget {
  const PhotoCaptureHome({super.key});

  @override
  _PhotoCaptureHomeState createState() => _PhotoCaptureHomeState();
}

class _PhotoCaptureHomeState extends State<PhotoCaptureHome> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Yêu cầu quyền
  Future<void> _requestPermission(Permission permission) async {
    if (await permission.isDenied) {
      await permission.request();
    }
  }

  // Chọn ảnh từ gallery
  Future<void> _pickImageFromGallery() async {
    await _requestPermission(Permission.photos);
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Chụp ảnh từ camera
  Future<void> _captureImageFromCamera() async {
    await _requestPermission(Permission.camera);
    final XFile? capturedFile = await _picker.pickImage(source: ImageSource.camera);
    
    if (capturedFile != null) {
      setState(() {
        _imageFile = File(capturedFile.path);
      });
    }
  }

  // Xem trước ảnh toàn màn hình
  void _showFullScreenPreview(BuildContext context) {
    if (_imageFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImage(imageFile: _imageFile!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo Capture & Preview')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Giao diện hiển thị ảnh
            _imageFile == null
                ? const Text('Chưa có ảnh nào được chọn.')
                : GestureDetector(
                    // Bắt sự kiện khi người dùng nhấn vào ảnh
                    onTap: () => _showFullScreenPreview(context), 
                    child: Image.file(_imageFile!, height: 300),
                  ),
                  
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _pickImageFromGallery,
              child: const Text('Chọn ảnh từ Gallery'),
            ),
            ElevatedButton(
              onPressed: _captureImageFromCamera,
              child: const Text('Chụp ảnh từ Camera'),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget màn hình mới: Xem trước toàn màn hình
class FullScreenImage extends StatelessWidget {
  final File imageFile;
  
  const FullScreenImage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xem trước'), backgroundColor: Colors.black,),
      backgroundColor: Colors.black, // Đổi phông nền đen cho giống thư viện ảnh thật
      body: Center(
        child: Image.file(imageFile),
      ),
    );
  }
}