import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/tm_date.dart';
import '../../../../core/money.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../widgets/history_filter.dart';

/// 2.4 · Süzgüç — шторка фильтра истории.
///
/// Затемнение и подъезд снизу даёт сам маршрут; экран — это только
/// содержимое шторки.
class HistoryFilterPage extends StatefulWidget {
  const HistoryFilterPage({super.key, this.initial = const HistoryFilter()});

  final HistoryFilter initial;

  @override
  State<HistoryFilterPage> createState() => _HistoryFilterPageState();
}

class _HistoryFilterPageState extends State<HistoryFilterPage> {
  late HistoryFilter _filter = widget.initial;
  late final _min = TextEditingController(
    text: widget.initial.min?.formatted ?? '',
  );
  late final _max = TextEditingController(
    text: widget.initial.max?.formatted ?? '',
  );

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  void _apply() {
    final min = _min.text.trim();
    final max = _max.text.trim();
    Navigator.of(context).pop(
      _filter.copyWith(
        min: min.isEmpty ? null : Money.parse(min),
        max: max.isEmpty ? null : Money.parse(max),
        resetRange: min.isEmpty && max.isEmpty,
      ),
    );
  }

  void _reset() {
    setState(() {
      _filter = const HistoryFilter();
      _min.clear();
      _max.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final now = DateTime.now();

    Widget label(String value) => Text(
      value,
      style: text.labelMedium?.copyWith(color: cs.onSurfaceVariant),
    );

    Widget dateBox(DateTime value) => Container(
      height: 52.h,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        borderRadius: AppRadius.smAll,
        border: Border.all(color: cs.outlineVariant, width: 1.5),
      ),
      child: Text(
        '${TmDate.two(value.day)}.${TmDate.two(value.month)}.${value.year}',
        style: text.bodyLarge?.copyWith(
          fontSize: 16.sp,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );

    final since = _filter.period == null
        ? now.subtract(const Duration(days: 30))
        : now.subtract(
            Duration(days: HistoryFilter.periodDays[_filter.period!]),
          );

    return AppSheet(
      title: 'Süzgüç',
      action: Pressable(
        onTap: _reset,
        child: Text(
          'Arassala',
          style: text.bodyMedium?.copyWith(fontSize: 15.sp, color: cs.primary),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          label('Döwür'),
          Gap(10.h),
          Row(
            children: [
              for (final (i, value) in ['Şu gün', '7 gün', 'Aý'].indexed) ...[
                AppChoiceChip(
                  label: value,
                  selected: _filter.period == i,
                  onTap: () => setState(
                    () => _filter = _filter.period == i
                        ? _filter.copyWith(resetPeriod: true)
                        : _filter.copyWith(period: i),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
            ],
          ),
          Gap(10.h),
          RangeFields(from: dateBox(since), to: dateBox(now)),
          Gap(18.h),
          label('Möçber, TMT'),
          Gap(10.h),
          RangeFields(
            from: AppTextField(
              controller: _min,
              hint: '0',
              height: 52.h,
              keyboardType: TextInputType.number,
            ),
            to: AppTextField(
              controller: _max,
              hint: '500',
              height: 52.h,
              keyboardType: TextInputType.number,
            ),
          ),
          Gap(18.h),
          label('Görnüşi'),
          Gap(10.h),
          AppSegmentedControl(
            segments: const ['Hemmesi', 'Gelen', 'Giden'],
            selectedIndex: _filter.direction,
            onChanged: (index) =>
                setState(() => _filter = _filter.copyWith(direction: index)),
          ),
          Gap(18.h),
          AppButton.filled(label: 'Ulan', onPressed: _apply),
        ],
      ),
    );
  }
}
