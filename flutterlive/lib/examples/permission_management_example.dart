import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/health_data_point.dart';
import '../services/health_connect_permission_service.dart';
import '../services/health_connect_service.dart';
import '../utils/health_connect_permission_handler.dart';

/// Example demonstrating Health Connect permission management
class PermissionManagementExample extends StatefulWidget {
  const PermissionManagementExample({super.key});

  @override
  State<PermissionManagementExample> createState() => _PermissionManagementExampleState();
}

class _PermissionManagementExampleState extends State<PermissionManagementExample> {
  final HealthConnectPermissionHandler _permissionHandler = 
      HealthConnectPermissionHandler.instance;
  
  StreamSubscription<PermissionEvent>? _permissionSubscription;
  Map<HealthDataType, PermissionStatus> _permissionStatus = {};
  bool _isLoading = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _permissionHandler.initialize();
    _listenToPermissionChanges();
    _checkInitialPermissions();
  }

  @override
  void dispose() {
    _permissionSubscription?.cancel();
    super.dispose();
  }

  void _listenToPermissionChanges() {
    _permissionSubscription = _permissionHandler.permissionEvents.listen((event) {
      if (event is PermissionStatusChangedEvent) {
        setState(() {
          _permissionStatus = event.permissions;
          _statusMessage = 'Permissions updated at ${event.timestamp}';
        });
      } else if (event is PermissionRequestCompletedEvent) {
        setState(() {
          _statusMessage = _permissionHandler.getPermissionSuccessMessage(event.result);
          if (!event.result.success) {
            _statusMessage = _permissionHandler.getPermissionErrorMessage(event.result);
          }
        });
      }
    });
  }

  Future<void> _checkInitialPermissions() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Checking permissions...';
    });

    try {
      final isAvailable = await _permissionHandler.isHealthConnectAvailable();
      
      if (isAvailable) {
        final essentialTypes = [
          HealthDataType.weight,
          HealthDataType.steps,
          HealthDataType.heartRate,
          HealthDataType.workout,
        ];
        
        final permissions = await _permissionHandler.getPermissionStatus(essentialTypes);
        
        setState(() {
          _permissionStatus = permissions;
          _statusMessage = 'Health Connect is available';
          _isLoading = false;
        });
      } else {
        setState(() {
          _statusMessage = 'Health Connect is not available on this device';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error checking permissions: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _requestEssentialPermissions() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Requesting essential permissions...';
    });

    try {
      final result = await _permissionHandler.requestEssentialPermissions();
      
      setState(() {
        _isLoading = false;
        if (result.success) {
          _permissionStatus.addAll(result.permissions);
          _statusMessage = _permissionHandler.getPermissionSuccessMessage(result);
        } else {
          _statusMessage = _permissionHandler.getPermissionErrorMessage(result);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error requesting permissions: $e';
      });
    }
  }

  Future<void> _requestAllPermissions() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Requesting all permissions...';
    });

    try {
      final result = await _permissionHandler.requestAllPermissions();
      
      setState(() {
        _isLoading = false;
        if (result.success) {
          _permissionStatus.addAll(result.permissions);
          _statusMessage = _permissionHandler.getPermissionSuccessMessage(result);
        } else {
          _statusMessage = _permissionHandler.getPermissionErrorMessage(result);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error requesting permissions: $e';
      });
    }
  }

  Future<void> _revokeAllPermissions() async {
    final confirmed = await _showConfirmationDialog(
      'Revoke All Permissions?',
      'This will revoke all Health Connect permissions. You will need to grant them again to use Health Connect features.',
    );
    
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Revoking permissions...';
    });

    try {
      final result = await _permissionHandler.revokeAllPermissions();
      
      setState(() {
        _isLoading = false;
        if (result.success) {
          _permissionStatus.clear();
          _statusMessage = 'All permissions revoked successfully';
        } else {
          _statusMessage = _permissionHandler.getPermissionErrorMessage(result);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error revoking permissions: $e';
      });
    }
  }

  Future<void> _checkPermissionStatistics() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Getting permission statistics...';
    });

    try {
      final stats = await _permissionHandler.getPermissionStatistics();
      
      setState(() {
        _isLoading = false;
        _statusMessage = 'Statistics: ${stats['granted_permissions']}/${stats['total_permissions']} permissions granted';
      });
      
      _showStatsDialog(stats);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error getting statistics: $e';
      });
    }
  }

  Future<bool> _showConfirmationDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  void _showStatsDialog(Map<String, dynamic> stats) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Statistics'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Platform Supported: ${stats['platform_supported']}'),
              Text('Health Connect Available: ${stats['health_connect_available']}'),
              Text('Total Permissions: ${stats['total_permissions']}'),
              Text('Granted: ${stats['granted_permissions']}'),
              Text('Denied: ${stats['denied_permissions']}'),
              const SizedBox(height: 16),
              const Text('Permission Details:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...((stats['permission_details'] as Map<String, dynamic>? ?? {}))
                  .entries
                  .map((entry) => Text('${entry.key}: ${entry.value}')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Management Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading) const LinearProgressIndicator(),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage ?? 'Ready',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Permissions list
            if (_permissionStatus.isNotEmpty) ...[
              Text(
                'Current Permissions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _permissionStatus.length,
                  itemBuilder: (context, index) {
                    final entry = _permissionStatus.entries.elementAt(index);
                    final type = entry.key;
                    final status = entry.value;
                    
                    return ListTile(
                      leading: Icon(
                        PermissionUIHelper.getStatusIcon(status),
                        color: PermissionUIHelper.getStatusColor(status, theme.colorScheme),
                      ),
                      title: Text(_getDataTypeName(type)),
                      subtitle: Text(status.displayName),
                      trailing: status.allowsAccess 
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.close, color: Colors.red),
                    );
                  },
                ),
              ),
            ] else ...[
              const Expanded(
                child: Center(
                  child: Text('No permission data available'),
                ),
              ),
            ],
            
            // Action buttons
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _checkInitialPermissions,
                  child: const Text('Check Permissions'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _requestEssentialPermissions,
                  child: const Text('Request Essential'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _requestAllPermissions,
                  child: const Text('Request All'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _revokeAllPermissions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  ),
                  child: const Text('Revoke All'),
                ),
                OutlinedButton(
                  onPressed: _isLoading ? null : _checkPermissionStatistics,
                  child: const Text('Statistics'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDataTypeName(HealthDataType type) {
    switch (type) {
      case HealthDataType.weight:
        return 'Weight';
      case HealthDataType.bodyFatPercentage:
        return 'Body Fat %';
      case HealthDataType.bmi:
        return 'BMI';
      case HealthDataType.steps:
        return 'Steps';
      case HealthDataType.heartRate:
        return 'Heart Rate';
      case HealthDataType.workout:
        return 'Workouts';
      case HealthDataType.calories:
        return 'Calories';
      case HealthDataType.sleep:
        return 'Sleep';
      case HealthDataType.bloodPressure:
        return 'Blood Pressure';
      case HealthDataType.bloodGlucose:
        return 'Blood Glucose';
    }
  }
}