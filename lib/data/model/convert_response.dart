class ConvertResponse {
  String? base;
  String? message;
  String? date;
  Map<String, dynamic>? rates;
  bool? success;
  int? timestamp;

  ConvertResponse(
      {this.base,
      this.message,
      this.date,
      this.rates,
      this.success,
      this.timestamp});

  ConvertResponse.fromJson(Map<String, dynamic> json) {
    base = json['base'];
    date = json['date'];
    rates =
        json['rates'] != null ? json['rates'] as Map<String, dynamic> : null;
    success = json['success'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['base'] = base;
    data['date'] = date;
    if (rates != null) {
      data['rates'] = rates!;
    }
    data['success'] = success;
    data['timestamp'] = timestamp;
    return data;
  }
}
