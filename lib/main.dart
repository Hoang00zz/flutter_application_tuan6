import 'package:flutter/material.dart';

// --- KHAI BÁO IMPORT CÁC FILE BÀI TẬP ---
import 'media_picker_home.dart';          // Bài 1
import 'photo_capture_home.dart';         // Bài 2 
// (Lưu ý: Nếu file Bài 2 của bạn tên khác, hãy sửa lại cho đúng tên file nhé)
import 'sms_reader_app.dart';             // Bài 3 (SMS)
import 'contacts_reader_app.dart';        // Bài 3 (Danh bạ)
import 'video_recorder_app.dart';         // Bài 4
import 'contacts_list_screen.dart';       // Bài 5
import 'simple_audio_player.dart';        // Bài 6
import 'sms_analyzer_screen.dart';        // Bài 7

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tổng Hợp Bài Tập Tuần 6',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainHomePage(),
      debugShowCheckedModeBanner: false, // Ẩn chữ Debug góc phải
    );
  }
}

class MainHomePage extends StatelessWidget {
  const MainHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Bài Tập Tuần 6'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView( // Giúp cuộn màn hình nếu menu quá dài
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch, // Nút kéo dài toàn màn hình
            children: [
              const Text(
                'Welcome to the Main App!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              const SizedBox(height: 30),
              
              // --- DANH SÁCH CÁC NÚT ĐIỀU HƯỚNG ---
              _buildMenuButton(context, 'Bài 1: Media Picker', MediaPickerHome()), 
              const SizedBox(height: 12),
              
              _buildMenuButton(context, 'Bài 2: Photo Capture', PhotoCaptureHome()),
              const SizedBox(height: 12),
              
              _buildMenuButton(context, 'Bài 3: SMS Reader', const SmsReaderApp()),
              const SizedBox(height: 12),

              _buildMenuButton(context, 'Bài 3: Contacts Reader', const ContactsReaderApp()),
              const SizedBox(height: 12),
              
              _buildMenuButton(context, 'Bài 4: Video Recorder', const VideoRecorderApp()),
              const SizedBox(height: 12),
              
              _buildMenuButton(context, 'Bài 5: Contacts Manager', const ContactsListScreen()),
              const SizedBox(height: 12),
              
              _buildMenuButton(context, 'Bài 6: Audio Player', const SimpleAudioPlayerScreen()),
              const SizedBox(height: 12),
              
              _buildMenuButton(context, 'Bài 7: SMS Analyzer', const SmsAnalyzerScreen(), color: Colors.orange),
            ],
          ),
        ),
      ),
    );
  }

  // --- HÀM TẠO NÚT BẤM (Rút gọn code) ---
  Widget _buildMenuButton(BuildContext context, String title, Widget destination, {Color color = Colors.blue}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Bo tròn góc nút
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}