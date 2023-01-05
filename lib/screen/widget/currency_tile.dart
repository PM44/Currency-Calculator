import 'package:currency_converter/core/consts/app_text_styles.dart';
import 'package:currency_converter/data/model/currency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CurrencyTile extends StatefulWidget {
  const CurrencyTile({
    Key? key,
    required this.currency,
    required this.isHint,
  }) : super(key: key);
  final Currency currency;
  final bool isHint;

  @override
  State<CurrencyTile> createState() => _CurrencyTileState();
}

class _CurrencyTileState extends State<CurrencyTile> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          widget.isHint ? BorderRadius.circular(10) : BorderRadius.circular(10),
      child: _hoveringFunc(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: isHovering
              ? const EdgeInsets.fromLTRB(7, 7, 30, 7)
              : const EdgeInsets.fromLTRB(7, 7, 15, 7),
          color: widget.isHint
              ? Colors.green.withOpacity(isHovering ? 0.4 : 0.1)
              : Colors.grey.withOpacity(isHovering ? 0.4 : 0.1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.isHint == true
                  ? Text(
                      widget.currency.currencyCode!,
                      style: AppTextStyles.titleWhiteMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.currency.currencyCode!,
                          style: AppTextStyles.titleWhiteMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.currency.currencyName!,
                          style: AppTextStyles.titleWhiteMedium.copyWith(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              color: Colors.black),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hoveringFunc({required Widget child}) {
    return kIsWeb
        ? MouseRegion(
            cursor: MouseCursor.defer,
            onExit: (event) {
              setState(() {
                isHovering = false;
              });
            },
            onEnter: (event) {
              setState(() {
                isHovering = true;
              });
            },
            child: child,
          )
        : Listener(
            child: child,
            onPointerUp: (event) {
              setState(() {
                isHovering = false;
              });
            },
            onPointerDown: (event) {
              setState(() {
                isHovering = true;
              });
            });
  }
}
