# Cloud Firestore Setup Documentation

## Overview

This document outlines the Cloud Firestore configuration for the LiveStyle health and fitness application, specifically for the Health Connect integration feature. The setup includes database structure, security rules, indexes, and collection schemas for managing health data from multiple sources.

## Database Structure

### Collections Overview

The Firestore database is organized with the following top-level structure:

```
/users/{userId}/
├── healthConnectData/{dataId}     # Health Connect synced data
├── manualHealthData/{dataId}      # Manually entered health data
├── preferences/
│   └── dataSourcePreferences      # User preferences for data sources
└── syncStatus/
    └── healthConnect              # Health Connect sync status
```

### Collection Schemas

#### 1. Health Connect Data Collection
**Path**: `/users/{userId}/healthConnectData/{dataId}`

```typescript
interface HealthConnectDataDocument {
  id: string;                    // Unique document ID
  type: string;                  // 'weight', 'bodyFatPercentage', 'steps', 'heartRate', 'workout', etc.
  value: number;                 // Numeric value of the measurement
  unit?: string;                 // Unit of measurement (kg, lbs, bpm, etc.)
  timestamp: Timestamp;          // When the measurement was taken
  endTimestamp?: Timestamp;      // For duration-based data (workouts, sleep)
  metadata?: {                   // Additional data specific to measurement type
    [key: string]: any;
  };
  healthConnectId?: string;      // Original Health Connect data ID for deduplication
  createdAt: Timestamp;          // When record was created in Firestore
  updatedAt: Timestamp;          // When record was last updated
}
```

**Example Documents**:
```json
// Weight measurement
{
  "id": "hc_weight_20250126_001",
  "type": "weight",
  "value": 75.5,
  "unit": "kg",
  "timestamp": "2025-01-26T08:30:00Z",
  "metadata": {
    "source": "health_connect",
    "device": "Samsung Health"
  },
  "healthConnectId": "hc_12345",
  "createdAt": "2025-01-26T08:35:00Z",
  "updatedAt": "2025-01-26T08:35:00Z"
}

// Workout session
{
  "id": "hc_workout_20250126_001",
  "type": "workout",
  "value": 450,
  "unit": "calories",
  "timestamp": "2025-01-26T07:00:00Z",
  "endTimestamp": "2025-01-26T08:00:00Z",
  "metadata": {
    "workoutType": "running",
    "duration": 3600,
    "distance": 5.2,
    "distanceUnit": "km",
    "averageHeartRate": 145,
    "maxHeartRate": 165
  },
  "healthConnectId": "hc_workout_67890",
  "createdAt": "2025-01-26T08:05:00Z",
  "updatedAt": "2025-01-26T08:05:00Z"
}
```

#### 2. Manual Health Data Collection
**Path**: `/users/{userId}/manualHealthData/{dataId}`

```typescript
interface ManualHealthDataDocument {
  id: string;                    // Unique document ID
  type: string;                  // Same types as Health Connect data
  value: number;                 // Numeric value of the measurement
  unit?: string;                 // Unit of measurement
  timestamp: Timestamp;          // When the measurement was taken
  endTimestamp?: Timestamp;      // For duration-based data
  metadata?: {                   // Additional manually entered data
    [key: string]: any;
  };
  createdAt: Timestamp;          // When record was created
  updatedAt: Timestamp;          // When record was last updated
}
```

#### 3. Data Source Preferences Document
**Path**: `/users/{userId}/preferences/dataSourcePreferences`

```typescript
interface DataSourcePreferencesDocument {
  weight: 'healthConnect' | 'manual';
  bodyFatPercentage: 'healthConnect' | 'manual';
  steps: 'healthConnect' | 'manual';
  heartRate: 'healthConnect' | 'manual';
  workout: 'healthConnect' | 'manual';
  sleep: 'healthConnect' | 'manual';
  calories: 'healthConnect' | 'manual';
  updatedAt: Timestamp;
}
```

#### 4. Health Connect Sync Status Document
**Path**: `/users/{userId}/syncStatus/healthConnect`

```typescript
interface HealthConnectSyncStatusDocument {
  lastSyncTimestamp: Timestamp;
  permissions: {
    weight: boolean;
    bodyFatPercentage: boolean;
    steps: boolean;
    heartRate: boolean;
    workout: boolean;
    sleep: boolean;
    calories: boolean;
  };
  isAvailable: boolean;
  lastError?: string;
  syncInProgress: boolean;
  totalRecordsSynced: number;
  lastSuccessfulSync?: Timestamp;
  updatedAt: Timestamp;
}
```

## Firestore Indexes

### Required Composite Indexes

