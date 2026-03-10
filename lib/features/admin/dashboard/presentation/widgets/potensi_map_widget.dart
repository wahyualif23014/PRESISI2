import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final GeoJsonParser _geoJsonParser = GeoJsonParser();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  static final LatLng _jatimCenter = LatLng(-7.536, 112.238);
  static const double _defaultZoom = 8.2;

  bool _satelliteMode = false;
  bool _showHeatmap = false;
  bool _requestedOnce = false;
  bool _isLegendExpanded = true;

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
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
    _loadJatimPolygon();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadJatimPolygon() async {
    try {
      final data = await rootBundle.loadString('assets/geo/jatim.geojson');
      _geoJsonParser.parseGeoJsonAsString(data);

      // Auto-fit bounds ke Jawa Timur setelah load
      if (mounted) {
        setState(() {});
        _fitToJatimBounds();
      }
    } catch (e) {
      debugPrint('Error loading GeoJSON: $e');
    }
  }

  void _fitToJatimBounds() {
    // Bounds Jawa Timur
    final bounds = LatLngBounds(
      const LatLng(-8.78, 110.90), // Southwest
      const LatLng(-6.75, 114.90), // Northeast
    );

    final center = bounds.center;
    _mapController.move(center, 9.0);
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

    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    final height = math.min(560.0, math.max(320.0, size.height * 0.5));

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Section dengan Gradient Background
              _buildHeader(theme),

              // Filter Toolbar
              const _FilterToolbar(),

              const Divider(height: 1, indent: 16, endIndent: 16),

              // Map Container
              Padding(
                padding: const EdgeInsets.all(4),
                child: SizedBox(
                  height: height,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Consumer<DashboardProvider>(
                      builder:
                          (_, provider, __) =>
                              _buildMapContent(provider, theme),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.05),
            theme.colorScheme.surface,
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Selector<DashboardProvider, MapPotensiModel?>(
        selector: (_, p) => p.mapPotensi,
        builder: (_, data, __) {
          final provider = context.read<DashboardProvider>();
          final totalPoints = data?.totalPoints ?? 0;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Peta Potensi Lahan",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(
                          0.3,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "$totalPoints titik data tersedia",
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildRefreshButton(provider, theme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRefreshButton(DashboardProvider provider, ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: "Refresh Data",
        child: InkWell(
          onTap:
              provider.isMapLoading
                  ? null
                  : () {
                    HapticFeedback.lightImpact();
                    provider.fetchMapPotensi(
                      resor: provider.selectedResor,
                      sektor: provider.selectedSektor,
                      idJenisLahan: provider.selectedJenisLahan,
                    );
                  },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  provider.isMapLoading
                      ? theme.colorScheme.surfaceVariant.withOpacity(0.5)
                      : theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    provider.isMapLoading
                        ? theme.colorScheme.outline.withOpacity(0.2)
                        : theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child:
                  provider.isMapLoading
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      )
                      : Icon(
                        Icons.refresh_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapContent(DashboardProvider provider, ThemeData theme) {
    if (provider.isMapLoading && _cachedMarkers.isEmpty) {
      return _buildLoadingState(theme);
    }

    final data = provider.mapPotensi;

    if (data == null || data.points.isEmpty) {
      return _buildEmptyState(theme);
    }

    _updateCacheIfNeeded(data.points);

    return Stack(
      children: [
        // Map Layer
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _jatimCenter,
            initialZoom: _defaultZoom,
            maxZoom: 18,
            minZoom: 6,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  _satelliteMode
                      ? MapConfig.satelliteTile
                      : MapConfig.streetTile,
              maxZoom: 20,
              tileProvider: NetworkTileProvider(),
              userAgentPackageName: 'com.ketahananpangan.app',
            ),

            if (_showHeatmap && _cachedHeatPoints.isNotEmpty)
              HeatMapLayer(
                heatMapDataSource: InMemoryHeatMapDataSource(
                  data: _cachedHeatPoints,
                ),
                heatMapOptions: HeatMapOptions(
                  gradient: {
                    0.0: Colors.transparent.toMaterialColor,
                    0.25: Colors.blue.toMaterialColor,
                    0.5: Colors.green.toMaterialColor,
                    0.75: Colors.yellow.toMaterialColor,
                    1.0: Colors.red.toMaterialColor,
                  },
                  radius: 25,
                  blurFactor:
                      0.5, // Tambahkan ini untuk efek blur yang lebih baik
                ),
              ),

            PolygonLayer(
              polygons:
                  _geoJsonParser.polygons.map((polygon) {
                    return Polygon(
                      points: polygon.points,
                      holePointsList: polygon.holePointsList,
                      color: theme.colorScheme.primary.withOpacity(0.05),
                      borderColor: theme.colorScheme.primary.withOpacity(0.3),
                      borderStrokeWidth: 2,
                    );
                  }).toList(),
            ),

            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                markers: _cachedMarkers,
                maxClusterRadius: 80,
                disableClusteringAtZoom: 14,
                size: const Size(50, 50),
                // anchor dihapus - tidak tersedia di versi ini
                // fitBoundsOptions dihapus - tidak tersedia di versi ini
                builder: (context, markers) {
                  return _buildClusterMarker(markers.length, theme);
                },
                spiderfyCluster: true,
                showPolygon: false,
                zoomToBoundsOnClick: true,
                // Tambahkan ini jika tersedia untuk center alignment:
                centerMarkerOnClick: true,
              ),
            ),
          ],
        ),

        // Map Controls
        _MapControls(
          onResetView: () => _mapController.move(_jatimCenter, _defaultZoom),
          onToggleSatellite:
              () => setState(() => _satelliteMode = !_satelliteMode),
          onToggleHeatmap: () => setState(() => _showHeatmap = !_showHeatmap),
          satelliteMode: _satelliteMode,
          heatmapMode: _showHeatmap,
        ),

        // Legend
        _Legend(
          isExpanded: _isLegendExpanded,
          onToggle:
              () => setState(() => _isLegendExpanded = !_isLegendExpanded),
        ),
      ],
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Memuat data peta...",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 64,
              color: theme.colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              "Tidak ada data peta",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Silakan pilih filter lain atau refresh data",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClusterMarker(int count, ThemeData theme) {
    final color =
        count > 50
            ? theme.colorScheme.error
            : count > 20
            ? Colors.orange
            : theme.colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 3),
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _updateCacheIfNeeded(List<MapPotensiItem> points) {
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
              width: 40,
              height: 40,
              point: LatLng(e.lat, e.lng),
              child: _PinMarker(
                status: e.statusLahan,
                onTap: () => _showMarkerDetail(e),
              ),
            );
          }).toList();

      _cachedHeatPoints =
          renderPoints
              .map((e) => WeightedLatLng(LatLng(e.lat, e.lng), 1))
              .toList();
    }
  }

  void _showMarkerDetail(MapPotensiItem item) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                item.statusLahan,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: _getStatusColor(item.statusLahan),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Detail Lahan",
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "ID: ${item.idLahan}",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildDetailRow(
                        icon: Icons.info_outline,
                        label: "Status",
                        value: item.statusLahan,
                        valueColor: _getStatusColor(item.statusLahan),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        icon: Icons.explore_outlined,
                        label: "Koordinat",
                        value:
                            "${item.lat.toStringAsFixed(6)}, ${item.lng.toStringAsFixed(6)}",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(
          "$label:",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? theme.colorScheme.onSurface,
            ),
          ),
        ),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'baik':
        return const Color(0xFF10B981); // Emerald 500
      case 'sedang':
        return const Color(0xFFF59E0B); // Amber 500
      case 'buruk':
        return const Color(0xFFEF4444); // Red 500
      default:
        return const Color(0xFF6B7280); // Gray 500
    }
  }
}

