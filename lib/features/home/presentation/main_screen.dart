import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocario/core/l10n/app_localizations.dart';
import 'package:vocario/core/theme/app_colors.dart';
import 'package:vocario/features/home/presentation/home_screen.dart';
import 'package:vocario/features/settings/presentation/settings_screen.dart';
import 'package:vocario/features/audio_analyzer/presentation/screens/recording_list_screen.dart';
import 'package:vocario/features/audio_analyzer/presentation/providers/recordings_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const RecordingListScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Summaries Tab (Left)
                Expanded(
                  child: _buildSideNavItem(
                    icon: Icons.summarize,
                    label: localizations.summaries,
                    index: 1,
                    isSelected: _currentIndex == 1,
                    appColors: appColors,
                  ),
                ),
                // Circular Record Button (Center)
                _buildCircularRecordButton(
                  localizations: localizations,
                  appColors: appColors,
                ),
                // Settings Tab (Right)
                Expanded(
                  child: _buildSideNavItem(
                    icon: Icons.settings,
                    label: localizations.settings,
                    index: 2,
                    isSelected: _currentIndex == 2,
                    appColors: appColors,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSideNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required AppColors appColors,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        
        // Refresh recordings when summaries tab is selected
        if (index == 1) {
          ref.read(recordingsNotifierProvider.notifier).refreshRecordings();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected 
              ? appColors.micButtonGradientStart.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? appColors.micButtonGradientStart
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: isSelected ? 28 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected 
                    ? appColors.micButtonGradientStart
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularRecordButton({
    required AppLocalizations localizations,
    required AppColors appColors,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = 0;
        });
        
        // Refresh recordings when navigating to recording screen
        ref.read(recordingsNotifierProvider.notifier).refreshRecordings();
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              appColors.micButtonGradientStart,
              appColors.micButtonGradientEnd,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: appColors.micButtonGradientStart.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.mic,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
