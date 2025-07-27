# Firestore Configuration Guide

## Overview

This guide provides step-by-step instructions for configuring Cloud Firestore for the LiveStyle Health Connect integration. Follow these steps to set up the database, security rules, and indexes for production deployment.

## Prerequisites

- Firebase project created (nomadlander-livestyle)
- Firebase CLI installed and authenticated
- Flutter project configured with Firebase

## Step 1: Enable Firestore

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `nomadlander-livestyle`
3. Navigate to **Firestore Database**
4. Click **Create database**
5. Choose **Start in production mode** (we'll deploy custom rules)
6. Select your preferred location (recommend: `us-central1` for optimal performance)

## Step 2: Deploy Security Rules

The security rules are defined in `firestore.rules`. Deploy them using Firebase CLI:

```bash
# Navigate to the Flutter project directory
cd flutterlive

# Deploy Firestore rules
firebase deploy --only firestore:rules
```

### Security Rules Overview

The rules ensure:

- **Authentication Required**: All operations require user authentication
- **Data Ownership**: Users can only access their own health data
- **Data Validation**: Strict validation of document structure and data types
- **Source Separation**: Health Connect and manual data are stored separately
- **Timestamp Validation**: Prevents backdating and future dating beyond reasonable limits

### Key Security Features

1. **User Isolation**: Each user's data is completely isolated using their UID
2. **Data Type Validation**: Ensures only valid health data types are stored
3. **Value Range Validation**: Prevents unrealistic health metric values
4. **Timestamp Integrity**: Validates timestamps are reasonable and not manipulated
5. **Schema Enforcement**: Ensures all required fields are present and correctly typed

## Step 3: Deploy Database Indexes

The indexes are defined in `firestore.indexes.json`. Deploy them using:

```bash
# Deploy Firestore indexes
firebase deploy --only firestore:indexes
```

### Index Overview

The following indexes are created for optimal query performance:

#### Composite Indexes

- `healthConnectData`: `(type, timestamp DESC)` - For type-specific time-ordered queries
- `healthConnectData`: `(type, timestamp ASC)` - For ascending time queries
- `manualHealthData`: `(type, timestamp DESC)` - For manual data queries
- `manualHealthData`: `(type, timestamp ASC)` - For ascending manual data queries
- `workoutSessions`: `(source, startTime DESC)` - For workout queries by source
- `workoutSessions`: `(workoutType, startTime DESC)` - For workout type queries

#### Single Field Indexes

- `timestamp`: Both ascending and descending for time-based queries
- `type`: For filtering by health data type
- `healthConnectId`: For deduplication queries

## Step 4: Initialize Database Structure

After deploying rules and indexes, initialize the database structure:

### Option A: Automatic Initialization (Recommended)

The app will automatically initialize user collections when a user first authenticates. The `FirestoreService.initializeUserCollections()` method creates:

- Data source preferences with default values
- Health Connect sync status document
- Required collection structure

### Option B: Manual Initialization

If you need to manually initialize collections, use the Firebase Console:

1. Go to **Firestore Database** in Firebase Console
2. Create the following document structure for a test user:

```
/users/{testUserId}/preferences/dataSourcePreferences
{
  "weight": "healthConnect",
  "bodyFatPercentage": "healthConnect",
  "steps": "healthConnect",
  "heartRate": "healthConnect",
  "workout": "healthConnect",
  "sleep": "healthConnect",
  "calories": "healthConnect",
  "updatedAt": [current timestamp]
}

/users/{testUserId}/syncStatus/healthConnect
{
  "isAvailable": false,
  "syncInProgress": false,
  "totalRecordsSynced": 0,
  "permissions": {
    "weight": false,
    "bodyFatPercentage": false,
    "steps": false,
    "heartRate": false,
    "workout": false,
    "sleep": false,
    "calories": false
  },
  "updatedAt": [current timestamp]
}
```

## Step 5: Configure Firestore Settings

The app automatically configures Firestore settings in `main.dart`:

```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

### Settings Explanation

- **persistenceEnabled**: Enables offline data persistence
- **cacheSizeBytes**: Sets unlimited cache size for better performance

## Step 6: Test Configuration

### Using Firebase Emulator (Development)

For local development and testing:

```bash
# Install Firebase emulators
firebase init emulators

# Select Firestore emulator
# Configure port (default: 8080)

# Start emulator
firebase emulators:start --only firestore

# In your Flutter app, connect to emulator (add to main.dart for development):
if (kDebugMode) {
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
}
```

### Production Testing

1. Deploy rules and indexes to production
2. Run the Flutter app with a test user
3. Verify collections are created automatically
4. Test data read/write operations
5. Monitor Firebase Console for any rule violations

## Step 7: Monitoring and Analytics

### Enable Firestore Monitoring

1. Go to **Firestore Database** > **Usage** tab
2. Monitor:
   - Read/Write operations
   - Storage usage
   - Index usage
   - Query performance

### Set Up Alerts

1. Go to **Monitoring** in Firebase Console
2. Create alerts for:
   - High read/write usage
   - Security rule violations
   - Query performance issues
   - Storage quota approaching limits

## Step 8: Backup Configuration

### Automatic Backups

1. Go to **Firestore Database** > **Backups**
2. Enable automatic backups
3. Configure retention period (recommend: 30 days)
4. Set backup schedule (recommend: daily)

### Manual Backup

```bash
# Export entire database
gcloud firestore export gs://[BUCKET_NAME]/[EXPORT_FOLDER]

# Export specific collections
gcloud firestore export gs://[BUCKET_NAME]/[EXPORT_FOLDER] \
  --collection-ids=users
```

## Step 9: Performance Optimization

### Query Optimization

1. **Use Indexes**: Ensure all queries use appropriate indexes
2. **Limit Results**: Always use `.limit()` for large datasets
3. **Pagination**: Implement cursor-based pagination for large result sets
4. **Batch Operations**: Use batch writes for multiple document updates

### Example Optimized Queries

```dart
// Good: Uses composite index (type, timestamp)
final query = collection
  .where('type', isEqualTo: 'weight')
  .orderBy('timestamp', descending: true)
  .limit(50);

// Good: Batch write for multiple documents
final batch = FirebaseFirestore.instance.batch();
for (final dataPoint in dataPoints) {
  batch.set(docRef, dataPoint.toFirestore());
}
await batch.commit();
```

### Avoid Anti-Patterns

```dart
// Bad: No limit on query
final query = collection.where('type', isEqualTo: 'weight');

// Bad: Individual writes in loop
for (final dataPoint in dataPoints) {
  await docRef.set(dataPoint.toFirestore()); // Don't do this
}
```

## Step 10: Security Best Practices

### Authentication

- Always verify user authentication before database operations
- Use Firebase Auth tokens for secure access
- Implement proper session management

### Data Validation

- Validate data on client side before writing
- Rely on security rules for server-side validation
- Sanitize user inputs

### Access Control

- Follow principle of least privilege
- Regularly audit security rules
- Monitor for unauthorized access attempts

## Troubleshooting

### Common Issues

1. **Permission Denied Errors**

   - Check security rules are deployed
   - Verify user authentication
   - Ensure user owns the data being accessed

2. **Index Errors**

   - Deploy missing indexes using Firebase CLI
   - Check Firebase Console for index creation status
   - Wait for index creation to complete (can take several minutes)

3. **Performance Issues**

   - Review query patterns and add appropriate indexes
   - Implement pagination for large datasets
   - Monitor Firestore usage in Firebase Console

4. **Offline Issues**
   - Verify persistence is enabled
   - Check network connectivity
   - Review offline data handling in app

### Debug Commands

```bash
# Check current Firestore rules
firebase firestore:rules:get

# List current indexes
firebase firestore:indexes

# View emulator logs
firebase emulators:start --debug

# Test security rules
firebase emulators:exec --only firestore "npm test"
```

## Production Checklist

Before deploying to production:

- [ ] Security rules deployed and tested
- [ ] All required indexes created
- [ ] Backup configuration enabled
- [ ] Monitoring and alerts configured
- [ ] Performance testing completed
- [ ] Security audit performed
- [ ] Documentation updated
- [ ] Team training completed

## Support and Resources

- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Security Rules Reference](https://firebase.google.com/docs/firestore/security/rules-conditions)
- [Query Optimization Guide](https://firebase.google.com/docs/firestore/query-data/queries)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)

For project-specific issues, refer to the project documentation or contact the development team.
