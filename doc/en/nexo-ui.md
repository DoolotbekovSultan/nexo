# UI Components

---

## NexoAsyncStateBuilder — mapping state to UI

```dart
NexoAsyncStateBuilder<User>(
  state: context.watch<UserCubit>().state,
  success: (_, user) => UserProfileWidget(user: user),
  idle: () => const SizedBox.shrink(),
  loading: () => const CircularProgressIndicator(),
  failure: (_, failure) => NexoFailureView(
    failure: failure,
    onRetry: () => context.read<UserCubit>().retry(),
  ),
)
```

### Defaults

Only `success` is required. When `idle`, `loading`, or `failure` are omitted:
- **Idle** — empty `SizedBox`
- **Loading** — centered `CircularProgressIndicator`
- **Failure** — `NexoFailureView` with the failure

```dart
NexoAsyncStateBuilder<List<User>>(
  state: cubit.state,
  success: (_, users) => UserList(users: users),
)
```

---

## NexoButton — button

```dart
// Filled (default)
NexoButton(
  label: 'Save',
  onPressed: () => save(),
)

// Outlined
NexoButton(
  label: 'Cancel',
  variant: NexoButtonVariant.outlined,
  onPressed: () => pop(),
)

// Text
NexoButton(
  label: 'Details',
  variant: NexoButtonVariant.text,
  onPressed: () => openDetails(),
)

// With icon
NexoButton(
  label: 'Download',
  icon: Icon(Icons.download),
  onPressed: () => download(),
)

// Full width
NexoButton(
  label: 'Sign in',
  expand: true,
  onPressed: () => login(),
)

// Loading state
NexoButton(
  label: 'Submit',
  isLoading: isSubmitting,
  onPressed: () => submit(),
)
```

---

## NexoCard — panel

```dart
NexoCard(
  onTap: () => openDetails(),
  padding: EdgeInsets.all(16),
  child: Column(
    children: [
      Text('Title'),
      Text('Description'),
    ],
  ),
)

// Customization
NexoCard(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  side: BorderSide(color: Colors.grey.shade300),
  elevation: 2,
  child: content,
)
```

---

## NexoEmptyView — empty state screen

```dart
NexoEmptyView(
  title: 'No results',
  subtitle: 'Try changing your search criteria',
  icon: Icons.search_off,
  actionLabel: 'Reset',
  onAction: () => resetFilters(),
)
```

---

## NexoFailureView — error screen

```dart
NexoFailureView(
  failure: failure,
  onRetry: () => load(),
  retryLabel: 'Retry',
  showTechnicalCode: true, // show error code
)

// Custom icon
NexoFailureView(
  failure: failure,
  onRetry: () => load(),
  icon: Icons.wifi_off,
)
```

---

## showFailureSnackBar — error snackbar

```dart
showFailureSnackBar(context, failure);

// With action button
showFailureSnackBar(
  context,
  failure,
  actionLabel: 'Retry',
  onAction: () => retry(),
  floating: true, // floating (Material 3)
);
```

---

## showFailureDialog — error dialog

```dart
await showFailureDialog(context, failure);

// With retry button
await showFailureDialog(
  context,
  failure,
  onRetry: () => retry(),
  retryLabel: 'Retry',
  dismissLabel: 'Close',
);
```

---

## NexoSkeletonLoader — loading placeholder

```dart
// Single skeleton
NexoSkeletonLoader(
  width: double.infinity,
  height: 20,
  borderRadius: 8,
)

// Skeleton list
NexoSkeletonList(
  itemCount: 5,
  itemHeight: 64,
  spacing: 12,
  padding: EdgeInsets.all(16),
)
```

---

## Geometric spacers

```dart
// Vertical spacer
16.gapH  // SizedBox(height: 16)
8.gapH   // SizedBox(height: 8)

// Horizontal spacer
16.gapW  // SizedBox(width: 16)
8.gapW   // SizedBox(width: 8)
```

---

## Widget chain wrappers

```dart
// Chain calls instead of nesting
Text('Hello')
    .pad(16)
    .center()
    .expanded()
    .opacity(0.8)
    .safeArea();

// Available methods:
widget.pad(16)
widget.padSymmetric(horizontal: 16, vertical: 8)
widget.padOnly(left: 16, top: 8)
widget.center()
widget.align(Alignment.topRight)
widget.expanded(flex: 1)
widget.flexible(flex: 1, fit: FlexFit.loose)
widget.sized(width: 100, height: 50)
widget.aspectRatio(16 / 9)
widget.opacity(0.5)
widget.safeArea(top: true, bottom: true, left: true, right: true)
widget.clipRRect(radius: 8)
widget.decorated(BoxDecoration(color: Colors.white))
widget.onTap(() => print('tapped'))
```

---

## Text wrapper

```dart
// Quick Text creation
'Hello, world!'.text(
  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  textAlign: TextAlign.center,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)
```
