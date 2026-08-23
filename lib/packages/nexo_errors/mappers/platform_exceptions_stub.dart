/// Web stub: none of the `dart:io` exception types can occur in browsers,
/// so every probe reports "not matched".
bool isSocketException(Object? error) => false;

String? socketMessage(Object? error) => null;

bool isHandshakeException(Object? error) => false;

bool isTlsException(Object? error) => false;

bool isHttpException(Object? error) => false;

String? httpMessage(Object? error) => null;

bool isFileSystemException(Object? error) => false;

bool isPathNotFoundException(Object? error) => false;

({String? path, String message})? fileSystemDetails(Object? error) => null;
