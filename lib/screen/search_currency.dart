import 'package:currency_converter/block/currency_bloc.dart';
import 'package:currency_converter/core/consts/app_text_styles.dart';
import 'package:currency_converter/data/model/currency.dart';
import 'package:currency_converter/screen/widget/currency_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchCurrencyBottomSheet extends StatefulWidget {
  const SearchCurrencyBottomSheet({
    Key? key,
    required this.isBaseCurrency,
    required this.allCurrency,
    required this.callbak,
  }) : super(key: key);

  final bool isBaseCurrency;
  final List<Currency> allCurrency;
  final void Function(Currency) callbak;

  @override
  State<SearchCurrencyBottomSheet> createState() =>
      _SearchCurrencyBottomSheetState();
}

class _SearchCurrencyBottomSheetState extends State<SearchCurrencyBottomSheet> {
  late CurrencyBloc _currencyConversionBloc;
  List<Currency> _currenciesFound = [];

  @override
  void initState() {
    _currenciesFound = widget.allCurrency;
    _currencyConversionBloc = context.read<CurrencyBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.75,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) => Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        color: Colors.white.withOpacity(0.3),
        child: Column(
          children: [
            _lineDecoration(),
            _textField(),
            _buildListView(scrollController),
          ],
        ),
      ),
    );
  }

  Widget _lineDecoration() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Container(
          height: 7,
          color: Colors.white.withOpacity(0.15),
        ),
      ),
    );
  }

  Widget _textField() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: TextField(
        decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search), hintText: 'USD / American dollar'),
        onChanged: (value) {
          setState(() {
            _searchCurrencies(value);
          });
        },
      ),
    );
  }

  BlocBuilder<CurrencyBloc, CurrencyState> _buildListView(
      ScrollController scrollController) {
    return BlocBuilder<CurrencyBloc, CurrencyState>(
      bloc: _currencyConversionBloc,
      builder: (context, state) {
        return Expanded(
          child: _currenciesFound.isNotEmpty
              ? ListView.separated(
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 5),
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _currenciesFound.length,
                  itemBuilder: (context, index) {
                    if (state is CurrencyFetchedState) {
                      return GestureDetector(
                        onTap: () => _onTileTap(index),
                        child: CurrencyTile(
                          currency: _currenciesFound[index],
                          isHint: false,
                        ),
                      );
                    }
                    if (state is CurrencyLoadedState) {
                      return GestureDetector(
                        onTap: () => _onTileTap(index),
                        child: CurrencyTile(
                          currency: _currenciesFound[index],
                          isHint: false,
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                )
              : Text(
                  'No currency found',
                  style: AppTextStyles.titleWhiteBig.copyWith(fontSize: 15),
                ),
        );
      },
    );
  }

  List<Currency> _searchCurrencies(String searchText) {
    if (searchText.isNotEmpty) {
      _currenciesFound = widget.allCurrency.where((element) {
        if (element.currencyCode!
            .toLowerCase()
            .contains(searchText.toLowerCase())) {
          return true;
        } else if (element.currencyName!
            .toLowerCase()
            .contains(searchText.toLowerCase())) {
          return true;
        }
        return false;
      }).toList();
    } else {
      _currenciesFound.addAll(widget.allCurrency);
    }
    return _currenciesFound;
  }

  void _onTileTap(int index) {
    widget.callbak(_currenciesFound[index]);
    Navigator.of(context).pop();
  }
}
