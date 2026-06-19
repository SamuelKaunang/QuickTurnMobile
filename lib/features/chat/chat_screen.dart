import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/qt_colors.dart';
import '../../core/widgets/qt_toast.dart';
import '../../core/network/websocket_manager.dart';
import '../../core/network/dio_client.dart';
import '../auth/services/auth_service.dart';
import 'services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final int? initialContactId;
  const ChatScreen({super.key, this.initialContactId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final msgCtrl = TextEditingController();
  final scrollCtrl = ScrollController();
  
  int? activeChatIndex;
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
          "id": c['userId'], // Fixed: backend returns 'userId', not 'id'
          "name": c['name'] ?? 'No Name',
          "lastMessage": c['lastMessage'] ?? '',
          "unread": c['unreadCount'] ?? 0,
          "online": c['online'] ?? false,
          "project": c['projectTitle'] ?? 'Project', // Fixed: backend returns 'projectTitle', not 'projectName'
        };
      }).toList();
      isContactsLoading = false;
    });

    // Check if initialContactId is specified and try to set it active
    if (widget.initialContactId != null && activeChatIndex == null) {
      final index = dynamicContacts.indexWhere((c) => c['id'] == widget.initialContactId);
      if (index != -1) {
        setState(() {
          activeChatIndex = index;
        });
        _loadChatHistory(dynamicContacts[index]['id']);
      }
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
    if (dynamicContacts.isEmpty) {
      _loadContacts();
      return;
    }

    if (activeChatIndex != null && activeChatIndex! < dynamicContacts.length) {
      final activeContactId = dynamicContacts[activeChatIndex!]['id'];
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
        return;
      }
    }

    // Refresh contact list or update unread counts locally
    _loadContacts();
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
    try {
      final dateTime = DateTime.parse(timestamp.toString()).toLocal();
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (_) {
      return 'Now';
    }
  }

  Widget _buildAttachment(String path) {
    final bool isNetwork = path.startsWith('http') || path.startsWith('/api/') || !File(path).existsSync();
    final String finalUrl = isNetwork 
        ? (path.startsWith('http') ? path : '${DioClient.baseUrl}${path.startsWith('/') ? '' : '/'}$path')
        : path;

    if (isNetwork) {
      return Image.network(
        finalUrl,
        width: 200,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 200,
            height: 100,
            color: Colors.grey[200],
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: Colors.grey, size: 32),
                SizedBox(height: 4),
                Text(
                  "Gagal memuat media",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 200,
            height: 200,
            color: Colors.grey[100],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    } else {
      return Image.file(
        File(path),
        width: 200,
        height: 200,
        fit: BoxFit.cover,
      );
    }
  }

  void sendMessage() async {
    if (msgCtrl.text.trim().isEmpty && selectedFile == null) return;
    
    if (activeChatIndex == null || dynamicContacts.isEmpty || activeChatIndex! >= dynamicContacts.length) {
      QTToast.show(
        context,
        title: "Pilih Kontak",
        message: "Silakan pilih kontak terlebih dahulu sebelum mengirim pesan.",
        type: QTToastType.warning,
      );
      return;
    }
    
    final recipientId = dynamicContacts[activeChatIndex!]['id'];
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

    if (activeChatIndex == null) {
      return _buildChatListScreen();
    } else {
      return _buildChatRoomScreen();
    }
  }

  Widget _buildChatListScreen() {
    return Scaffold(
      backgroundColor: QTColors.bgPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Text(
                "Messages",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: QTColors.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                "Hubungi klien atau talent untuk mendiskusikan detail proyek Anda.",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: QTColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                itemCount: dynamicContacts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final ct = dynamicContacts[index];
                  final unread = ct["unread"] as int;
                  final online = ct["online"] == true;
                  final initials = (ct["name"] as String).isNotEmpty
                      ? (ct["name"] as String)[0].toUpperCase()
                      : "?";

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        activeChatIndex = index;
                        ct["unread"] = 0;
                      });
                      _loadChatHistory(ct["id"]);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          // Avatar with online indicator
                          Stack(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    colors: [QTColors.brandPrimary, QTColors.brandDark],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    initials,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              if (online)
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
                          const SizedBox(width: 16),
                          // Text Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ct["name"] as String,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: QTColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: QTColors.bgTertiary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    ct["project"] as String,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: QTColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Badges (Unread) & Chevron
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (unread > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: QTColors.brandPrimary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "$unread",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: QTColors.textMuted,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatRoomScreen() {
    final ct = dynamicContacts[activeChatIndex!];
    final online = ct["online"] == true;
    final initials = (ct["name"] as String).isNotEmpty
        ? (ct["name"] as String)[0].toUpperCase()
        : "?";

    return Scaffold(
      backgroundColor: QTColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leadingWidth: 40,
        leading: IconButton(
          onPressed: () {
            setState(() {
              activeChatIndex = null;
            });
            _loadContacts(); // Refresh unread count list
          },
          icon: const Icon(Icons.arrow_back, color: QTColors.textPrimary),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [QTColors.brandPrimary, QTColors.brandDark],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (online)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: QTColors.accentBeginner,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ct["name"] as String,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: QTColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    ct["project"] as String,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: QTColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Messages List
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(20),
                itemCount: dynamicMessages.length,
                itemBuilder: (_, i) {
                  final msg = dynamicMessages[i];
                  final mine = msg["mine"] as bool;
                  final hasFile = msg["file"] != null;
                  final messageText = (msg["message"] ?? "") as String;
                  
                  return Align(
                    alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 300),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment:
                            mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(18),
                                topRight: const Radius.circular(18),
                                bottomLeft: Radius.circular(mine ? 18 : 4),
                                bottomRight: Radius.circular(mine ? 4 : 18),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (hasFile)
                                    _buildAttachment(msg["file"] as String),
                                  if (messageText.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        messageText,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: mine ? Colors.white : QTColors.textPrimary,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                ],
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
            // File preview (if selected)
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
