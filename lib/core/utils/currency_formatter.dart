import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/generated/app_localizations.dart';

class CurrencyFormatter {
  final String symbol;
  final String locale;

  const CurrencyFormatter({required this.symbol, required this.locale});

  // ── Factory — build from current app locale ────────────────
  factory CurrencyFormatter.of(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CurrencyFormatter(
      symbol: l10n.currencySymbol,
      locale: l10n.currencyLocale,
    );
  }

  factory CurrencyFormatter.fallback() =>
      const CurrencyFormatter(symbol: '₹', locale: 'en_IN');

  String format(double amount) {
    final fmt = NumberFormat.currency(locale: locale, symbol: symbol);
    return fmt.format(amount);
  }

  // ── Compact format e.g. ₹1.2L / $1.2K / Rp1.2jt ──────────
  String compact(double amount) {
    // Each locale has different large-number conventions
    switch (locale) {
      case 'en_IN':
        // Indian: K / L / Cr
        if (amount >= 10000000) {
          return '$symbol${(amount / 10000000).toStringAsFixed(1)}Cr';
        }
        if (amount >= 100000) {
          return '$symbol${(amount / 100000).toStringAsFixed(1)}L';
        }
        if (amount >= 1000) {
          return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
        }
        return format(amount);

      // --------------------- For future language support -----------
      case 'id':
        // Indonesian: jt (juta = million), rb (ribu = thousand)
        if (amount >= 1000000)
          return '${symbol}${(amount / 1000000).toStringAsFixed(1)}jt';
        if (amount >= 1000)
          return '${symbol}${(amount / 1000).toStringAsFixed(1)}rb';
        return format(amount);

      case 'vi':
        // Vietnamese: tr (triệu = million), N (nghìn = thousand)
        if (amount >= 1000000)
          return '${(amount / 1000000).toStringAsFixed(1)}tr$symbol';
        if (amount >= 1000)
          return '${(amount / 1000).toStringAsFixed(0)}N$symbol';
        return format(amount);

      case 'ar':
        // Arabic: symbol comes after number in most Arab locales
        if (amount >= 1000000)
          return '${(amount / 1000000).toStringAsFixed(1)}م $symbol';
        if (amount >= 1000)
          return '${(amount / 1000).toStringAsFixed(1)}ك $symbol';
        return format(amount);

      default:
        // Universal: K / M (used for es, fr, ru, tr, th, sw, pt_BR)
        if (amount >= 1000000)
          return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
        if (amount >= 1000)
          return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
        return format(amount);
    }
  }

  // ── Signed format e.g. +₹450 / -$120 ─────────────────────
  String signed(double amount, {required bool isExpense}) {
    final prefix = isExpense ? '-' : '+';
    return '$prefix${format(amount)}';
  }
}

extension CurrencyFormatterExtension on BuildContext {
  CurrencyFormatter get formatter => CurrencyFormatter.of(this);
}
