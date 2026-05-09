import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/health_data_point.dart';
import '../services/health_connect_permission_service.dart';
import '../services/health_connect_service.dart';

/// Widget for managing Health Connect permissions in settings
class HealthConnectPermissionSettings extends ConsumerStatefulWidget {
  const HealthConnectPermissionSettings({super.key});

  @override
  ConsumerState<HealthConnectPermissionSettings> createState() =>
      _HealthConnectPermissionSettingsState();
}

class _HealthConnectPermissionSettingsState
    extends ConsumerState<HealthConnectPermissionSettings> {
  late final HealthConnectPermissionService _permissionService;
  bool _isLoading = false;
  bool _isHealthConnectAvailable = false;
  Map<HealthDataType, PermissionStatus> _permissionStatus = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _permissionService = HealthConnectPermissionService(
      Platform.isAndroid 
          ? HealthConnectServiceImpl() 
          : HealthConnectServiceStub(),
    );
    _loadPermissionStatus();
    _listenToPermissionChanges();
  }

  @override
  void dispose() {
    _permissionService.dispose();
    super.dispose();
  }

  void _listenToPermissionChanges() {
    _permissionService.permissionEvents.listen((event) {
      if (event is PermissionStatusChangedEvent) {
        setState(() {
          _permissionStatus = event.permissions;
        });
      }
    });
  }

  Future<void> _loadPermissionStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isAvailable = await _permissionService.isHealthConnectAvailable();
      
      if (isAvailable) {
        final allTypes = _permissionService.getSupportedDataTypes();
        final permissions = await _permissionService.getPermissionStatus(allTypes);
        
        setState(() {
          _isHealthConnectAvailable = isAvailable;
          _permissionStatus = permissions;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isHealthConnectAvailable = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load permission status: ${e.toString()}';
      });
    }
  }

  Future<void> _requestPermission(HealthDataType type) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _permissionService.requestPermissions([type]);
      
      if (result.success) {
        setState(() {
          _permissionStatus.addAll(result.permissions);
          _isLoading = false;
        });
        
        _showSnackBar(
          result.permissions[type] == PermissionStatus.granted
              ? 'Permission granted for ${_permissionService.getDataTypeName(type)}'
              : 'Permission denied for ${_permissionService.getDataTypeName(type)}',
          result.permissions[type] == PermissionStatus.granted,
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result.errorMessage;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error requesting permission: ${e.toString()}';
      });
    }
  }

  Future<void> _requestAllPermissions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final allTypes = _permissionService.getSupportedDataTypes();
      final result = await _permissionService.requestPermissions(allTypes);
      
      if (result.success) {
        setState(() {
          _permissionStatus = result.permissions;
          _isLoading = false;
        });
        
        final grantedCount = result.grantedPermissions.length;
        final totalCount = allTypes.length;
        
        _showSnackBar(
          'Granted $grantedCount of $totalCount permissions',
          grantedCount > 0,
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result.errorMessage;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error requesting permissions: ${e.toString()}';
      });
    }
  }

  Future<void> _revokeAllPermissions() async {
    final confirmed = await _showRevokeConfirmationDialog();
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _permissionService.revokeAllPermissions();
      
      if (result.success) {
        setState(() {
          _permissionStatus.clear();
          _isLoading = false;
        });
        
        _showSnackBar('All Health Connect permissions revoked', false);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result.errorMessage;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error revoking permissions: ${e.toString()}';
      });
    }
  }

  Future<bool> _showRevokeConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke All Permissions?'),
        content: const Text(
          'This will revoke all Health Connect permissions. You will need to '
          'grant them again to use Health Connect features. Manual data entry '
          'will still be available.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Revoke All'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess 
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (!Platform.isAndroid) {
      return _buildPlatformNotSupportedCard(theme);
    }
    
    if (!_isHealthConnectAvailable) {
      return _buildHealthConnectUnavailableCard(theme);
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 16),
            if (_isLoading) _buildLoadingIndicator(),
            if (_errorMessage != null) _buildErrorMessage(theme),
            _buildPermissionsList(theme),
            const SizedBox(height: 16),
            _buildActionButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformNotSupportedCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Health Connect',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Health Connect is only available on Android devices. '
              'You can use manual data entry on this platform.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthConnectUnavailableCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'Health Connect Unavailable',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Health Connect is not available on this device. '
              'Please ensure you have the latest version of Health Connect installed.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadPermissionStatus,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.health_and_safety,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          'Health Connect Permissions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: LinearProgressIndicator(),
    );
  }

  Widget _buildErrorMessage(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsList(ThemeData theme) {
    final essentialTypes = _permissionService.getEssentialDataTypes();
    final optionalTypes = _permissionService.getOptionalDataTypes();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Essential Permissions',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...essentialTypes.map((type) => _buildPermissionTile(theme, type)),
        const SizedBox(height: 16),
        Text(
          'Optional Permissions',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 8),
        ...optionalTypes.map((type) => _buildPermissionTile(theme, type)),
      ],
    );
  }

  Widget _buildPermissionTile(ThemeData theme, HealthDataType type) {
    final status = _permissionStatus[type] ?? PermissionStatus.notDetermined;
    final name = _permissionService.getDataTypeName(type);
    final description = _permissionService.getDataTypeDescription(type);
    final iconName = _permissionService.getDataTypeIcon(type);
    
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (status) {
      case PermissionStatus.granted:
        statusColor = theme.colorScheme.primary;
        statusIcon = Icons.check_circle;
        statusText = 'Granted';
        break;
      case PermissionStatus.denied:
        statusColor = theme.colorScheme.error;
        statusIcon = Icons.cancel;
        statusText = 'Denied';
        break;
      case PermissionStatus.restricted:
        statusColor = theme.colorScheme.outline;
        statusIcon = Icons.block;
        statusText = 'Restricted';
        break;
      case PermissionStatus.notDetermined:
        statusColor = theme.colorScheme.outline;
        statusIcon = Icons.help_outline;
        statusText = 'Not Set';
        break;
    }
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        _getIconData(iconName),
        color: theme.colorScheme.primary,
      ),
      title: Text(
        name,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        description,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                statusIcon,
                color: statusColor,
                size: 20,
              ),
              Text(
                statusText,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: statusColor,
                ),
              ),
            ],
          ),
          if (status != PermissionStatus.granted) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: _isLoading ? null : () => _requestPermission(type),
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Request Permission',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    final hasAnyPermissions = _permissionStatus.values
        .any((status) => status == PermissionStatus.granted);
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : _requestAllPermissions,
            child: const Text('Request All'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading || !hasAnyPermissions ? null : _revokeAllPermissions,
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
            ),
            child: const Text('Revoke All'),
          ),
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'scale':
        return Icons.monitor_weight;
      case 'body':
        return Icons.accessibility;
      case 'calculator':
        return Icons.calculate;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'favorite':
        return Icons.favorite;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'bedtime':
        return Icons.bedtime;
      case 'monitor_heart':
        return Icons.monitor_heart;
      case 'bloodtype':
        return Icons.bloodtype;
      default:
        return Icons.health_and_safety;
    }
  }
}