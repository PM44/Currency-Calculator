import 'package:bloc_test/bloc_test.dart';
import 'package:currency_converter/bloc/currency_bloc/currency_bloc.dart';
import 'package:currency_converter/bloc/output_currency/output_currency_bloc.dart';
import 'package:currency_converter/bloc/selected_currency/selected_currency_bloc.dart';
import 'package:currency_converter/data/model/currency.dart';
import 'package:currency_converter/data/repositories/currency_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group("Currency Bloc Testing", () {
    late CurrencyBloc currencyBloc;
    late OutputCurrencyBloc outputCurrencyBloc;
    late SelectedCurrencyBloc selectedCurrencyBloc;
    setUp(() async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      currencyBloc = CurrencyBloc(currencyRepository: CurrencyRepository());
      outputCurrencyBloc = OutputCurrencyBloc();
      selectedCurrencyBloc = SelectedCurrencyBloc();
    });
    blocTest<CurrencyBloc, CurrencyState>(
      "Get Currency",
      build: () => currencyBloc,
      act: ((bloc) => bloc.add(const GetAllCurrency())),
      tearDown: () {},
      wait: const Duration(seconds: 7),
      expect: () => [isA<CurrencyLoadingState>(), isA<CurrencyFetchedState>()],
    );
    blocTest<OutputCurrencyBloc, OutputCurrencyState>("Set Currency",
        build: () => outputCurrencyBloc,
        act: ((bloc) => bloc.add(SetOutPutCurrency(Currency(
            currencyName: "INR", currencyCode: "INR", conversionRate: 82)))),
        expect: () => [isA<OutputLoadedState>()]);
    blocTest<SelectedCurrencyBloc, SelectedCurrencyState>("Set Edit Controller",
        build: () => selectedCurrencyBloc,
        act: ((bloc) => bloc.add(AddCurrencyEvent(
            '=',
            Currency(
                currencyName: "INR", currencyCode: "INR", conversionRate: 82),
            TextEditingController()))),
        expect: () => [isA<SelectedCurrencyLoadedState>()]);
    blocTest<CurrencyBloc, CurrencyState>(
      "Get conversion",
      build: () => currencyBloc,
      act: ((bloc) => bloc.add(const ConvertCurrenciesEvent(
          expression: '=',
          amount: 100,
          baseCurrency: 'INR',
          toCurrency: 'INR',
          isFirstValue: true,
          isSingleValue: true))),
    );

    blocTest<CurrencyBloc, CurrencyState>("Get total value",
        build: () {
          currencyBloc.add(const ConvertCurrenciesEvent(
              expression: '=',
              amount: 100,
              baseCurrency: 'INR',
              toCurrency: 'INR',
              isFirstValue: true,
              isSingleValue: true));
          return currencyBloc;
        },
        wait: const Duration(seconds: 10),
        act: ((bloc) =>
            bloc.add(const CalculateCurrencyEvent(toCurrency: 'INR'))),
        tearDown: () {},
        expect: () => [isA<CurrencyFailedState>(), isA<CurrencyLoadedState>()],
        errors: () {
          return [];
        });

    blocTest<CurrencyBloc, CurrencyState>("Calculate conversion",
        build: () {
          return currencyBloc;
        },
        act: ((bloc) =>
            bloc.add(const CalculateCurrencyEvent(toCurrency: 'INR'))),
        wait: const Duration(seconds: 10),
        expect: () => [isA<CurrencyLoadedState>()],
        errors: () {
          return [];
        });
  });
}
