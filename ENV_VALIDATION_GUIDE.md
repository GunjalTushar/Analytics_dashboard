# 🔒 Environment Validation Guide

## Overview

The Analytics Dashboard now includes comprehensive environment validation that runs at startup to ensure all required configuration is present and valid.

---

## ✨ Features

- ✅ **Startup Validation** - Validates environment before app initialization
- ✅ **Structured Error Logging** - Clear `[ENV_CONFIG_ERROR]` prefixed logs
- ✅ **Missing Key Detection** - Lists all missing required variables
- ✅ **Format Validation** - Validates credential formats (email, private key, etc.)
- ✅ **UI Error State** - Shows configuration error screen if validation fails
- ✅ **Prevents Crashes** - Gracefully handles missing configuration
- ✅ **Configuration Summary** - Logs complete configuration status

---

## 📋 Validated Variables

### Required Variables
These MUST be present for the app to function:

```bash
GOOGLE_SERVICE_ACCOUNT_EMAIL  # Service account email
GOOGLE_PRIVATE_KEY            # Private key in PEM format
GA4_PROPERTY_ID               # Google Analytics 4 property ID
```

### Optional Variables
These are checked but not required:

```bash
SERVER_URL          # Backend API URL (if using backend)
SUPABASE_URL        # Supabase project URL (if using Supabase)
SUPABASE_ANON_KEY   # Supabase anonymous key (if using Supabase)
```

---

## 🚀 How It Works

### 1. Startup Validation

When the app starts, the validator runs automatically:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env file
  await dotenv.load(fileName: ".env");
  
  // Validate environment
  final validationResult = EnvValidator.validate();
  
  if (!validationResult.isValid) {
    // Show error screen
    runApp(AnalyticsDashboardApp(
      configError: validationResult.errorMessage,
    ));
    return;
  }
  
  // Continue with normal app
  runApp(const AnalyticsDashboardApp());
}
```

### 2. Validation Checks

The validator performs these checks:

1. **Presence Check** - Verifies all required keys exist
2. **Format Validation** - Validates credential formats:
   - Service account email must contain `@` and `.iam.gserviceaccount.com`
   - Private key must be in PEM format (contains BEGIN/END markers)
   - GA4 Property ID must be a valid number
3. **Optional Keys** - Checks and logs optional variable status

### 3. Error Handling

If validation fails:

1. **Logs Error** - Prints detailed error with `[ENV_CONFIG_ERROR]` prefix
2. **Shows UI** - Displays configuration error screen
3. **Lists Missing Keys** - Shows exactly what's missing
4. **Prevents Crash** - App doesn't crash, shows helpful error instead

---

## 📊 Console Output

### Successful Validation

```
[ENV_CONFIG] ✓ GOOGLE_SERVICE_ACCOUNT_EMAIL configured
[ENV_CONFIG] ✓ GOOGLE_PRIVATE_KEY configured
[ENV_CONFIG] ✓ GA4_PROPERTY_ID configured
[ENV_CONFIG] ✓ Environment validation passed
[ENV_CONFIG] ✓ All required environment variables configured

Environment Configuration Summary:
Required Variables:
  ✓ GOOGLE_SERVICE_ACCOUNT_EMAIL
  ✓ GOOGLE_PRIVATE_KEY
  ✓ GA4_PROPERTY_ID
Optional Variables:
  ○ SERVER_URL
  ✓ SUPABASE_URL
  ✓ SUPABASE_ANON_KEY
```

### Failed Validation

```
[ENV_CONFIG_ERROR] Missing required key: GOOGLE_PRIVATE_KEY
[ENV_CONFIG_ERROR] Environment validation failed
[ENV_CONFIG_ERROR] Missing keys: GOOGLE_PRIVATE_KEY

[ENV_CONFIG_ERROR] Environment configuration is incomplete

Missing required variables:
  ❌ GOOGLE_PRIVATE_KEY

Configuration errors:
  ⚠️  GOOGLE_SERVICE_ACCOUNT_EMAIL format invalid
```

---

## 🔧 Usage

### Programmatic Validation

```dart
import 'package:your_app/core/environment/env_validator.dart';

// Validate and get result
final result = EnvValidator.validate();

