import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:viranav/core/theme/theme_provider.dart';
import 'package:viranav/core/theme/app_theme.dart';
import 'package:viranav/core/localization/app_localizations.dart';
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
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _destinationPos = const LatLng(36.850, 27.480);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recalculateRoute();
    });
  }

  void _recalculateRoute() {
    if (_destinationPos == null) return;
    final vessel = ref.read(vesselProvider);

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

  Future<void> _centerOnCurrentLocation() async {
    setState(() => _isLocating = true);
    final s = ref.read(stringsProvider);
    try {
      // 1. Check if location services (GPS) are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('GPS kapalı. Lütfen konumu açınız / Please turn on GPS'),
              action: SnackBarAction(
                label: 'Ayarlar',
                onPressed: () => Geolocator.openLocationSettings(),
              ),
            ),
          );
        }
        return;
      }

      // 2. Check and actively request permission if denied
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Konum izni verilmedi / Location permission denied')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Konum izni kalıcı reddedildi / Location permission permanently denied'),
              action: SnackBarAction(
                label: 'Ayarlar',
                onPressed: () => Geolocator.openAppSettings(),
              ),
            ),
          );
        }
        return;
      }

      // 3. Obtain position (try fast cached position first, then fresh accurate fix)
      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 8),
        ),
      );

      final newCoord = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentBoatPos = newCoord;
      });
      _mapController.move(newCoord, 14.0);
      _recalculateRoute();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${s.tripErrorMsg}$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final isNightVision = ref.watch(isNightVisionProvider);
    final vessel = ref.watch(vesselProvider);
    final trackingState = ref.watch(trackingStateStreamProvider).value;

    if (trackingState?.lastPosition != null) {
      _currentBoatPos = LatLng(
        trackingState!.lastPosition!.latitude,
        trackingState.lastPosition!.longitude,
      );
    }

    final primaryAccent = isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.mapTitle),
        actions: [
          ActionChip(
            avatar: Icon(
              vessel.isSailboat ? Icons.sailing : Icons.directions_boat,
              size: 16,
              color: primaryAccent,
            ),
            label: Text(
              vessel.isSailboat ? s.sailboatMode : s.motorYachtMode,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: primaryAccent,
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

          // "MY LOCATION" FLOATING ACTION BUTTON
          Positioned(
            right: 16,
            top: 16,
            child: FloatingActionButton(
              heroTag: 'map_my_location_btn',
              mini: true,
              backgroundColor: isNightVision ? AppTheme.nightRedPrimary : AppTheme.navySurface,
              foregroundColor: isNightVision ? Colors.white : AppTheme.neonCyan,
              tooltip: s.locateMeTooltip,
              onPressed: _isLocating ? null : _centerOnCurrentLocation,
              child: _isLocating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.my_location),
            ),
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
                                _calculatedRoute!.requiresTacking ? s.tackRoute : s.directRoute,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${s.shallowWaterLimit}: >${_calculatedRoute!.minSafeDepthMeters.toStringAsFixed(1)}m',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(s.distance, '${_calculatedRoute!.totalDistanceNm.toStringAsFixed(1)} NM'),
                          _buildStatItem(s.estimatedTime, '${_calculatedRoute!.estimatedTimeHours.toStringAsFixed(1)} ${s.hoursUnit}'),
                          if (vessel.isMotorYacht)
                            _buildStatItem(s.fuelUsage, '${_calculatedRoute!.estimatedFuelLiters.round()} L')
                          else
                            _buildStatItem(s.vmgSpeed, '${_calculatedRoute!.vmgKnots.toStringAsFixed(1)} kn'),
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
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, size: 14, color: Colors.amber),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  s.tackingNotice,
                                  style: const TextStyle(fontSize: 10, color: Colors.amber),
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
        Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
