class ApiKey {
  static String getApiKey() {
    return 'yWQcKLYm9IeYguHtnTXQDPsclsIEKkNh';
  }

  static String getBaseUrl() {
    return 'https://api.apilayer.com/exchangerates_data/';
  }

  static String getPathUrl(String url, {Map<String, dynamic>? paths}) {
    String path = url;
    if (paths != null) {
      paths.forEach((key, value) {
        path = path.replaceAll("{$key}", value.toString());
      });
    }
    return path;
  }
}
