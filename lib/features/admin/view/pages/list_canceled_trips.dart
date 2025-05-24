import 'package:driver_app/features/admin/model/ride_history_model.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class CanceledRidesPage extends StatefulWidget {
  const CanceledRidesPage({super.key});

  @override
  State<CanceledRidesPage> createState() => _CanceledRidesPageState();
}

class _CanceledRidesPageState extends State<CanceledRidesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final int _limit = 15; // Number of documents to fetch per page

  List<RideRequest> _rides = [];
  DocumentSnapshot? _lastDocument; // For pagination
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        _fetchInitialRides();
        _scrollController.addListener(_scrollListener);
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialRides() async {
    setState(() => _isLoading = true);
    try {
      final query = _firestore
          .collection('ride_history')
          .where('status', isEqualTo: DriverRideStatus.canceled)
          .orderBy('startTime', descending: true)
          .limit(_limit);

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        _rides = snapshot.docs
            .map((doc) => RideRequest.fromJson(doc.data()))
            .toList();
      } else {
        _hasMore = false;
      }
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching rides: $e');
      }
      // Optionally show error to user
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMoreRides() async {
    if (!_hasMore || _isLoading) return;

    setState(() => _isLoading = true);
    try {
      final query = _firestore
          .collection('ride_history')
          .where('status', isEqualTo: DriverRideStatus.canceled)
          .orderBy('timesTamp', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_limit);

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        _rides.addAll(
            snapshot.docs.map((doc) => RideRequest.fromJson(doc.data())));
      } else {
        _hasMore = false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching more rides: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _fetchMoreRides();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viajes cancelados'),
      ),
      body: _isLoading && _rides.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _rides.isEmpty
              ? const Center(child: Text('No se encontraron vaijes cancelados'))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: _rides.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _rides.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final ride = _rides[index];
                    return _buildRideItem(ride);
                  },
                ),
    );
  }

  Widget _buildRideItem(RideRequest ride) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cliente: ${ride.passengerName}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Conductor: ${ride.driverName}'),
            const SizedBox(height: 4),
            Text('Recogida: ${ride.pickUpLocation}'),
            const SizedBox(height: 4),
            Text('Sector: ${ride.sector}'),
            const SizedBox(height: 4),
            Text(
              'Canceledo el: ${DateFormat('MMM dd, yyyy - hh:mm a').format(ride.timestamp.toDate())}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
