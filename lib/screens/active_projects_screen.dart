import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/widgets/qt_toast.dart';

class ActiveProjectsScreen
    extends StatefulWidget {

  const ActiveProjectsScreen({
    super.key,
  });

  @override
  State<ActiveProjectsScreen>
  createState() =>
      _ActiveProjectsScreenState();
}

class _ActiveProjectsScreenState
    extends State<
        ActiveProjectsScreen> {

  List<Map<String, dynamic>>
  ongoingProjects = [

    {
      "title":
      "AI Dashboard Development",

      "budget":
      3500000,

      "status":
      "ONGOING",

      "submissionRejected":
      true,

      "feedback":
      "Please improve mobile responsiveness.",
    },

    {
      "title":
      "Company Landing Page",

      "budget":
      2200000,

      "status":
      "ONGOING",

      "submissionRejected":
      false,
    },
  ];

  List<Map<String, dynamic>>
  completedProjects = [

    {
      "title":
      "E-Commerce UI Design",

      "completedDate":
      "May 18, 2026",

      "reviewed":
      true,

      "rating":
      5,
    },

    {
      "title":
      "Restaurant Branding",

      "completedDate":
      "May 12, 2026",

      "reviewed":
      false,
    },
  ];

  List<Map<String, dynamic>>
  rejectedProjects = [

    {
      "title":
      "Crypto Mobile App",

      "budget":
      4000000,
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
            CrossAxisAlignment
                .start,

            children: [

              /// HEADER
              Text(
                "Active Projects",

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
                "Manage your ongoing work and submissions",

                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 40),

              /// ONGOING
              _sectionTitle(
                "Ongoing Projects",
              ),

              const SizedBox(height: 20),

              if (ongoingProjects
                  .isEmpty)

                _emptyState(
                  "No ongoing projects.",
                )

              else

                ...ongoingProjects
                    .map((p) {

                  return Padding(
                    padding:
                    const EdgeInsets
                        .only(
                      bottom: 20,
                    ),

                    child:
                    _ongoingCard(
                      context,
                      p,
                    ),
                  );
                }),

              const SizedBox(height: 40),

              /// COMPLETED
              _sectionTitle(
                "Completed Projects",
              ),

              const SizedBox(height: 20),

              if (completedProjects
                  .isEmpty)

                _emptyState(
                  "No completed projects.",
                )

              else

                ...completedProjects
                    .map((p) {

                  return Padding(
                    padding:
                    const EdgeInsets
                        .only(
                      bottom: 20,
                    ),

                    child:
                    _completedCard(
                      context,
                      p,
                    ),
                  );
                }),

              const SizedBox(height: 40),

              /// REJECTED
              _sectionTitle(
                "Rejected Applications",
                color: Colors.red,
              ),

              const SizedBox(height: 20),

              if (rejectedProjects
                  .isEmpty)

                _emptyState(
                  "No rejected applications.",
                )

              else

                ...rejectedProjects
                    .map((p) {

                  return Padding(
                    padding:
                    const EdgeInsets
                        .only(
                      bottom: 20,
                    ),

                    child:
                    _rejectedCard(
                      p,
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(
      String title, {
        Color? color,
      }) {

    return Text(
      title,

      style:
      GoogleFonts.plusJakartaSans(
        fontSize: 24,

        fontWeight:
        FontWeight.bold,

        color:
        color ?? Colors.black,
      ),
    );
  }

  Widget _emptyState(
      String text,
      ) {

    return Container(
      width: double.infinity,

      padding:
      const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(
            20),
      ),

      child: Text(
        text,

        style: TextStyle(
          color: Colors.grey[600],
          fontStyle:
          FontStyle.italic,
        ),
      ),
    );
  }

  Widget _ongoingCard(
      BuildContext context,
      Map<String, dynamic> p,
      ) {

    return Container(

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

      child: Padding(
        padding:
        const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .start,

          children: [

            Row(
              children: [

                Container(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),

                  decoration:
                  BoxDecoration(
                    color: Colors.blue
                        .withOpacity(
                        0.1),

                    borderRadius:
                    BorderRadius.circular(
                        999),
                  ),

                  child: const Text(
                    "ONGOING",

                    style: TextStyle(
                      color:
                      Colors.blue,

                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),
                ),

                const Spacer(),

                const Icon(
                  Icons.work,
                  color: Colors.blue,
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              p["title"],

              style:
              GoogleFonts.plusJakartaSans(
                fontSize: 24,

                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Budget: Rp ${p["budget"]}",

              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(height: 20),

            /// FEEDBACK
            if (p["submissionRejected"] ==
                true)

              Container(
                padding:
                const EdgeInsets
                    .all(16),

                decoration:
                BoxDecoration(
                  color: Colors.red
                      .withOpacity(
                      0.08),

                  borderRadius:
                  BorderRadius.circular(
                      16),

                  border: Border.all(
                    color: Colors.red,
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [

                    const Text(
                      "⚠ Previous submission rejected",

                      style: TextStyle(
                        color: Colors.red,

                        fontWeight:
                        FontWeight
                            .bold,
                      ),
                    ),

                    const SizedBox(
                        height: 8),

                    Text(
                      p["feedback"],

                      style: TextStyle(
                        color: Colors
                            .grey[700],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            Row(
              children: [

                Expanded(
                  child:
                  OutlinedButton
                      .icon(
                    onPressed: () {
                      _showBriefModal(
                        context,
                        p,
                      );
                    },

                    icon:
                    const Icon(
                      Icons.attach_file,
                    ),

                    label:
                    const Text(
                      "View Brief",
                    ),
                  ),
                ),

                const SizedBox(
                    width: 14),

                Expanded(
                  child:
                  ElevatedButton(
                    onPressed: () {
                      _showSubmissionModal(
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
                        16,
                      ),
                    ),

                    child: Text(
                      p["submissionRejected"] ==
                          true

                          ? "Resubmit Work"

                          : "Submit Work",
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _completedCard(
      BuildContext context,
      Map<String, dynamic> p,
      ) {

    return Container(

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(
            24),

        border: Border.all(
          color: Colors.green,
        ),
      ),

      child: Padding(
        padding:
        const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .start,

          children: [

            Row(
              children: [

                Container(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),

                  decoration:
                  BoxDecoration(
                    color: Colors.green
                        .withOpacity(
                        0.1),

                    borderRadius:
                    BorderRadius.circular(
                        999),
                  ),

                  child: const Text(
                    "COMPLETED",

                    style: TextStyle(
                      color:
                      Colors.green,

                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),
                ),

                const Spacer(),

                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              p["title"],

              style:
              GoogleFonts.plusJakartaSans(
                fontSize: 22,

                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Completed: ${p["completedDate"]}",

              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(height: 24),

            if (p["reviewed"] ==
                true)

              Container(
                width:
                double.infinity,

                padding:
                const EdgeInsets
                    .all(18),

                decoration:
                BoxDecoration(
                  color: Colors.amber
                      .withOpacity(
                      0.1),

                  borderRadius:
                  BorderRadius.circular(
                      16),
                ),

                child: Column(
                  children: [

                    const Text(
                      "✅ You rated this client",

                      style: TextStyle(
                        fontWeight:
                        FontWeight
                            .bold,
                      ),
                    ),

                    const SizedBox(
                        height: 10),

                    Text(
                      "★" *
                          p["rating"],

                      style:
                      const TextStyle(
                        color:
                        Colors.amber,

                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              )

            else

              SizedBox(
                width:
                double.infinity,

                child:
                ElevatedButton(
                  onPressed: () {
                    _showReviewModal(
                      context,
                      p,
                    );
                  },

                  style:
                  ElevatedButton
                      .styleFrom(
                    backgroundColor:
                    Colors.amber,

                    foregroundColor:
                    Colors.black,

                    padding:
                    const EdgeInsets
                        .symmetric(
                      vertical: 16,
                    ),
                  ),

                  child: const Text(
                    "Leave Review",
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _rejectedCard(
      Map<String, dynamic> p,
      ) {

    return Container(

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(
            24),

        border: Border.all(
          color: Colors.red,
        ),
      ),

      child: Padding(
        padding:
        const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .start,

          children: [

            Row(
              children: [

                Container(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),

                  decoration:
                  BoxDecoration(
                    color: Colors.red
                        .withOpacity(
                        0.1),

                    borderRadius:
                    BorderRadius.circular(
                        999),
                  ),

                  child: const Text(
                    "REJECTED",

                    style: TextStyle(
                      color: Colors.red,

                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),
                ),

                const Spacer(),

                const Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              p["title"],

              style:
              GoogleFonts.plusJakartaSans(
                fontSize: 22,

                fontWeight:
                FontWeight.bold,

                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Budget: Rp ${p["budget"]}",

              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width:
              double.infinity,

              padding:
              const EdgeInsets
                  .all(14),

              decoration:
              BoxDecoration(
                color: Colors.red
                    .withOpacity(
                    0.08),

                borderRadius:
                BorderRadius.circular(
                    14),
              ),

              child: const Text(
                "Application not selected.",

                textAlign:
                TextAlign.center,

                style: TextStyle(
                  color: Colors.red,

                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBriefModal(
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

          child: Padding(
            padding:
            const EdgeInsets.all(
                28),

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
                        "Project Brief",

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
                  p["title"],

                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight
                        .bold,

                    fontSize: 20,
                  ),
                ),

                const SizedBox(
                    height: 16),

                const Text(
                  "Project attachments and requirements would appear here.",
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
                    },

                    child:
                    const Text(
                      "Close",
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSubmissionModal(
      BuildContext context,
      Map<String, dynamic> p,
      ) {

    final linkController =
    TextEditingController();

    final noteController =
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

          child: Padding(
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
                          "Submit Work",

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

                  TextField(
                    controller:
                    linkController,

                    decoration:
                    InputDecoration(
                      hintText:
                      "Drive / GitHub / Figma link",

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
                    noteController,

                    maxLines: 5,

                    decoration:
                    InputDecoration(
                      hintText:
                      "Submission notes",

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
                          title: "Pekerjaan Dikirim! 🎉",
                          message: "Pekerjaan berhasil dikirim.",
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
                        "Submit Work",
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

  void _showReviewModal(
      BuildContext context,
      Map<String, dynamic> p,
      ) {

    int rating = 5;

    final reviewController =
    TextEditingController();

    showDialog(
      context: context,

      builder: (_) {

        return StatefulBuilder(
          builder:
              (context, setModalState) {

            return Dialog(

              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                    28),
              ),

              child: Padding(
                padding:
                const EdgeInsets
                    .all(28),

                child:
                SingleChildScrollView(
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
                              "Leave Review",

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
                        p["title"],

                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight
                              .bold,

                          fontSize: 20,
                        ),
                      ),

                      const SizedBox(
                          height: 20),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                        children:
                        List.generate(
                          5,
                              (index) {

                            return IconButton(
                              onPressed: () {

                                setModalState(
                                        () {

                                      rating =
                                          index +
                                              1;
                                    });
                              },

                              icon: Icon(
                                index <
                                    rating

                                    ? Icons
                                    .star

                                    : Icons
                                    .star_border,

                                color: Colors
                                    .amber,

                                size: 36,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(
                          height: 20),

                      TextField(
                        controller:
                        reviewController,

                        maxLines: 5,

                        decoration:
                        InputDecoration(
                          hintText:
                          "Write your review...",

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
                              title: "Ulasan Terkirim! ⭐",
                              message: "Ulasan berhasil dikirim.",
                              type: QTToastType.success,
                            );
                          },

                          style:
                          ElevatedButton
                              .styleFrom(
                            backgroundColor:
                            Colors.amber,

                            foregroundColor:
                            Colors.black,

                            padding:
                            const EdgeInsets
                                .symmetric(
                              vertical:
                              18,
                            ),
                          ),

                          child:
                          const Text(
                            "Submit Review",
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
      },
    );
  }
}