import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vocario/core/routing/app_router.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Vocario'),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_sharp),
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
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}