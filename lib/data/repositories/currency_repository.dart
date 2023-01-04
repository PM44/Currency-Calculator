import 'package:currency_converter/data/api_client.dart';
import 'package:currency_converter/data/model/convert_response.dart';
import 'package:currency_converter/data/model/currency.dart';

class CurrencyRepository {
  late ApiClient _apiClient;

  CurrencyRepository() {
    _apiClient = ApiClient.getInstance();
  }

  Future<ConvertResponse> convertCurrencies({
    required String baseCurrency,
    required String toCurrency,
    required double amount,
  }) async {
    try {
      final response = await (await _apiClient.dioCore).get(
          'https://api.apilayer.com/exchangerates_data/convert?to=$toCurrency&from=$baseCurrency&amount=${amount.toString()}');
      return ConvertResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Currency>> getAllCurrencies() async {
    List<Currency> list = [];
    try {
      final response = await (await _apiClient.dioCore).get('symbols');
      (response.data['symbols'] as Map<String, dynamic>).forEach((key, value) {
        list.add(Currency(currencyName: value, currencyCode: key));
      });
      return list;
    } catch (e) {
      print(e);
    }
    return list;
  }
}
