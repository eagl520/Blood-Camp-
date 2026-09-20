import 'package:flutter/material.dart';


const Color kPrimary = Color(0xFFE53935);
const Color kPrimaryDark = Color(0xFFB71C1C);
const Color kPrimaryLight = Color(0xFFFFCDD2);
const Color kSuccess = Color(0xFF2E7D32);
const Color kSuccessLight = Color(0xFFE8F5E9);
const Color kInfo = Color(0xFF1565C0);
const Color kInfoLight = Color(0xFFE3F2FD);
const Color kWarning = Color(0xFFEF6C00);
const Color kWarningLight = Color(0xFFFFF3E0);
const Color kSurface = Color(0xFFF5F6F8);
const Color kCardBackground = Colors.white;
const Color kTextPrimary = Color(0xFF1A1A2E);
const Color kTextSecondary = Color(0xFF6B7280);
const Color kTextHint = Color(0xFF9CA3AF);
const Color kFieldFill = Color(0xFFF7F8FA);
const Color kFieldBorder = Color(0xFFE5E7EB);
const Color kDivider = Color(0xFFF0F0F5);
const double kRadius = 22;
const double kRadiusSm = 14;

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  
  final List<Map<String, dynamic>> _quickActions = [
    {
      'icon': Icons.chat_bubble_outline_rounded,
      'title': 'Live Chat',
      'subtitle': 'Avg. reply in 2 min',
      'color': kPrimary,
      'bg': kPrimaryLight,
    },
    {
      'icon': Icons.email_outlined,
      'title': 'Email Us',
      'subtitle': 'support@lifedrop.app',
      'color': kInfo,
      'bg': kInfoLight,
    },
    {
      'icon': Icons.phone_in_talk_outlined,
      'title': 'Call Support',
      'subtitle': '+92 300 1234567',
      'color': kSuccess,
      'bg': kSuccessLight,
    },
    {
      'icon': Icons.video_library_outlined,
      'title': 'Video Guides',
      'subtitle': '12 tutorials',
      'color': kWarning,
      'bg': kWarningLight,
    },
  ];

  final List<Map<String, dynamic>> _faqs = [
    {
      'q': 'How do I book a donation slot?',
      'a': 'Open the Camps tab, choose a nearby camp, tap "Book Now", fill in your details, select a date within the camp range, and confirm. You will get a confirmation instantly.',
    },
    {
      'q': 'When can I donate blood again?',
      'a': 'A healthy adult can donate whole blood every 56 days (8 weeks). Our Health & Recovery screen shows a live countdown until your next eligible date.',
    },
    {
      'q': 'What should I eat before donating?',
      'a': 'Have an iron-rich, low-fat meal 3 hours before donation. Avoid oily or heavy food. Drink at least 500ml of water before you arrive at the camp.',
    },
    {
      'q': 'Is donating blood safe?',
      'a': 'Yes. We use sterile, single-use equipment. Trained medical staff handle every step. Your body replaces the plasma within 24 hours and red cells within a few weeks.',
    },
    {
      'q': 'Can I cancel my booking?',
      'a': 'Yes, you can cancel from the Bookings tab. Tap your booking and select "Cancel". Cancellation is free up to 2 hours before your slot.',
    },
    {
      'q': 'How do I change my blood group?',
      'a': 'Go to your Profile → Settings → Edit Details. Update your blood group and save. Your profile will reflect the change immediately.',
    },
  ];

  final List<Map<String, dynamic>> _guides = [
    {
      'title': 'First-time Donor Guide',
      'duration': '5 min read',
      'icon': Icons.menu_book_rounded,
      'color': kPrimary,
    },
    {
      'title': 'Post-Donation Care',
      'duration': '3 min read',
      'icon': Icons.health_and_safety_rounded,
      'color': kSuccess,
    },
    {
      'title': 'Managing Your Bookings',
      'duration': '4 min read',
      'icon': Icons.event_note_rounded,
      'color': kInfo,
    },
    {
      'title': 'Eligibility Checklist',
      'duration': '2 min read',
      'icon': Icons.checklist_rounded,
      'color': kWarning,
    },
  ];

  int? _expandedFaqIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.help_outline_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Help & Support',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 0.2),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryDark, kPrimary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            _buildHeroBanner(),
            const SizedBox(height: 28),

            
            _buildSectionHeader(
              icon: Icons.flash_on_rounded,
              title: "Get in Touch",
            ),
            const SizedBox(height: 14),
            _buildQuickActionsGrid(),
            const SizedBox(height: 28),

            
            _buildSectionHeader(
              icon: Icons.quiz_outlined,
              title: "Frequently Asked",
            ),
            const SizedBox(height: 14),
            _buildFaqList(),
            const SizedBox(height: 28),

            
            _buildSectionHeader(
              icon: Icons.auto_stories_rounded,
              title: "Helpful Guides",
            ),
            const SizedBox(height: 14),
            _buildGuidesList(),
            const SizedBox(height: 28),

            
            _buildStillNeedHelp(),
          ],
        ),
      ),
    );
  }

  
  
  
  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: kPrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: kTextPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        Icon(icon, size: 18, color: kPrimary.withOpacity(0.4)),
      ],
    );
  }

  
  
  
  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryDark, kPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(kRadius),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "How can we help?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "We're here 24/7. Reach out anytime.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildQuickActionsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.25,
      children: _quickActions.map((action) => _buildQuickActionCard(action)).toList(),
    );
  }

  Widget _buildQuickActionCard(Map<String, dynamic> action) {
    final Color color = action['color'] as Color;
    final Color bg = action['bg'] as Color;
    final IconData icon = action['icon'] as IconData;
    final String title = action['title'] as String;
    final String subtitle = action['subtitle'] as String;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title tapped (demo)')),
          );
        },
        borderRadius: BorderRadius.circular(kRadiusSm),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kCardBackground,
            borderRadius: BorderRadius.circular(kRadiusSm),
            border: Border.all(color: kDivider, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: kTextPrimary,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: kTextHint,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  
  
  Widget _buildFaqList() {
    return Column(
      children: List.generate(_faqs.length, (index) {
        final faq = _faqs[index];
        final bool isExpanded = _expandedFaqIndex == index;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: kCardBackground,
            borderRadius: BorderRadius.circular(kRadiusSm),
            border: Border.all(
              color: isExpanded ? kPrimary.withOpacity(0.35) : kDivider,
              width: isExpanded ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(kRadiusSm),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                setState(() {
                  _expandedFaqIndex = isExpanded ? null : index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isExpanded
                                ? kPrimary.withOpacity(0.12)
                                : kFieldFill,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.help_outline_rounded,
                              size: 15,
                              color: isExpanded ? kPrimary : kTextHint,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            faq['q'] as String,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: isExpanded ? kPrimaryDark : kTextPrimary,
                              letterSpacing: -0.2,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 220),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: isExpanded ? kPrimary : kTextHint,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    
                    AnimatedCrossFade(
                      firstChild: const SizedBox(width: double.infinity),
                      secondChild: Padding(
                        padding: const EdgeInsets.only(top: 12, left: 40),
                        child: Text(
                          faq['a'] as String,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: kTextSecondary,
                            height: 1.55,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      crossFadeState: isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 220),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  
  
  
  Widget _buildGuidesList() {
    return Column(
      children: _guides.map((guide) {
        final Color color = guide['color'] as Color;
        final IconData icon = guide['icon'] as IconData;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: kCardBackground,
            borderRadius: BorderRadius.circular(kRadiusSm),
            border: Border.all(color: kDivider, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(kRadiusSm),
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening "${guide['title']}" (demo)')),
                );
              },
              borderRadius: BorderRadius.circular(kRadiusSm),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(icon, color: color, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guide['title'] as String,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: kTextPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            guide['duration'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              color: kTextHint,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: kTextHint),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  
  
  
  Widget _buildStillNeedHelp() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(kRadius),
        border: Border.all(color: kDivider, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kPrimaryLight.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_chat_unread_rounded, color: kPrimary, size: 26),
          ),
          const SizedBox(height: 14),
          const Text(
            "Still need help?",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Our support team is available 24/7 to assist you with any issue.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: kTextSecondary,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Starting live chat... (demo)')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: kPrimary.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_rounded, size: 17, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Start Live Chat',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}