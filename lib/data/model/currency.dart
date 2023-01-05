class Currency {
   String? currencyCode;
   String? currencyName;

   Currency({
    required this.currencyName,
    required this.currencyCode,
  });

  Currency.fromJson(Map<String, dynamic> json) {
    currencyName = json['currencyName'];
    currencyCode = json['currencyCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currencyName'] = currencyName;
    data['currencyCode'] = currencyCode;
    return data;
  }
}
