import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  // ✅ 1. Project URL (Maine aapke screenshot se utha liya hai)
  static const String supabaseUrl = 'https://epkbscopmbixkhjblcxu.supabase.co';

  // ⚠️ 2. API Key (Yahan wo lambi 'anon public' key paste karein jo 'sb_publishable' se shuru hoti hai)
  static const String supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVwa2JzY29wbWJpeGtoamJsY3h1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc5NjMzNzQsImV4cCI6MjA4MzUzOTM3NH0.gvIt8POyuGfn3J1Igh1Tw1gNMrURF0Q1apad9IXveas';

  static final SupabaseClient client = Supabase.instance.client;

  // --- INITIALIZATION ---
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
      debugPrint("✅ Supabase Initialized Successfully!");
    } catch (e) {
      debugPrint("❌ Supabase Init Error: $e");
    }
  }

  // --- TEST CONNECTION ---
  static Future<bool> checkConnection() async {
    try {
      // Aik simple query chala kar dekhte hain
      await client.from('products').select().limit(1);
      debugPrint("✅ Connection Verified!");
      return true;
    } catch (e) {
      debugPrint("❌ Connection Failed: $e");
      return false;
    }
  }
}
