import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quickshift/const/color.dart';
import 'package:quickshift/const/consts.dart';
import 'package:quickshift/data/database/settings/settings_notifier.dart';
import 'package:quickshift/data/state/tabs.dart';
import 'package:quickshift/data/state/torrent_status.dart';
import 'package:quickshift/data/torrent/torrent_client_provider.dart';
import 'package:quickshift/data/torrent/torrents_provider.dart';
import 'package:quickshift/models/backends/torrent_client_interface.dart';
import 'package:quickshift/widgets/areas/settings/settings_dialog.dart';
import 'package:quickshift/widgets/toolbar/toolbar_icon_button.dart';
import 'package:quickshift/widgets/toolbar/toolbar_quick_connect_dropdown_icon_button.dart';

class Toolbar extends ConsumerStatefulWidget {
  const Toolbar({super.key});

  @override
  ConsumerState<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends ConsumerState<Toolbar> {
  Offset mousePosition = const Offset(0, 0);
  final searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    ref.listenManual(
      currentTabProvider,
      (previous, next) {
        if (previous != next) {
          searchController.text = ref.read(torrentSearchProvider(next));
        }
      },
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      ref
          .read(torrentSearchProvider(
            ref.read(currentTabProvider),
          ).notifier)
          .setSearch(searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    //final colorScheme = context.theme.colorScheme;

    final currentTab = ref.watch(currentTabProvider);
    final currentClient = ref.watch(currentClientProvider);

    final globalSettings = ref.watch(settingsProvider);

    return Container(
      color: tabColorDark,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          ToolbarIconButton(
            icon: FontAwesomeIcons.server,
            tooltip: "Server Manager",
            onPressed: () {},
          ),
          ToolbarQuickConnectDropdownIconButton(
              onServerSelected: (server) async {
                ref.read(tabsProvider.notifier).setConfig(currentTab, server);
                ref.read(currentClientProvider.notifier).init();
              },
              currentTab: currentTab,
              icon: FontAwesomeIcons.plug,
              tooltip: "Quick connect",
              selectedConfig: currentTab.config,
              servers: MOCK_SERVERS),
          ToolbarIconButton(
            icon: FontAwesomeIcons.gear,
            onPressed: () => showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => SettingsDialog(
                settings: globalSettings,
              ),
            ),
          ),
          ToolbarIconButton(
              icon: FontAwesomeIcons.plugCircleMinus,
              onPressed:
                  (currentClient.clientStatus is TorrentClientStatusInitialized)
                      ? () {
                          ref.read(currentClientProvider.notifier).disconnect();
                        }
                      : null),
          ToolbarIconButton(
              icon: FontAwesomeIcons.plus,
              onPressed: currentClient.clientStatus
                      is! TorrentClientStatusInitialized
                  ? null
                  : () => ref.read(torrentsProvider.notifier).addTorrentFromMagnet(
                      "magnet:?xt=urn:btih:265863cbbb5ed9ef39e7c891ebebdf1623b09d5e&dn=archlinux-2024.12.01-x86_64.iso ")),
          const Spacer(),
          SizedBox(
            width: 250,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: TextField(
                enabled: currentClient.clientStatus ==
                    const TorrentClientStatusInitialized(),
                controller: searchController,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(8),
                  border: OutlineInputBorder(),
                  hintStyle: TextStyle(fontSize: 14),
                  hintText: "Search",
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
