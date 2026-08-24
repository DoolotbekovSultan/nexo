import 'package:flutter/material.dart';
import 'package:nexo/nexo.dart';

enum _NetworkMode { ok, empty, offline }

class _ItemsCubit extends NexoAsyncCubit<List<String>> {
  _ItemsCubit();

  var mode = _NetworkMode.ok;

  @override
  Future<Result<List<String>>> fetch() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return switch (mode) {
      _NetworkMode.offline => const Left(
        Failure.network(type: NetworkFailure.timeout),
      ),
      _NetworkMode.empty => const Right(<String>[]),
      _NetworkMode.ok => const Right(['Пункт 1', 'Пункт 2', 'Пункт 3']),
    };
  }
}

class AsyncDemoPage extends StatefulWidget {
  const AsyncDemoPage({super.key});

  @override
  State<AsyncDemoPage> createState() => _AsyncDemoPageState();
}

class _AsyncDemoPageState extends State<AsyncDemoPage> {
  late final _cubit = _ItemsCubit();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _cubit,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<_NetworkMode>(
              segments: const [
                ButtonSegment(value: _NetworkMode.ok, label: Text('Данные')),
                ButtonSegment(value: _NetworkMode.empty, label: Text('Пусто')),
                ButtonSegment(
                  value: _NetworkMode.offline,
                  label: Text('Нет сети'),
                ),
              ],
              selected: {_cubit.mode},
              onSelectionChanged: (selection) =>
                  setState(() => _cubit.mode = selection.first),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: () => _cubit.load(),
                child: const Text('load()'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => _cubit.refresh(),
                child: const Text('refresh()'),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: BlocBuilder<_ItemsCubit, NexoAsyncState<List<String>>>(
              builder: (context, state) {
                return NexoAsyncStateBuilder<List<String>>(
                  state: state,
                  loading: (_) => const NexoSkeletonList(itemCount: 4),
                  success: (_, items) => items.isEmpty
                      ? NexoEmptyView(
                          title: 'Пока ничего нет',
                          subtitle: 'Переключите режим на «Данные» и повторите',
                          actionLabel: 'load()',
                          onAction: () => _cubit.load(),
                        )
                      : ListView(
                          children: [
                            for (final item in items)
                              ListTile(title: Text(item)),
                          ],
                        ),
                  failure: (_, failure) => NexoFailureView(
                    failure: failure,
                    showTechnicalCode: true,
                    onRetry: () => _cubit.retry(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
