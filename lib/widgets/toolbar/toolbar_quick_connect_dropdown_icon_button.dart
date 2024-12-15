import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:quickshift/const/color.dart';
import 'package:quickshift/data/torrent/torrent_client_provider.dart';
import 'package:quickshift/models/server.dart';
import 'package:quickshift/state/tabs.dart' as t;

class ToolbarQuickConnectDropdownIconButton<T> extends ConsumerStatefulWidget {
  final IconData icon;
  final String? tooltip;
  final List<ServerConfig> servers;
  final ServerConfig? selectedConfig;
  final t.Tab currentTab;
  final Function(ServerConfig server) onServerSelected;

  const ToolbarQuickConnectDropdownIconButton(
      {super.key,
      required this.icon,
      this.tooltip,
      required this.servers,
      required this.onServerSelected,
      required this.currentTab,
      this.selectedConfig});

  @override
  ConsumerState<ToolbarQuickConnectDropdownIconButton> createState() =>
      _ToolbarQuickConnectDropdownIconButtonState();
}

class _ToolbarQuickConnectDropdownIconButtonState
    extends ConsumerState<ToolbarQuickConnectDropdownIconButton> {
  OverlayEntry? _overlayEntry;
  _showOverlay(BuildContext context) {
    OverlayState? state = Overlay.of(context);
    final RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
    Size size = box.size;
    Offset position = box.localToGlobal(Offset.zero);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: size.height + position.dy,
        left: position.dx,
        child: Material(
          color: tabColorDark,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 250,
            constraints: const BoxConstraints(maxHeight: 200, minHeight: 0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...widget.servers.map(
                    (e) {
                      return SizedBox(
                        height: 30,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(2),
                          onTap: () {
                            widget.onServerSelected(e);
                            _closeOverlay(context);
                            setState(() {
                              overlayIsVisible = false;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              children: [
                                Flexible(
                                    child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: e.clientType.icon,
                                )),
                                const Gap(10),
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    "${e.name} (${e.host})",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Spacer(),
                                if (widget.selectedConfig == e)
                                  FaIcon(
                                    switch (ref
                                        .watch(torrentClientProvider(
                                            widget.currentTab.config!))
                                        .isInit) {
                                      false => FontAwesomeIcons.spinner,
                                      // TODO: Handle this case.
                                      true => FontAwesomeIcons.plugCircleCheck,
                                    },
                                    size: 18,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (_overlayEntry != null) state.insert(_overlayEntry!);
  }

  bool overlayIsVisible = false;

  void _closeOverlay(BuildContext context) {
    _overlayEntry?.remove();
  }

  final GlobalKey key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      key: key,
      message: overlayIsVisible ? "" : widget.tooltip ?? "",
      waitDuration: const Duration(milliseconds: 600),
      child: IconButton(
        iconSize: 18,
        visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
        icon: FaIcon(
          widget.icon,
        ),
        onPressed: () {
          if (overlayIsVisible) {
            _closeOverlay(context);
          } else {
            _showOverlay(context);
          }
          setState(() {
            overlayIsVisible = !overlayIsVisible;
          });
        },
      ),
    );
  }
}
