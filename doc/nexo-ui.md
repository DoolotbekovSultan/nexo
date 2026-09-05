# UI-компоненты

---

## NexoAsyncStateBuilder — маппинг состояния в UI

```dart
NexoAsyncStateBuilder<User>(
  state: context.watch<UserCubit>().state,
  onIdle: () => const SizedBox.shrink(),
  onLoading: () => const CircularProgressIndicator(),
  onSuccess: (user) => UserProfileWidget(user: user),
  onFailure: (failure) => NexoFailureView(
    failure: failure,
    onRetry: () => context.read<UserCubit>().retry(),
  ),
)
```

### По умолчанию

Если `onIdle`, `onLoading`, `onFailure` не заданы:
- **Idle** → пустой `SizedBox`
- **Loading** → `CircularProgressIndicator` (по центру)
- **Failure** → `NexoFailureView` с кнопкой повтора

```dart
NexoAsyncStateBuilder<List<User>>(
  state: cubit.state,
  onSuccess: (users) => UserList(users: users),
)
```

---

## NexoButton — кнопка

```dart
// Filled (по умолчанию)
NexoButton(
  label: 'Сохранить',
  onPressed: () => save(),
)

// Outlined
NexoButton(
  label: 'Отмена',
  variant: NexoButtonVariant.outlined,
  onPressed: () => pop(),
)

// Text
NexoButton(
  label: 'Подробнее',
  variant: NexoButtonVariant.text,
  onPressed: () => openDetails(),
)

// С иконкой
NexoButton(
  label: 'Загрузить',
  icon: Icon(Icons.download),
  onPressed: () => download(),
)

// На всю ширину
NexoButton(
  label: 'Войти',
  expand: true,
  onPressed: () => login(),
)

// Состояние загрузки
NexoButton(
  label: 'Отправить',
  isLoading: isSubmitting,
  onPressed: () => submit(),
)
```

---

## NexoCard — панель

```dart
NexoCard(
  onTap: () => openDetails(),
  padding: EdgeInsets.all(16),
  child: Column(
    children: [
      Text('Заголовок'),
      Text('Описание'),
    ],
  ),
)

// Кастомизация
NexoCard(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  side: BorderSide(color: Colors.grey.shade300),
  elevation: 2,
  child: content,
)
```

---

## NexoEmptyView — экран «нет данных»

```dart
NexoEmptyView(
  title: 'Нет результатов',
  subtitle: 'Попробуйте изменить параметры поиска',
  icon: Icons.search_off,
  actionLabel: 'Сбросить',
  onAction: () => resetFilters(),
)
```

---

## NexoFailureView — экран ошибки

```dart
NexoFailureView(
  failure: failure,
  onRetry: () => load(),
  retryLabel: 'Повторить',
  showTechnicalCode: true, // показать код ошибки
)

// Кастомная иконка
NexoFailureView(
  failure: failure,
  onRetry: () => load(),
  icon: Icons.wifi_off,
)
```

---

## showFailureSnackBar — снекбар с ошибкой

```dart
showFailureSnackBar(context, failure);

// С кнопкой действия
showFailureSnackBar(
  context,
  failure,
  actionLabel: 'Повторить',
  onAction: () => retry(),
  floating: true, // плавающий (Material 3)
);
```

---

## showFailureDialog — диалог с ошибкой

```dart
await showFailureDialog(context, failure);

// С кнопкой повтора
await showFailureDialog(
  context,
  failure,
  onRetry: () => retry(),
  retryLabel: 'Повторить',
  dismissLabel: 'Закрыть',
);
```

---

## NexoSkeletonLoader — плейсхолдер загрузки

```dart
// Один скелетон
NexoSkeletonLoader(
  width: double.infinity,
  height: 20,
  borderRadius: BorderRadius.circular(4),
)

// Список скелетонов
NexoSkeletonList(
  itemCount: 5,
  itemHeight: 60,
  spacing: 8,
  padding: EdgeInsets.all(16),
)
```

---

## Геометрические спейсеры

```dart
// Вертикальный отступ
16.gapH  // SizedBox(height: 16)
8.gapH   // SizedBox(height: 8)

// Горизонтальный отступ
16.gapW  // SizedBox(width: 16)
8.gapW   // SizedBox(width: 8)
```

---

## Цепочки обёрток виджетов

```dart
// Цепочка вызовов вместо вложенности
Text('Привет')
    .pad(all: 16)
    .center()
    .expanded()
    .opacity(0.8)
    .safeArea();

// Доступные методы:
widget.pad(all: 16)
widget.padSymmetric(horizontal: 16, vertical: 8)
widget.padOnly(left: 16, top: 8)
widget.center()
widget.align(Alignment.topRight)
widget.expanded()
widget.flexible()
widget.sized(width: 100, height: 50)
widget.aspectRatio(16 / 9)
widget.opacity(0.5)
widget.safeArea()
widget.clipRRect(borderRadius: BorderRadius.circular(8))
widget.decorated(BoxDecoration(color: Colors.white))
widget.onTap(() => print('tapped'))
```

---

## Текстовый враппер

```dart
// Быстрое создание Text
'Привет, мир!'.text(
  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  textAlign: TextAlign.center,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)
```
