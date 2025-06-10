class Config {
  //static String ipBackend = '192.168.100.248';
  static String ipBackend = '10.0.0.9';

  static String get ipback => 'http://$ipBackend:4001/api';

  static String get solIP => 'http://$ipBackend:4001';
}
