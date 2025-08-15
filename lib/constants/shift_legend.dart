class ShiftLegend {
  static const Map<String, String> shiftEmojiLegend = {
    r'$': '💰',
    '^': '🕑',
    '!': '⏱️',
    'A': '🏖️',
    'ADMIN': '📝',
    'AWOL': '🚫',
    'AWS': '⏰',
    'TRNG': '🎓',
    'BL': '🩸',
    'CL': '⚖️',
    'COS': '✈️',
    'CTU': '⏳',
    'XTU': '⏳',
    'FL': '⚰️',
    'FRLO': '🛑',
    'FSL': '🤒',
    'HL': '🎉',
    'JURY': '👩‍⚖️',
    'LWOP': '🚷',
    'MIL': '🎖️',
    'SL': '🤒',
    'TOA': '⏲️',
    'WX': '🌩️',
    'X': '❌',
  };

  static String formatShiftWithEmoji(String code) {
    final parts = code.split(RegExp(r'[\s,]'));
    final formattedParts = parts.map((part) {
      final symbolMatch = RegExp(r'([0-9A-Z]+)([\$\!\^]*)').firstMatch(part);
      if (symbolMatch != null) {
        final mainCode = symbolMatch.group(1)!;
        final symbols = symbolMatch.group(2)!;
        final codeWithoutNumbers = mainCode.replaceAll(RegExp(r'\d'), '');
        final mainEmoji = shiftEmojiLegend[codeWithoutNumbers];
        final symbolsEmoji = symbols
            .split('')
            .map((s) => shiftEmojiLegend[s] ?? s)
            .join();
        if (mainEmoji != null && codeWithoutNumbers.isNotEmpty) {
          return '$mainCode ($mainEmoji)$symbolsEmoji';
        } else {
          return '$mainCode$symbolsEmoji';
        }
      }
      return part;
    }).toList();
    return formattedParts.join(' ');
  }
}
