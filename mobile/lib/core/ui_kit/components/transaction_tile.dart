import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../foundation/app_radius.dart';
import '../motion/pressable.dart';
import 'amount_text.dart';

/// Направление и состояние операции.
enum TransactionKind {
  /// Деньги пришли.
  incoming,

  /// Деньги ушли.
  outgoing,

  /// Ушли, но платформа ещё не подтвердила (офлайн-очередь).
  pending,
}

/// Строка операции в истории и на главном.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.kind = TransactionKind.outgoing,
    this.onTap,
    this.padding,
    this.avatarSize,
  });

  final String title;
  final String subtitle;

  /// Готовая строка суммы со знаком: «+120,00».
  final String amount;
  final TransactionKind kind;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? avatarSize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final side = avatarSize ?? 44.r;

    final (Color bg, Color fg, IconData icon, AmountTone tone) = switch (kind) {
      TransactionKind.incoming => (
        cs.secondaryContainer,
        cs.onSecondaryContainer,
        CupertinoIcons.arrow_down,
        AmountTone.income,
      ),
      TransactionKind.outgoing => (
        cs.surfaceContainerHighest,
        cs.onSurfaceVariant,
        CupertinoIcons.arrow_up,
        AmountTone.neutral,
      ),
      TransactionKind.pending => (
        cs.tertiaryContainer,
        cs.onTertiaryContainer,
        CupertinoIcons.arrow_up,
        AmountTone.pending,
      ),
    };

    final isPending = kind == TransactionKind.pending;

    return Pressable(
      onTap: onTap,
      scale: 0.985,
      child: Container(
        padding:
            padding ?? EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        color: isPending ? cs.tertiaryFixedDim : Colors.transparent,
        child: Row(
          children: [
            Container(
              width: side,
              height: side,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(side * 0.34),
              ),
              child: Icon(icon, size: side * 0.44, color: fg),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: text.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  if (isPending)
                    Row(
                      children: [
                        Container(
                          width: 6.r,
                          height: 6.r,
                          decoration: BoxDecoration(
                            color: cs.tertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Flexible(
                          child: Text(
                            subtitle,
                            style: text.labelMedium?.copyWith(
                              fontSize: 13.sp,
                              color: cs.onTertiaryContainer,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      subtitle,
                      style: text.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            AmountLabel(amount, tone: tone),
          ],
        ),
      ),
    );
  }
}

/// Строка контакта в списке получателей.
class ContactTile extends StatelessWidget {
  const ContactTile({
    super.key,
    required this.name,
    required this.phone,
    this.recent = false,
    this.onTap,
    this.trailing,
  });

  final String name;
  final String phone;

  /// Недавний контакт — аватар красится брендом.
  final bool recent;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Pressable(
      onTap: onTap,
      scale: 0.985,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            _ContactAvatar(name: name, recent: recent),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: text.titleSmall?.copyWith(fontSize: 17.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    phone,
                    style: text.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class _ContactAvatar extends StatelessWidget {
  const _ContactAvatar({required this.name, required this.recent});

  final String name;
  final bool recent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final initials = name
        .replaceAll(RegExp(r'[«»"]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w.substring(0, 1).toUpperCase())
        .join();

    return Container(
      width: 46.r,
      height: 46.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: recent ? cs.primaryContainer : cs.surfaceContainerHighest,
        borderRadius: AppRadius.mdAll,
      ),
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontSize: 16.sp,
          color: recent ? cs.onPrimaryContainer : cs.onSurfaceVariant,
        ),
      ),
    );
  }
}
