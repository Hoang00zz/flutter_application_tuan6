import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SimpleAudioPlayerScreen extends StatefulWidget {
  const SimpleAudioPlayerScreen({super.key});

  @override
  State<SimpleAudioPlayerScreen> createState() => _SimpleAudioPlayerScreenState();
}

class _SimpleAudioPlayerScreenState extends State<SimpleAudioPlayerScreen> {
  late AudioPlayer _audioPlayer;
  int _currentSongIndex = 0;
  bool _isPlaying = false;

  // Danh sách đường dẫn bài hát (từ assets)
  final List<String> _songs = [
    'assets/audios/sample1.mp3',
    'assets/audios/sample2.mp3',
    'assets/audios/sample3.mp3',
  ];

  // Tên bài hát để hiển thị
  final List<String> _songTitles = ['Bài hát 1 (Sample 1)', 'Bài hát 2 (Sample 2)', 'Bài hát 3 (Sample 3)'];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Lắng nghe trạng thái phát
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) { // Kiểm tra xem màn hình còn mở không trước khi setState
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    // Lắng nghe khi bài hát kết thúc để tự động chuyển bài
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) _nextSong();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Giải phóng tài nguyên, tắt nhạc khi bấm quay lại
    super.dispose();
  }

  // Phát bài hát
  Future<void> _playSong() async {
    await _audioPlayer.play(
      AssetSource(_songs[_currentSongIndex].replaceAll('assets/', '')),
    );
    setState(() => _isPlaying = true);
  }

  // Tạm dừng
  Future<void> _pauseSong() async {
    await _audioPlayer.pause();
    setState(() => _isPlaying = false);
  }

  // Dừng hẳn (Stop)
  Future<void> _stopSong() async {
    await _audioPlayer.stop();
    setState(() => _isPlaying = false);
  }

  // Chuyển bài tiếp theo
  void _nextSong() {
    setState(() {
      if (_currentSongIndex < _songs.length - 1) {
        _currentSongIndex++;
      } else {
        _currentSongIndex = 0; // Quay lại bài đầu nếu hết danh sách
      }
      _stopSong();
      _playSong();
    });
  }

  // Lùi lại bài trước
  void _previousSong() {
    setState(() {
      if (_currentSongIndex > 0) {
        _currentSongIndex--;
      } else {
        _currentSongIndex = _songs.length - 1; // Nhảy xuống bài cuối
      }
      _stopSong();
      _playSong();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Audio Player')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hiển thị tên bài hát
            Text(
              _songTitles[_currentSongIndex],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            
            // Các nút điều khiển
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, size: 45),
                  onPressed: _previousSong,
                ),
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    size: 65,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    if (_isPlaying) {
                      _pauseSong();
                    } else {
                      _playSong();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.stop_circle, size: 45),
                  onPressed: _stopSong,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 45),
                  onPressed: _nextSong,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}