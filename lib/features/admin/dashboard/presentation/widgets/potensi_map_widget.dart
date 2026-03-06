import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';

import 'package:KETAHANANPANGAN/features/admin/dashboard/providers/dashboard_provider.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/data/model/dashboard_data_response.dart'
    show MapPotensiItem;

class PotensiMapSection extends StatefulWidget {
  const PotensiMapSection({super.key});

  @override
  State<PotensiMapSection> createState() => _PotensiMapSectionState();
}

class _PotensiMapSectionState extends State<PotensiMapSection>
    with AutomaticKeepAliveClientMixin {
  final MapController _mapController = MapController();
  final PopupController _popupController = PopupController();

  static final LatLng _jatimCenter = LatLng(-7.536, 112.238);
  static const double _defaultZoom = 8.2;

  static const double _minLat = -9.9;
  static const double _maxLat = -5.4;
  static const double _minLng = 110.5;
  static const double _maxLng = 115.7;

  bool _requestedOnce = false;

  int _lastHash = 0;
  List<Marker> _cachedMarkers = const [];
  List<MapPotensiItem> _cachedRenderPoints = const [];
  final Map<Key, MapPotensiItem> _markerItemByKey = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requestedOnce) {
      _requestedOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<DashboardProvider>().fetchMapPotensi();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final p = context.watch<DashboardProvider>();

    final height = math.min(
      520.0,
      math.max(280.0, MediaQuery.of(context).size.height * 0.42),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            totalPoints: p.mapPotensi?.totalPoints ?? 0,
            isLoading: p.isMapLoading,
            onRefresh: () => p.fetchMapPotensi(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _buildBody(context, p),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, DashboardProvider p) {
    if (p.isMapLoading && (p.mapPotensi == null || p.mapPotensi!.points.isEmpty)) {
      return _StateCard(
        icon: Icons.map_outlined,
        title: 'Memuat peta…',
        subtitle: 'Sedang mengambil titik potensi lahan.',
        trailing: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (p.mapErrorMessage.isNotEmpty && p.mapPotensi == null) {
      return _StateCard(
        icon: Icons.error_outline,
        title: 'Gagal memuat peta',
        subtitle: p.mapErrorMessage,
        actionLabel: 'Coba lagi',
        onAction: () => p.fetchMapPotensi(),
      );
    }

    final data = p.mapPotensi;
    if (data == null || data.points.isEmpty) {
      return _StateCard(
        icon: Icons.location_off_outlined,
        title: 'Belum ada titik',
        subtitle: 'Tidak ada data koordinat yang valid untuk ditampilkan.',
        actionLabel: 'Refresh',
        onAction: () => p.fetchMapPotensi(),
      );
    }

    final points = data.points.where(_isValidLatLngJatim).toList();
    if (points.isEmpty) {
      return _StateCard(
        icon: Icons.location_off_outlined,
        title: 'Koordinat tidak valid',
        subtitle: 'Semua titik kosong/0 atau di luar area Jawa Timur.',
        actionLabel: 'Refresh',
        onAction: () => p.fetchMapPotensi(),
      );
    }

    const maxRender = 1200; // lebih aman utk HP mid-range
    final renderPoints =
        points.length > maxRender ? points.take(maxRender).toList() : points;

    final newHash = _hashPoints(renderPoints);
    if (newHash != _lastHash) {
      _lastHash = newHash;
      _cachedRenderPoints = renderPoints;
      _markerItemByKey.clear();

      _cachedMarkers = renderPoints.map((e) {
        final key = ValueKey('lahan_${e.idLahan}_${e.lat.toStringAsFixed(6)}_${e.lng.toStringAsFixed(6)}');
        _markerItemByKey[key] = e;

        late final Marker m;
        m = Marker(
          key: key,
          width: 44,
          height: 44,
          point: LatLng(e.lat, e.lng),
          child: GestureDetector(
            onTap: () => _popupController.togglePopup(m),
            child: _PinMarker(status: e.statusLahan),
          ),
        );
        return m;
      }).toList();
    }

    final center = _calcCenter(renderPoints) ?? _jatimCenter;

    return PopupScope(
      popupController: _popupController,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: _defaultZoom,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
              onTap: (_, __) => _popupController.hideAllPopups(),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.sdmapp',
              ),

              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  markers: _cachedMarkers,
                  maxClusterRadius: 52,
                  size: const Size(46, 46),
                  builder: (context, clusterMarkers) {
                    return _ClusterBubble(count: clusterMarkers.length);
                  },
                ),
              ),

              PopupMarkerLayerWidget(
                options: PopupMarkerLayerOptions(
                  popupController: _popupController,
                  markers: _cachedMarkers,
                  markerTapBehavior: MarkerTapBehavior.togglePopupAndHideRest(),
                  popupDisplayOptions: PopupDisplayOptions(
                    builder: (context, marker) {
                      final item = _markerItemByKey[marker.key] ?? _cachedRenderPoints.first;
                      return _PopupCard(
                        item: item,
                        onFocus: () => _focus(item),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          // Legend ringan
          Positioned(
            left: 12,
            top: 12,
            child: _Legend(),
          ),

          if (p.isMapLoading)
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _isValidLatLngJatim(MapPotensiItem e) {
    if (e.lat == 0 || e.lng == 0) return false;
    if (e.lat < -90 || e.lat > 90) return false;
    if (e.lng < -180 || e.lng > 180) return false;

    if (e.lat < _minLat || e.lat > _maxLat) return false;
    if (e.lng < _minLng || e.lng > _maxLng) return false;
    return true;
  }

  LatLng? _calcCenter(List<MapPotensiItem> pts) {
    if (pts.isEmpty) return null;
    final avgLat = pts.map((e) => e.lat).reduce((a, b) => a + b) / pts.length;
    final avgLng = pts.map((e) => e.lng).reduce((a, b) => a + b) / pts.length;
    return LatLng(avgLat, avgLng);
  }

  void _focus(MapPotensiItem item) {
    _popupController.hideAllPopups();
    _mapController.move(LatLng(item.lat, item.lng), 14);
  }

  int _hashPoints(List<MapPotensiItem> pts) {
    var h = 17;
    for (final p in pts) {
      h = 37 * h + p.idLahan.hashCode;
      h = 37 * h + p.lat.toStringAsFixed(5).hashCode;
      h = 37 * h + p.lng.toStringAsFixed(5).hashCode;
    }
    return h;
  }
}

class _PinMarker extends StatelessWidget {
  final String status;
  const _PinMarker({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      '1' => Colors.blue,
      '2' => Colors.green,
      '3' => Colors.orange,
      '4' => Colors.red,
      _ => Colors.grey,
    };

    // Icon lebih ringan daripada Container+shadow besar
    return Icon(
      Icons.location_on,
      size: 34,
      color: color.withOpacity(0.95),
      shadows: const [Shadow(blurRadius: 10, color: Colors.black26, offset: Offset(0, 4))],
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget dot(Color c) => Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.labelSmall ?? const TextStyle(fontSize: 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status Lahan', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Row(children: [dot(Colors.blue), const SizedBox(width: 6), const Text('1')]),
            const SizedBox(height: 4),
            Row(children: [dot(Colors.green), const SizedBox(width: 6), const Text('2')]),
            const SizedBox(height: 4),
            Row(children: [dot(Colors.orange), const SizedBox(width: 6), const Text('3')]),
            const SizedBox(height: 4),
            Row(children: [dot(Colors.red), const SizedBox(width: 6), const Text('4')]),
          ],
        ),
      ),
    );
  }
}

class _ClusterBubble extends StatelessWidget {
  final int count;
  const _ClusterBubble({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black87,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Colors.black26),
        ],
      ),
      child: Text(
        '$count',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _PopupCard extends StatelessWidget {
  final MapPotensiItem item;
  final VoidCallback onFocus;

  const _PopupCard({required this.item, required this.onFocus});

  @override
  Widget build(BuildContext context) {
    final title = (item.namaKomoditi?.trim().isNotEmpty ?? false)
        ? item.namaKomoditi!
        : 'Lahan ${item.idLahan}';

    String fmtHa(double v) {
      if (v == 0) return '0';
      if (v.abs() >= 10) return v.toStringAsFixed(1);
      return v.toStringAsFixed(2);
    }

    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                '${item.jenisLahan} • ${fmtHa(item.luasLahan)} HA',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (item.namaWilayah?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(item.namaWilayah!, style: Theme.of(context).textTheme.bodySmall),
              ],
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onFocus,
                  child: const Text('Fokus'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int totalPoints;
  final bool isLoading;
  final VoidCallback onRefresh;

  const _Header({
    required this.totalPoints,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Peta Penyebaran Potensi Lahan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Total titik: $totalPoints',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: isLoading ? null : onRefresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}

class _StateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _StateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                    if (actionLabel != null && onAction != null) ...[
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: onAction,
                        child: Text(actionLabel!),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}