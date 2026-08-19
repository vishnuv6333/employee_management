import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../../features/notes/domain/repositories/note_repository.dart';
import '../../main.dart';

class SyncService {
  final NoteRepository noteRepository;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOffline = false;
  final _offlineStatusController = StreamController<bool>.broadcast();

  SyncService({required this.noteRepository});

  Stream<bool> get offlineStatusStream => _offlineStatusController.stream;
  bool get isOffline => _isOffline;

  void init() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) async {
    final wasOffline = _isOffline;
    _isOffline = results.contains(ConnectivityResult.none);

    if (_isOffline != wasOffline) {
      _offlineStatusController.add(_isOffline);
    }

    if (wasOffline && !_isOffline) {
      // Returned online, simulate sync
      await _simulateSync();
    }
  }

  Future<void> _simulateSync() async {
    debugPrint('SyncService: Network restored. Syncing queued items...');
    // We get the queued operations
    final queue = await noteRepository.getSyncQueue();
    if (queue.isEmpty) {
      debugPrint('SyncService: No items in sync queue.');
      return;
    }

    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('Syncing ${queue.length} items...'),
        duration: const Duration(seconds: 1),
      ),
    );

    for (var i = 0; i < queue.length; i++) {
      final item = queue[i];
      final operation = item['operation'];

      scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Syncing $operation (${i + 1}/${queue.length})...'),
          duration: const Duration(milliseconds: 800),
        ),
      );

      // Simulated delay for each item
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('SyncService: Synced $operation for note ${item['noteId']}');
    }

    // Clear the queue after successful sync simulation
    await noteRepository.clearSyncQueue();
    debugPrint('SyncService: Sync completed successfully.');

    scaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text('Sync completed successfully.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _offlineStatusController.close();
  }
}
