import 'package:flutter/material.dart';
import 'package:nexo/nexo.dart';

class FeedbackDemoPage extends StatelessWidget {
  const FeedbackDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    const noInternet = Failure.network(type: NetworkFailure.noInternet);
    const serverError = Failure.http(type: HttpFailure.internalServerError);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Snackbar / диалоги',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed: () => showFailureSnackBar(context, noInternet),
              child: const Text('SnackBar'),
            ),
            OutlinedButton(
              onPressed: () => showFailureSnackBar(
                context,
                serverError,
                actionLabel: 'Повторить',
                onAction: () {},
              ),
              child: const Text('SnackBar + action'),
            ),
            OutlinedButton(
              onPressed: () => showFailureDialog(context, noInternet),
              child: const Text('Диалог'),
            ),
            OutlinedButton(
              onPressed: () =>
                  showFailureDialog(context, serverError, onRetry: () {}),
              child: const Text('Диалог + retry'),
            ),
          ],
        ),
        const Divider(height: 32),
        Text(
          'Локализация ошибок',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text('RU: ${noInternet.userMessage}'),
        Text(
          'EN: ${noInternet.localizedMessage(const EnFailureUserMessages())}',
        ),
        Text('Код: ${noInternet.code} · retryable: ${noInternet.isRetryable}'),
        const Divider(height: 32),
        Text(
          'Заглушки состояний',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        const NexoSkeletonLoader(width: 220),
        const SizedBox(height: 8),
        const NexoSkeletonList(itemCount: 2),
        NexoEmptyView(
          title: 'Пример пустого состояния',
          subtitle: 'NexoEmptyView с действием',
          actionLabel: 'Действие',
          onAction: () {},
        ),
      ],
    );
  }
}
