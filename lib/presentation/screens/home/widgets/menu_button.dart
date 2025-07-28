import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vocario/core/theme/app_colors.dart';
import 'package:vocario/core/routing/app_router.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    
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
            case 'settings':
              context.push(AppRouter.settings);
              break;
            case 'about':
              context.push(AppRouter.about);
              break;
            case 'licensing':
              context.push(AppRouter.licensing);
              break;
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'settings',
            child: ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const PopupMenuItem<String>(
            value: 'about',
            child: ListTile(
              leading: Icon(Icons.info),
              title: Text('About Us'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const PopupMenuItem<String>(
            value: 'licensing',
            child: ListTile(
              leading: Icon(Icons.description),
              title: Text('Licensing'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}