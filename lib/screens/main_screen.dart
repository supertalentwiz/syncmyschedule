import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/schedule_provider.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/schedule/date_time_card.dart';
import '../widgets/schedule/shift_card.dart';
import '../widgets/schedule/shift_toolbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late String _dateString;
  late Timer _timer;
  String? _selectedPayPeriod;

  @override
  void initState() {
    super.initState();
    _updateDate();
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _updateDate(),
    );
  }

  void _updateDate() {
    final now = DateTime.now();
    setState(() {
      _dateString = DateFormat('EEEE, MMMM d, yyyy').format(now);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final now = DateTime.now();

    return Scaffold(
      appBar: CustomAppBar(title: AppStrings.mySchedule),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: DateTimeCard(
              date: _dateString,
              payPeriods: scheduleProvider.payPeriods,
              selectedPayPeriod: _selectedPayPeriod,
              onPayPeriodChanged: (value) async {
                setState(() {
                  _selectedPayPeriod = value;
                });
                if (value != null) {
                  final credentials = await scheduleProvider.getSavedCredentials();
                  if (credentials != null) {
                    // Fetch schedule (initial fetch) – you can later implement fetch for specific period
                    await scheduleProvider.fetchSchedule(
                      credentials['username']!,
                      credentials['password']!,
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 12),
          ShiftToolbar(scheduleProvider: scheduleProvider),
          Expanded(
            child: scheduleProvider.errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        scheduleProvider.errorMessage!,
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : scheduleProvider.shifts.isEmpty
                    ? Center(
                        child: Text(
                          AppStrings.noSchedule,
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: scheduleProvider.shifts.length,
                        itemBuilder: (context, index) {
                          final shift = scheduleProvider.shifts[index];
                          final shiftDate = DateFormat('MM/dd/yyyy').parse(shift.date);
                          final isPastShift = shiftDate.isBefore(now);
                          return ShiftCard(
                            code: shift.code,
                            date: shift.date,
                            isChecked: scheduleProvider.shiftCheckedStates[shift.date] ?? false,
                            onChecked: isPastShift
                                ? null
                                : (value) {
                                    scheduleProvider.toggleShiftChecked(shift.date, value);
                                  },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
