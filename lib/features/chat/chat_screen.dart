import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/qt_colors.dart';

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

  final contacts = [
    {"name": "PT Digital Nusantara", "lastMessage": "Can you revise the UI?", "unread": 2, "online": true, "project": "AI Dashboard"},
    {"name": "Creative Studio", "lastMessage": "Project approved!", "unread": 0, "online": false, "project": "Brand Design"},
  ];

  final messages = <Map<String, dynamic>>[
    {"mine": false, "message": "Hi! We reviewed your portfolio.", "time": "10:20"},
    {"mine": true, "message": "Thank you! Looking forward to working with you.", "time": "10:22"},
    {"mine": false, "message": "Can you start with the dashboard wireframes?", "time": "10:25"},
    {"mine": true, "message": "Sure, I'll share the initial mockups by tomorrow.", "time": "10:30"},
  ];

  void sendMessage() {
    if (msgCtrl.text.trim().isEmpty && selectedFile == null) return;
    setState(() {
      messages.add({"mine": true, "message": msgCtrl.text, "time": "Now", if (selectedFile != null) "file": selectedFile!.path});
      msgCtrl.clear();
      selectedFile = null;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollCtrl.hasClients) scrollCtrl.animateTo(scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = contacts[activeChat];
    return Scaffold(backgroundColor: QTColors.bgPrimary, body: SafeArea(
      child: Column(children: [
        // Mobile contacts bar
        SizedBox(height: 90, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(14), itemCount: contacts.length,
          itemBuilder: (_, i) {
            final ct = contacts[i];
            return GestureDetector(onTap: () => setState(() { activeChat = i; contacts[i]["unread"] = 0; }),
              child: Container(width: 68, margin: const EdgeInsets.only(right: 10),
                child: Column(children: [
                  Stack(children: [
                    CircleAvatar(radius: 24, backgroundColor: QTColors.brandPrimary,
                      child: Text((ct["name"] as String)[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    if ((ct["unread"] as int) > 0) Positioned(right: 0, top: 0,
                      child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: QTColors.accentBeginner, shape: BoxShape.circle),
                        child: Text("${ct["unread"]}", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
                    if (ct["online"] == true) Positioned(right: 0, bottom: 0,
                      child: Container(width: 14, height: 14, decoration: BoxDecoration(color: QTColors.accentBeginner, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
                  ]),
                  const SizedBox(height: 6),
                  Text(ct["name"] as String, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 11)),
                ])));
          })),
        // Chat header
        Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: QTColors.slate200))),
          child: Row(children: [
            CircleAvatar(radius: 22, backgroundColor: QTColors.brandPrimary, child: Text((c["name"] as String)[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c["name"] as String, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16)),
              Text(c["project"] as String, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: QTColors.textSecondary)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: c["online"] == true ? QTColors.accentBeginner.withOpacity(0.1) : QTColors.slate200, borderRadius: BorderRadius.circular(999)),
              child: Text(c["online"] == true ? "Online" : "Offline",
                style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: c["online"] == true ? QTColors.accentBeginner : QTColors.textMuted))),
          ])),
        // Messages
        Expanded(child: ListView.builder(controller: scrollCtrl, padding: const EdgeInsets.all(20), itemCount: messages.length,
          itemBuilder: (_, i) {
            final msg = messages[i];
            final mine = msg["mine"] as bool;
            return Align(alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(constraints: const BoxConstraints(maxWidth: 300), margin: const EdgeInsets.only(bottom: 12),
                child: Column(crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
                  if (msg["file"] != null) Container(margin: const EdgeInsets.only(bottom: 6),
                    child: ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.file(File(msg["file"]), width: 200, height: 200, fit: BoxFit.cover))),
                  Container(padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: mine ? QTColors.brandPrimary : Colors.white,
                      borderRadius: BorderRadius.only(topLeft: const Radius.circular(18), topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(mine ? 18 : 4), bottomRight: Radius.circular(mine ? 4 : 18)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
                    child: Text(msg["message"] as String, style: GoogleFonts.plusJakartaSans(color: mine ? Colors.white : QTColors.textPrimary, height: 1.4))),
                  const SizedBox(height: 4),
                  Text(msg["time"] as String, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: QTColors.textMuted)),
                ])));
          })),
        // File preview
        if (selectedFile != null) Container(padding: const EdgeInsets.all(12), color: Colors.white,
          child: Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(selectedFile!, width: 50, height: 50, fit: BoxFit.cover)),
            const SizedBox(width: 12),
            Expanded(child: Text(selectedFile!.path.split(Platform.pathSeparator).last, overflow: TextOverflow.ellipsis)),
            IconButton(onPressed: () => setState(() => selectedFile = null), icon: const Icon(Icons.close, size: 20)),
          ])),
        // Input area
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: QTColors.slate200))),
          child: Row(children: [
            IconButton(onPressed: () async {
              final r = await FilePicker.platform.pickFiles();
              if (r != null) setState(() => selectedFile = File(r.files.single.path!));
            }, icon: const Icon(Icons.attach_file, color: QTColors.textMuted)),
            Expanded(child: TextField(controller: msgCtrl,
              decoration: InputDecoration(hintText: selectedFile != null ? "Add caption..." : "Type message...",
                filled: true, fillColor: QTColors.bgTertiary, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)))),
            const SizedBox(width: 10),
            GestureDetector(onTap: sendMessage, child: Container(width: 48, height: 48,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [QTColors.brandPrimary, QTColors.brandDark])),
              child: const Icon(Icons.send, color: Colors.white, size: 20))),
          ])),
      ])));
  }
}
