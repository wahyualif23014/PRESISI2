import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';

import 'package:latlong2/latlong.dart';

import 'package:KETAHANANPANGAN/core/config/map_config.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/providers/dashboard_provider.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/data/model/dashboard_data_response.dart'
    show MapPotensiItem, MapPotensiModel;

class PotensiMapSection extends StatefulWidget {
  const PotensiMapSection({super.key});

  @override
  State<PotensiMapSection> createState() => _PotensiMapSectionState();
}

class _PotensiMapSectionState extends State<PotensiMapSection>
    with AutomaticKeepAliveClientMixin {

  final MapController _mapController = MapController();
  final GeoJsonParser _geoJsonParser = GeoJsonParser();

  static final LatLng _jatimCenter = LatLng(-7.536, 112.238);
  static const double _defaultZoom = 8.2;

  bool _satelliteMode = false;
  bool _showHeatmap = false;
  bool _requestedOnce = false;

  int _lastHash = 0;

  List<Marker> _cachedMarkers = const [];
  List<MapPotensiItem> _cachedRenderPoints = const [];
  List<WeightedLatLng> _cachedHeatPoints = const [];

  final Map<Key, MapPotensiItem> _markerItemByKey = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadJatimPolygon();
  }

  Future<void> _loadJatimPolygon() async {
    final data = await DefaultAssetBundle.of(context)
        .loadString('assets/geo/jatim.geojson');

    _geoJsonParser.parseGeoJsonAsString(data);

    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_requestedOnce) {

      _requestedOnce = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {

        final provider = context.read<DashboardProvider>();

        provider.fetchMapPotensi(
          resor: provider.selectedResor,
          sektor: provider.selectedSektor,
          idJenisLahan: provider.selectedJenisLahan,
        );

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final height = math.min(
      520.0,
      math.max(300.0, MediaQuery.of(context).size.height * 0.45),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ===============================
          /// FILTER TOOLBAR
          /// ===============================

          const _FilterToolbar(),

          const SizedBox(height: 12),

          Selector<DashboardProvider, MapPotensiModel?>(
            selector: (_, p) => p.mapPotensi,
            builder: (_, data, __) {

              final provider = context.read<DashboardProvider>();

              return _Header(
                totalPoints: data?.totalPoints ?? 0,
                isLoading: provider.isMapLoading,
                onRefresh: () {
                  provider.fetchMapPotensi(
                    resor: provider.selectedResor,
                    sektor: provider.selectedSektor,
                    idJenisLahan: provider.selectedJenisLahan,
                  );
                },
              );
            },
          ),

          const SizedBox(height: 14),

          SizedBox(
            height: height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Consumer<DashboardProvider>(
                builder: (_, p, __) => _buildBody(p),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(DashboardProvider p) {

    if (p.isMapLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = p.mapPotensi;

    if (data == null || data.points.isEmpty) {
      return const Center(child: Text("Tidak ada data peta"));
    }

    final points = data.points;

    const maxRender = 2000;

    final renderPoints =
        points.length > maxRender ? points.take(maxRender).toList() : points;

    final newHash = _hashPoints(renderPoints);

    if (newHash != _lastHash) {

      _lastHash = newHash;

      _cachedRenderPoints = renderPoints;

      _markerItemByKey.clear();

      _cachedMarkers =
          renderPoints.map((e) {

            final key = ValueKey("lahan_${e.idLahan}");

            _markerItemByKey[key] = e;

            return Marker(
              key: key,
              width: 36,
              height: 36,
              point: LatLng(e.lat, e.lng),
              child: _PinMarker(status: e.statusLahan),
            );

          }).toList();

      _cachedHeatPoints =
          renderPoints
              .map((e) => WeightedLatLng(LatLng(e.lat, e.lng), 1))
              .toList();
    }

    return Stack(
      children: [

        FlutterMap(

          mapController: _mapController,

          options: MapOptions(
            initialCenter: _jatimCenter,
            initialZoom: _defaultZoom,
            maxZoom: 18,
            minZoom: 6,
          ),

          children: [

            TileLayer(
              urlTemplate:
                  _satelliteMode
                      ? MapConfig.satelliteTile
                      : MapConfig.streetTile,
              maxZoom: 20,
            ),

            if (_showHeatmap)
              HeatMapLayer(
                heatMapDataSource:
                    InMemoryHeatMapDataSource(data: _cachedHeatPoints),
              ),

            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                markers: _cachedMarkers,
                maxClusterRadius: 80,
                disableClusteringAtZoom: 14,
                size: const Size(48, 48),
                builder: (context, cluster) {

                  final count = cluster.length;

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            PolygonLayer(polygons: _geoJsonParser.polygons),

          ],
        ),

        _MapControls(),

        _Legend(),

      ],
    );
  }

  int _hashPoints(List<MapPotensiItem> pts) {

    var h = 17;

    for (final p in pts) {
      h = 37 * h + p.idLahan.hashCode;
    }

    return h;
  }

  Widget _PinMarker({required String status}) {

    final color = _getStatusColor(status);

    return Icon(
      Icons.location_on,
      size: 34,
      color: color,
      shadows: [Shadow(color: Colors.black.withOpacity(.4), blurRadius: 6)],
    );
  }

  Color _getStatusColor(String status) {

    switch (status.toLowerCase()) {

      case 'baik':
        return Colors.green;

      case 'sedang':
        return Colors.orange;

      case 'buruk':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }
}

/// =================================================
/// FILTER TOOLBAR
/// =================================================

class _FilterToolbar extends StatelessWidget {

  const _FilterToolbar();

  @override
  Widget build(BuildContext context) {

    final provider = context.watch<DashboardProvider>();

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [

        _DropdownFilter(
          label: "Jenis Komoditi",
          value: provider.selectedJenisKomoditi,
          items: provider.jenisKomoditiList,
          onChanged: provider.selectJenisKomoditi,
        ),

        _DropdownFilter(
          label: "Komoditi",
          value: provider.selectedKomoditiId,
          items: provider.komoditiList.map((e) => e.id).toList(),
          labels: provider.komoditiList.map((e) => e.label).toList(),
          onChanged: provider.selectKomoditi,
        ),

      ],
    );
  }
}

class _DropdownFilter extends StatelessWidget {

  final String label;
  final String? value;
  final List<String> items;
  final List<String>? labels;
  final ValueChanged<String?> onChanged;

  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        items: List.generate(items.length, (i) {

          final val = items[i];
          final text = labels != null ? labels![i] : val;

          return DropdownMenuItem(
            value: val,
            child: Text(text),
          );
        }),
        onChanged: onChanged,
      ),
    );
  }
}
class _MapControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_PotensiMapSectionState>()!;

    return Positioned(
      right: 12,
      top: 12,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [

            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () {
                state._mapController.move(
                  _PotensiMapSectionState._jatimCenter,
                  _PotensiMapSectionState._defaultZoom,
                );
              },
            ),

            IconButton(
              icon: const Icon(Icons.layers),
              onPressed: () {
                state.setState(() {
                  state._satelliteMode = !state._satelliteMode;
                });
              },
            ),

            IconButton(
              icon: const Icon(Icons.local_fire_department),
              onPressed: () {
                state.setState(() {
                  state._showHeatmap = !state._showHeatmap;
                });
              },
            ),

          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 14,
      left: 14,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [

              Text(
                "Status Lahan",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 6),

              _LegendItem(color: Colors.green, label: "Baik"),
              _LegendItem(color: Colors.orange, label: "Sedang"),
              _LegendItem(color: Colors.red, label: "Buruk"),
              _LegendItem(color: Colors.grey, label: "Lainnya"),

            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          Icon(Icons.location_on, color: color, size: 18),

          const SizedBox(width: 6),

          Text(label),

        ],
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "Peta Potensi Lahan",
              style: Theme.of(context).textTheme.titleLarge,
            ),

            Text(
              "$totalPoints titik data",
              style: Theme.of(context).textTheme.bodySmall,
            ),

          ],
        ),

        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: isLoading ? null : onRefresh,
        ),

      ],
    );
  }
}