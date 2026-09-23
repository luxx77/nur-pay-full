import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/tm_date.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../../../home/presentation/widgets/operation_list.dart';
import '../../../wallet/domain/entities/operation.dart';
import '../../../wallet/presentation/bloc/wallet_cubit.dart';
import '../widgets/history_filter.dart';

/// 2.3 · Taryh — история операций, сгруппированная по дням.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  HistoryFilter _filter = const HistoryFilter();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<WalletCubit>().refresh(),
    );
  }

  Future<void> _openFilter() async {
    final result = await context.push<HistoryFilter>(
      AppRoutes.historyFilter,
      extra: _filter,
    );
    if (result != null && mounted) setState(() => _filter = result);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final wallet = context.watch<WalletCubit>().state;
    final operations = _filter.apply(wallet.operations);
    final groups = _groupByDay(operations);
    final filtering = _filter.isActive || _filter.direction != 0;

    return AppScaffold(
      padded: false,
      safeBottom: false,
      body: Column(
        children: [
          AppLargeTitleBar(
            title: 'Taryh',
            trailing: AppPillButton(
              label: _filter.isActive ? 'Süzgüç · 1' : 'Süzgüç',
              onTap: _openFilter,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
            child: AppSegmentedControl(
              segments: const ['Hemmesi', 'Gelen', 'Giden'],
              selectedIndex: _filter.direction,
              compact: true,
              onChanged: (index) =>
                  setState(() => _filter = _filter.copyWith(direction: index)),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: context.read<WalletCubit>().refresh,
              child: operations.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 120.h),
                        EmptyState(
                          title: 'Amal ýok',
                          message: filtering
                              ? 'Süzgüji üýtgediň ýa-da arassalaň'
                              : 'Ilkinji tölegiňizden soň ähli amallar '
                                    'şu ýerde ýygnalar',
                          actions: [
                            if (filtering)
                              AppButton.tonal(
                                label: 'Süzgüji arassala',
                                size: AppButtonSize.medium,
                                expanded: false,
                                onPressed: () => setState(
                                  () => _filter = const HistoryFilter(),
                                ),
                              ),
                          ],
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final (header, items) = groups[index];
                        final rows = <Widget>[];
                        for (final (i, operation) in items.indexed) {
                          rows.add(
                            OperationRow(operation: operation, detailed: true),
                          );
                          if (i != items.length - 1) {
                            rows.add(
                              Divider(
                                color: cs.outlineVariant,
                                height: 1,
                                indent: 70.w,
                              ),
                            );
                          }
                        }
                        return Entrance(
                          index: index,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SectionLabel(
                                header,
                                padding: EdgeInsets.fromLTRB(
                                  4.w,
                                  14.h,
                                  4.w,
                                  8.h,
                                ),
                              ),
                              AppCard.list(child: Column(children: rows)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Раскладывает проводки по дням, от свежих к старым.
List<(String, List<Operation>)> _groupByDay(List<Operation> operations) {
  final groups = <String, List<Operation>>{};
  for (final operation in operations) {
    groups
        .putIfAbsent(TmDate.dayHeader(operation.createdAt), () => [])
        .add(operation);
  }
  return groups.entries.map((e) => (e.key, e.value)).toList();
}
