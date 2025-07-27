import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/health_data_point.dart';

/// Service class for managing Firestore operations related to health data
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID, throws exception if not authenticated
  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  /// Get reference to user's Health Connect data collection
  CollectionReference get _healthConnectDataCollection {
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('healthConnectData');
  }

  /// Get reference to user's manual health data collection
  CollectionReference get _manualHealthDataCollection {
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('manualHealthData');
  }

  /// Get reference to user's data source preferences document
  DocumentReference get _dataSourcePreferencesDoc {
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('preferences')
        .doc('dataSourcePreferences');
  }

  /// Get reference to user's Health Connect sync status document
  DocumentReference get _healthConnectSyncStatusDoc {
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('syncStatus')
        .doc('healthConnect');
  }

  /// Save Health Connect data to Firestore
  Future<void> saveHealthConnectData(List<HealthDataPoint> dataPoints) async {
    final batch = _firestore.batch();
    
    for (final dataPoint in dataPoints) {
      final docRef = _healthConnectDataCollection.doc(dataPoint.id);
      batch.set(docRef, dataPoint.toFirestore(), SetOptions(merge: true));
    }
    
    await batch.commit();
  }

  /// Save manual health data to Firestore
  Future<void> saveManualHealthData(List<HealthDataPoint> dataPoints) async {
    final batch = _firestore.batch();
    
    for (final dataPoint in dataPoints) {
      final docRef = _manualHealthDataCollection.doc(dataPoint.id);
      batch.set(docRef, dataPoint.toFirestore(), SetOptions(merge: true));
    }
    
    await batch.commit();
  }

  /// Get Health Connect data for specific types and time range
  Future<List<HealthDataPoint>> getHealthConnectData({
    required List<String> types,
    required DateTime startTime,
    required DateTime endTime,
    int? limit,
  }) async {
    Query query = _healthConnectDataCollection
        .where('type', whereIn: types)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startTime))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endTime))
        .orderBy('timestamp', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => HealthDataPoint.fromFirestore(doc))
        .toList();
  }

  /// Get manual health data for specific types and time range
  Future<List<HealthDataPoint>> getManualHealthData({
    required List<String> types,
    required DateTime startTime,
    required DateTime endTime,
    int? limit,
  }) async {
    Query query = _manualHealthDataCollection
        .where('type', whereIn: types)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startTime))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endTime))
        .orderBy('timestamp', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => HealthDataPoint.fromFirestore(doc))
        .toList();
  }

  /// Get combined health data from both sources
  Future<List<HealthDataPoint>> getCombinedHealthData({
    required List<String> types,
    required DateTime startTime,
    required DateTime endTime,
    int? limit,
  }) async {
    final healthConnectData = await getHealthConnectData(
      types: types,
      startTime: startTime,
      endTime: endTime,
    );

    final manualData = await getManualHealthData(
      types: types,
      startTime: startTime,
      endTime: endTime,
    );

    // Combine and sort by timestamp
    final combinedData = [...healthConnectData, ...manualData];
    combinedData.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (limit != null && combinedData.length > limit) {
      return combinedData.take(limit).toList();
    }

    return combinedData;
  }

  /// Stream Health Connect data changes
  Stream<List<HealthDataPoint>> streamHealthConnectData({
    required List<String> types,
    int? limit,
  }) {
    Query query = _healthConnectDataCollection
        .where('type', whereIn: types)
        .orderBy('timestamp', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => HealthDataPoint.fromFirestore(doc)).toList());
  }

  /// Stream manual health data changes
  Stream<List<HealthDataPoint>> streamManualHealthData({
    required List<String> types,
    int? limit,
  }) {
    Query query = _manualHealthDataCollection
        .where('type', whereIn: types)
        .orderBy('timestamp', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => HealthDataPoint.fromFirestore(doc)).toList());
  }

  /// Delete all Health Connect data for the current user
  Future<void> deleteAllHealthConnectData() async {
    final batch = _firestore.batch();
    final snapshot = await _healthConnectDataCollection.get();
    
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }

  /// Save data source preferences
  Future<void> saveDataSourcePreferences(Map<String, String> preferences) async {
    await _dataSourcePreferencesDoc.set({
      ...preferences,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Get data source preferences
  Future<Map<String, String>> getDataSourcePreferences() async {
    final doc = await _dataSourcePreferencesDoc.get();
    if (!doc.exists) {
      // Return default preferences
      return {
        'weight': 'healthConnect',
        'bodyFatPercentage': 'healthConnect',
        'steps': 'healthConnect',
        'heartRate': 'healthConnect',
        'workout': 'healthConnect',
        'sleep': 'healthConnect',
        'calories': 'healthConnect',
      };
    }
    
    final data = doc.data() as Map<String, dynamic>;
    return Map<String, String>.from(data)..remove('updatedAt');
  }

  /// Stream data source preferences changes
  Stream<Map<String, String>> streamDataSourcePreferences() {
    return _dataSourcePreferencesDoc.snapshots().map((doc) {
      if (!doc.exists) {
        return {
          'weight': 'healthConnect',
          'bodyFatPercentage': 'healthConnect',
          'steps': 'healthConnect',
          'heartRate': 'healthConnect',
          'workout': 'healthConnect',
          'sleep': 'healthConnect',
          'calories': 'healthConnect',
        };
      }
      
      final data = doc.data() as Map<String, dynamic>;
      return Map<String, String>.from(data)..remove('updatedAt');
    });
  }

  /// Update Health Connect sync status
  Future<void> updateHealthConnectSyncStatus({
    DateTime? lastSyncTimestamp,
    Map<String, bool>? permissions,
    bool? isAvailable,
    String? lastError,
    bool? syncInProgress,
    int? totalRecordsSynced,
    DateTime? lastSuccessfulSync,
  }) async {
    final updateData = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (lastSyncTimestamp != null) {
      updateData['lastSyncTimestamp'] = Timestamp.fromDate(lastSyncTimestamp);
    }
    if (permissions != null) {
      updateData['permissions'] = permissions;
    }
    if (isAvailable != null) {
      updateData['isAvailable'] = isAvailable;
    }
    if (lastError != null) {
      updateData['lastError'] = lastError;
    }
    if (syncInProgress != null) {
      updateData['syncInProgress'] = syncInProgress;
    }
    if (totalRecordsSynced != null) {
      updateData['totalRecordsSynced'] = totalRecordsSynced;
    }
    if (lastSuccessfulSync != null) {
      updateData['lastSuccessfulSync'] = Timestamp.fromDate(lastSuccessfulSync);
    }

    await _healthConnectSyncStatusDoc.set(updateData, SetOptions(merge: true));
  }

  /// Get Health Connect sync status
  Future<Map<String, dynamic>?> getHealthConnectSyncStatus() async {
    final doc = await _healthConnectSyncStatusDoc.get();
    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }

  /// Stream Health Connect sync status changes
  Stream<Map<String, dynamic>?> streamHealthConnectSyncStatus() {
    return _healthConnectSyncStatusDoc.snapshots().map((doc) =>
        doc.exists ? doc.data() as Map<String, dynamic> : null);
  }

  /// Check if Health Connect data exists for deduplication
  Future<bool> healthConnectDataExists(String healthConnectId) async {
    final query = await _healthConnectDataCollection
        .where('healthConnectId', isEqualTo: healthConnectId)
        .limit(1)
        .get();
    
    return query.docs.isNotEmpty;
  }

  /// Get the latest data point for a specific type from Health Connect
  Future<HealthDataPoint?> getLatestHealthConnectData(String type) async {
    final query = await _healthConnectDataCollection
        .where('type', isEqualTo: type)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return HealthDataPoint.fromFirestore(query.docs.first);
  }

  /// Get the latest data point for a specific type from manual data
  Future<HealthDataPoint?> getLatestManualData(String type) async {
    final query = await _manualHealthDataCollection
        .where('type', isEqualTo: type)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return HealthDataPoint.fromFirestore(query.docs.first);
  }

  /// Initialize user collections with default documents
  Future<void> initializeUserCollections() async {
    // Initialize data source preferences
    await saveDataSourcePreferences({
      'weight': 'healthConnect',
      'bodyFatPercentage': 'healthConnect',
      'steps': 'healthConnect',
      'heartRate': 'healthConnect',
      'workout': 'healthConnect',
      'sleep': 'healthConnect',
      'calories': 'healthConnect',
    });

    // Initialize sync status
    await updateHealthConnectSyncStatus(
      isAvailable: false,
      syncInProgress: false,
      totalRecordsSynced: 0,
      permissions: {
        'weight': false,
        'bodyFatPercentage': false,
        'steps': false,
        'heartRate': false,
        'workout': false,
        'sleep': false,
        'calories': false,
      },
    );
  }
}