import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:quickshift/const/color.dart';
import 'package:quickshift/extensions/theme.dart';
import 'package:quickshift/icons/dynamic_icons.dart';
import 'package:quickshift/state/tabs.dart' as tabs;

class TitleTab extends ConsumerStatefulWidget {
  final bool isSelected;
  final tabs.Tab tab;
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  const TitleTab(
      {super.key,
      this.isSelected = false,
      required this.title,
      required this.icon,
      required this.tab,
      this.onTap});

  @override
  ConsumerState<TitleTab> createState() => _TitleTabState();
}

class _TitleTabState extends ConsumerState<TitleTab> {
  bool hovering = false;
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return InkWell(
      mouseCursor: SystemMouseCursors.basic,
      onHover: (value) {
        setState(() {
          hovering = value;
        });
      },
      onTap: widget.onTap,
      child: Container(
        width: 200,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(-10)),
            color: widget.isSelected
                ? tabColorDark
                : hovering
                    ? tabColorDark.withOpacity(0.5)
                    : null),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              color: colorScheme.secondary,
            ),
            const Gap(5),
            Text(
              widget.title,
              style: const TextStyle(),
            ),
            const Expanded(child: SizedBox()),
            IconButton(
                onPressed: () {
                  ref.read(tabs.tabsProvider.notifier).closeTab(widget.tab);
                },
                icon: Icon(
                  DynamicIcons.close,
                  size: 16,
                ))
          ],
        ),
      ),
    );
  }
}
