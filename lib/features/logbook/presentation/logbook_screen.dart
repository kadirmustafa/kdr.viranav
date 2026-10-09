import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:viranav/core/theme/theme_provider.dart';
import 'package:viranav/core/theme/app_theme.dart';
import 'package:viranav/core/localization/app_localizations.dart';
import 'package:viranav/core/providers/navigation_providers.dart';
import 'package:viranav/features/logbook/domain/trip.dart';

class LogbookScreen extends ConsumerStatefulWidget {
  const LogbookScreen({super.key});

  @override
  ConsumerState<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends ConsumerState<LogbookScreen> {
  List<Trip> _trips = [];
  bool _isLoading = true;
  bool _isStopping = false;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(tripRepositoryProvider);
      final list = await repo.getAllTrips();
      if (mounted) {
        setState(() {
          _trips = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showStartTripDialog() {
    final s = ref.read(stringsProvider);
    final vessel = ref.read(vesselProvider);
    final textController = TextEditingController(
      text: s.tripNameDefault,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.newTripDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.newTripDialogDesc,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                labelText: s.tripNameLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${s.vesselLabel}: ${vessel.name}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancelButton),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final tripId = const Uuid().v4();
              try {
                await ref.read(trackingServiceProvider).startTrip(
                  tripId: tripId,
                  title: textController.text.trim().isEmpty
                      ? s.tripNameDefault
                      : textController.text.trim(),
                  vesselName: vessel.name,
                );
                await _loadTrips();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s.tripStartedMsg)),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${s.tripErrorMsg}$e')),
                  );
                }
              }
            },
            child: Text(s.startButton),
          ),
        ],
      ),
    );
  }

  void _confirmAndStopTrip() {
    final s = ref.read(stringsProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.stopTripConfirmTitle),
        content: Text(s.stopTripConfirmDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancelButton),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isStopping = true);
              try {
                final finished = await ref.read(trackingServiceProvider).stopTrip();
                await _loadTrips();
                if (mounted) {
                  setState(() => _isStopping = false);
                  final dist = finished?.totalDistanceNm.toStringAsFixed(2) ?? '0.00';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${s.tripEndedMsg}$dist NM, GPX ✓'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _isStopping = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${s.tripErrorMsg}$e')),
                  );
                }
              }
            },
            child: Text(s.stopTripConfirmButton),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = ref.watch(stringsProvider);
    final isNightVision = ref.watch(isNightVisionProvider);
    final trackingState = ref.watch(trackingStateStreamProvider).value ??
        ref.read(trackingServiceProvider).currentState;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.logbookTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadTrips,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTrips,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active Voyage Recording Card
              Card(
                color: trackingState.isTracking
                    ? (isNightVision ? AppTheme.nightCard : const Color(0xFF0F3254))
                    : theme.cardTheme.color,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                trackingState.isTracking ? Icons.fiber_manual_record : Icons.trip_origin,
                                color: trackingState.isTracking
                                    ? Colors.redAccent
                                    : (isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                trackingState.isTracking ? s.tripActive : s.tripStatus,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: trackingState.isTracking
                                  ? Colors.redAccent.withValues(alpha: 0.2)
                                  : Colors.grey.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              trackingState.isTracking ? '5s GPS' : s.tripIdle,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: trackingState.isTracking ? Colors.redAccent : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (trackingState.isTracking) ...[
                        Text(
                          trackingState.currentTrip?.title ?? s.tripNameDefault,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${s.points}: ${trackingState.pointsLogged}  |  SOG: ${trackingState.currentSogKnots.toStringAsFixed(1)} kn',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            icon: _isStopping
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Icon(Icons.stop),
                            label: Text(
                              _isStopping ? '...' : s.stopTrip,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: _isStopping ? null : _confirmAndStopTrip,
                          ),
                        ),
                      ] else ...[
                        Text(
                          s.newTripDialogDesc,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan,
                              foregroundColor: isNightVision ? Colors.white : AppTheme.navyBackground,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            icon: const Icon(Icons.play_arrow),
                            label: Text(
                              s.startNewTrip,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: _showStartTripDialog,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.pastTrips,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                  Text(
                    '${_trips.length} ${s.tripCount}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
              else if (_trips.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.menu_book, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text(s.noTripsYet, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _trips.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final trip = _trips[index];
                    return _buildTripCard(trip, isNightVision, s);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(Trip trip, bool isNightVision, AppStrings s) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    trip.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                if (trip.isSynced)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(s.r2Synced, style: const TextStyle(fontSize: 10, color: Colors.greenAccent)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${dateFormat.format(trip.startTime)}  •  ${trip.vesselName}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTripMetric(s.distance, '${trip.totalDistanceNm.toStringAsFixed(1)} NM'),
                _buildTripMetric(s.maxSog, '${trip.maxSpeedKnots.toStringAsFixed(1)} kn'),
                _buildTripMetric(s.avgSog, '${trip.avgSpeedKnots.toStringAsFixed(1)} kn'),
                _buildTripMetric(s.points, '${trip.totalPointsCount}'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.share, size: 16),
                  label: Text(s.shareGpx, style: const TextStyle(fontSize: 12)),
                  onPressed: () async {
                    await ref.read(tripRepositoryProvider).shareGpx(trip.id);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                  tooltip: s.deleteTrip,
                  onPressed: () async {
                    await ref.read(tripRepositoryProvider).deleteTrip(trip.id);
                    await _loadTrips();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
