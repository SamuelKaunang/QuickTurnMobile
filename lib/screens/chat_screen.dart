import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState
    extends State<ChatScreen> {

  final TextEditingController
  messageController =
  TextEditingController();

  final ScrollController
  scrollController =
  ScrollController();

  int activeChatIndex = 0;

  File? selectedFile;

  bool isUploading = false;

  List<Map<String, dynamic>>
  contacts = [

    {
      "name": "PT Digital Nusantara",

      "lastMessage":
      "Can you revise the UI?",

      "unread": 2,

      "online": true,
    },

    {
      "name": "Creative Studio",

      "lastMessage":
      "Project approved!",

      "unread": 0,

      "online": false,
    },
  ];

  List<Map<String, dynamic>>
  messages = [

    {
      "mine": false,

      "message":
      "Hi! We reviewed your portfolio.",

      "time": "10:20",
    },

    {
      "mine": true,

      "message":
      "Thank you! Looking forward to working with you.",

      "time": "10:22",
    },
  ];

  Future<void> pickFile() async {

    final result =
    await FilePicker.platform
        .pickFiles();

    if (result == null) return;

    setState(() {
      selectedFile = File(
        result.files.single.path!,
      );
    });
  }

  void sendMessage() {

    if (messageController.text
        .trim()
        .isEmpty &&
        selectedFile == null) {
      return;
    }

    setState(() {

      messages.add({

        "mine": true,

        "message":
        messageController.text,

        "time": "Now",

        "file":
        selectedFile?.path,
      });

      messageController.clear();

      selectedFile = null;
    });

    Future.delayed(
      const Duration(milliseconds: 100),
          () {

        scrollController.animateTo(
          scrollController
              .position
              .maxScrollExtent,

          duration:
          const Duration(
            milliseconds: 300,
          ),

          curve: Curves.easeOut,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final isMobile =
        MediaQuery.of(context)
            .size
            .width <
            768;

    final activeChat =
    contacts[activeChatIndex];

    return Scaffold(

      backgroundColor:
      const Color(0xfff8fafc),

      body: SafeArea(

        child: Row(
          children: [

            /// SIDEBAR
            if (!isMobile)

              Container(
                width: 360,

                decoration: BoxDecoration(
                  color: Colors.white,

                  border: Border(
                    right: BorderSide(
                      color:
                      Colors.grey
                          .shade200,
                    ),
                  ),
                ),

                child: _sidebar(),
              ),

            /// CHAT AREA
            Expanded(
              child: Column(
                children: [

                  /// MOBILE SIDEBAR
                  if (isMobile)

                    SizedBox(
                      height: 90,

                      child: _mobileContacts(),
                    ),

                  /// HEADER
                  _chatHeader(
                    activeChat,
                  ),

                  /// MESSAGES
                  Expanded(
                    child:
                    _messagesArea(),
                  ),

                  /// FILE PREVIEW
                  if (selectedFile !=
                      null)

                    _filePreview(),

                  /// INPUT
                  _inputArea(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebar() {

    return Column(
      children: [

        Container(
          padding:
          const EdgeInsets.all(
              24),

          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:
                Colors.grey
                    .shade200,
              ),
            ),
          ),

          child: Row(
            children: [

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(
                      context);
                },

                style:
                ElevatedButton
                    .styleFrom(
                  backgroundColor:
                  Colors.pink,

                  foregroundColor:
                  Colors.white,
                ),

                icon:
                const Icon(
                  Icons.arrow_back,
                ),

                label:
                const Text(
                  "Back",
                ),
              ),

              const SizedBox(
                  width: 16),

              Text(
                "Messages",

                style:
                GoogleFonts.plusJakartaSans(
                  fontSize: 24,

                  fontWeight:
                  FontWeight
                      .bold,
                ),
              ),
            ],
          ),
        ),

        /// SEARCH
        Padding(
          padding:
          const EdgeInsets.all(
              20),

          child: TextField(
            decoration:
            InputDecoration(
              hintText:
              "Search conversation",

              prefixIcon:
              const Icon(
                Icons.search,
              ),

              filled: true,

              fillColor:
              const Color(
                  0xfff8fafc),

              border:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(
                    14),

                borderSide:
                BorderSide.none,
              ),
            ),
          ),
        ),

        /// CONTACTS
        Expanded(
          child: ListView.builder(

            itemCount:
            contacts.length,

            itemBuilder:
                (context, index) {

              final c =
              contacts[index];

              final active =
                  activeChatIndex ==
                      index;

              return GestureDetector(

                onTap: () {

                  setState(() {

                    activeChatIndex =
                        index;

                    contacts[index]
                    ["unread"] =
                    0;
                  });
                },

                child: Container(
                  padding:
                  const EdgeInsets
                      .all(18),

                  decoration:
                  BoxDecoration(

                    color: active

                        ? Colors.pink
                        .withOpacity(
                        0.08)

                        : Colors
                        .transparent,

                    border: Border(
                      left: BorderSide(

                        color: active

                            ? Colors
                            .pink

                            : Colors
                            .transparent,

                        width: 3,
                      ),
                    ),
                  ),

                  child: Row(
                    children: [

                      Stack(
                        children: [

                          CircleAvatar(
                            radius: 24,

                            backgroundColor:
                            Colors
                                .pink,

                            child: Text(
                              c["name"][0],

                              style:
                              const TextStyle(
                                color: Colors
                                    .white,

                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),
                          ),

                          if (c["online"])

                            Positioned(
                              bottom: 0,
                              right: 0,

                              child:
                              Container(
                                width: 14,
                                height: 14,

                                decoration:
                                BoxDecoration(
                                  color: Colors
                                      .green,

                                  shape: BoxShape
                                      .circle,

                                  border: Border.all(
                                      color: Colors.white,
                                      width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(
                          width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [

                            Text(
                              c["name"],

                              overflow:
                              TextOverflow
                                  .ellipsis,

                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),

                            const SizedBox(
                                height: 4),

                            Text(
                              c["lastMessage"],

                              overflow:
                              TextOverflow
                                  .ellipsis,

                              style:
                              TextStyle(
                                color: Colors
                                    .grey[
                                600],

                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (c["unread"] >
                          0)

                        Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),

                          decoration:
                          BoxDecoration(
                            color:
                            Colors.green,

                            borderRadius:
                            BorderRadius.circular(
                                999),
                          ),

                          child: Text(
                            "${c["unread"]}",

                            style:
                            const TextStyle(
                              color:
                              Colors.white,

                              fontSize: 12,

                              fontWeight:
                              FontWeight
                                  .bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _mobileContacts() {

    return ListView.builder(

      scrollDirection:
      Axis.horizontal,

      padding:
      const EdgeInsets.all(14),

      itemCount: contacts.length,

      itemBuilder:
          (context, index) {

        final c = contacts[index];

        return GestureDetector(

          onTap: () {

            setState(() {

              activeChatIndex =
                  index;

              contacts[index]
              ["unread"] =
              0;
            });
          },

          child: Container(
            width: 80,

            margin:
            const EdgeInsets.only(
              right: 12,
            ),

            child: Column(
              children: [

                Stack(
                  children: [

                    CircleAvatar(
                      radius: 24,

                      backgroundColor:
                      Colors.pink,

                      child: Text(
                        c["name"][0],

                        style:
                        const TextStyle(
                          color:
                          Colors.white,
                        ),
                      ),
                    ),

                    if (c["unread"] >
                        0)

                      Positioned(
                        right: 0,
                        top: 0,

                        child:
                        Container(
                          padding:
                          const EdgeInsets
                              .all(5),

                          decoration:
                          const BoxDecoration(
                            color:
                            Colors.green,

                            shape:
                            BoxShape.circle,
                          ),

                          child: Text(
                            "${c["unread"]}",

                            style:
                            const TextStyle(
                              color:
                              Colors.white,

                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(
                    height: 8),

                Text(
                  c["name"],

                  overflow:
                  TextOverflow
                      .ellipsis,

                  style:
                  const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _chatHeader(
      Map<String, dynamic> c,
      ) {

    return Container(

      padding:
      const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        border: Border(
          bottom: BorderSide(
            color:
            Colors.grey
                .shade200,
          ),
        ),
      ),

      child: Row(
        children: [

          CircleAvatar(
            radius: 24,

            backgroundColor:
            Colors.pink,

            child: Text(
              c["name"][0],

              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [

                Text(
                  c["name"],

                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,

                    fontSize: 18,
                  ),
                ),

                const SizedBox(
                    height: 4),

                Text(
                  c["online"]

                      ? "Online"

                      : "Offline",

                  style: TextStyle(
                    color:
                    Colors.grey[600],

                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {},

            icon: const Icon(
              Icons.more_vert,
            ),
          ),
        ],
      ),
    );
  }

  Widget _messagesArea() {

    return ListView.builder(

      controller:
      scrollController,

      padding:
      const EdgeInsets.all(20),

      itemCount:
      messages.length,

      itemBuilder:
          (context, index) {

        final msg =
        messages[index];

        final mine =
        msg["mine"];

        return Align(
          alignment: mine

              ? Alignment.centerRight

              : Alignment.centerLeft,

          child: Container(
            constraints:
            const BoxConstraints(
              maxWidth: 340,
            ),

            margin:
            const EdgeInsets.only(
              bottom: 16,
            ),

            child: Column(
              crossAxisAlignment: mine

                  ? CrossAxisAlignment
                  .end

                  : CrossAxisAlignment
                  .start,

              children: [

                /// FILE
                if (msg["file"] !=
                    null)

                  Container(
                    margin:
                    const EdgeInsets
                        .only(
                      bottom: 8,
                    ),

                    child: ClipRRect(
                      borderRadius:
                      BorderRadius.circular(
                          14),

                      child:
                      Image.file(
                        File(
                          msg["file"],
                        ),

                        width: 220,
                        height: 220,

                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                /// MESSAGE
                Container(
                  padding:
                  const EdgeInsets
                      .all(16),

                  decoration:
                  BoxDecoration(

                    color: mine

                        ? Colors.pink

                        : Colors.white,

                    borderRadius:
                    BorderRadius.only(
                      topLeft:
                      const Radius
                          .circular(
                          20),

                      topRight:
                      const Radius
                          .circular(
                          20),

                      bottomLeft:
                      Radius.circular(
                        mine ? 20 : 6,
                      ),

                      bottomRight:
                      Radius.circular(
                        mine ? 6 : 20,
                      ),
                    ),

                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,

                        color: Colors
                            .black
                            .withOpacity(
                            0.05),
                      ),
                    ],
                  ),

                  child: Text(
                    msg["message"],

                    style: TextStyle(

                      color: mine

                          ? Colors.white

                          : Colors.black,

                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(
                    height: 6),

                Text(
                  msg["time"],

                  style: TextStyle(
                    color:
                    Colors.grey[500],

                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _filePreview() {

    return Container(

      padding:
      const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,

        border: Border(
          top: BorderSide(
            color:
            Colors.grey
                .shade200,
          ),
        ),
      ),

      child: Row(
        children: [

          ClipRRect(
            borderRadius:
            BorderRadius.circular(
                12),

            child: Image.file(
              selectedFile!,

              width: 60,
              height: 60,

              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              selectedFile!.path
                  .split("/")
                  .last,

              overflow:
              TextOverflow
                  .ellipsis,
            ),
          ),

          IconButton(
            onPressed: () {

              setState(() {
                selectedFile = null;
              });
            },

            icon:
            const Icon(
              Icons.close,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputArea() {

    return Container(

      padding:
      const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        border: Border(
          top: BorderSide(
            color:
            Colors.grey
                .shade200,
          ),
        ),
      ),

      child: Row(
        children: [

          IconButton(
            onPressed:
            isUploading
                ? null
                : pickFile,

            icon: const Icon(
              Icons.attach_file,
            ),
          ),

          Expanded(
            child: TextField(
              controller:
              messageController,

              decoration:
              InputDecoration(
                hintText:
                selectedFile !=
                    null

                    ? "Add caption..."

                    : "Type message...",

                filled: true,

                fillColor:
                const Color(
                    0xfff8fafc),

                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                      14),

                  borderSide:
                  BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          GestureDetector(
            onTap: sendMessage,

            child: Container(
              width: 52,
              height: 52,

              decoration:
              const BoxDecoration(
                shape:
                BoxShape.circle,

                gradient:
                LinearGradient(
                  colors: [
                    Colors.pink,
                    Colors.red,
                  ],
                ),
              ),

              child: isUploading

                  ? const Padding(
                padding:
                EdgeInsets.all(
                    14),

                child:
                CircularProgressIndicator(
                  color:
                  Colors.white,

                  strokeWidth:
                  2,
                ),
              )

                  : const Icon(
                Icons.send,
                color:
                Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}