import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class Sidebar extends StatelessWidget {

  final int activeIndex;
  final Function(int) onChanged;

  const Sidebar({
    super.key,
    required this.activeIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {

    final items = [
      {
        "title": "Dashboard",
        "icon": Icons.dashboard,
      },
      {
        "title": "Browse",
        "icon": Icons.search,
      },
      {
        "title": "Projects",
        "icon": Icons.work,
      },
      {
        "title": "Messages",
        "icon": Icons.message,
      },
    ];

    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),

      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),

          borderRadius:
          BorderRadius.circular(24),
        ),

        child: Column(
          children: [

            const SizedBox(height: 20),

            const Text(
              "QuickTurn",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 40),

            Expanded(
              child: ListView.builder(
                itemCount: items.length,

                itemBuilder: (context, index) {

                  final active =
                      activeIndex == index;

                  return Padding(
                    padding:
                    const EdgeInsets.only(
                      bottom: 12,
                    ),

                    child: InkWell(
                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),

                      onTap: () {
                        onChanged(index);
                      },

                      child: Container(
                        padding:
                        const EdgeInsets.all(
                          16,
                        ),

                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.brandLight
                              : Colors.transparent,

                          borderRadius:
                          BorderRadius.circular(
                            14,
                          ),
                        ),

                        child: Row(
                          children: [

                            Icon(
                              items[index]["icon"]
                              as IconData,

                              color: active
                                  ? AppColors.brand
                                  : AppColors.slate500,
                            ),

                            const SizedBox(
                              width: 14,
                            ),

                            Expanded(
                              child: Text(
                                items[index]["title"]
                                as String,

                                style: TextStyle(
                                  fontWeight:
                                  FontWeight.w600,

                                  color: active
                                      ? AppColors.brand
                                      : AppColors
                                      .slate500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
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
}