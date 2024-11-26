// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:quickshift/data/torrent/torrent_client_provider.dart';
import 'package:quickshift/models/server.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part "tabs.g.dart";

class Tab {
  final int id;
  final Server? server;
  Tab({
    required this.id,
    this.server,
  });

  Tab copyWith({
    int? id,
    Server? server,
  }) {
    return Tab(
      id: id ?? this.id,
      server: server ?? this.server,
    );
  }

  @override
  bool operator ==(covariant Tab other) {
    if (identical(this, other)) return true;

    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Tab(id: $id, server: $server)';
}

@Riverpod(keepAlive: true)
class Tabs extends _$Tabs {
  @override
  List<Tab> build() {
    return [Tab(id: 0)];
  }

  void newTab({Server? server, bool setCurrent = true}) {
    final newTabId = state.isEmpty ? 0 : state.last.id + 1;
    final newTab = Tab(id: newTabId, server: server);
    state = [...state, newTab];
    if (setCurrent) {
      ref.read(currentTabProvider.notifier).selectTab(newTab);
    }
  }

  void closeTab(Tab t) {
    if (state.length == 1) return;
    if (t == ref.read(currentTabProvider)) {
      ref
          .read(currentTabProvider.notifier)
          .selectTab(state[max(state.indexOf(t) - 1, 0)]);
    }
    ref.invalidate(torrentClientProvider(t));
    state = [...state..remove(t)];
  }

  void setServer(Tab t, Server s) {
    state = [
      for (final tab in state)
        if (tab == t) tab.copyWith(server: s) else tab
    ];
    ref.refresh(torrentClientProvider(t));
    print(ref.read(torrentClientProvider(t).notifier).tab);
    //state.forEach(print);
    return;
  }
/*
  void disconnect(Tab t) {
    state = [
      for (final tab in state)
        if (tab == t) tab.copyWith(server: null) else tab
    ];
    ref.invalidate(torrentClientProvider(t));
  } */
}

@Riverpod(keepAlive: false)
class CurrentTab extends _$CurrentTab {
  @override
  Tab build() {
    return ref.read(tabsProvider).first;
  }

  void selectTab(Tab t) {
    state = ref.read(tabsProvider).firstWhere(
          (element) => element == t,
        );
  }
}
