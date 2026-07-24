// lib/config/app_config.dart
class AppConfig {
  // معلومات التطبيق
  static const String appName = 'أبو ليث ERP';
  static const String appVersion = '1.0.0';
  static const String companyName = 'معمل أبو ليث';
  static const String companyActivity = 'إنتاج الكيك والنواشف';
  
  // العملة
  static const String currency = 'ريال يمني';
  static const String currencySymbol = 'ر.ي';
  
  // قاعدة البيانات
  static const String dbName = 'abu_laith_erp.db';
  static const int dbVersion = 1;
  
  // الأمان
  static const int sessionTimeout = 30; // دقيقة
  static const int maxLoginAttempts = 5;
  
  // المزامنة
  static const String syncInterval = '5'; // دقائق
  static const int maxRetries = 3;
  
  // المخزون
  static const int defaultBoxSize = 60; // عدد القطع في السلة افتراضي
  static const int lowStockThreshold = 100; // حد التنبيه لنقص المخزون
  
  // الصفحات
  static const int pageSize = 20; // عدد السجلات في الصفحة
}