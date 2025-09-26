import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../easy_date_time_line_picker/utils/typed_ahead.dart';
import '../../models/models.dart';
import '../../properties/properties.dart';
import '../../utils/utils.dart';
import '../easy_month_picker/easy_month_picker.dart';
import '../time_line_widget/timeline_widget.dart';
import 'selected_date_widget.dart';

/// Represents a timeline widget for displaying dates in a horizontal line.
class EasyDateTimeLine extends StatefulWidget {
  const EasyDateTimeLine({
    super.key,
    required this.initialDate,
    this.controller,
    this.disabledDates,
    this.headerProps = const EasyHeaderProps(),
    this.timeLineProps = const EasyTimeLineProps(),
    this.dayProps = const EasyDayProps(),
    this.onDateChange,
    this.onMonthChange,
    this.itemBuilder,
    this.activeColor,
    this.locale = "en_US",
  });

  final EasyDateTimelineController? controller;

  /// Represents the initial date for the timeline widget.
  final DateTime initialDate;

  /// List of inactive dates.
  final List<DateTime>? disabledDates;

  /// The color for the active day.
  final Color? activeColor;

  final EasyHeaderProps headerProps;
  final EasyTimeLineProps timeLineProps;
  final EasyDayProps dayProps;

  final OnDateChangeCallBack? onDateChange;
  final ValueChanged<DateTime>? onMonthChange;

  final ItemBuilderCallBack? itemBuilder;
  final String locale;

  @override
  State<EasyDateTimeLine> createState() => _EasyDateTimeLineState();
}

class _EasyDateTimeLineState extends State<EasyDateTimeLine> {
  late EasyMonth _easyMonth;
  late int _initialDay;

  late ValueNotifier<DateTime?> _focusedDateListener;

  final GlobalKey<_TimeLineWidgetState> _timeLineKey =
  GlobalKey<_TimeLineWidgetState>();

  DateTime get initialDate => widget.initialDate;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting(widget.locale, null);

    _easyMonth =
        EasyDateUtils.convertDateToEasyMonth(widget.initialDate, widget.locale);
    _initialDay = widget.initialDate.day;
    _focusedDateListener = ValueNotifier(widget.initialDate);

    // conecta controller
    widget.controller?._attach(this);
  }

  @override
  void dispose() {
    _focusedDateListener.dispose();
    super.dispose();
  }

  /// Força o scroll até a data
  void jumpToDate(DateTime date) {
    setState(() {
      _easyMonth = EasyDateUtils.convertDateToEasyMonth(date, widget.locale);
      _initialDay = date.day;
      _focusedDateListener.value = date;
    });
    widget.onDateChange?.call(date);

    // 🔥 força o scroll na lista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timeLineKey.currentState?.scrollToDate(date);
    });
  }

  /// Apenas seleciona a data, sem scroll
  void setDate(DateTime date) {
    setState(() {
      _focusedDateListener.value = date;
    });
    widget.onDateChange?.call(date);
  }

  void _onFocusedDateChanged(DateTime date) {
    _focusedDateListener.value = date;
    widget.onDateChange?.call(date);
  }

  EasyHeaderProps get _headerProps => widget.headerProps;

  @override
  Widget build(BuildContext context) {
    final activeDayColor = widget.activeColor ?? Theme.of(context).primaryColor;
    final brightness =
    ThemeData.estimateBrightnessForColor(widget.activeColor ?? activeDayColor);

    final activeDayTextColor =
    brightness == Brightness.light ? EasyColors.dayAsNumColor : Colors.white;

    return ValueListenableBuilder(
      valueListenable: _focusedDateListener,
      builder: (context, focusedDate, child) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_headerProps.showHeader)
            Padding(
              padding: _headerProps.padding ??
                  const EdgeInsets.only(
                    left: EasyConstants.timelinePadding * 2,
                    right: EasyConstants.timelinePadding,
                    bottom: EasyConstants.timelinePadding,
                  ),
              child: Row(
                mainAxisAlignment: _headerProps.centerHeader == true
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceBetween,
                children: [
                  SelectedDateWidget(
                    date: focusedDate ?? initialDate,
                    locale: widget.locale,
                    headerProps: _headerProps,
                  ),
                  if (_showMonthPicker(pickerType: MonthPickerType.dropDown))
                    child!,
                  if (_showMonthPicker(pickerType: MonthPickerType.switcher))
                    EasyMonthSwitcher(
                      locale: widget.locale,
                      value: _easyMonth,
                      onMonthChange: _onMonthChange,
                      style: _headerProps.monthStyle,
                    ),
                ],
              ),
            ),
          TimeLineWidget(
            key: _timeLineKey, // ✅ conecta key
            initialDate: _focusedDateListener.value ??
                initialDate.copyWith(
                  month: _easyMonth.vale,
                  day: _initialDay,
                ),
            inactiveDates: widget.disabledDates,
            focusedDate: focusedDate,
            onDateChange: _onFocusedDateChanged,
            timeLineProps: widget.timeLineProps,
            dayProps: widget.dayProps,
            itemBuilder: widget.itemBuilder,
            activeDayTextColor: activeDayTextColor,
            activeDayColor: activeDayColor,
            locale: widget.locale,
          ),
        ],
      ),
      child: EasyMonthDropDown(
        value: _easyMonth,
        locale: widget.locale,
        onMonthChange: _onMonthChange,
        style: _headerProps.monthStyle,
      ),
    );
  }

  void _onMonthChange(EasyMonth? month) {
    if (month == null) return;

    setState(() {
      _initialDay = 1;
      _easyMonth = month;
      final newDate = DateTime(
        _focusedDateListener.value?.year ?? DateTime.now().year,
        month.vale,
        1,
      );
      _focusedDateListener.value = newDate;
    });

    final currentYear = _focusedDateListener.value?.year ?? DateTime.now().year;
    widget.onMonthChange?.call(DateTime(currentYear, month.vale, 1));
    widget.onDateChange?.call(DateTime(currentYear, month.vale, 1));

    // 🔥 scrolla pro início do mês
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timeLineKey.currentState?.scrollToDate(
        DateTime(currentYear, month.vale, 1),
      );
    });
  }

  bool _showMonthPicker({required MonthPickerType pickerType}) {
    final bool showMonthPicker = _headerProps.showMonthPicker;
    return _headerProps.monthPickerType == pickerType && showMonthPicker;
  }
}

/// Controller para manipular o calendário externamente
class EasyDateTimelineController {
  _EasyDateTimeLineState? _state;

  void _attach(_EasyDateTimeLineState state) {
    _state = state;
  }

  void jumpToDate(DateTime date) {
    _state?.jumpToDate(date);
  }

  void setDate(DateTime date) {
    _state?.setDate(date);
  }
}
