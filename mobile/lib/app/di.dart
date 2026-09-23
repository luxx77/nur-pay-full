import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/network/api_client.dart';
import '../core/session/pin_storage.dart';
import '../core/session/session_storage.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/wallet/data/datasources/wallet_remote_data_source.dart';
import '../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../features/wallet/domain/repositories/wallet_repository.dart';

/// Сборка зависимостей приложения.
///
/// Всё создаётся один раз в корне и раздаётся через `RepositoryProvider`:
/// экраны получают интерфейсы, а не конкретные реализации.
class Dependencies extends StatelessWidget {
  Dependencies({super.key, required this.child, ApiClient? client})
    : client = client ?? ApiClient(baseUrl: ApiClient.defaultBaseUrl);

  final Widget child;
  final ApiClient client;

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider.value(value: client),
      RepositoryProvider<PinStorage>(create: (_) => const PinStorage()),
      RepositoryProvider<AuthRepository>(
        create: (_) => AuthRepositoryImpl(client, const SessionStorage()),
      ),
      RepositoryProvider<WalletRepository>(
        create: (_) => WalletRepositoryImpl(WalletRemoteDataSource(client)),
      ),
    ],
    child: child,
  );
}