The following composite indexes are required for efficient querying:

#### 1. Health Connect Data Queries
```
Collection: users/{userId}/healthConnectData
Fields: type (Ascending), timestamp (Descending)
```

#### 2. Manual Health Data Queries
```
Collection: users/{userId}/manualHealthData
Fields: type (Ascending), timestamp (Descending)
```

#### 3. Time Range Queries
```
Collection: users/{userId}/healthConnectData
Fields: type (Ascending), timestamp (Ascending), timestamp (Descending)
```

```
Collection: users/{userId}/manualHealthData
Fields: type (Ascending), timestamp (Ascending), timestamp (Descending)
```

### Single Field Indexes

The following single field indexes are automatically created but should be verified:

- `healthConnectId` (Ascending) - for deduplication
- `timestamp` (Ascending/Descending) - for time-based queries
- `type` (Ascending) - for filtering by data type
- `createdAt` (Ascending) - for creation time queries

## Security Rules

### Authentication Requirements

All health data access requires user authentication. The security rules ensure:

1. Users can only access their own health data
2. Authenticated users can read/write their own data
3. Data validation is enforced at the database level
4. Sensitive health information is protected

### Rule Implementation

The security rules are implemented to:
- Validate user authentication
- Ensure data ownership
- Validate document structure
- Prevent unauthorized access
- Enforce data type constraints

## Data Validation

### Client-Side Validation

Before writing to Firestore, the application validates:

1. **Data Types**: Ensure numeric values are valid numbers
2. **Required Fields**: Verify all required fields are present
3. **Timestamp Validation**: Ensure timestamps are valid and not in the future
4. **Unit Consistency**: Validate units match the data type
5. **Value Ranges**: Check that values are within reasonable ranges

### Server-Side Validation

Firestore security rules provide additional validation:

1. **Schema Enforcement**: Ensure documents match expected schema
2. **Data Type Validation**: Verify field types are correct
3. **User Ownership**: Confirm user can only modify their own data
4. **Timestamp Integrity**: Prevent backdating or future dating beyond reasonable limits

## Performance Considerations

### Query Optimization

1. **Limit Results**: Use `.limit()` for paginated queries
2. **Index Usage**: Ensure all queries use appropriate indexes
3. **Batch Operations**: Use batch writes for multiple document updates
4. **Offline Support**: Leverage Firestore's offline capabilities

### Data Management

1. **Document Size**: Keep documents under 1MB limit
2. **Collection Scaling**: Use subcollections for large datasets
3. **Cleanup**: Implement data retention policies for old records
4. **Caching**: Use appropriate caching strategies for frequently accessed data

## Migration Strategy

### Initial Setup

1. Create collections with proper security rules
2. Set up required indexes
3. Initialize user preference documents
4. Configure sync status tracking

### Data Migration

For existing users with manual data:

1. Preserve existing manual health data
2. Create separate Health Connect data collections
3. Update UI to display both data sources
4. Allow users to choose preferred data sources

## Monitoring and Analytics

### Sync Monitoring

Track the following metrics:

1. **Sync Success Rate**: Percentage of successful syncs
2. **Sync Duration**: Time taken for sync operations
3. **Error Rates**: Frequency and types of sync errors
4. **Data Volume**: Amount of data synced per user

### Performance Metrics

Monitor:

1. **Query Performance**: Response times for data queries
2. **Write Performance**: Time for data writes
3. **Index Usage**: Efficiency of database indexes
4. **Storage Usage**: Database storage consumption

## Backup and Recovery

### Data Backup

1. **Automated Backups**: Configure Firebase automatic backups
2. **Export Capabilities**: Implement data export functionality
3. **Point-in-Time Recovery**: Use Firebase's backup features
4. **Cross-Region Replication**: Consider multi-region setup for critical data

### Recovery Procedures

1. **Data Corruption**: Steps to recover from corrupted data
2. **Accidental Deletion**: Recovery from user or system errors
3. **Sync Issues**: Procedures to resolve sync conflicts
4. **System Failures**: Recovery from system-wide issues

## Development and Testing

### Local Development

1. **Firestore Emulator**: Use local emulator for development
2. **Test Data**: Create realistic test datasets
3. **Security Rule Testing**: Test rules with emulator
4. **Performance Testing**: Test with large datasets

### Production Deployment

1. **Gradual Rollout**: Deploy to subset of users first
2. **Monitoring**: Monitor performance and errors
3. **Rollback Plan**: Prepare rollback procedures
4. **Documentation**: Maintain deployment documentation

This documentation provides a comprehensive guide for setting up and maintaining the Cloud Firestore database for Health Connect integration in the LiveStyle application.