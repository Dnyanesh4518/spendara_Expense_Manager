import '../../l10n/generated/app_localizations.dart';

class EmailValidator {
  String? validateEmail(String? val, AppLocalizations? l10n) {
    final empty = l10n?.pleaseEnterEmail ?? 'Please enter your email';
    final invalid = l10n?.enterValidEmail ?? 'Enter a valid email address';

    if (val == null || val.trim().isEmpty) return empty;

    final email = val.trim();

    // ── 1. Overall length (RFC 5321 limit) ──────────────────
    if (email.length > 254) return invalid;

    // ── 2. Must have exactly one @ ───────────────────────────
    final parts = email.split('@');
    if (parts.length != 2) return invalid;

    final local = parts[0];
    final domain = parts[1];

    // ── 3. Local part (before @) ─────────────────────────────
    if (local.isEmpty || local.length > 64) return invalid;
    if (local.startsWith('.') || local.endsWith('.')) return invalid;
    if (local.contains('..')) return invalid; // no consecutive dots
    // Allowed: letters, digits, and . _ % + -
    if (!RegExp(r'^[a-zA-Z0-9._%+\-]+$').hasMatch(local)) return invalid;

    // ── 4. Domain part (after @) ─────────────────────────────
    if (domain.isEmpty || domain.length > 253) return invalid;
    if (domain.startsWith('.') || domain.endsWith('.')) return invalid;
    if (domain.startsWith('-')) return invalid;
    if (domain.contains('..')) return invalid; // no consecutive dots

    // ── 5. Domain must have at least one dot ─────────────────
    final domainParts = domain.split('.');
    if (domainParts.length < 2) return invalid;

    // ── 6. Validate each domain label ────────────────────────
    for (final label in domainParts) {
      if (label.isEmpty) return invalid;
      if (label.startsWith('-') || label.endsWith('-')) return invalid;
      if (label.length > 63) return invalid;
      // Only letters, digits, hyphens allowed in domain labels
      if (!RegExp(r'^[a-zA-Z0-9\-]+$').hasMatch(label)) return invalid;
    }

    // ── 7. TLD must be letters only, min 2 chars ─────────────
    // Allows .com .in .co.in .photography .museum etc.
    final tld = domainParts.last;
    if (tld.length < 2 || !RegExp(r'^[a-zA-Z]+$').hasMatch(tld)) return invalid;
    if (!_isDomainValid(domain)) return invalid;

    return null; // ✅ valid
  }

  static const _knownDomains = [
    'gmail.com',
    'yahoo.com',
    'outlook.com',
    'hotmail.com',
    'icloud.com',
    'live.com',
    'rediffmail.com',
    'ymail.com',
    'protonmail.com',
    'zoho.com',
    'me.com',
    'yahoo.in',
    'hotmail.co.uk',
    'googlemail.com',
    'msn.com',
  ];

  int _levenshtein(String a, String b) {
    final dp = List.generate(
      a.length + 1,
      (i) => List.generate(b.length + 1, (j) => 0),
    );
    for (int i = 0; i <= a.length; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= b.length; j++) {
      dp[0][j] = j;
    }
    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        dp[i][j] = a[i - 1] == b[j - 1]
            ? dp[i - 1][j - 1]
            : 1 +
                  [
                    dp[i - 1][j],
                    dp[i][j - 1],
                    dp[i - 1][j - 1],
                  ].reduce((x, y) => x < y ? x : y);
      }
    }
    return dp[a.length][b.length];
  }

  bool _isDomainValid(String domain) {
    final d = domain.toLowerCase();

    // ── 1. Exact match — always valid ─────────────────────────
    if (_knownDomains.contains(d)) return true;

    // ── 2. Close to a known domain (distance <= 2) — likely a typo ──
    for (final known in _knownDomains) {
      if (_levenshtein(d, known) <= 2) return false;
    }

    // ── 3. Unknown domain (company, custom) — allow it ────────
    return true;
  }
}
