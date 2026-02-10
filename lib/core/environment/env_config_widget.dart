/// 🔧 Environment Configuration Widget
/// 
/// Shows environment configuration status in the UI

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'env_validator.dart';

class EnvConfigWidget extends StatelessWidget {
  const EnvConfigWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final validationResult = EnvValidator.validate();
    final optionalKeys = EnvValidator.checkOptionalKeys();

    return Card(
      margin: const EdgeInsets.all(16),
      child: ExpansionTile(
        leading: Icon(
          validationResult.isValid ? Icons.check_circle : Icons.error,
          color: validationResult.isValid ? Colors.green : Colors.red,
        ),
        title: Text(
          validationResult.isValid
              ? 'Configuration Valid'
              : 'Configuration Issues',
          style: TextStyle(
            color: validationResult.isValid ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          validationResult.isValid
              ? 'All required variables configured'
              : '${validationResult.missingKeys.length} missing variables',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!validationResult.isValid) ...[
                  const Text(
                    'Missing Variables:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...validationResult.missingKeys.map((key) => Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.close, size: 16, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(key),
                          ],
                        ),
                      )),
                  const SizedBox(height: 16),
                ],
                const Text(
                  'Optional Variables:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...optionalKeys.entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            entry.value ? Icons.check : Icons.circle_outlined,
                            size: 16,
                            color: entry.value ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(entry.key),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
