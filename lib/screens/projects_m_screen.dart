import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/widgets/qt_toast.dart';

class ProjectsMScreen extends StatefulWidget {
  const ProjectsMScreen({super.key});

  @override
  State<ProjectsMScreen> createState() =>
      _ProjectsMScreenState();
}

class _ProjectsMScreenState
    extends State<ProjectsMScreen> {

  final TextEditingController
  searchController =
  TextEditingController();

  String selectedCategory = "All";

  List<Map<String, dynamic>>
  projects = [

    {
      "title":
      "Build AI Dashboard UI",

      "category":
      "IT / Web",

      "description":
      "Need Flutter developer for AI dashboard system.",

      "budget":
      3500000,

      "deadline":
      "5 Days",

      "duration":
      "2 Weeks",

      "complexity":
      "Intermediate",

      "skills": [
        "Flutter",
        "Firebase",
        "UI/UX",
      ],

      "appliers":
      24,
    },

    {
      "title":
      "Modern Brand Design",

      "category":
      "Desain",

      "description":
      "Need modern logo and branding system.",

      "budget":
      1500000,

      "deadline":
      "3 Days",

      "duration":
      "1 Week",

      "complexity":
      "Beginner",

      "skills": [
        "Figma",
        "Illustrator",
      ],

      "appliers":
      12,
    },
  ];

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

      body: SafeArea(

        child: SingleChildScrollView(

          padding: EdgeInsets.all(
            isMobile ? 16 : 28,
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              /// HEADER
              Text(
                "Browse Projects",

                style:
                GoogleFonts.plusJakartaSans(
                  fontSize:
                  isMobile ? 28 : 38,

                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Find projects that match your skills",

                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 32),

              /// SEARCH BAR
              Container(
                padding:
                const EdgeInsets.all(
                    20),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(
                      20),

                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,

                      color: Colors
                          .black
                          .withOpacity(
                          0.04),
                    ),
                  ],
                ),

                child: Column(
                  children: [

                    TextField(
                      controller:
                      searchController,

                      decoration:
                      InputDecoration(
                        hintText:
                        "Search projects...",

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
                          BorderSide
                              .none,
                        ),
                      ),

                      onChanged: (_) {
                        setState(() {});
                      },
                    ),

                    const SizedBox(
                        height: 16),

                    DropdownButtonFormField(
                      value:
                      selectedCategory,

                      items: const [

                        DropdownMenuItem(
                          value: "All",
                          child:
                          Text("All"),
                        ),

                        DropdownMenuItem(
                          value:
                          "IT / Web",

                          child: Text(
                              "IT / Web"),
                        ),

                        DropdownMenuItem(
                          value:
                          "Desain",

                          child:
                          Text("Design"),
                        ),
                      ],

                      onChanged: (value) {
                        setState(() {
                          selectedCategory =
                          value!;
                        });
                      },

                      decoration:
                      InputDecoration(
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
                          BorderSide
                              .none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              /// RESULT TITLE
              Text(
                "Search Results (${projects.length})",

                style:
                GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              /// PROJECT LIST
              ...projects
                  .where((project) {

                final matchesSearch =
                project["title"]
                    .toString()
                    .toLowerCase()
                    .contains(
                  searchController
                      .text
                      .toLowerCase(),
                );

                final matchesCategory =
                    selectedCategory ==
                        "All" ||

                        project[
                        "category"] ==
                            selectedCategory;

                return matchesSearch &&
                    matchesCategory;
              }).map((project) {

                return Padding(
                  padding:
                  const EdgeInsets.only(
                    bottom: 20,
                  ),

                  child: _projectCard(
                    context,
                    project,
                    isMobile,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _projectCard(
      BuildContext context,
      Map<String, dynamic> p,
      bool isMobile,
      ) {

    return GestureDetector(

      onTap: () {
        _showDetailModal(
          context,
          p,
        );
      },

      child: Container(

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
          BorderRadius.circular(
              24),

          boxShadow: [
            BoxShadow(
              blurRadius: 20,

              color: Colors.black
                  .withOpacity(0.05),
            ),
          ],
        ),

        child: isMobile

        /// MOBILE
            ? Column(
          children: [

            _cardTop(p),

            _cardContent(p),

            _cardFooter(
              context,
              p,
            ),
          ],
        )

        /// DESKTOP
            : Row(
          children: [

            Expanded(
              flex: 5,

              child: Column(
                children: [

                  _cardTop(p),

                  _cardContent(p),
                ],
              ),
            ),

            Container(
              width: 180,

              padding:
              const EdgeInsets
                  .all(24),

              child:
              _cardFooter(
                context,
                p,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardTop(
      Map<String, dynamic> p,
      ) {

    return Container(
      padding: const EdgeInsets.all(20),

      child: Row(
        mainAxisAlignment:
        MainAxisAlignment
            .spaceBetween,

        children: [

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),

            decoration: BoxDecoration(
              color: Colors.deepPurple
                  .withOpacity(0.1),

              borderRadius:
              BorderRadius.circular(
                  999),
            ),

            child: Text(
              p["category"],

              style: const TextStyle(
                color:
                Colors.deepPurple,

                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),

            decoration: BoxDecoration(
              color:
              Colors.orange
                  .withOpacity(0.1),

              borderRadius:
              BorderRadius.circular(
                  999),
            ),

            child: Text(
              p["complexity"],

              style: const TextStyle(
                color: Colors.orange,

                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardContent(
      Map<String, dynamic> p,
      ) {

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(
            p["title"],

            style:
            GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            p["description"],

            style: TextStyle(
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),

          const SizedBox(height: 18),

          Wrap(
            spacing: 8,
            runSpacing: 8,

            children:
            (p["skills"] as List)
                .map((skill) {

              return Container(
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),

                decoration:
                BoxDecoration(
                  color: Colors.blue
                      .withOpacity(0.08),

                  borderRadius:
                  BorderRadius.circular(
                      999),
                ),

                child: Text(
                  skill,

                  style:
                  const TextStyle(
                    color:
                    Colors.blue,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          Wrap(
            spacing: 10,
            runSpacing: 10,

            children: [

              _metaPill(
                Icons.payments,
                "Rp ${p["budget"]}",
                Colors.green,
              ),

              _metaPill(
                Icons.calendar_today,
                p["deadline"],
                Colors.orange,
              ),

              _metaPill(
                Icons.people,
                "${p["appliers"]} applied",
                Colors.blue,
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _cardFooter(
      BuildContext context,
      Map<String, dynamic> p,
      ) {

    return SizedBox(
      width: double.infinity,

      child: ElevatedButton(
        onPressed: () {
          _showApplyModal(
            context,
            p,
          );
        },

        style:
        ElevatedButton.styleFrom(
          backgroundColor:
          Colors.pink,

          foregroundColor:
          Colors.white,

          padding:
          const EdgeInsets
              .symmetric(
            vertical: 18,
          ),

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
                14),
          ),
        ),

        child: const Text(
          "Apply Now",
        ),
      ),
    );
  }

  Widget _metaPill(
      IconData icon,
      String text,
      Color color,
      ) {

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: color.withOpacity(0.08),

        borderRadius:
        BorderRadius.circular(12),
      ),

      child: Row(
        mainAxisSize:
        MainAxisSize.min,

        children: [

          Icon(
            icon,
            size: 16,
            color: color,
          ),

          const SizedBox(width: 8),

          Text(
            text,

            style: TextStyle(
              color: color,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailModal(
      BuildContext context,
      Map<String, dynamic> p,
      ) {

    showDialog(
      context: context,

      builder: (_) {

        return Dialog(

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
                28),
          ),

          child: Container(
            padding:
            const EdgeInsets.all(
                28),

            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                mainAxisSize:
                MainAxisSize.min,

                children: [

                  Row(
                    children: [

                      Expanded(
                        child: Text(
                          p["title"],

                          style:
                          GoogleFonts.plusJakartaSans(
                            fontSize:
                            28,

                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(
                              context);
                        },

                        icon:
                        const Icon(
                          Icons.close,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 20),

                  Text(
                    p["description"],

                    style: TextStyle(
                      color:
                      Colors.grey[700],

                      height: 1.7,
                    ),
                  ),

                  const SizedBox(
                      height: 24),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,

                    children: [

                      _metaPill(
                        Icons.payments,
                        "Rp ${p["budget"]}",
                        Colors.green,
                      ),

                      _metaPill(
                        Icons.people,
                        "${p["appliers"]} applied",
                        Colors.blue,
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 24),

                  const Text(
                    "Required Skills",

                    style: TextStyle(
                      fontWeight:
                      FontWeight.bold,

                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(
                      height: 14),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,

                    children:
                    (p["skills"]
                    as List)
                        .map((s) {

                      return Chip(
                        label: Text(s),
                      );
                    }).toList(),
                  ),

                  const SizedBox(
                      height: 30),

                  SizedBox(
                    width:
                    double.infinity,

                    child:
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                            context);

                        _showApplyModal(
                          context,
                          p,
                        );
                      },

                      style:
                      ElevatedButton
                          .styleFrom(
                        backgroundColor:
                        Colors.pink,

                        foregroundColor:
                        Colors.white,

                        padding:
                        const EdgeInsets
                            .symmetric(
                          vertical:
                          18,
                        ),
                      ),

                      child:
                      const Text(
                        "Apply Now",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showApplyModal(
      BuildContext context,
      Map<String, dynamic> p,
      ) {

    final proposalController =
    TextEditingController();

    final bidController =
    TextEditingController();

    showDialog(
      context: context,

      builder: (_) {

        return Dialog(

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
                28),
          ),

          child: Container(
            padding:
            const EdgeInsets.all(
                28),

            child: SingleChildScrollView(
              child: Column(
                mainAxisSize:
                MainAxisSize.min,

                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [

                  Row(
                    children: [

                      Expanded(
                        child: Text(
                          "Submit Application",

                          style:
                          GoogleFonts.plusJakartaSans(
                            fontSize:
                            26,

                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(
                              context);
                        },

                        icon:
                        const Icon(
                          Icons.close,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 20),

                  TextField(
                    controller:
                    proposalController,

                    maxLines: 6,

                    decoration:
                    InputDecoration(
                      hintText:
                      "Explain why you're the right fit...",

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

                  const SizedBox(
                      height: 20),

                  TextField(
                    controller:
                    bidController,

                    keyboardType:
                    TextInputType
                        .number,

                    decoration:
                    InputDecoration(
                      hintText:
                      "Bid Amount",

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

                  const SizedBox(
                      height: 28),

                  SizedBox(
                    width:
                    double.infinity,

                    child:
                    ElevatedButton(
                      onPressed: () {

                        Navigator.pop(
                            context);

                        QTToast.show(
                          context,
                          title: "Aplikasi Terkirim! 🚀",
                          message: "Lamaran proyek Anda berhasil dikirim.",
                          type: QTToastType.success,
                        );
                      },

                      style:
                      ElevatedButton
                          .styleFrom(
                        backgroundColor:
                        Colors.pink,

                        foregroundColor:
                        Colors.white,

                        padding:
                        const EdgeInsets
                            .symmetric(
                          vertical:
                          18,
                        ),
                      ),

                      child:
                      const Text(
                        "Submit Application",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}