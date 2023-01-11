import 'package:currency_converter/data/model/currency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'output_currency_event.dart';
part 'output_currency_state.dart';

class OutputCurrencyBloc
    extends Bloc<OutputCurrencyEvent, OutputCurrencyState> {
  late Currency selectedCurrency;

  OutputCurrencyBloc() : super(OutputCurrencyInitial()) {
    on<OutputCurrencyEvent>((event, emit) {
      if (event is SetOutPutCurrency) {
        selectedCurrency = event.selectedCurrency;
        emit(OutputLoadedState(event.selectedCurrency));
      }
    });
  }
}
