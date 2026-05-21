import 'package:flutter/material.dart';

import 'chat_screen.dart';
import 'active_projects_screen.dart';
import 'projects_m_screen.dart';
import 'profile_m_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/sidebar.dart';
import '../widgets/stat_card.dart';
import '../widgets/mobile_bottom_nav.dart';
import '../widgets/glass_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {

  int activeTab = 0;

  @override
  Widget build(BuildContext context) {

    final isMobile =
        MediaQuery.of(context)
            .size
            .width <
            768;

    return Scaffold(

      bottomNavigationBar: isMobile
          ? MobileBottomNav(
        currentIndex: activeTab,

        onTap: (index) {

          setState(() {
            activeTab = index;
          });

          /// DASHBOARD
          if (index == 0) {

            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (_) =>
                const DashboardScreen(),
              ),
            );
          }

          /// BROWSE PROJECTS
          else if (index == 1) {

            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (_) =>
                const ProjectsMScreen(),
              ),
            );
          }

          /// ACTIVE PROJECTS
          else if (index == 2) {

            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (_) =>
                const ActiveProjectsScreen(),
              ),
            );
          }

          /// PROFILE
          else if (index == 3) {

            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (_) =>
                const ChatScreen(),
              ),
            );
          }
        },
      )
          : null,

      body: Container(

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,

            colors: [
              AppColors.slate50,
              AppColors.slate100,
              AppColors.slate200,
            ],
          ),
        ),

        child: Row(
          children: [

            /// SIDEBAR DESKTOP
            if (!isMobile)
              Sidebar(
                activeIndex: activeTab,

                onChanged: (index) {
                  setState(() {
                    activeTab = index;
                  });
                },
              ),

            /// MAIN CONTENT
            Expanded(
              child: SafeArea(
                child: SingleChildScrollView(

                  padding: EdgeInsets.all(
                    isMobile ? 16 : 24,
                  ),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      /// TOPBAR
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                        children: [

                          Expanded(
                            child: Text(
                              "Welcome to QuickTurn",

                              overflow:
                              TextOverflow
                                  .ellipsis,

                              style: TextStyle(
                                fontSize:
                                isMobile
                                    ? 22
                                    : 28,

                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          GestureDetector(
                            onTap: () {

                              Navigator.push(
                                context,

                                MaterialPageRoute(
                                  builder: (_) =>
                                  const ProfileMScreen(),
                                ),
                              );
                            },

                            child: CircleAvatar(
                              radius:
                              isMobile ? 20 : 24,

                              backgroundColor:
                              AppColors.brand,

                              child: Icon(
                                Icons.person,
                                color: Colors.white,

                                size:
                                isMobile ? 20 : 24,
                              ),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 28),

                      /// WELCOME BANNER
                      Container(
                        width: double.infinity,

                        padding:
                        EdgeInsets.all(
                          isMobile ? 20 : 32,
                        ),

                        decoration:
                        BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(
                            24,
                          ),

                          gradient:
                          const LinearGradient(
                            colors: [
                              AppColors.brand,
                              AppColors.brandDark,
                            ],
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: AppColors
                                  .brand
                                  .withOpacity(
                                  0.3),

                              blurRadius: 20,
                              offset:
                              const Offset(
                                  0, 10),
                            ),
                          ],
                        ),

                        child: isMobile

                        /// MOBILE
                            ? Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [

                            Text(
                              "Welcome Back!",

                              style:
                              TextStyle(
                                color: Colors
                                    .white,

                                fontSize:
                                26,

                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),

                            const SizedBox(
                                height: 10),

                            const Text(
                              "Build your portfolio with real projects",

                              style:
                              TextStyle(
                                color: Colors
                                    .white70,

                                height: 1.5,
                              ),
                            ),

                            const SizedBox(
                                height: 24),

                            SizedBox(
                              width: double
                                  .infinity,

                              child:
                              ElevatedButton
                                  .icon(
                                onPressed:
                                    () {},

                                style:
                                ElevatedButton
                                    .styleFrom(
                                  backgroundColor:
                                  Colors
                                      .white,

                                  foregroundColor:
                                  AppColors
                                      .slate900,

                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    vertical:
                                    16,
                                  ),

                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                        14),
                                  ),
                                ),

                                icon:
                                const Icon(
                                  Icons.search,
                                ),

                                label:
                                const Text(
                                  "Find Work",
                                ),
                              ),
                            ),
                          ],
                        )

                        /// DESKTOP
                            : Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                          children: [

                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                              children: [

                                Text(
                                  "Welcome Back!",

                                  style:
                                  TextStyle(
                                    color:
                                    Colors
                                        .white,

                                    fontSize:
                                    isMobile
                                        ? 24
                                        : 32,

                                    fontWeight:
                                    FontWeight
                                        .bold,
                                  ),
                                ),

                                const SizedBox(
                                    height:
                                    10),

                                const Text(
                                  "Build your portfolio with real projects",

                                  style:
                                  TextStyle(
                                    color: Colors
                                        .white70,
                                  ),
                                ),
                              ],
                            ),

                            ElevatedButton.icon(
                              onPressed: () {

                                Navigator.push(
                                  context,

                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const ProjectsMScreen(),
                                  ),
                                );
                              },

                              style:
                              ElevatedButton.styleFrom(
                                backgroundColor:
                                Colors.white,

                                foregroundColor:
                                AppColors.slate900,
                              ),

                              icon: const Icon(
                                Icons.search,
                              ),

                              label: const Text(
                                "Find Work",
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      /// STATS
                      GridView.count(
                        shrinkWrap: true,

                        physics:
                        const NeverScrollableScrollPhysics(),

                        crossAxisCount:
                        isMobile ? 1 : 3,

                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,

                        childAspectRatio:
                        isMobile ? 1.8 : 1.4,

                        children: const [

                          StatCard(
                            label:
                            "Available Projects",

                            value: "24",

                            icon:
                            Icons.work_outline,

                            color:
                            AppColors.brand,
                          ),

                          StatCard(
                            label:
                            "Projects Completed",

                            value: "12",

                            icon:
                            Icons.check_circle,

                            color:
                            AppColors.green,
                          ),

                          StatCard(
                            label:
                            "Applications Sent",

                            value: "48",

                            icon: Icons.send,

                            color:
                            AppColors.blue,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      /// ANNOUNCEMENTS
                      Text(
                        "Latest Announcements",

                        style: TextStyle(
                          fontSize:
                          isMobile ? 20 : 22,

                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      GlassCard(
                        child: Column(
                          children: [

                            _announcementItem(
                              "New AI Project Available",
                              "Apply before Friday",
                            ),

                            const Divider(),

                            _announcementItem(
                              "Backend Challenge",
                              "Laravel + Flutter",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _announcementItem(
      String title,
      String subtitle,
      ) {

    return ListTile(
      contentPadding: EdgeInsets.zero,

      leading: Container(
        width: 12,
        height: 12,

        decoration: const BoxDecoration(
          shape: BoxShape.circle,

          gradient: LinearGradient(
            colors: [
              AppColors.brand,
              Colors.orange,
            ],
          ),
        ),
      ),

      title: Text(
        title,

        style: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),

      subtitle: Text(subtitle),
    );
  }
}