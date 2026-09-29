import 'package:flutter/material.dart';
import 'package:flutter_contacts_service/flutter_contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsReaderApp extends StatelessWidget {
  const ContactsReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Thay MaterialApp thành Scaffold để mũi tên quay lại hoạt động tốt
      appBar: AppBar(title: const Text('Contacts Reader')),
      body: const ContactsReaderHome(),
    );
  }
}

class ContactsReaderHome extends StatefulWidget {
  const ContactsReaderHome({super.key});

  @override
  State<ContactsReaderHome> createState() => _ContactsReaderHomeState();
}

class _ContactsReaderHomeState extends State<ContactsReaderHome> {
  List<dynamic> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePermissions();
  }

  Future<void> _initializePermissions() async {
    Map<Permission, PermissionStatus> statuses = await [Permission.contacts].request();
    if (statuses[Permission.contacts]!.isGranted) {
      _loadContacts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng cấp quyền để đọc danh bạ!')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    List<dynamic> contacts = await FlutterContactsService.getContacts();
    setState(() {
      _contacts = contacts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _contacts.isEmpty
            ? const Center(child: Text('Không có danh bạ nào.'))
            : ListView.builder(
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  ContactInfo contact = _contacts[index];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(contact.displayName ?? 'Không có tên'),
                    subtitle: Text(
                      contact.phones!.isNotEmpty
                          ? contact.phones?.first.value ?? 'Không có số'
                          : 'Không có số',
                    ),
                  );
                },
              );
  }
}