import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:viranav/core/theme/theme_provider.dart';
import 'package:viranav/core/theme/app_theme.dart';
import 'package:viranav/core/constants/marine_constants.dart';
import 'package:viranav/core/providers/navigation_providers.dart';
import 'package:viranav/features/navigation/domain/route_engine.dart';

class NavigationMapScreen extends ConsumerStatefulWidget {
  const NavigationMapScreen({super.key});

  @override
  ConsumerState<NavigationMapScreen> createState() => _NavigationMapScreenState();
}

class _NavigationMapScreenState extends ConsumerState<NavigationMapScreen> {
  final MapController _mapController = MapController();

  // Aegean baseline coordinates (Bodrum / Kos channel)
  LatLng _currentBoatPos = const LatLng(36.985, 27.350);
  LatLng? _destinationPos;
  PlannedRoute? _calculatedRoute;

  @override
  void initState() {
    super.initState();
    // Default destination: Simi / Datça direction
    _destinationPos = const LatLng(36.850, 27.480);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recalculateRoute();
    });
  }

  void _recalculateRoute() {
    if (_destinationPos == null) return;
    final vessel = ref.read(vesselProvider);

    // Weather wind direction (assumed 330° Meltemi / NW wind)
    const windDirection = 340.0;
    const windSpeed = 16.0;

    final route = RouteEngine.calculateRoute(
      departure: _currentBoatPos,
      destination: _destinationPos!,
      vessel: vessel,
      trueWindDirectionDeg: windDirection,
      windSpeedKnots: windSpeed,
    );

    setState(() {
      _calculatedRoute = route;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isNightVision = ref.watch(themeModeProvider) == NavThemeMode.nightVisionRed;
    final vessel = ref.watch(vesselProvider);
    final trackingState = ref.watch(trackingStateStreamProvider).value;

    if (trackingState?.lastPosition != null) {
      _currentBoatPos = LatLng(
        trackingState!.lastPosition!.latitude,
        trackingState.lastPosition!.longitude,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SEYİR HARİTASI & ROTA'),
        actions: [
          // Switch between Sailboat and Motor Yacht modes
          ActionChip(
            avatar: Icon(
              vessel.isSailboat ? Icons.sailing : Icons.directions_boat,
              size: 16,
              color: isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan,
            ),
            label: Text(
              vessel.isSailboat ? 'Yelkenli' : 'Motor Yat',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan,
              ),
            ),
            onPressed: () {
              ref.read(vesselProvider.notifier).toggleType();
              Future.microtask(() => _recalculateRoute());
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentBoatPos,
              initialZoom: 11.5,
              onTap: (tapPosition, point) {
                setState(() {
                  _destinationPos = point;
                });
                _recalculateRoute();
              },
            ),
            children: [
              // OpenStreetMap Base Navigation Layer
              TileLayer(
                urlTemplate: MarineConstants.openStreetMapUrl,
                userAgentPackageName: 'com.viranav.app',
              ),
              // OpenSeaMap Seamarks Nautical Overlay Layer (Buoys, lights, lighthouses)
              TileLayer(
                urlTemplate: MarineConstants.openSeaMapTileUrl,
                userAgentPackageName: 'com.viranav.app',
              ),
              // Planned Route Polyline
              if (_calculatedRoute != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _calculatedRoute!.waypoints,
                      color: _calculatedRoute!.requiresTacking
                          ? (isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan)
                          : (isNightVision ? AppTheme.nightRedPrimary : Colors.greenAccent),
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
              // Markers Layer (Current Boat + Tack Waypoints + Destination)
              MarkerLayer(
                markers: [
                  // Current Boat Position
                  Marker(
                    point: _currentBoatPos,
                    width: 44,
                    height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isNightVision ? AppTheme.nightRedPrimary : AppTheme.navyBackground,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: const [
                          BoxShadow(color: Colors.black45, blurRadius: 6),
                        ],
                      ),
                      child: Icon(
                        vessel.isSailboat ? Icons.sailing : Icons.directions_boat,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  // Destination Marker
                  if (_destinationPos != null)
                    Marker(
                      point: _destinationPos!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.redAccent,
                        size: 40,
                      ),
                    ),
                  // Intermediate Tacking Waypoints
                  if (_calculatedRoute != null && _calculatedRoute!.requiresTacking)
                    ..._calculatedRoute!.waypoints.sublist(1, _calculatedRoute!.waypoints.length - 1).map(
                          (wp) => Marker(
                            point: wp,
                            width: 32,
                            height: 32,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isNightVision ? AppTheme.nightRedSecondary : AppTheme.warningAmber,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: const Center(
                                child: Text(
                                  'TACK',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ],
          ),

          // Route Information Overlay Panel at Bottom
          if (_calculatedRoute != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 16,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan.withValues(alpha: 0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _calculatedRoute!.requiresTacking ? Icons.alt_route : Icons.straight,
                                color: isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _calculatedRoute!.requiresTacking
                                    ? 'YELKEN TRAMOLA ROTASI'
                                    : 'DOĞRUDAN SEYİR ROTASI',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Sığlık Limiti: >${_calculatedRoute!.minSafeDepthMeters.toStringAsFixed(1)}m',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Mesafe', '${_calculatedRoute!.totalDistanceNm.toStringAsFixed(1)} NM'),
                          _buildStatItem('Tahmini Süre', '${_calculatedRoute!.estimatedTimeHours.toStringAsFixed(1)} Sa'),
                          if (vessel.isMotorYacht)
                            _buildStatItem('Yakıt', '${_calculatedRoute!.estimatedFuelLiters.round()} L')
                          else
                            _buildStatItem('VMG Hızı', '${_calculatedRoute!.vmgKnots.toStringAsFixed(1)} kn'),
                        ],
                      ),
                      if (_calculatedRoute!.requiresTacking) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, size: 14, color: Colors.amber),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Rüzgara karşı ±45° kör açı engellendi. Tramola zikzakları ile varış hesaplandı.',
                                  style: TextStyle(fontSize: 10, color: Colors.amber),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
