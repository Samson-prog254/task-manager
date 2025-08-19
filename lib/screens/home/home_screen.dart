import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/task_card.dart';
import '../profile_screen.dart';
import '../task/add_task_screen.dart';
import '../task/task_list_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabAnimationController;
  late AnimationController _navAnimationController;
  late Animation<double> _fabScaleAnimation;

  final List<Widget> _screens = [
    const HomeTab(),
    const TaskListScreen(),
    const TaskListScreen(showCompleted: true),
    const ProfileScreen(),
  ];

  final List<NavItem> _navItems = [
    NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      color: const Color(0xFF667EEA),
    ),
    NavItem(
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment_rounded,
      label: 'Tasks',
      color: const Color(0xFF10B981),
    ),
    NavItem(
      icon: Icons.check_circle_outline_rounded,
      activeIcon: Icons.check_circle_rounded,
      label: 'Done',
      color: const Color(0xFFF59E0B),
    ),
    NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
      color: const Color(0xFF8B5CF6),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _navAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));

    _navAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _navAnimationController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
      HapticFeedback.lightImpact();

      // Animate the navigation change
      _navAnimationController.reset();
      _navAnimationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildCompactBottomNav(),
      floatingActionButton: _buildNormalFAB(),
    );
  }

  Widget _buildCompactBottomNav() {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated background indicator
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            left: _currentIndex * (MediaQuery.of(context).size.width / 4),
            top: 0,
            child: Container(
              width: MediaQuery.of(context).size.width / 4,
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _navItems[_currentIndex].color,
                    _navItems[_currentIndex].color.withOpacity(0.7),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(2),
                  bottomRight: Radius.circular(2),
                ),
              ),
            ),
          ),

          // Navigation items
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: _navItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isActive = index == _currentIndex;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onNavTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      height: 57,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 4),
                          Icon(
                            isActive ? item.activeIcon : item.icon,
                            size: 22,
                            color: isActive
                                ? item.color
                                : const Color(0xFF9CA3AF),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 12,
                            child: Text(
                              item.label,
                              style: GoogleFonts.inter(
                                fontSize: 8,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                                color: isActive
                                    ? item.color
                                    : const Color(0xFF9CA3AF),
                                letterSpacing: 0.0,
                                height: 1.0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalFAB() {
    return GestureDetector(
      onTapDown: (_) => _fabAnimationController.forward(),
      onTapUp: (_) => _fabAnimationController.reverse(),
      onTapCancel: () => _fabAnimationController.reverse(),
      child: ScaleTransition(
        scale: _fabScaleAnimation,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667EEA),
                Color(0xFF764BA2),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const AddTaskScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: animation.drive(
                        Tween(begin: const Offset(0, 1), end: Offset.zero).chain(
                          CurveTween(curve: Curves.easeOutCubic),
                        ),
                      ),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}

// Navigation item model
class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  String _getUserInitials(String? displayName, String? email) {
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim().substring(0, 1).toUpperCase();
    } else if (email != null && email.trim().isNotEmpty) {
      return email.trim().substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  String _getDisplayName(String? displayName, String? email) {
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim();
    } else if (email != null && email.trim().isNotEmpty) {
      String emailName = email.split('@')[0];
      return emailName.replaceAll('.', ' ').replaceAll('_', ' ');
    }
    return 'User';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final taskStats = ref.watch(taskStatsProvider);
    final pendingTasks = ref.watch(pendingTasksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // FINAL FIX: Ultra-compact SliverAppBar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Main Gradient Background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(-0.5, -1.0),
                        end: Alignment(1.0, 1.0),
                        colors: [
                          Color(0xFF667EEA),
                          Color(0xFF667EEA),
                          Color(0xFF886FBF),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                    ),
                  ),

                  // Floating Orbs - Further reduced
                  Positioned(
                    top: 50,
                    right: -15,
                    child: Container(
                      width: 60, // Further reduced from 80
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08), // More subtle
                      ),
                    ),
                  ),
                  Positioned(
                    top: 110,
                    left: -25,
                    child: Container(
                      width: 45, // Further reduced from 60
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06), // More subtle
                      ),
                    ),
                  ),

                  // ULTRA-COMPACT Content Layout
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8), // Further reduced padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top Row - Ultra compact
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Notification Bell - Smaller
                              Container(
                                padding: const EdgeInsets.all(6), // Further reduced from 8
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10), // Reduced from 12
                                ),
                                child: Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                  size: 16, // Further reduced from 18
                                ),
                              ),

                              // Profile Avatar - Smaller
                              Container(
                                padding: const EdgeInsets.all(1.5), // Further reduced from 2
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.3),
                                      Colors.white.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 18, // Further reduced from 20
                                  backgroundColor: Colors.white,
                                  backgroundImage: user?.photoURL != null
                                      ? NetworkImage(user!.photoURL!)
                                      : null,
                                  child: user?.photoURL == null
                                      ? Text(
                                    _getUserInitials(user?.displayName, user?.email),
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF667EEA),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12, // Further reduced from 14
                                    ),
                                  )
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12), // Further reduced from 16

                          // Greeting - Smaller
                          Text(
                            _getGreeting(),
                            style: GoogleFonts.inter(
                              fontSize: 12, // Further reduced from 14
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3, // Reduced from 0.5
                            ),
                          ),
                          const SizedBox(height: 2), // Further reduced from 4

                          // User Name - Smaller
                          Text(
                            _getDisplayName(user?.displayName, user?.email),
                            style: GoogleFonts.inter(
                              fontSize: 20, // Further reduced from 24
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.3, // Reduced from -0.5
                              height: 1.0, // Reduced from 1.1
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8), // Further reduced from 12

                          // Ultra-Compact Motivational Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8), // Further reduced from 12
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6), // Further reduced from 8
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8), // Reduced from 10
                                  ),
                                  child: Icon(
                                    Icons.rocket_launch_rounded,
                                    color: Colors.white,
                                    size: 14, // Further reduced from 16
                                  ),
                                ),
                                const SizedBox(width: 8), // Further reduced from 10
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Ready to be productive?',
                                        style: GoogleFonts.inter(
                                          fontSize: 18, // Further reduced from 12
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          height: 1.0, // Tight line height
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 8), // Further reduced from 4
                                      Text(
                                        'Let\'s make today amazing!',
                                        style: GoogleFonts.inter(
                                          fontSize: 12, // Further reduced from 10
                                          color: Colors.white.withOpacity(0.8),
                                          fontWeight: FontWeight.w400,
                                          height: 1.0, // Tight line height
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stats Section with Modern Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Progress',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = (constraints.maxWidth - 16) / 2;
                      final cardHeight = cardWidth * 0.85;

                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: cardWidth,
                            height: cardHeight,
                            child: _buildModernStatCard(
                              'Total Tasks',
                              taskStats['total'].toString(),
                              Icons.apps_rounded,
                              const Color(0xFF667EEA),
                              const LinearGradient(
                                colors: [Color(0xFFEBF4FF), Color(0xFFF0F8FF)],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            height: cardHeight,
                            child: _buildModernStatCard(
                              'Completed',
                              taskStats['completed'].toString(),
                              Icons.check_circle_rounded,
                              const Color(0xFF10B981),
                              const LinearGradient(
                                colors: [Color(0xFFECFDF5), Color(0xFFF0FDF9)],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            height: cardHeight,
                            child: _buildModernStatCard(
                              'In Progress',
                              taskStats['pending'].toString(),
                              Icons.schedule_rounded,
                              const Color(0xFFF59E0B),
                              const LinearGradient(
                                colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            height: cardHeight,
                            child: _buildModernStatCard(
                              'Success Rate',
                              taskStats['total']! > 0
                                  ? '${((taskStats['completed']! / taskStats['total']!) * 100).round()}%'
                                  : '0%',
                              Icons.trending_up_rounded,
                              const Color(0xFF8B5CF6),
                              const LinearGradient(
                                colors: [Color(0xFFF3E8FF), Color(0xFFFAF5FF)],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Recent Tasks Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recent Tasks',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF667EEA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const TaskListScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return SlideTransition(
                                position: animation.drive(
                                  Tween(begin: const Offset(0, 1), end: Offset.zero).chain(
                                    CurveTween(curve: Curves.easeOutCubic),
                                  ),
                                ),
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 300),
                          ),
                        );
                        // Navigate to tasks tab
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      icon: Icon(
                        Icons.arrow_forward_rounded,
                        color: const Color(0xFF667EEA),
                        size: 16,
                      ),
                      label: Text(
                        'View All',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF667EEA),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Enhanced Task List or Empty State
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
            sliver: pendingTasks.isEmpty
                ? SliverToBoxAdapter(child: _buildEnhancedEmptyState())
                : SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildEnhancedTaskCard(pendingTasks[index]),
                  );
                },
                childCount: pendingTasks.length > 4 ? 4 : pendingTasks.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatCard(
      String title,
      String value,
      IconData icon,
      Color color,
      Gradient gradient,
      ) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111827),
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildEnhancedTaskCard(task) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: task.isCompleted
                  ? const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              )
                  : null,
              border: Border.all(
                color: task.isCompleted
                    ? Colors.transparent
                    : const Color(0xFFD1D5DB),
                width: 2,
              ),
            ),
            child: task.isCompleted
                ? Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 14,
            )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title ?? 'Untitled Task',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: task.isCompleted
                        ? const Color(0xFF6B7280)
                        : const Color(0xFF111827),
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (task.description?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF6B7280),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667EEA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'High Priority',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF667EEA),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 10,
                            color: const Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Today',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF6B7280),
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFAFBFC),
            Color(0xFFF8FAFC),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.assignment_outlined,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No tasks yet!',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your journey to productivity starts with\nyour first task. Let\'s create one!',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextButton.icon(
              onPressed: () {

                // Navigate to add task
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              //icon: const Icon(Icons.add_rounded, color: Colors.white, size: 16),
              label: Text(
                'Tap the plus icon and\nCreate First Task',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}