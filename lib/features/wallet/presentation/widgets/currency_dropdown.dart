import 'package:flutter/material.dart';
import '../../../../core/utils/constants/currency.dart';
import '../../../../core/utils/extensions/context_extension.dart';

class CurrencyDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const CurrencyDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: context.l10n.currency,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.currency_exchange),
      ),
      items: Currency.availableCurrencies.map((String currency) {
        return DropdownMenuItem<String>(
          value: currency,
          child: Text('$currency (${Currency.getSymbol(currency)})'),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return context.l10n.pleaseSelectCurrency;
        }
        return null;
      },
    );
  }
}
