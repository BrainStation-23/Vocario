import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vocario/core/theme/app_colors.dart';
import 'package:vocario/core/routing/app_router.dart';
import 'package:vocario/core/l10n/app_localizations.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final localizations = AppLocalizations.of(context)!;
    
    return Positioned(
      top: 40,
      right: 8,
      child: PopupMenuButton<String>(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: appColors.menuButtonBackground.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.more_vert_sharp,
            color: appColors.menuButtonIcon,
          ),
        ),
        onSelected: (String value) {
          switch (value) {
            case 'summaries':
              context.push(AppRouter.summaryDetails);
              break;
            case 'settings':
              context.push(AppRouter.settings);
              break;
            case 'about':
              context.push(AppRouter.about);
              break;
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'summaries',
            child: ListTile(
              leading: const Icon(Icons.summarize),
              title: Text(localizations.summaries),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          PopupMenuItem<String>(
            value: 'settings',
            child: ListTile(
              leading: const Icon(Icons.settings),
              title: Text(localizations.settings),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          PopupMenuItem<String>(
            value: 'about',
            child: ListTile(
              leading: const Icon(Icons.info),
              title: Text(localizations.aboutUs),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}