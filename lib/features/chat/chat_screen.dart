import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/qt_colors.dart';
import '../../core/widgets/qt_toast.dart';
import '../../core/network/websocket_manager.dart';
import '../auth/services/auth_service.dart';
import 'services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final msgCtrl = TextEditingController();
  final scrollCtrl = ScrollController();
  
  int activeChat = 0;
  File? selectedFile;
  bool isLoadingFile = false;
  
  int? currentUserId;
  bool isProfileLoading = true;
  bool isContactsLoading = true;
  
  List<Map<String, dynamic>> dynamicContacts = [];
  List<Map<String, dynamic>> dynamicMessages = [];

  @override
  void initState() {
    super.initState();
    _loadProfileAndInitChat();
  }

  void _loadProfileAndInitChat() async {
    final profileRes = await AuthService().getProfile();
    if (profileRes['success'] == true && profileRes['data'] != null) {
      setState(() {
        currentUserId = profileRes['data']['id'];
        isProfileLoading = false;
      });
      
      // Connect to WebSocket using currentUserId
      if (currentUserId != null) {
        WebSocketManager().connect(
          currentUserId: currentUserId!,
          onMessageReceived: (message) {
            _handleIncomingMessage(message);
          },
        );
      }
    } else {
      setState(() {
        isProfileLoading = false;
      });
    }
    
    // Load contacts
    _loadContacts();
  }

  void _loadContacts() async {
    setState(() => isContactsLoading = true);
    final fetchedContacts = await ChatService().getContacts();
    
    setState(() {
      dynamicContacts = fetchedContacts.map((c) {
        return {
          "id": c['id'],
          "name": c['name'] ?? 'No Name',
          "lastMessage": c['lastMessage'] ?? '',
          "unread": c['unreadCount'] ?? 0,
          "online": c['online'] ?? false,
          "project": c['projectName'] ?? 'Project',
        };
      }).toList();
      isContactsLoading = false;
    });

    if (dynamicContacts.isNotEmpty) {
      activeChat = 0;
      _loadChatHistory(dynamicContacts[activeChat]['id']);
    }
  }

  void _loadChatHistory(int contactId) async {
    final history = await ChatService().getChatHistory(contactId);
    setState(() {
      dynamicMessages = history.map((m) {
        final mine = m['senderId'] == currentUserId;
        return {
          "mine": mine,
          "message": m['content'] ?? '',
          "time": m['timestamp'] != null ? _formatTime(m['timestamp']) : 'Now',
          if (m['attachmentUrl'] != null) "file": m['attachmentUrl']
        };
      }).toList();
    });
    
    _scrollToBottom();
    ChatService().markAsRead(contactId);
  }

  void _handleIncomingMessage(Map<String, dynamic> msg) {
    if (dynamicContacts.isEmpty || activeChat >= dynamicContacts.length) {
      _loadContacts();
      return;
    }

    final activeContactId = dynamicContacts[activeChat]['id'];
    if (msg['senderId'] == activeContactId) {
      setState(() {
        dynamicMessages.add({
          "mine": false,
          "message": msg['content'] ?? '',
          "time": "Now",
          if (msg['attachmentUrl'] != null) "file": msg['attachmentUrl']
        });
      });
      
      _scrollToBottom();
      ChatService().markAsRead(activeContactId);
    } else {
      // Refresh contact list or update unread counts locally
      _loadContacts();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollCtrl.hasClients) {
        scrollCtrl.animateTo(
          scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(dynamic timestamp) {
    // Basic time formatter, assuming ISO String
    try {
      final dateTime = DateTime.parse(timestamp.toString()).toLocal();
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (_) {
      return 'Now';
    }
  }

  void sendMessage() async {
    if (msgCtrl.text.trim().isEmpty && selectedFile == null) return;
    
    if (dynamicContacts.isEmpty || activeChat >= dynamicContacts.length) {
      QTToast.show(
        context,
        title: "Pilih Kontak",
        message: "Silakan pilih kontak terlebih dahulu sebelum mengirim pesan.",
        type: QTToastType.warning,
      );
      return;
    }
    
    final recipientId = dynamicContacts[activeChat]['id'];
    if (recipientId == null || currentUserId == null) return;

    String? attachmentUrl;
    String? originalFilename;
    int fileSize = 0;

    if (selectedFile != null) {
      setState(() => isLoadingFile = true);
      final uploadRes = await ChatService().uploadAttachment(selectedFile!.path, recipientId as int);
      setState(() => isLoadingFile = false);
      
      if (uploadRes['success'] == true) {
        attachmentUrl = uploadRes['url'];
        originalFilename = uploadRes['fileName'];
        fileSize = uploadRes['fileSize'] ?? 0;
      } else {
        QTToast.show(
          context,
          title: "Gagal Kirim File",
          message: uploadRes['message'] ?? 'Gagal mengunggah berkas.',
          type: QTToastType.error,
        );
        return;
      }
    }

    final contentText = msgCtrl.text;
    
    // Send via WebSocket STOMP client
    WebSocketManager().sendChatMessage(
      senderId: currentUserId!,
      recipientId: recipientId,
      content: contentText,
      attachmentUrl: attachmentUrl,
      originalFilename: originalFilename,
      fileSize: fileSize,
    );

    // Add locally to list immediately for smooth user experience
    setState(() {
      dynamicMessages.add({
        "mine": true,
        "message": contentText,
        "time": "Now",
        if (selectedFile != null) "file": selectedFile!.path
      });
      msgCtrl.clear();
      selectedFile = null;
    });

    _scrollToBottom();
  }

  @override
  void dispose() {
    msgCtrl.dispose();
    scrollCtrl.dispose();
    WebSocketManager().disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isProfileLoading || isContactsLoading) {
      return const Scaffold(
        backgroundColor: QTColors.bgPrimary,
        body: Center(
          child: CircularProgressIndicator(color: QTColors.brandPrimary),
        ),
      );
    }

    if (dynamicContacts.isEmpty) {
      return Scaffold(
        backgroundColor: QTColors.bgPrimary,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: QTColors.brandPrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 48,
                      color: QTColors.brandPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Belum ada obrolan",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: QTColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Obrolan baru akan muncul di sini setelah Anda memulai percakapan di halaman detail proyek.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: QTColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final c = dynamicContacts[activeChat];
    return Scaffold(
      backgroundColor: QTColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Mobile contacts bar
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(14),
                itemCount: dynamicContacts.length,
                itemBuilder: (_, i) {
                  final ct = dynamicContacts[i];
                  final isSelected = activeChat == i;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        activeChat = i;
                        dynamicContacts[i]["unread"] = 0;
                      });
                      _loadChatHistory(ct["id"]);
                    },
                    child: Container(
                      width: 68,
                      margin: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: isSelected
                                    ? QTColors.brandPrimary
                                    : QTColors.slate300,
                                child: Text(
                                  (ct["name"] as String)[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if ((ct["unread"] as int) > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: QTColors.accentBeginner,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      "${ct["unread"]}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              if (ct["online"] == true)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: QTColors.accentBeginner,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            ct["name"] as String,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                              color: isSelected
                                  ? QTColors.brandPrimary
                                  : QTColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Chat header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: QTColors.slate200),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: QTColors.brandPrimary,
                    child: Text(
                      (c["name"] as String)[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c["name"] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          c["project"] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: QTColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: c["online"] == true
                          ? QTColors.accentBeginner.withOpacity(0.1)
                          : QTColors.slate200,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      c["online"] == true ? "Online" : "Offline",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: c["online"] == true
                            ? QTColors.accentBeginner
                            : QTColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Messages
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(20),
                itemCount: dynamicMessages.length,
                itemBuilder: (_, i) {
                  final msg = dynamicMessages[i];
                  final mine = msg["mine"] as bool;
                  return Align(
                    alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 300),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment:
                            mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (msg["file"] != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: msg["file"].startsWith('http')
                                    ? Image.network(
                                        msg["file"],
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.broken_image),
                                      )
                                    : Image.file(
                                        File(msg["file"]),
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: mine ? QTColors.brandPrimary : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(18),
                                topRight: const Radius.circular(18),
                                bottomLeft: Radius.circular(mine ? 18 : 4),
                                bottomRight: Radius.circular(mine ? 4 : 18),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                )
                              ],
                            ),
                            child: Text(
                              msg["message"] as String,
                              style: GoogleFonts.plusJakartaSans(
                                color: mine ? Colors.white : QTColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            msg["time"] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: QTColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // File preview
            if (selectedFile != null)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        selectedFile!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedFile!.path.split(Platform.pathSeparator).last,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => selectedFile = null),
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
              ),
            // Input area
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: QTColors.slate200),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      final r = await FilePicker.platform.pickFiles();
                      if (r != null) {
                        setState(() => selectedFile = File(r.files.single.path!));
                      }
                    },
                    icon: const Icon(Icons.attach_file, color: QTColors.textMuted),
                  ),
                  Expanded(
                    child: TextField(
                      controller: msgCtrl,
                      decoration: InputDecoration(
                        hintText: selectedFile != null
                            ? "Add caption..."
                            : "Type message...",
                        filled: true,
                        fillColor: QTColors.bgTertiary,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: isLoadingFile ? null : sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [QTColors.brandPrimary, QTColors.brandDark],
                        ),
                      ),
                      child: isLoadingFile
                          ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
