import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/connectivity/connectivity_cubit.dart';
import '../core/network/api_client.dart';
import '../core/network/network_error_toast.dart';
import '../core/session/pin_storage.dart';
import '../core/theme/theme.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/bloc/session_cubit.dart';
import '../features/merchant/presentation/bloc/merchant_payment_cubit.dart';
import '../features/pay/presentation/bloc/payment_qr_cubit.dart';
import '../features/topup/presentation/bloc/activation_cubit.dart';
import '../features/transfer/presentation/bloc/transfer_cubit.dart';
import '../features/wallet/domain/repositories/wallet_repository.dart';
import '../features/wallet/presentation/bloc/wallet_cubit.dart';
import 'di.dart';
import 'router/app_router.dart';

/// Корневой виджет Nur Pay.
class NurPayApp extends StatelessWidget {
  const NurPayApp({super.key, this.client});

  /// Подменяется в отладке, чтобы смотреть на другой бэкенд.
  final ApiClient? client;

  @override
  Widget build(BuildContext context) =>
      Dependencies(client: client, child: const _AppScope());
}

class _AppScope extends StatelessWidget {
  const _AppScope();

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => ConnectivityCubit()),
      BlocProvider(
        // Сессия читается с устройства сразу: пока её нет, показываем
        // заставку, а не мигаем экраном входа.
        create: (context) => SessionCubit(
          context.read<AuthRepository>(),
          context.read<PinStorage>(),
        )..restore(),
      ),
      BlocProvider(
        create: (context) => WalletCubit(context.read<WalletRepository>()),
      ),
      BlocProvider(
        create: (context) => TransferCubit(context.read<WalletRepository>()),
      ),
      BlocProvider(
        create: (context) =>
            MerchantPaymentCubit(context.read<WalletRepository>()),
      ),
      BlocProvider(
        create: (context) => ActivationCubit(context.read<WalletRepository>()),
      ),
      BlocProvider(create: (_) => PaymentQrCubit()),
    ],
    child: const _AppRouterHost(),
  );
}

class _AppRouterHost extends StatefulWidget {
  const _AppRouterHost();

  @override
  State<_AppRouterHost> createState() => _AppRouterHostState();
}

class _AppRouterHostState extends State<_AppRouterHost> {
  late final _router = AppRouter.create(context.read<SessionCubit>());

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
    designSize: AppTheme.designSize,
    minTextAdapt: true,
    builder: (_, _) => MaterialApp.router(
      title: 'Nur Pay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(AppRole.customer),
      darkTheme: AppTheme.dark(AppRole.customer),
      themeMode: ThemeMode.light,
      routerConfig: _router,
      builder: (context, child) => NetworkErrorToast(child: child!),
    ),
  );
}
