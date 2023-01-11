class Currency {
  String? currencyCode;
  String? currencyName;
  num? conversionRate;

  Currency(
      {required this.currencyName,
      required this.currencyCode,
      this.conversionRate});

  Currency.fromJson(Map<String, dynamic> json) {
    currencyName = json['currencyName'];
    currencyCode = json['currencyCode'];
    conversionRate = json['conversionRate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currencyName'] = currencyName;
    data['currencyCode'] = currencyCode;
    data['conversionRate'] = conversionRate;
    return data;
  }
}
