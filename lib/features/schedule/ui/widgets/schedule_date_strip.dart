import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleDateStrip extends StatefulWidget {
  const ScheduleDateStrip({
    required this.selectedDay,
    required this.onDateSelected,
    super.key,
  });
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDateSelected;

  @override
  State<ScheduleDateStrip> createState() => _ScheduleDateStripState();
}

class _ScheduleDateStripState extends State<ScheduleDateStrip> {
  static const int _visibleDaysCount = 31; // show current month + 30 days
  static const double _itemWidth = 82; // width + margin

  final ScrollController _controller = ScrollController();

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  int _selectedIndex() {
    return widget.selectedDay
        .difference(_today)
        .inDays
        .clamp(0, _visibleDaysCount - 1);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final index = _selectedIndex();

      _controller.jumpTo(index * _itemWidth);
    });
  }

  void _handleTap(DateTime day, int index) {
    widget.onDateSelected(day);

    if (!_controller.hasClients) return;

    final viewport = _controller.position.viewportDimension;
    final lastVisibleIndex = ((_controller.offset + viewport) / _itemWidth)
        .floor()
        .clamp(0, _visibleDaysCount - 1);

    if (index < lastVisibleIndex) return;

    final targetIndex = (index + 1).clamp(0, _visibleDaysCount - 1);
    final targetOffset = targetIndex * _itemWidth;
    final maxOffset = _controller.position.maxScrollExtent;

    unawaited(
      _controller.animateTo(
        targetOffset.clamp(0, maxOffset).toDouble(),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 102,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _visibleDaysCount,
        itemBuilder: (context, index) {
          final day = _today.add(Duration(days: index));
          final isSelected = DateUtils.isSameDay(day, widget.selectedDay);

          return GestureDetector(
            onTap: () => _handleTap(day, index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF9E5135).withAlpha(180)
                    : Colors.white.withAlpha(25),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat(
                      'E',
                      Localizations.localeOf(context).toLanguageTag(),
                    ).format(day).toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      height: 1,
                      color: isSelected ? Colors.white : Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('d').format(day),
                    style: TextStyle(
                      fontSize: 22,
                      height: 1,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
