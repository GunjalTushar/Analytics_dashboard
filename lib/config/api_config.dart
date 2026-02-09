/// 🔑 API Configuration - Supabase
/// 
/// ✅ SECURITY: All credentials loaded from environment variables
/// 
/// 🔧 Setup Instructions:
/// 1. Add SUPABASE_URL to your .env file
/// 2. Add SUPABASE_ANON_KEY to your .env file
/// 3. Make sure your Supabase Edge Function is deployed at /analytics

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // 🌐 Supabase Project URL (loaded from .env)
  static String get supabaseUrl => 
      dotenv.env['SUPABASE_URL'] ?? 
      throw Exception('SUPABASE_URL not found in .env file');
  
  // 🔑 Supabase Anon Key (loaded from .env)
  static String get supabaseAnonKey => 
      dotenv.env['SUPABASE_ANON_KEY'] ?? 
      throw Exception('SUPABASE_ANON_KEY not found in .env file');
  
  // 📊 Analytics Edge Function Name
  static const String analyticsFunction = "analytics";
  
  // 🌐 Full Analytics URL
  static String get analyticsUrl => 
      "$supabaseUrl/functions/v1/$analyticsFunction";
  
  // 📝 Request Headers with Supabase Authentication
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'apikey': supabaseAnonKey,
    'Authorization': 'Bearer $supabaseAnonKey',
  };
}
