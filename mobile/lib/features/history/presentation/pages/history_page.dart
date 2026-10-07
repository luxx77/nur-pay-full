import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/connectivity/connectivity_cubit.dart';
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
  static const _segments = ['Hemmesi', 'Gelen', 'Giden'];

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
    final text = Theme.of(context).textTheme;
    final wallet = context.watch<WalletCubit>().state;

    // DefaultTabController раздаёт один TabController через контекст:
    // TabBar и TabBarView ниже находят его сами, без ручной синхронизации.
    return BlocListener<ConnectivityCubit, bool>(
      // Связь вернулась — история могла устареть, обновляем сразу, не
      // дожидаясь следующего открытия вкладки.
      listenWhen: (was, isNow) => !was && isNow,
      listener: (context, _) => context.read<WalletCubit>().refresh(),
      child: DefaultTabController(
        length: _segments.length,
        child: AppScaffold(
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
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: AppRadius.smAll,
                  ),
                  child: TabBar(
                    // Заливка под активным табом едет как раньше в
                    // AppSegmentedControl — не полоска снизу.
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    indicatorAnimation: TabIndicatorAnimation.elastic,
                    dividerColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    labelColor: cs.onSurface,
                    unselectedLabelColor: cs.onSurfaceVariant,
                    labelStyle: text.bodyMedium?.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: text.bodyMedium?.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                    ),
                    tabs: [
                      for (final segment in _segments)
                        Tab(height: 34.h, text: segment),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    for (
                      var direction = 0;
                      direction < _segments.length;
                      direction++
                    )
                      _OperationsTab(
                        operations: _filter
                            .copyWith(direction: direction)
                            .apply(wallet.operations),
                        filtering: _filter.isActive || direction != 0,
                        onRefresh: context.read<WalletCubit>().refresh,
                        onClearFilter: () =>
                            setState(() => _filter = const HistoryFilter()),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Один таб: список операций одного направления, сгруппированный по дням.
class _OperationsTab extends StatelessWidget {
  const _OperationsTab({
    required this.operations,
    required this.filtering,
    required this.onRefresh,
    required this.onClearFilter,
  });

  final List<Operation> operations;
  final bool filtering;
  final Future<void> Function() onRefresh;
  final VoidCallback onClearFilter;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final groups = _groupByDay(operations);

    return RefreshIndicator(
      onRefresh: onRefresh,
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
                        onPressed: onClearFilter,
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
                  rows.add(OperationRow(operation: operation, detailed: true));
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
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionLabel(
                      header,
                      padding: EdgeInsets.fromLTRB(4.w, 14.h, 4.w, 8.h),
                    ),
                    AppCard.list(child: Column(children: rows)),
                  ],
                );
              },
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
