// lib/widgets/sync_status.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/sync_provider.dart';

class SyncStatusWidget extends StatelessWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, child) {
        final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Synchronisierung',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Switch(
                      value: syncProvider.autoSync,
                      onChanged: (value) => syncProvider.setAutoSync(value),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusIcon(syncProvider.status),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_getStatusText(syncProvider.status)),
                          if (syncProvider.lastSyncTime != null)
                            Text(
                              'Letzte Synchronisierung: ${dateFormat.format(syncProvider.lastSyncTime!)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          if (syncProvider.lastError != null && syncProvider.status == SyncStatus.error)
                            Text(
                              'Fehler: ${syncProvider.lastError}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: syncProvider.status == SyncStatus.syncing
                        ? null
                        : () => syncProvider.sync(),
                    icon: const Icon(Icons.sync),
                    label: const Text('Jetzt synchronisieren'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return const Icon(Icons.hourglass_empty, color: Colors.grey);
      case SyncStatus.syncing:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case SyncStatus.complete:
        return const Icon(Icons.check_circle, color: Colors.green);
      case SyncStatus.error:
        return const Icon(Icons.error, color: Colors.red);
      case SyncStatus.offline:
        return const Icon(Icons.cloud_off, color: Colors.grey);
    }
  }

  String _getStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return 'Bereit';
      case SyncStatus.syncing:
        return 'Synchronisierung läuft...';
      case SyncStatus.complete:
        return 'Synchronisierung abgeschlossen';
      case SyncStatus.error:
        return 'Synchronisierungsfehler';
      case SyncStatus.offline:
        return 'Offline - keine Verbindung';
    }
  }
}