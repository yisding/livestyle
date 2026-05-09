import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/health_data_point.dart';
import '../../services/health_connect_permission_service.dart';
import '../../services/health_connect_service.dart';

/// Screen for requesting Health Connect permissions
class HealthConnectPermissionScreen extends ConsumerStatefulWidget {
  const HealthConnectPermissionScreen({super.key});

  @override
  ConsumerState<HealthConnectPermissionScreen> createState() =>
      _HealthConnectPermissionScreenState();
}

class _HealthConnectPermissionScreenState
    extends ConsumerState<HealthConnectPermissionScreen> {
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
    _checkHealthConnectAvailability();
  }

  @override
  void dispose() {
    _permissionService.dispose();
    super.dispose();
  }

  Future<void> _checkHealthConnectAvailability() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isAvailable = await _permissionService.isHealthConnectAvailable();
      final essentialTypes = _permissionService.getEssentialDataTypes();
      final permissions = await _permissionService.getPermissionStatus(essentialTypes);

      setState(() {
        _isHealthConnectAvailable = isAvailable;
        _permissionStatus = permissions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to check Health Connect availability: ${e.toString()}';
      });
    }
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final essentialTypes = _permissionService.getEssentialDataTypes();
      final result = await _permissionService.requestPermissions(essentialTypes);

      if (result.success) {
        setState(() {
          _permissionStatus = result.permissions;
          _isLoading = false;
        });

        if (result.allPermissionsGranted) {
          _showSuccessDialog();
        } else {
          _showPartialSuccessDialog(result);
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result.errorMessage ?? 'Failed to request permissions';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error requesting permissions: ${e.toString()}';
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Granted'),
        content: const Text(
          'Great! LiveStyle can now access your health data to provide '
          'personalized recommendations and track your progress.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToHome();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showPartialSuccessDialog(PermissionResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Some Permissions Granted'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Some permissions were granted:'),
            const SizedBox(height: 8),
            ...result.grantedPermissions.map(
              (type) => Text('✓ ${_permissionService.getDataTypeName(type)}'),
            ),
            if (result.deniedPermissions.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('These permissions were denied:'),
              const SizedBox(height: 4),
              ...result.deniedPermissions.map(
                (type) => Text('✗ ${_permissionService.getDataTypeName(type)}'),
              ),
            ],
            const SizedBox(height: 8),
            const Text(
              'You can still use LiveStyle with manual data entry for '
              'the denied permissions.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToHome();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _skipPermissions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Health Connect?'),
        content: const Text(
          'You can skip Health Connect integration and use manual data entry. '
          'You can always enable Health Connect later in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToHome();
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 32),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : !_isHealthConnectAvailable
                        ? _buildUnavailableState(theme)
                        : _buildPermissionsList(theme),
              ),
              _buildActionButtons(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.health_and_safety,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Connect Health Data',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'LiveStyle can sync with Health Connect to automatically track '
          'your health metrics and provide personalized AI coaching.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Checking Health Connect availability...'),
        ],
      ),
    );
  }

  Widget _buildUnavailableState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Health Connect Unavailable',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Health Connect is not available on this device. '
            'You can still use LiveStyle with manual data entry.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPermissionsList(ThemeData theme) {
    final essentialTypes = _permissionService.getEssentialDataTypes();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Data Permissions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'LiveStyle needs access to the following health data to provide '
          'personalized recommendations:',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: essentialTypes.length,
            itemBuilder: (context, index) {
              final type = essentialTypes[index];
              final status = _permissionStatus[type] ?? PermissionStatus.notDetermined;
              
              return _buildPermissionItem(theme, type, status);
            },
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Container(
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
          ),
        ],
      ],
    );
  }

  Widget _buildPermissionItem(
    ThemeData theme,
    HealthDataType type,
    PermissionStatus status,
  ) {
    final iconName = _permissionService.getDataTypeIcon(type);
    final name = _permissionService.getDataTypeName(type);
    final description = _permissionService.getDataTypeDescription(type);
    
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case PermissionStatus.granted:
        statusColor = theme.colorScheme.primary;
        statusIcon = Icons.check_circle;
        break;
      case PermissionStatus.denied:
        statusColor = theme.colorScheme.error;
        statusIcon = Icons.cancel;
        break;
      case PermissionStatus.restricted:
        statusColor = theme.colorScheme.outline;
        statusIcon = Icons.block;
        break;
      case PermissionStatus.notDetermined:
        statusColor = theme.colorScheme.outline;
        statusIcon = Icons.help_outline;
        break;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getIconData(iconName),
          color: theme.colorScheme.primary,
        ),
        title: Text(
          name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: Icon(
          statusIcon,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        if (_isHealthConnectAvailable) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _requestPermissions,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Grant Permissions'),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isLoading ? null : _skipPermissions,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              _isHealthConnectAvailable ? 'Skip for Now' : 'Continue with Manual Entry',
            ),
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