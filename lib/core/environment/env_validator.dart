/// 🔒 Environment Validator
/// 
/// Validates required environment variables at startup
/// Prevents app crashes due to missing configuration

import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvValidationResult {
  final bool isValid;
  final List<String> missingKeys;
  final List<String> errors;

  EnvValidationResult({
    required this.isValid,
    required this.missingKeys,
    required this.errors,
  });

  String get errorMessage {
    if (isValid) return '';
    
    final buffer = StringBuffer();
    buffer.writeln('[ENV_CONFIG_ERROR] Environment configuration is incomplete');
    buffer.writeln('');
    
    if (missingKeys.isNotEmpty) {
      buffer.writeln('Missing required variables:');
      for (final key in missingKeys) {
        buffer.writeln('  ❌ $key');
      }
    }
    
    if (errors.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Configuration errors:');
      for (final error in errors) {
        buffer.writeln('  ⚠️  $error');
      }
    }
    
    return buffer.toString();
  }
}

class EnvValidator {
  // Required environment variables for Analytics Dashboard
  static const List<String> _requiredKeys = [
    'GOOGLE_SERVICE_ACCOUNT_EMAIL',
    'GOOGLE_PRIVATE_KEY',
    'GA4_PROPERTY_ID',
  ];

  // Optional but recommended variables
  static const List<String> _optionalKeys = [
    'SUPABASE_URL',
    'SUPABASE_ANON_KEY',
  ];

  /// Validate environment configuration
  /// Returns validation result with details about missing keys
  static EnvValidationResult validate() {
    final missingKeys = <String>[];
    final errors = <String>[];

    // Check required keys
    for (final key in _requiredKeys) {
      final value = dotenv.env[key];
      if (value == null || value.isEmpty) {
        missingKeys.add(key);
        _logError('Missing required key: $key');
      } else {
        _logInfo('✓ $key configured');
      }
    }

    // Validate specific formats
    _validateGoogleCredentials(errors);
    _validateGA4PropertyId(errors);

    final isValid = missingKeys.isEmpty && errors.isEmpty;

    if (!isValid) {
      _logError('Environment validation failed');
      _logError('Missing keys: ${missingKeys.join(", ")}');
    } else {
      _logInfo('✓ Environment validation passed');
    }

    return EnvValidationResult(
      isValid: isValid,
      missingKeys: missingKeys,
      errors: errors,
    );
  }

  /// Validate Google service account credentials
  static void _validateGoogleCredentials(List<String> errors) {
    final email = dotenv.env['GOOGLE_SERVICE_ACCOUNT_EMAIL'];
    if (email != null && email.isNotEmpty) {
      if (!email.contains('@') || !email.contains('.iam.gserviceaccount.com')) {
        errors.add('GOOGLE_SERVICE_ACCOUNT_EMAIL format invalid');
        _logError('Invalid service account email format');
      }
    }

    final privateKey = dotenv.env['GOOGLE_PRIVATE_KEY'];
    if (privateKey != null && privateKey.isNotEmpty) {
      if (!privateKey.contains('BEGIN PRIVATE KEY') || 
          !privateKey.contains('END PRIVATE KEY')) {
        errors.add('GOOGLE_PRIVATE_KEY format invalid (must be PEM format)');
        _logError('Invalid private key format');
      }
    }
  }

  /// Validate GA4 Property ID
  static void _validateGA4PropertyId(List<String> errors) {
    final propertyId = dotenv.env['GA4_PROPERTY_ID'];
    if (propertyId != null && propertyId.isNotEmpty) {
      if (int.tryParse(propertyId) == null) {
        errors.add('GA4_PROPERTY_ID must be a number');
        _logError('Invalid GA4 property ID format');
      }
    }
  }

  /// Check if optional keys are configured
  static Map<String, bool> checkOptionalKeys() {
    final result = <String, bool>{};
    for (final key in _optionalKeys) {
      final value = dotenv.env[key];
      result[key] = value != null && value.isNotEmpty;
      if (result[key]!) {
        _logInfo('✓ Optional key $key configured');
      } else {
        _logInfo('ℹ Optional key $key not configured');
      }
    }
    return result;
  }

  /// Get configuration summary
  static String getConfigSummary() {
    final buffer = StringBuffer();
    buffer.writeln('Environment Configuration Summary:');
    buffer.writeln('');
    
    buffer.writeln('Required Variables:');
    for (final key in _requiredKeys) {
      final value = dotenv.env[key];
      final status = (value != null && value.isNotEmpty) ? '✓' : '❌';
      buffer.writeln('  $status $key');
    }
    
    buffer.writeln('');
    buffer.writeln('Optional Variables:');
    for (final key in _optionalKeys) {
      final value = dotenv.env[key];
      final status = (value != null && value.isNotEmpty) ? '✓' : '○';
      buffer.writeln('  $status $key');
    }
    
    return buffer.toString();
  }

  /// Log error with prefix
  static void _logError(String message) {
    // ignore: avoid_print
    print('[ENV_CONFIG_ERROR] $message');
  }

  /// Log info with prefix
  static void _logInfo(String message) {
    // ignore: avoid_print
    print('[ENV_CONFIG] $message');
  }

  /// Throw structured error if validation fails
  static void validateOrThrow() {
    final result = validate();
    if (!result.isValid) {
      throw EnvironmentConfigurationException(result);
    }
  }
}

/// Custom exception for environment configuration errors
class EnvironmentConfigurationException implements Exception {
  final EnvValidationResult validationResult;

  EnvironmentConfigurationException(this.validationResult);

  @override
  String toString() => validationResult.errorMessage;
}
