// config.dart

class Config {
  static String _homeUrl = 'https://digitalbadapatra.com';
  static String _splashImage = 'assets/logo/govlogo.png';
  static bool _hasInternet = false;

  static void setHomeUrl(String homeUrl) {
    _homeUrl = homeUrl;
  }

  static String getHomeUrl() {
    return _homeUrl;
  }

  static void setSplashImage(String img) {
    _splashImage = img;
  }

  static String getSplashImage() {
    return _splashImage;
  }

  static void hasInternet(bool net) {
    _hasInternet = net;
  }

  static bool getInternet() {
    return _hasInternet;
  }
}