// ==========================================
// FILTER TOOLBAR - Redesigned
// ==========================================

class _FilterToolbar extends StatelessWidget {
  const _FilterToolbar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<DashboardProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Filter Data",
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _FilterChip(
                  icon: Icons.category_outlined,
                  label: "Jenis Komoditi",
                  value: provider.selectedJenisKomoditi ?? "Semua",
                  items: ["Semua", ...provider.jenisKomoditiList],
                  onSelected:
                      (val) => provider.selectJenisKomoditi(
                        val == "Semua" ? null : val,
                      ),
                ),
                const SizedBox(width: 12),
                _FilterChip(
                  icon: Icons.grass_outlined,
                  label: "Komoditi",
                  value: provider.selectedKomoditiId ?? "Semua",
                  items: ["Semua", ...provider.komoditiList.map((e) => e.id)],
                  itemLabels: [
                    "Semua",
                    ...provider.komoditiList.map((e) => e.label),
                  ],
                  onSelected:
                      (val) =>
                          provider.selectKomoditi(val == "Semua" ? null : val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<String> items;
  final List<String>? itemLabels;
  final ValueChanged<String> onSelected;

  const _FilterChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.items,
    required this.onSelected,
    this.itemLabels,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showFilterMenu(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    _getDisplayValue(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDisplayValue() {
    if (itemLabels != null && items.contains(value)) {
      final index = items.indexOf(value);
      if (index < itemLabels!.length) {
        return itemLabels![index];
      }
    }
    return value;
  }

  void _showFilterMenu(BuildContext context) {
    final theme = Theme.of(context);
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items:
          items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final displayText =
                itemLabels != null && index < itemLabels!.length
                    ? itemLabels![index]
                    : item;
            final isSelected = item == value;

            return PopupMenuItem<String>(
              value: item,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    if (isSelected)
                      Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      )
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 12),
                    Text(
                      displayText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color:
                            isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    ).then((selected) {
      if (selected != null) {
        onSelected(selected);
      }
    });
  }
}

// ==========================================
// MAP CONTROLS - Redesigned
// ==========================================

class _MapControls extends StatelessWidget {
  final VoidCallback onResetView;
  final VoidCallback onToggleSatellite;
  final VoidCallback onToggleHeatmap;
  final bool satelliteMode;
  final bool heatmapMode;

  const _MapControls({
    required this.onResetView,
    required this.onToggleSatellite,
    required this.onToggleHeatmap,
    required this.satelliteMode,
    required this.heatmapMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      right: 16,
      top: 16,
      child: Column(
        children: [
          _ControlButton(
            icon: Icons.my_location_rounded,
            tooltip: "Reset View",
            onTap: onResetView,
            theme: theme,
          ),
          const SizedBox(height: 8),
          _ControlButton(
            icon: satelliteMode ? Icons.satellite_alt : Icons.map_outlined,
            tooltip: satelliteMode ? "Mode Jalan" : "Mode Satelit",
            onTap: onToggleSatellite,
            isActive: satelliteMode,
            theme: theme,
          ),
          const SizedBox(height: 8),
          _ControlButton(
            icon: Icons.local_fire_department_rounded,
            tooltip: heatmapMode ? "Sembunyikan Heatmap" : "Tampilkan Heatmap",
            onTap: onToggleHeatmap,
            isActive: heatmapMode,
            theme: theme,
            activeColor: Colors.orange,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final ThemeData theme;
  final bool isActive;
  final Color? activeColor;

  const _ControlButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.theme,
    this.isActive = false,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color:
                isActive
                    ? (activeColor ?? theme.colorScheme.primary).withOpacity(
                      0.1,
                    )
                    : Colors.white,
            border:
                isActive
                    ? Border.all(
                      color: (activeColor ?? theme.colorScheme.primary)
                          .withOpacity(0.3),
                      width: 1.5,
                    )
                    : null,
          ),
          child: Tooltip(
            message: tooltip,
            child: Icon(
              icon,
              size: 22,
              color:
                  isActive
                      ? (activeColor ?? theme.colorScheme.primary)
                      : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// LEGEND - Collapsible
// ==========================================

class _Legend extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const _Legend({required this.isExpanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      bottom: 16,
      left: 16,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: onToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.legend_toggle_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Legenda",
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedRotation(
                          turns: isExpanded ? 0 : 0.5,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.keyboard_arrow_up_rounded,
                            size: 18,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: Container(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        _LegendItem(
                          color: const Color(0xFF10B981),
                          label: "Baik",
                          count: "Optimal",
                        ),
                        const SizedBox(height: 8),
                        _LegendItem(
                          color: const Color(0xFFF59E0B),
                          label: "Sedang",
                          count: "Perlu Perhatian",
                        ),
                        const SizedBox(height: 8),
                        _LegendItem(
                          color: const Color(0xFFEF4444),
                          label: "Buruk",
                          count: "Kritis",
                        ),
                        const SizedBox(height: 8),
                        _LegendItem(
                          color: const Color(0xFF6B7280),
                          label: "Lainnya",
                          count: "Tidak Terdefinisi",
                        ),
                      ],
                    ),
                  ),
                  secondChild: const SizedBox.shrink(),
                  crossFadeState:
                      isExpanded
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String count;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              count,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ==========================================
// PIN MARKER - Enhanced
// ==========================================

class _PinMarker extends StatelessWidget {
  final String status;
  final VoidCallback onTap;

  const _PinMarker({required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.location_on_rounded,
            size: 36,
            color: color,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'baik':
        return const Color(0xFF10B981);
      case 'sedang':
        return const Color(0xFFF59E0B);
      case 'buruk':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }
}

// Tambahkan di atas class PotensiMapSection atau di file terpisah
extension ColorExtension on Color {
  MaterialColor get toMaterialColor {
    final Map<int, Color> shades = {
      50: withOpacity(0.1),
      100: withOpacity(0.2),
      200: withOpacity(0.3),
      300: withOpacity(0.4),
      400: withOpacity(0.5),
      500: this,
      600: withOpacity(0.6),
      700: withOpacity(0.7),
      800: withOpacity(0.8),
      900: withOpacity(0.9),
    };
    return MaterialColor(value.toInt(), shades);
  }
}
