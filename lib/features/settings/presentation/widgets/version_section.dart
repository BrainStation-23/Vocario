import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocario/features/settings/presentation/providers/package_info_provider.dart';

class VersionSection extends ConsumerStatefulWidget {
  const VersionSection({super.key});

  @override
  ConsumerState<VersionSection> createState() => _VersionSectionState();
}

class _VersionSectionState extends ConsumerState<VersionSection> {
  @override
  Widget build(BuildContext context) {
    final packageInfoAsync = ref.watch(packageInfoProvider);

    return Center(
      child: packageInfoAsync.when(
        data: (packageInfo) => Text(
          '${packageInfo.version} (${packageInfo.buildNumber})',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }
}
