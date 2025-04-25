class Config {
  static String ipBackend = '10.0.0.10';

  static String get ipback => 'http://$ipBackend:4001/api';

  static String get solIP => 'http://$ipBackend:4001';
}
