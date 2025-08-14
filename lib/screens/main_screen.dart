import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

/// Mapping of shift/leave codes to emojis
const Map<String, String> shiftEmojiLegend = {
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

/// Formats a shift code string like "11AWS" or "630$" into "11AWS (⏰)" or "630💰"
String formatShiftWithEmoji(String code) {
  // Split by space/comma to handle multiple codes
  final parts = code.split(RegExp(r'[\s,]'));
  final formattedParts = parts.map((part) {
    // Allow digits + letters in the main code, keep $, !, ^ as symbols
    final symbolMatch = RegExp(r'([0-9A-Z]+)([\$\!\^]*)').firstMatch(part);
    if (symbolMatch != null) {
      final mainCode = symbolMatch.group(1)!;
      final symbols = symbolMatch.group(2)!;

      // Remove numbers for emoji lookup
      final codeWithoutNumbers = mainCode.replaceAll(RegExp(r'\d'), '');
      final mainEmoji = shiftEmojiLegend[codeWithoutNumbers];

      // Convert each symbol to its emoji if exists
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

class MainScreen extends StatefulWidget {
  final List<Map<String, String>> shifts;
  final String? errorMessage;

  const MainScreen({Key? key, required this.shifts, this.errorMessage})
    : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late String _timeString;
  late String _dateString;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateDateTime(),
    );
  }

  void _updateDateTime() {
    final now = DateTime.now();
    setState(() {
      _dateString = DateFormat('EEEE, MMMM d, yyyy').format(now);
      _timeString = DateFormat('hh:mm a').format(now);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedule'),
        backgroundColor: const Color(0xFF002B53),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF9800), Color(0xFFFFC107)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.all(Radius.circular(25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              constraints: const BoxConstraints(minHeight: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _dateString,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _timeString,
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: widget.errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        widget.errorMessage!,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : (widget.shifts.isEmpty
                      ? Center(
                          child: Text(
                            'No schedule loaded.\nTap "Sync Now" to fetch your shifts.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: widget.shifts.length,
                          itemBuilder: (context, index) {
                            final shift = widget.shifts[index];
                            final formattedCode = formatShiftWithEmoji(
                              shift['code'] ?? '',
                            );
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      formattedCode,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      shift['date'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )),
          ),
        ],
      ),
    );
  }
}