if (result.isValid) {
  print('Configuration is valid!');
} else {
  print('Missing keys: ${result.missingKeys}');
  print('Errors: ${result.errors}');
}

// Get configuration summary
print(EnvValidator.getConfigSummary());

// Check optional keys
final optionalKeys = EnvValidator.checkOptionalKeys();
print('SERVER_URL configured: ${optionalKeys['SERVER_URL']}');

// Validate or throw exception
try {
  EnvValidator.validateOrThrow();
} catch (e) {
  print('Validation failed: $e');
}
```

### UI Configuration Widget

Show configuration status in your UI:

```dart
import 'package:your_app/core/environment/env_config_widget.dart';

// In your widget tree
Column(
  children: [
    EnvConfigWidget(), // Shows expandable configuration status
    // ... rest of your UI
  ],
)
```

---

## 🐛 Troubleshooting

### Issue: "GOOGLE_SERVICE_ACCOUNT_EMAIL not found"

**Solution**: Add to `.env` file:
```bash
GOOGLE_SERVICE_ACCOUNT_EMAIL=your-service-account@project.iam.gserviceaccount.com
```

### Issue: "GOOGLE_PRIVATE_KEY format invalid"

**Solution**: Ensure private key is in PEM format with `\n` for line breaks:
```bash
GOOGLE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0B...\n-----END PRIVATE KEY-----
```

### Issue: "GA4_PROPERTY_ID must be a number"

**Solution**: Use only the numeric property ID:
```bash
GA4_PROPERTY_ID=516686879
```

### Issue: Configuration error screen shows on startup

**Solution**: 
1. Check console logs for specific missing keys
2. Add missing variables to `.env` file
3. Restart the app

---

## 📝 Best Practices

### 1. Always Validate Early

Run validation before any initialization:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  // Validate BEFORE Supabase.initialize()
  final result = EnvValidator.validate();
  if (!result.isValid) {
    // Handle error
    return;
  }
  
  // Now safe to initialize services
  await Supabase.initialize(...);
}
```

### 2. Log Configuration on Startup

Always log configuration summary in development:

```dart
if (kDebugMode) {
  print(EnvValidator.getConfigSummary());
}
```

### 3. Handle Missing Optional Keys

Check optional keys before using them:

```dart
final optionalKeys = EnvValidator.checkOptionalKeys();

if (optionalKeys['SERVER_URL'] == true) {
  // Use backend API
} else {
  // Use alternative approach
}
```

### 4. Test Error States

Test your app with missing configuration:

```bash
# Temporarily rename .env
mv .env .env.backup

# Run app - should show error screen
flutter run

# Restore .env
mv .env.backup .env
```

---

## 🔒 Security Notes

- ✅ Validator only checks presence and format
- ✅ Never logs actual credential values
- ✅ Error messages don't expose sensitive data
- ✅ Configuration summary shows status only (✓/❌/○)

---

## 📚 API Reference

### EnvValidator

```dart
class EnvValidator {
  // Validate environment and return result
  static EnvValidationResult validate();
  
  // Check optional keys status
  static Map<String, bool> checkOptionalKeys();
  
  // Get configuration summary string
  static String getConfigSummary();
  
  // Validate or throw exception
  static void validateOrThrow();
}
```

### EnvValidationResult

```dart
class EnvValidationResult {
  final bool isValid;              // Overall validation status
  final List<String> missingKeys;  // List of missing required keys
  final List<String> errors;       // List of validation errors
  
  String get errorMessage;         // Formatted error message
}
```

### EnvironmentConfigurationException

```dart
class EnvironmentConfigurationException implements Exception {
  final EnvValidationResult validationResult;
  
  @override
  String toString(); // Returns formatted error message
}
```

---

## ✅ Checklist

Before deploying:

- [ ] All required variables in `.env`
- [ ] Run app and check console for validation logs
- [ ] Verify no `[ENV_CONFIG_ERROR]` messages
- [ ] Test with missing variables (should show error screen)
- [ ] Verify `.env` is in `.gitignore`
- [ ] Document required variables for your team

---

**Last Updated**: February 9, 2026  
**Version**: 1.0.0  
**Status**: Production Ready ✅
