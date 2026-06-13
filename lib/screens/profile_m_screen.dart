import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ProfileMScreen extends StatefulWidget {
  const ProfileMScreen({super.key});

  @override
  State<ProfileMScreen> createState() =>
      _ProfileMScreenState();
}

class _ProfileMScreenState
    extends State<ProfileMScreen> {

  final formKey = GlobalKey<FormState>();

  final nameController =
  TextEditingController();

  final headlineController =
  TextEditingController();

  final bioController =
  TextEditingController();

  final skillsController =
  TextEditingController();

  final universityController =
  TextEditingController();

  final experienceController =
  TextEditingController();

  final locationController =
  TextEditingController();

  final phoneController =
  TextEditingController();

  final portfolioController =
  TextEditingController();

  final linkedinController =
  TextEditingController();

  final githubController =
  TextEditingController();

  String availability = "";

  File? profileImage;

  bool loading = false;

  bool showDeleteModal = false;

  bool showReportModal = false;

  Future<void> pickImage() async {

    final picker = ImagePicker();

    final picked =
    await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked == null) return;

    final cropped =
    await ImageCropper().cropImage(
      sourcePath: picked.path,

      aspectRatio:
      const CropAspectRatio(
        ratioX: 1,
        ratioY: 1,
      ),

      uiSettings: [

        AndroidUiSettings(
          toolbarTitle: "Crop Image",
          lockAspectRatio: true,
        ),
      ],
    );

    if (cropped != null) {
      setState(() {
        profileImage =
            File(cropped.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final isMobile =
        MediaQuery.of(context)
            .size
            .width <
            900;

    return Scaffold(

      backgroundColor:
      const Color(0xfff8fafc),

      body: Stack(
        children: [

          /// BACKGROUND GLOW
          Positioned(
            top: -200,
            left: -100,

            child: Container(
              width: 400,
              height: 400,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: Colors.purple
                    .withOpacity(0.15),
              ),
            ),
          ),

          SafeArea(

            child: isMobile

                ? _mobileLayout()

                : _desktopLayout(),
          ),

          if (showDeleteModal)
            _deleteModal(),

          if (showReportModal)
            _reportModal(),
        ],
      ),
    );
  }

  Widget _desktopLayout() {

    return Row(
      children: [

        /// SIDEBAR
        Container(
          width: 340,

          decoration: BoxDecoration(
            color: Colors.white,

            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black
                    .withOpacity(0.05),
              ),
            ],
          ),

          child: _sidebarContent(),
        ),

        /// CONTENT
        Expanded(
          child: SingleChildScrollView(

            padding:
            const EdgeInsets.all(40),

            child: _content(),
          ),
        ),
      ],
    );
  }

  Widget _mobileLayout() {

    return SingleChildScrollView(

      child: Column(
        children: [

          Container(
            width: double.infinity,

            color: Colors.white,

            child: _sidebarContent(),
          ),

          Padding(
            padding:
            const EdgeInsets.all(20),

            child: _content(),
          ),
        ],
      ),
    );
  }

  Widget _sidebarContent() {

    return Padding(
      padding: const EdgeInsets.all(24),

      child: Column(
        children: [

          Align(
            alignment: Alignment.centerLeft,

            child: ElevatedButton.icon(
              onPressed: () {},

              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                Colors.deepPurple,

                foregroundColor:
                Colors.white,
              ),

              icon: const Icon(
                Icons.arrow_back,
              ),

              label: const Text("Back"),
            ),
          ),

          const SizedBox(height: 40),

          /// PROFILE IMAGE
          GestureDetector(
            onTap: pickImage,

            child: Stack(
              children: [

                Container(
                  width: 160,
                  height: 160,

                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(
                        24),

                    gradient:
                    const LinearGradient(
                      colors: [
                        Colors.deepPurple,
                        Colors.blue,
                      ],
                    ),
                  ),

                  padding:
                  const EdgeInsets.all(4),

                  child: ClipRRect(
                    borderRadius:
                    BorderRadius.circular(
                        20),

                    child: profileImage !=
                        null

                        ? Image.file(
                      profileImage!,
                      fit: BoxFit.cover,
                    )

                        : Container(
                      color: Colors.white,

                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color:
                        Colors.grey,
                      ),
                    ),
                  ),
                ),

                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(
                          24),

                      color: Colors.black
                          .withOpacity(0.3),
                    ),

                    child: const Center(
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            nameController.text
                .isEmpty
                ? "Your Name"
                : nameController.text,

            style:
            GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),

            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.circular(
                  999),

              color: Colors.deepPurple
                  .withOpacity(0.1),
            ),

            child: const Text(
              "TALENT",

              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 30),

          Row(
            children: [

              Expanded(
                child: _statCard(
                  "Projects",
                  "12",
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _statCard(
                  "Rating",
                  "5.0",
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,

            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  showReportModal =
                  true;
                });
              },

              icon: const Icon(
                Icons.flag,
              ),

              label: const Text(
                "Report Problem",
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,

            child: ElevatedButton.icon(
              onPressed: () {},

              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                Colors.red.shade50,

                foregroundColor:
                Colors.red,
              ),

              icon: const Icon(
                Icons.logout,
              ),

              label:
              const Text("Logout"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() {

    return Form(
      key: formKey,

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(
            "Edit Talent Profile",

            style:
            GoogleFonts.plusJakartaSans(
              fontSize: 36,
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "Make your profile stand out",

            style:
            TextStyle(
              color: Colors.grey[700],
            ),
          ),

          const SizedBox(height: 40),

          _sectionCard(
            title: "Personal Information",
            icon: Icons.work,

            child: Column(
              children: [

                Row(
                  children: [

                    Expanded(
                      child:
                      _textField(
                        "Full Name",
                        nameController,
                      ),
                    ),

                    const SizedBox(
                        width: 20),

                    Expanded(
                      child:
                      _textField(
                        "Headline",
                        headlineController,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _textField(
                  "Bio",
                  bioController,
                  maxLines: 5,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          _sectionCard(
            title:
            "Education & Experience",

            icon:
            Icons.school,

            child: Column(
              children: [

                Row(
                  children: [

                    Expanded(
                      child:
                      _textField(
                        "University",
                        universityController,
                      ),
                    ),

                    const SizedBox(
                        width: 20),

                    Expanded(
                      child:
                      _textField(
                        "Experience",
                        experienceController,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                DropdownButtonFormField(
                  initialValue:
                  availability.isEmpty
                      ? null
                      : availability,

                  items: const [

                    DropdownMenuItem(
                      value:
                      "Full-time",

                      child:
                      Text("Full-time"),
                    ),

                    DropdownMenuItem(
                      value:
                      "Part-time",

                      child:
                      Text("Part-time"),
                    ),

                    DropdownMenuItem(
                      value:
                      "Freelance",

                      child:
                      Text("Freelance"),
                    ),
                  ],

                  onChanged: (value) {
                    setState(() {
                      availability =
                      value!;
                    });
                  },

                  decoration:
                  _inputDecoration(
                    "Availability",
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          _sectionCard(
            title:
            "Skills & Expertise",

            icon:
            Icons.code,

            child: _textField(
              "Skills",
              skillsController,
            ),
          ),

          const SizedBox(height: 28),

          _sectionCard(
            title:
            "Contact Information",

            icon:
            Icons.phone,

            child: Column(
              children: [

                Row(
                  children: [

                    Expanded(
                      child:
                      _textField(
                        "Location",
                        locationController,
                      ),
                    ),

                    const SizedBox(
                        width: 20),

                    Expanded(
                      child:
                      _textField(
                        "Phone",
                        phoneController,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          _sectionCard(
            title:
            "Portfolio & Links",

            icon:
            Icons.language,

            child: Column(
              children: [

                _textField(
                  "Portfolio URL",
                  portfolioController,
                ),

                const SizedBox(height: 20),

                Row(
                  children: [

                    Expanded(
                      child:
                      _textField(
                        "LinkedIn",
                        linkedinController,
                      ),
                    ),

                    const SizedBox(
                        width: 20),

                    Expanded(
                      child:
                      _textField(
                        "GitHub",
                        githubController,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          Row(
            children: [

              ElevatedButton.icon(
                onPressed: () {},

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  Colors.deepPurple,

                  foregroundColor:
                  Colors.white,

                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 28,
                    vertical: 18,
                  ),
                ),

                icon:
                const Icon(Icons.save),

                label: const Text(
                  "Save Changes",
                ),
              ),

              const SizedBox(width: 16),

              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    showDeleteModal =
                    true;
                  });
                },

                style:
                OutlinedButton.styleFrom(
                  foregroundColor:
                  Colors.red,

                  side: const BorderSide(
                    color: Colors.red,
                  ),

                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 28,
                    vertical: 18,
                  ),
                ),

                icon:
                const Icon(Icons.delete),

                label: const Text(
                  "Delete Account",
                ),
              ),
            ],
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(28),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black
                .withOpacity(0.04),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Row(
            children: [

              Icon(
                icon,
                color: Colors.deepPurple,
              ),

              const SizedBox(width: 12),

              Text(
                title,

                style:
                GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          child,
        ],
      ),
    );
  }

  Widget _textField(
      String label,
      TextEditingController controller, {
        int maxLines = 1,
      }) {

    return TextFormField(
      controller: controller,
      maxLines: maxLines,

      decoration:
      _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(
      String label,
      ) {

    return InputDecoration(
      labelText: label,

      filled: true,
      fillColor:
      const Color(0xfff8fafc),

      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),

        borderSide:
        BorderSide.none,
      ),
    );
  }

  Widget _statCard(
      String title,
      String value,
      ) {

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(18),

        color:
        const Color(0xfff8fafc),
      ),

      child: Column(
        children: [

          Text(
            value,

            style:
            GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight:
              FontWeight.w800,

              color:
              Colors.deepPurple,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            title,

            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _deleteModal() {

    return Material(
      color: Colors.black54,

      child: Center(
        child: Container(
          width: 500,

          padding:
          const EdgeInsets.all(28),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
            BorderRadius.circular(
                24),
          ),

          child: Column(
            mainAxisSize:
            MainAxisSize.min,

            children: [

              const Icon(
                Icons.warning,
                size: 60,
                color: Colors.red,
              ),

              const SizedBox(height: 20),

              Text(
                "Delete Account",

                style:
                GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "This action cannot be undone.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              Row(
                children: [

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          showDeleteModal =
                          false;
                        });
                      },

                      child:
                      const Text(
                        "Cancel",
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},

                      style:
                      ElevatedButton
                          .styleFrom(
                        backgroundColor:
                        Colors.red,
                      ),

                      child: const Text(
                        "Delete",
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reportModal() {

    return Material(
      color: Colors.black54,

      child: Center(
        child: Container(
          width: 550,

          padding:
          const EdgeInsets.all(28),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
            BorderRadius.circular(
                24),
          ),

          child: Column(
            mainAxisSize:
            MainAxisSize.min,

            children: [

              Row(
                children: [

                  const Icon(
                    Icons.flag,
                    color: Colors.blue,
                  ),

                  const SizedBox(width: 12),

                  Text(
                    "Report Problem",

                    style:
                    GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  IconButton(
                    onPressed: () {
                      setState(() {
                        showReportModal =
                        false;
                      });
                    },

                    icon:
                    const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _textField(
                "Subject",
                TextEditingController(),
              ),

              const SizedBox(height: 20),

              _textField(
                "Description",
                TextEditingController(),
                maxLines: 5,
              ),

              const SizedBox(height: 24),

              Row(
                children: [

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          showReportModal =
                          false;
                        });
                      },

                      child:
                      const Text(
                        "Cancel",
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},

                      child: const Text(
                        "Submit",
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}