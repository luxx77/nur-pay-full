import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/tm_date.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../../../wallet/domain/entities/operation.dart';

/// Строка операции, собранная из проводки.
///
/// Держит в одном месте правила: направление, подпись и переход на чек.
class OperationRow extends StatelessWidget {
  const OperationRow({
    super.key,
    required this.operation,
    this.detailed = false,
    this.padding,
    this.avatarSize,
  });

  final Operation operation;

  /// В истории подпись подробнее: «Geçirim · 14:20» вместо «14:20».
  final bool detailed;
  final EdgeInsetsGeometry? padding;
  final double? avatarSize;

  @override
  Widget build(BuildContext context) => TransactionTile(
    title: operation.counterparty.title,
    subtitle: detailed
        ? '${operation.type.label} · ${TmDate.time(operation.createdAt)}'
        : TmDate.relativeTime(operation.createdAt),
    amount: operation.signedAmount,
    kind: operation.isIncoming
        ? TransactionKind.incoming
        : TransactionKind.outgoing,
    padding: padding,
    avatarSize: avatarSize,
    // У комиссии своего чека нет — она часть основной операции.
    onTap: operation.isFee
        ? null
        : () => context.push(AppRoutes.transactionOf(operation.id)),
  );
}
