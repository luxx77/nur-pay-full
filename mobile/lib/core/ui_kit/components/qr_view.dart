import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../foundation/app_radius.dart';

/// Настоящий QR-код с содержимым [data].
///
/// Это не картинка-заглушка: код читается камерой, в том числе нашим же
/// сканером.
class QrView extends StatelessWidget {
  const QrView({
    super.key,
    required this.data,
    this.size,
    this.color,
    this.background,
  });

  final String data;
  final double? size;
  final Color? color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final side = size ?? 212.r;

    return QrImageView(
      data: data,
      size: side,
      padding: EdgeInsets.zero,
      backgroundColor: background ?? Colors.transparent,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
      eyeStyle: QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: color ?? cs.primary,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: color ?? cs.primary,
      ),
    );
  }
}

/// Постоянный QR клиента: код в брендовой рамке с подписью.
class QrBrandCard extends StatelessWidget {
  const QrBrandCard({
    super.key,
    required this.data,
    this.caption = 'NUR PAY QR',
    this.qrSize,
  });

  final String data;
  final String caption;
  final double? qrSize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: AppRadius.xxlAll,
            ),
            child: QrView(data: data, size: qrSize ?? 212.r),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text(
              caption,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onPrimary,
                letterSpacing: 0.1 * 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Одноразовый платёжный QR: белая карточка в брендовой обводке.
class QrOutlinedCard extends StatelessWidget {
  const QrOutlinedCard({
    super.key,
    required this.data,
    this.caption = 'BIR GEZEKLIK NUR PAY QR',
    this.qrSize,
  });

  final String data;
  final String caption;
  final double? qrSize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: cs.primary, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QrView(data: data, size: qrSize ?? 208.r),
          SizedBox(height: 12.h),
          Text(
            caption,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: cs.onPrimaryContainer,
              letterSpacing: 0.1 * 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

/// Маленький значок QR — в шапке, на кнопках и в плавающем действии.
class QrGlyph extends StatelessWidget {
  const QrGlyph({super.key, this.size, this.color});

  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) => Icon(
    Icons.qr_code_2_rounded,
    size: size ?? 20.r,
    color: color ?? Theme.of(context).colorScheme.onSurface,
  );
}
