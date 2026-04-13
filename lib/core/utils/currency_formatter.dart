import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/generated/app_localizations.dart';

class CurrencyFormatter {
  final String symbol;
  final String locale;

  const CurrencyFormatter({required this.symbol, required this.locale});

  factory CurrencyFormatter.of(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CurrencyFormatter(
      symbol: l10n.currencySymbol,
      locale: l10n.currencyLocale,
    );
  }

  factory CurrencyFormatter.fallback() =>
      const CurrencyFormatter(symbol: '₹', locale: 'en_IN');

  bool _isWhole(double value) => value == value.roundToDouble();

  String _formatNumber(double value, {int? maxDecimals}) {
    final decimals = maxDecimals ?? (_isWhole(value) ? 0 : 2);
    final fmt = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimals,
    );
    return fmt.format(value);
  }

  String _compactNum(double value) {
    final fmt = NumberFormat(_isWhole(value) ? '#,##0' : '#,##0.#', locale);
    return fmt.format(value);
  }

  String format(double amount) {
    return _formatNumber(amount);
  }

  String compact(double amount) {
    switch (locale) {
      case 'en_IN':
        if (amount >= 10000000) {
          return '$symbol${_compactNum(amount / 10000000)}Cr';
        }
        if (amount >= 100000) {
          return '$symbol${_compactNum(amount / 100000)}L';
        }
        if (amount >= 1000) {
          return '$symbol${_compactNum(amount / 1000)}K';
        }
        return _formatNumber(amount, maxDecimals: 0);

      case 'id':
        if (amount >= 1000000) {
          return '$symbol${_compactNum(amount / 1000000)}jt';
        }
        if (amount >= 1000) {
          return '$symbol${_compactNum(amount / 1000)}rb';
        }
        return _formatNumber(amount, maxDecimals: 0);

      case 'vi':
        if (amount >= 1000000) {
          return '${_compactNum(amount / 1000000)}tr$symbol';
        }
        if (amount >= 1000) {
          return '${_compactNum(amount / 1000)}N$symbol';
        }
        return _formatNumber(amount, maxDecimals: 0);

      case 'ar':
        if (amount >= 1000000) {
          return '${_compactNum(amount / 1000000)}م $symbol';
        }
        if (amount >= 1000) {
          return '${_compactNum(amount / 1000)}ك $symbol';
        }
        return _formatNumber(amount, maxDecimals: 0);

      default:
        if (amount >= 1000000) {
          return '$symbol${_compactNum(amount / 1000000)}M';
        }
        if (amount >= 1000) {
          return '$symbol${_compactNum(amount / 1000)}K';
        }
        return _formatNumber(amount, maxDecimals: 0);
    }
  }

  String signed(double amount, {required bool isExpense}) {
    final prefix = isExpense ? '-' : '+';
    return '$prefix${format(amount)}';
  }
}

extension CurrencyFormatterExtension on BuildContext {
  CurrencyFormatter get formatter => CurrencyFormatter.of(this);
}
