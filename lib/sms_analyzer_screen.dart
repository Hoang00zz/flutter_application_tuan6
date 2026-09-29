import 'package:flutter/material.dart';
import 'package:another_telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsAnalyzerScreen extends StatefulWidget {
  const SmsAnalyzerScreen({super.key});

  @override
  State<SmsAnalyzerScreen> createState() => _SmsAnalyzerScreenState();
}

class _SmsAnalyzerScreenState extends State<SmsAnalyzerScreen> {
  final Telephony telephony = Telephony.instance;
  List<SmsMessage> _allMessages = [];
  bool _isLoading = true;
  String _filterType = 'Tất cả'; // Trạng thái lọc: Tất cả, QC, OTP

  @override
  void initState() {
    super.initState();
    _initializePermissions();
  }

  // Xin quyền và tải tin nhắn (giống Bài 3)
  Future<void> _initializePermissions() async {
    Map<Permission, PermissionStatus> statuses = await [Permission.sms].request();
    if (statuses[Permission.sms]!.isGranted) {
      _loadMessages();
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng cấp quyền đọc SMS!')),
        );
      }
    }
  }

  Future<void> _loadMessages() async {
    List<SmsMessage> messages = await telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
      sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
    );
    if (mounted) {
      setState(() {
        _allMessages = messages;
        _isLoading = false;
      });
    }
  }

  // --- CÁC HÀM XỬ LÝ LOGIC BÀI 7 ---

  // 1. Lấy danh sách tin nhắn theo bộ lọc
  List<SmsMessage> get _filteredMessages {
    if (_filterType == 'QC') {
      return _allMessages.where((m) => (m.body ?? '').startsWith('[QC]')).toList();
    } else if (_filterType == 'OTP') {
      return _allMessages.where((m) => (m.body ?? '').contains('[OTP]')).toList();
    }
    return _allMessages;
  }

  // 2. Hàm trích xuất 6 số OTP
  void _extractAndShowOTP(String body) {
    // Dùng Regex tìm chuỗi [OTP] và theo sau là 6 chữ số
    RegExp regExp = RegExp(r'\[OTP\].*?(\d{6})');
    var match = regExp.firstMatch(body);
    
    String otpCode = match != null ? match.group(1)! : "Không tìm thấy mã 6 số";
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mã OTP của bạn'),
        content: Text(
          otpCode,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 5, color: Colors.blue),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))
        ],
      ),
    );
  }

  // 3. Hàm tính toán dữ liệu thống kê
  Map<String, int> _getSenderStats() {
    Map<String, int> stats = {};
    for (var msg in _allMessages) {
      String sender = msg.address ?? 'Không rõ';
      stats[sender] = (stats[sender] ?? 0) + 1;
    }
    return stats;
  }

  Map<String, int> _getDateStats() {
    Map<String, int> stats = {};
    for (var msg in _allMessages) {
      if (msg.date != null) {
        DateTime date = DateTime.fromMillisecondsSinceEpoch(msg.date!);
        String dateString = "${date.day}/${date.month}/${date.year}";
        stats[dateString] = (stats[dateString] ?? 0) + 1;
      }
    }
    return stats;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Chia làm 2 Tab: Thống kê và Lọc
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SMS Analyzer (Bài 7)'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.analytics), text: 'Thống kê'),
              Tab(icon: Icon(Icons.filter_alt), text: 'Lọc SMS'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildStatsTab(),
                  _buildFilterTab(),
                ],
              ),
      ),
    );
  }

  // GIAO DIỆN TAB 1: THỐNG KÊ
  Widget _buildStatsTab() {
    if (_allMessages.isEmpty) return const Center(child: Text('Không có tin nhắn nào.'));
    
    var senderStats = _getSenderStats();
    var dateStats = _getDateStats();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.blue.shade50,
          child: ListTile(
            title: const Text('Tổng số tin nhắn nhận được:', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text('${_allMessages.length}', style: const TextStyle(fontSize: 24, color: Colors.blue)),
          ),
        ),
        const SizedBox(height: 10),
        const Text('Thống kê theo Người gửi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ...senderStats.entries.map((e) => ListTile(
              leading: const Icon(Icons.person),
              title: Text(e.key),
              trailing: Text('${e.value} tin'),
            )),
        const Divider(),
        const Text('Thống kê theo Ngày/Tháng:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ...dateStats.entries.map((e) => ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(e.key),
              trailing: Text('${e.value} tin'),
            )),
      ],
    );
  }

  // GIAO DIỆN TAB 2: LỌC TIN NHẮN QC & OTP
  Widget _buildFilterTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Tất cả', label: Text('Tất cả')),
              ButtonSegment(value: 'QC', label: Text('Quảng cáo')),
              ButtonSegment(value: 'OTP', label: Text('Mã OTP')),
            ],
            selected: {_filterType},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() => _filterType = newSelection.first);
            },
          ),
        ),
        Expanded(
          child: _filteredMessages.isEmpty
              ? const Center(child: Text('Không có tin nhắn nào phù hợp.'))
              : ListView.builder(
                  itemCount: _filteredMessages.length,
                  itemBuilder: (context, index) {
                    SmsMessage msg = _filteredMessages[index];
                    bool isOTP = (msg.body ?? '').contains('[OTP]');
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: Icon(
                          isOTP ? Icons.security : Icons.message,
                          color: isOTP ? Colors.red : Colors.grey,
                        ),
                        title: Text(msg.body ?? ''),
                        subtitle: Text('Từ: ${msg.address}'),
                        onTap: isOTP ? () => _extractAndShowOTP(msg.body!) : null, // Chỉ cho phép bấm vào tin OTP
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}