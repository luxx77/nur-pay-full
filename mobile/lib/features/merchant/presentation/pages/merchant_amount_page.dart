import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/input/amount_editor.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../bloc/merchant_payment_cubit.dart';

/// 7.2 · Möçber — кассир вводит сумму до сканирования.
///
/// QR клиента суммы не содержит, поэтому сначала сумма, потом сканер.
class MerchantAmountPage extends StatefulWidget {
  const MerchantAmountPage({super.key});

  @override
  State<MerchantAmountPage> createState() => _MerchantAmountPageState();
}

class _MerchantAmountPageState extends State<MerchantAmountPage> {
  late final AmountEditor _editor;

  @override
  void initState() {
    super.initState();
    _editor = AmountEditor(
      initial: context.read<MerchantPaymentCubit>().state.amount,
    )..addListener(_onChanged);
  }

  @override
  void dispose() {
    _editor
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) => RoleTheme(
    role: AppRole.merchant,
    child: Builder(
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        final text = Theme.of(context).textTheme;
        final canScan = _editor.value.isPositive;

        return AppScaffold(
          padded: false,
          body: Column(
            children: [
              const AppTopBar(title: 'Töleg kabul et'),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 10.h, bottom: 14.h),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: cs.outlineVariant),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 26.r,
                              height: 26.r,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: cs.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CupertinoIcons.arrow_down,
                                size: 14.r,
                                color: cs.onPrimaryContainer,
                              ),
                            ),
                            SizedBox(width: 11.w),
                            Expanded(
                              child: Text(
                                'Müşderiniň QR kody möçberi saklamaýar '
                                '— ilki möçberi giriziň',
                                style: text.bodySmall?.copyWith(
                                  fontSize: 13.5.sp,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap(14.h),
                      Center(
                        child: AmountText(
                          _editor.display,
                          size: AmountSize.display,
                        ),
                      ),
                      const Spacer(),
                      AppButton.filled(
                        label: 'Dowam et',
                        onPressed: canScan
                            ? () {
                                context.read<MerchantPaymentCubit>().setAmount(
                                  _editor.value,
                                );
                                context.push(AppRoutes.merchantScanAccept);
                              }
                            : null,
                      ),
                      Gap(14.h),
                      NumericKeypad(
                        onKey: _editor.push,
                        onBackspace: _editor.backspace,
                        onBackspaceLongPress: _editor.clear,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
