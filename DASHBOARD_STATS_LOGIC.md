# Dashboard Statistics - Data Logic

## Overview

This document explains the data sources and calculations for the dashboard statistics cards, useful for implementing the mobile app version.

## Total Credits Card

### Main Display Value

- **Data Source**: `credit_balances` table
- **Calculation**: Sum of all user credit balances converted to credits
  ```
  Total Credits = SUM(balanceDollars × 100)
  ```
- **Example**: If user has $10.50 balance → 1,050 credits

### Description Breakdown (External/Internal)

- **Data Source**: `usage_logs` table
- **API Endpoint**: `POST /api/usage-logs-aggregated`
- **Calculation**:
  ```
  External Credits = grandTotalCost × 100 (where userTypeFilter = 'external')
  Internal Credits = grandTotalCost × 100 (where userTypeFilter = 'internal')
  ```
- **How it works**:
  1. Makes two parallel API calls to `/api/usage-logs-aggregated`
  2. First call filters for `userTypeFilter: 'external'` → gets total external usage cost
  3. Second call filters for `userTypeFilter: 'internal'` → gets total internal usage cost
  4. Backend aggregates all usage logs for that user type and returns `grandTotalCost` (sum of all costs in dollars)
  5. Frontend converts dollars to credits by multiplying by 100
  6. Displays both values in the card description with 3 decimal places
- **Example**:
  - If external users consumed $12.345 worth of credits → displays as "12.345" credits
  - If internal users consumed $5.678 worth of credits → displays as "5.678" credits

### User Type Classification

Users are classified as internal or external based on their email:

- **Function**: `getUserType(email)` from `/src/lib/utils.ts`
- **Returns**: `'internal'` or `'external'`
- Likely checks email domain (e.g., company emails = internal, others = external)

### Real-time Updates

- Subscribes to `usage_logs` table changes via Supabase Realtime
- Fallback: Refreshes every 30 seconds
- Channel: `dashboard_stats_usage_updates`

## Other Dashboard Stats

### Total Users

- **Data Source**: `user_profiles` table (via `useGlobal()` context)
- **Filter**: Only external users counted
- **Calculation**: `COUNT(user_profiles WHERE getUserType(email) = 'external')`

### New Users Today

- **Data Source**: `user_profiles` table
- **Filter**: External users created today
- **Calculation**: `COUNT(user_profiles WHERE createdAt >= today AND userType = 'external')`

### Paid Users

- **Data Sources**:
  - `credit_purchases` table (via `useCreditPurchases()`)
  - `subscriptions` table (via `useSubscriptions()`)
- **Calculation**: Unique count of external users who appear in either table
  ```
  Paid Users = DISTINCT COUNT(userId) WHERE userId IN (credit_purchases OR subscriptions)
  AND getUserType(email) = 'external'
  ```

### Helium Revenue (Commented Out)

If you need to implement this:

- **Credit Purchase Revenue**: `SUM(amountDollars WHERE status = 'completed')`
- **Initial Subscription Revenue**: Sum of subscription amounts where `createdAt ≈ updatedAt`
- **Renewal Revenue**: Sum of subscription amounts where `updatedAt > createdAt + 1 second`
- **Total Revenue**: Sum of all three above

## API Endpoints to Implement

### 1. Get Aggregated Usage Logs

```
POST /api/usage-logs-aggregated
Body: {
  page: 1,
  limit: 1,
  searchQuery: '',
  activityFilter: 'all',
  userTypeFilter: 'external' | 'internal'
}
Response: {
  success: boolean,
  grandTotalCost: number  // in dollars
}
```

### 2. Real-time Hooks

- **Credit Balances**: Subscribe to `credit_balances` table
- **User Profiles**: Subscribe to `user_profiles` table
- **Credit Purchases**: Subscribe to `credit_purchases` table
- **Subscriptions**: Subscribe to `subscriptions` table
- **Usage Logs**: Subscribe to `usage_logs` table

## Data Formatting

### Credits Display

```typescript
// Format with 3 decimal places
credits.toLocaleString("en-US", {
  minimumFractionDigits: 3,
  maximumFractionDigits: 3,
});
// Example: 1,234.567
```

### Currency Display

```typescript
// Use formatCurrency() utility
formatCurrency(amount);
// Example: $1,234.56
```

## Key Tables Schema Reference

### credit_balances

- `userId`: string
- `balanceDollars`: number

### usage_logs

- `userId`: string
- `cost`: number (in dollars)
- Other activity tracking fields

### user_profiles

- `userId`: string
- `email`: string
- `createdAt`: timestamp
- `updatedAt`: timestamp

### credit_purchases

- `userId`: string
- `amountDollars`: number
- `status`: string ('completed', etc.)

### subscriptions

- `userId`: string
- `planName`: string
- `planType`: string ('seed', 'edge', etc.)
- `status`: string ('active', 'trialing', etc.)
- `createdAt`: timestamp
- `updatedAt`: timestamp

## Notes for Mobile Implementation

1. **Real-time Updates**: Use Supabase Realtime client for live data
2. **Polling Fallback**: Implement 30-second refresh as backup
3. **User Type Logic**: Ensure `getUserType()` function is consistent across platforms
4. **Error Handling**: Handle API failures gracefully, show cached data if available
5. **Performance**: Consider caching aggregated data to reduce API calls
