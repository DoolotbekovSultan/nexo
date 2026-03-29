// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Failure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Failure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Failure()';
}


}

/// @nodoc
class $FailureCopyWith<$Res>  {
$FailureCopyWith(Failure _, $Res Function(Failure) __);
}


/// Adds pattern-matching-related methods to [Failure].
extension FailurePatterns on Failure {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NetworkAppFailure value)?  network,TResult Function( HttpAppFailure value)?  http,TResult Function( AuthAppFailure value)?  auth,TResult Function( ValidationAppFailure value)?  validation,TResult Function( StorageAppFailure value)?  storage,TResult Function( DatabaseAppFailure value)?  database,TResult Function( CacheAppFailure value)?  cache,TResult Function( ParseAppFailure value)?  parse,TResult Function( PermissionAppFailure value)?  permission,TResult Function( PlatformAppFailure value)?  platform,TResult Function( FileAppFailure value)?  file,TResult Function( LocationAppFailure value)?  location,TResult Function( NotificationAppFailure value)?  notification,TResult Function( PaymentAppFailure value)?  payment,TResult Function( SyncAppFailure value)?  sync,TResult Function( UnknownAppFailure value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NetworkAppFailure() when network != null:
return network(_that);case HttpAppFailure() when http != null:
return http(_that);case AuthAppFailure() when auth != null:
return auth(_that);case ValidationAppFailure() when validation != null:
return validation(_that);case StorageAppFailure() when storage != null:
return storage(_that);case DatabaseAppFailure() when database != null:
return database(_that);case CacheAppFailure() when cache != null:
return cache(_that);case ParseAppFailure() when parse != null:
return parse(_that);case PermissionAppFailure() when permission != null:
return permission(_that);case PlatformAppFailure() when platform != null:
return platform(_that);case FileAppFailure() when file != null:
return file(_that);case LocationAppFailure() when location != null:
return location(_that);case NotificationAppFailure() when notification != null:
return notification(_that);case PaymentAppFailure() when payment != null:
return payment(_that);case SyncAppFailure() when sync != null:
return sync(_that);case UnknownAppFailure() when unknown != null:
return unknown(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NetworkAppFailure value)  network,required TResult Function( HttpAppFailure value)  http,required TResult Function( AuthAppFailure value)  auth,required TResult Function( ValidationAppFailure value)  validation,required TResult Function( StorageAppFailure value)  storage,required TResult Function( DatabaseAppFailure value)  database,required TResult Function( CacheAppFailure value)  cache,required TResult Function( ParseAppFailure value)  parse,required TResult Function( PermissionAppFailure value)  permission,required TResult Function( PlatformAppFailure value)  platform,required TResult Function( FileAppFailure value)  file,required TResult Function( LocationAppFailure value)  location,required TResult Function( NotificationAppFailure value)  notification,required TResult Function( PaymentAppFailure value)  payment,required TResult Function( SyncAppFailure value)  sync,required TResult Function( UnknownAppFailure value)  unknown,}){
final _that = this;
switch (_that) {
case NetworkAppFailure():
return network(_that);case HttpAppFailure():
return http(_that);case AuthAppFailure():
return auth(_that);case ValidationAppFailure():
return validation(_that);case StorageAppFailure():
return storage(_that);case DatabaseAppFailure():
return database(_that);case CacheAppFailure():
return cache(_that);case ParseAppFailure():
return parse(_that);case PermissionAppFailure():
return permission(_that);case PlatformAppFailure():
return platform(_that);case FileAppFailure():
return file(_that);case LocationAppFailure():
return location(_that);case NotificationAppFailure():
return notification(_that);case PaymentAppFailure():
return payment(_that);case SyncAppFailure():
return sync(_that);case UnknownAppFailure():
return unknown(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NetworkAppFailure value)?  network,TResult? Function( HttpAppFailure value)?  http,TResult? Function( AuthAppFailure value)?  auth,TResult? Function( ValidationAppFailure value)?  validation,TResult? Function( StorageAppFailure value)?  storage,TResult? Function( DatabaseAppFailure value)?  database,TResult? Function( CacheAppFailure value)?  cache,TResult? Function( ParseAppFailure value)?  parse,TResult? Function( PermissionAppFailure value)?  permission,TResult? Function( PlatformAppFailure value)?  platform,TResult? Function( FileAppFailure value)?  file,TResult? Function( LocationAppFailure value)?  location,TResult? Function( NotificationAppFailure value)?  notification,TResult? Function( PaymentAppFailure value)?  payment,TResult? Function( SyncAppFailure value)?  sync,TResult? Function( UnknownAppFailure value)?  unknown,}){
final _that = this;
switch (_that) {
case NetworkAppFailure() when network != null:
return network(_that);case HttpAppFailure() when http != null:
return http(_that);case AuthAppFailure() when auth != null:
return auth(_that);case ValidationAppFailure() when validation != null:
return validation(_that);case StorageAppFailure() when storage != null:
return storage(_that);case DatabaseAppFailure() when database != null:
return database(_that);case CacheAppFailure() when cache != null:
return cache(_that);case ParseAppFailure() when parse != null:
return parse(_that);case PermissionAppFailure() when permission != null:
return permission(_that);case PlatformAppFailure() when platform != null:
return platform(_that);case FileAppFailure() when file != null:
return file(_that);case LocationAppFailure() when location != null:
return location(_that);case NotificationAppFailure() when notification != null:
return notification(_that);case PaymentAppFailure() when payment != null:
return payment(_that);case SyncAppFailure() when sync != null:
return sync(_that);case UnknownAppFailure() when unknown != null:
return unknown(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( NetworkFailure type)?  network,TResult Function( HttpFailure type,  int? statusCode,  String? message,  Map<String, List<String>> fieldErrors)?  http,TResult Function( AuthFailure type,  String? message)?  auth,TResult Function( ValidationFailure type,  String? field,  String? message,  Map<String, List<String>> fieldErrors)?  validation,TResult Function( StorageFailure type,  String? key,  String? message)?  storage,TResult Function( DatabaseFailure type,  String? message)?  database,TResult Function( CacheFailure type,  String? key)?  cache,TResult Function( ParseFailure type,  String? field,  String? message)?  parse,TResult Function( PermissionFailure type,  String? permission)?  permission,TResult Function( PlatformFailure type,  String? details)?  platform,TResult Function( FileFailure type,  String? path,  String? message)?  file,TResult Function( LocationFailure type,  String? message)?  location,TResult Function( NotificationFailure type,  String? message)?  notification,TResult Function( PaymentFailure type,  String? message,  String? transactionId)?  payment,TResult Function( SyncFailure type,  String? message)?  sync,TResult Function( Object? error,  StackTrace? stackTrace,  String? message)?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NetworkAppFailure() when network != null:
return network(_that.type);case HttpAppFailure() when http != null:
return http(_that.type,_that.statusCode,_that.message,_that.fieldErrors);case AuthAppFailure() when auth != null:
return auth(_that.type,_that.message);case ValidationAppFailure() when validation != null:
return validation(_that.type,_that.field,_that.message,_that.fieldErrors);case StorageAppFailure() when storage != null:
return storage(_that.type,_that.key,_that.message);case DatabaseAppFailure() when database != null:
return database(_that.type,_that.message);case CacheAppFailure() when cache != null:
return cache(_that.type,_that.key);case ParseAppFailure() when parse != null:
return parse(_that.type,_that.field,_that.message);case PermissionAppFailure() when permission != null:
return permission(_that.type,_that.permission);case PlatformAppFailure() when platform != null:
return platform(_that.type,_that.details);case FileAppFailure() when file != null:
return file(_that.type,_that.path,_that.message);case LocationAppFailure() when location != null:
return location(_that.type,_that.message);case NotificationAppFailure() when notification != null:
return notification(_that.type,_that.message);case PaymentAppFailure() when payment != null:
return payment(_that.type,_that.message,_that.transactionId);case SyncAppFailure() when sync != null:
return sync(_that.type,_that.message);case UnknownAppFailure() when unknown != null:
return unknown(_that.error,_that.stackTrace,_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( NetworkFailure type)  network,required TResult Function( HttpFailure type,  int? statusCode,  String? message,  Map<String, List<String>> fieldErrors)  http,required TResult Function( AuthFailure type,  String? message)  auth,required TResult Function( ValidationFailure type,  String? field,  String? message,  Map<String, List<String>> fieldErrors)  validation,required TResult Function( StorageFailure type,  String? key,  String? message)  storage,required TResult Function( DatabaseFailure type,  String? message)  database,required TResult Function( CacheFailure type,  String? key)  cache,required TResult Function( ParseFailure type,  String? field,  String? message)  parse,required TResult Function( PermissionFailure type,  String? permission)  permission,required TResult Function( PlatformFailure type,  String? details)  platform,required TResult Function( FileFailure type,  String? path,  String? message)  file,required TResult Function( LocationFailure type,  String? message)  location,required TResult Function( NotificationFailure type,  String? message)  notification,required TResult Function( PaymentFailure type,  String? message,  String? transactionId)  payment,required TResult Function( SyncFailure type,  String? message)  sync,required TResult Function( Object? error,  StackTrace? stackTrace,  String? message)  unknown,}) {final _that = this;
switch (_that) {
case NetworkAppFailure():
return network(_that.type);case HttpAppFailure():
return http(_that.type,_that.statusCode,_that.message,_that.fieldErrors);case AuthAppFailure():
return auth(_that.type,_that.message);case ValidationAppFailure():
return validation(_that.type,_that.field,_that.message,_that.fieldErrors);case StorageAppFailure():
return storage(_that.type,_that.key,_that.message);case DatabaseAppFailure():
return database(_that.type,_that.message);case CacheAppFailure():
return cache(_that.type,_that.key);case ParseAppFailure():
return parse(_that.type,_that.field,_that.message);case PermissionAppFailure():
return permission(_that.type,_that.permission);case PlatformAppFailure():
return platform(_that.type,_that.details);case FileAppFailure():
return file(_that.type,_that.path,_that.message);case LocationAppFailure():
return location(_that.type,_that.message);case NotificationAppFailure():
return notification(_that.type,_that.message);case PaymentAppFailure():
return payment(_that.type,_that.message,_that.transactionId);case SyncAppFailure():
return sync(_that.type,_that.message);case UnknownAppFailure():
return unknown(_that.error,_that.stackTrace,_that.message);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( NetworkFailure type)?  network,TResult? Function( HttpFailure type,  int? statusCode,  String? message,  Map<String, List<String>> fieldErrors)?  http,TResult? Function( AuthFailure type,  String? message)?  auth,TResult? Function( ValidationFailure type,  String? field,  String? message,  Map<String, List<String>> fieldErrors)?  validation,TResult? Function( StorageFailure type,  String? key,  String? message)?  storage,TResult? Function( DatabaseFailure type,  String? message)?  database,TResult? Function( CacheFailure type,  String? key)?  cache,TResult? Function( ParseFailure type,  String? field,  String? message)?  parse,TResult? Function( PermissionFailure type,  String? permission)?  permission,TResult? Function( PlatformFailure type,  String? details)?  platform,TResult? Function( FileFailure type,  String? path,  String? message)?  file,TResult? Function( LocationFailure type,  String? message)?  location,TResult? Function( NotificationFailure type,  String? message)?  notification,TResult? Function( PaymentFailure type,  String? message,  String? transactionId)?  payment,TResult? Function( SyncFailure type,  String? message)?  sync,TResult? Function( Object? error,  StackTrace? stackTrace,  String? message)?  unknown,}) {final _that = this;
switch (_that) {
case NetworkAppFailure() when network != null:
return network(_that.type);case HttpAppFailure() when http != null:
return http(_that.type,_that.statusCode,_that.message,_that.fieldErrors);case AuthAppFailure() when auth != null:
return auth(_that.type,_that.message);case ValidationAppFailure() when validation != null:
return validation(_that.type,_that.field,_that.message,_that.fieldErrors);case StorageAppFailure() when storage != null:
return storage(_that.type,_that.key,_that.message);case DatabaseAppFailure() when database != null:
return database(_that.type,_that.message);case CacheAppFailure() when cache != null:
return cache(_that.type,_that.key);case ParseAppFailure() when parse != null:
return parse(_that.type,_that.field,_that.message);case PermissionAppFailure() when permission != null:
return permission(_that.type,_that.permission);case PlatformAppFailure() when platform != null:
return platform(_that.type,_that.details);case FileAppFailure() when file != null:
return file(_that.type,_that.path,_that.message);case LocationAppFailure() when location != null:
return location(_that.type,_that.message);case NotificationAppFailure() when notification != null:
return notification(_that.type,_that.message);case PaymentAppFailure() when payment != null:
return payment(_that.type,_that.message,_that.transactionId);case SyncAppFailure() when sync != null:
return sync(_that.type,_that.message);case UnknownAppFailure() when unknown != null:
return unknown(_that.error,_that.stackTrace,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class NetworkAppFailure extends Failure {
  const NetworkAppFailure({required this.type}): super._();
  

 final  NetworkFailure type;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkAppFailureCopyWith<NetworkAppFailure> get copyWith => _$NetworkAppFailureCopyWithImpl<NetworkAppFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkAppFailure&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,type);

@override
String toString() {
  return 'Failure.network(type: $type)';
}


}

/// @nodoc
abstract mixin class $NetworkAppFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $NetworkAppFailureCopyWith(NetworkAppFailure value, $Res Function(NetworkAppFailure) _then) = _$NetworkAppFailureCopyWithImpl;
@useResult
$Res call({
 NetworkFailure type
});




}
/// @nodoc
class _$NetworkAppFailureCopyWithImpl<$Res>
    implements $NetworkAppFailureCopyWith<$Res> {
  _$NetworkAppFailureCopyWithImpl(this._self, this._then);

  final NetworkAppFailure _self;
  final $Res Function(NetworkAppFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? type = null,}) {
  return _then(NetworkAppFailure(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NetworkFailure,
  ));
}


}

/// @nodoc


class HttpAppFailure extends Failure {
  const HttpAppFailure({required this.type, this.statusCode, this.message, final  Map<String, List<String>> fieldErrors = const {}}): _fieldErrors = fieldErrors,super._();
  

 final  HttpFailure type;
 final  int? statusCode;
 final  String? message;
 final  Map<String, List<String>> _fieldErrors;
@JsonKey() Map<String, List<String>> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}


/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HttpAppFailureCopyWith<HttpAppFailure> get copyWith => _$HttpAppFailureCopyWithImpl<HttpAppFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HttpAppFailure&&(identical(other.type, type) || other.type == type)&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other._fieldErrors, _fieldErrors));
}


@override
int get hashCode => Object.hash(runtimeType,type,statusCode,message,const DeepCollectionEquality().hash(_fieldErrors));

@override
String toString() {
  return 'Failure.http(type: $type, statusCode: $statusCode, message: $message, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class $HttpAppFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $HttpAppFailureCopyWith(HttpAppFailure value, $Res Function(HttpAppFailure) _then) = _$HttpAppFailureCopyWithImpl;
@useResult
$Res call({
 HttpFailure type, int? statusCode, String? message, Map<String, List<String>> fieldErrors
});




}
/// @nodoc
class _$HttpAppFailureCopyWithImpl<$Res>
    implements $HttpAppFailureCopyWith<$Res> {
  _$HttpAppFailureCopyWithImpl(this._self, this._then);

  final HttpAppFailure _self;
  final $Res Function(HttpAppFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? type = null,Object? statusCode = freezed,Object? message = freezed,Object? fieldErrors = null,}) {
  return _then(HttpAppFailure(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as HttpFailure,statusCode: freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,
  ));
}


}

/// @nodoc


class AuthAppFailure extends Failure {
  const AuthAppFailure({required this.type, this.message}): super._();
  

 final  AuthFailure type;
 final  String? message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthAppFailureCopyWith<AuthAppFailure> get copyWith => _$AuthAppFailureCopyWithImpl<AuthAppFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthAppFailure&&(identical(other.type, type) || other.type == type)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,type,message);

@override
String toString() {
  return 'Failure.auth(type: $type, message: $message)';
}


}

/// @nodoc
abstract mixin class $AuthAppFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $AuthAppFailureCopyWith(AuthAppFailure value, $Res Function(AuthAppFailure) _then) = _$AuthAppFailureCopyWithImpl;
@useResult
$Res call({
 AuthFailure type, String? message
});




}
/// @nodoc
class _$AuthAppFailureCopyWithImpl<$Res>
    implements $AuthAppFailureCopyWith<$Res> {
  _$AuthAppFailureCopyWithImpl(this._self, this._then);

  final AuthAppFailure _self;
  final $Res Function(AuthAppFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? type = null,Object? message = freezed,}) {
  return _then(AuthAppFailure(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AuthFailure,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class ValidationAppFailure extends Failure {
  const ValidationAppFailure({required this.type, this.field, this.message, final  Map<String, List<String>> fieldErrors = const {}}): _fieldErrors = fieldErrors,super._();
  

 final  ValidationFailure type;
 final  String? field;
 final  String? message;
 final  Map<String, List<String>> _fieldErrors;
@JsonKey() Map<String, List<String>> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}


/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidationAppFailureCopyWith<ValidationAppFailure> get copyWith => _$ValidationAppFailureCopyWithImpl<ValidationAppFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidationAppFailure&&(identical(other.type, type) || other.type == type)&&(identical(other.field, field) || other.field == field)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other._fieldErrors, _fieldErrors));
}


@override
int get hashCode => Object.hash(runtimeType,type,field,message,const DeepCollectionEquality().hash(_fieldErrors));

@override
String toString() {
  return 'Failure.validation(type: $type, field: $field, message: $message, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class $ValidationAppFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $ValidationAppFailureCopyWith(ValidationAppFailure value, $Res Function(ValidationAppFailure) _then) = _$ValidationAppFailureCopyWithImpl;
@useResult
$Res call({
 ValidationFailure type, String? field, String? message, Map<String, List<String>> fieldErrors
});




}
/// @nodoc
class _$ValidationAppFailureCopyWithImpl<$Res>
    implements $ValidationAppFailureCopyWith<$Res> {
  _$ValidationAppFailureCopyWithImpl(this._self, this._then);

  final ValidationAppFailure _self;
  final $Res Function(ValidationAppFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? type = null,Object? field = freezed,Object? message = freezed,Object? fieldErrors = null,}) {
  return _then(ValidationAppFailure(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ValidationFailure,field: freezed == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,
  ));
}


}

/// @nodoc


class StorageAppFailure extends Failure {
  const StorageAppFailure({required this.type, this.key, this.message}): super._();
  

 final  StorageFailure type;
 final  String? key;
 final  String? message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StorageAppFailureCopyWith<StorageAppFailure> get copyWith => _$StorageAppFailureCopyWithImpl<StorageAppFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StorageAppFailure&&(identical(other.type, type) || other.type == type)&&(identical(other.key, key) || other.key == key)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,type,key,message);

@override
String toString() {
  return 'Failure.storage(type: $type, key: $key, message: $message)';
}


}

/// @nodoc
abstract mixin class $StorageAppFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $StorageAppFailureCopyWith(StorageAppFailure value, $Res Function(StorageAppFailure) _then) = _$StorageAppFailureCopyWithImpl;
@useResult
$Res call({
 StorageFailure type, String? key, String? message
});




}
/// @nodoc
class _$StorageAppFailureCopyWithImpl<$Res>
    implements $StorageAppFailureCopyWith<$Res> {
  _$StorageAppFailureCopyWithImpl(this._self, this._then);

  final StorageAppFailure _self;
  final $Res Function(StorageAppFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? type = null,Object? key = freezed,Object? message = freezed,}) {
  return _then(StorageAppFailure(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as StorageFailure,key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class DatabaseAppFailure extends Failure {
  const DatabaseAppFailure({required this.type, this.message}): super._();
  

 final  DatabaseFailure type;
 final  String? message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DatabaseAppFailureCopyWith<DatabaseAppFailure> get copyWith => _$DatabaseAppFailureCopyWithImpl<DatabaseAppFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DatabaseAppFailure&&(identical(other.type, type) || other.type == type)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,type,message);

@override
String toString() {
  return 'Failure.database(type: $type, message: $message)';
}


}

/// @nodoc
abstract mixin class $DatabaseAppFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $DatabaseAppFailureCopyWith(DatabaseAppFailure value, $Res Function(DatabaseAppFailure) _then) = _$DatabaseAppFailureCopyWithImpl;
@useResult
$Res call({
 DatabaseFailure type, String? message
});




}
/// @nodoc
class _$DatabaseAppFailureCopyWithImpl<$Res>
    implements $DatabaseAppFailureCopyWith<$Res> {
  _$DatabaseAppFailureCopyWithImpl(this._self, this._then);

  final DatabaseAppFailure _self;
  final $Res Function(DatabaseAppFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? type = null,Object? message = freezed,}) {
  return _then(DatabaseAppFailure(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DatabaseFailure,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class CacheAppFailure extends Failure {
  const CacheAppFailure({required this.type, this.key}): super._();
  

 final  CacheFailure type;
 final  String? key;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CacheAppFailureCopyWith<CacheAppFailure> get copyWith => _$CacheAppFailureCopyWithImpl<CacheAppFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CacheAppFailure&&(identical(other.type, type) || other.type == type)&&(identical(other.key, key) || other.key == key));
}


@override
int get hashCode => Object.hash(runtimeType,type,key);

@override
String toString() {
  return 'Failure.cache(type: $type, key: $key)';
}


}

/// @nodoc
abstract mixin class $CacheAppFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $CacheAppFailureCopyWith(CacheAppFailure value, $Res Function(CacheAppFailure) _then) = _$CacheAppFailureCopyWithImpl;
@useResult
$Res call({
 CacheFailure type, String? key
});




}
/// @nodoc
class _$CacheAppFailureCopyWithImpl<$Res>
    implements $CacheAppFailureCopyWith<$Res> {
  _$CacheAppFailureCopyWithImpl(this._self, this._then);

  final CacheAppFailure _self;
  final $Res Function(CacheAppFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? type = null,Object? key = freezed,}) {
  return _then(CacheAppFailure(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CacheFailure,key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class ParseAppFailure extends Failure {
  const ParseAppFailure({required this.type, this.field, this.message}): super._();
  

 final  ParseFailure type;
 final  String? field;
 final  String? message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParseAppFailureCopyWith<ParseAppFailure> get copyWith => _$ParseAppFailureCopyWithImpl<ParseAppFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParseAppFailure&&(identical(other.type, type) || other.type == type)&&(identical(other.field, field) || other.field == field)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,type,field,message);

@override
String toString() {
  return 'Failure.parse(type: $type, field: $field, message: $message)';
}


}

/// @nodoc
abstract mixin class $ParseAppFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $ParseAppFailureCopyWith(ParseAppFailure value, $Res Function(ParseAppFailure) _then) = _$ParseAppFailureCopyWithImpl;
@useResult
$Res call({
 ParseFailure type, String? field, String? message
});




}
/// @nodoc
class _$ParseAppFailureCopyWithImpl<$Res>
    implements $ParseAppFailureCopyWith<$Res> {
  _$ParseAppFailureCopyWithImpl(this._self, this._then);

  final ParseAppFailure _self;
  final $Res Function(ParseAppFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? type = null,Object? field = freezed,Object? message = freezed,}) {
  return _then(ParseAppFailure(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ParseFailure,field: freezed == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class PermissionAppFailure extends Failure {
  const PermissionAppFailure({required this.type, this.permission}): super._();
  

 final  PermissionFailure type;
 final  String? permission;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PermissionAppFailureCopyWith<PermissionAppFailure> get copyWith => _$PermissionAppFailureCopyWithImpl<PermissionAppFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PermissionAppFailure&&(identical(other.type, type) || other.type == type)&&(identical(other.permission, permission) || other.permission == permission));
}


@override
int get hashCode => Object.hash(runtimeType,type,permission);

@override
String toString() {
  return 'Failure.permission(type: $type, permission: $permission)';
}


}

/// @nodoc
abstract mixin class $PermissionAppFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $PermissionAppFailureCopyWith(PermissionAppFailure value, $Res Function(PermissionAppFailure) _then) = _$PermissionAppFailureCopyWithImpl;
@useResult
$Res call({
 PermissionFailure type, String? permission
});




}
/// @nodoc
class _$PermissionAppFailureCopyWithImpl<$Res>
    implements $PermissionAppFailureCopyWith<$Res> {
  _$PermissionAppFailureCopyWithImpl(this._self, this._then);

  final PermissionAppFailure _self;
  final $Res Function(PermissionAppFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? type = null,Object? permission = freezed,}) {
  return _then(PermissionAppFailure(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PermissionFailure,permission: freezed == permission ? _self.permission : permission // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class PlatformAppFailure extends Failure {
  const PlatformAppFailure({required this.type, this.details}): super._();
  

 final  PlatformFailure type;
 final  String? details;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlatformAppFailureCopyWith<PlatformAppFailure> get copyWith => _$PlatformAppFailureCopyWithImpl<PlatformAppFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlatformAppFailure&&(identical(other.type, type) || other.type == type)&&(identical(other.details, details) || other.details == details));
}


@override
int get hashCode => Object.hash(runtimeType,type,details);

@override
String toString() {
  return 'Failure.platform(type: $type, details: $details)';
}


}

/// @nodoc
abstract mixin class $PlatformAppFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $PlatformAppFailureCopyWith(PlatformAppFailure value, $Res Function(PlatformAppFailure) _then) = _$PlatformAppFailureCopyWithImpl;
@useResult
$Res call({
 PlatformFailure type, String? details
});




}
/// @nodoc
class _$PlatformAppFailureCopyWithImpl<$Res>
    implements $PlatformAppFailureCopyWith<$Res> {
  _$PlatformAppFailureCopyWithImpl(this._self, this._then);

  final PlatformAppFailure _self;
  final $Res Function(PlatformAppFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? type = null,Object? details = freezed,}) {
  return _then(PlatformAppFailure(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PlatformFailure,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class FileAppFailure extends Failure {
  const FileAppFailure({required this.type, this.path, this.message}): super._();
  

 final  FileFailure type;
 final  String? path;
 final  String? message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileAppFailureCopyWith<FileAppFailure> get copyWith => _$FileAppFailureCopyWithImpl<FileAppFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileAppFailure&&(identical(other.type, type) || other.type == type)&&(identical(other.path, path) || other.path == path)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,type,path,message);

@override
String toString() {
  return 'Failure.file(type: $type, path: $path, message: $message)';
}


}

/// @nodoc
abstract mixin class $FileAppFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $FileAppFailureCopyWith(FileAppFailure value, $Res Function(FileAppFailure) _then) = _$FileAppFailureCopyWithImpl;
@useResult
$Res call({
 FileFailure type, String? path, String? message
});




}
/// @nodoc
class _$FileAppFailureCopyWithImpl<$Res>
    implements $FileAppFailureCopyWith<$Res> {
  _$FileAppFailureCopyWithImpl(this._self, this._then);

  final FileAppFailure _self;
  final $Res Function(FileAppFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? type = null,Object? path = freezed,Object? message = freezed,}) {
  return _then(FileAppFailure(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FileFailure,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class LocationAppFailure extends Failure {
  const LocationAppFailure({required this.type, this.message}): super._();
  

 final  LocationFailure type;
 final  String? message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationAppFailureCopyWith<LocationAppFailure> get copyWith => _$LocationAppFailureCopyWithImpl<LocationAppFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationAppFailure&&(identical(other.type, type) || other.type == type)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,type,message);

@override
String toString() {
  return 'Failure.location(type: $type, message: $message)';
}


}

/// @nodoc
abstract mixin class $LocationAppFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $LocationAppFailureCopyWith(LocationAppFailure value, $Res Function(LocationAppFailure) _then) = _$LocationAppFailureCopyWithImpl;
@useResult
$Res call({
 LocationFailure type, String? message
});




}
/// @nodoc
class _$LocationAppFailureCopyWithImpl<$Res>
    implements $LocationAppFailureCopyWith<$Res> {
  _$LocationAppFailureCopyWithImpl(this._self, this._then);

  final LocationAppFailure _self;
  final $Res Function(LocationAppFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? type = null,Object? message = freezed,}) {
  return _then(LocationAppFailure(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LocationFailure,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class NotificationAppFailure extends Failure {
  const NotificationAppFailure({required this.type, this.message}): super._();
  

 final  NotificationFailure type;
 final  String? message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationAppFailureCopyWith<NotificationAppFailure> get copyWith => _$NotificationAppFailureCopyWithImpl<NotificationAppFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationAppFailure&&(identical(other.type, type) || other.type == type)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,type,message);

@override
String toString() {
  return 'Failure.notification(type: $type, message: $message)';
}


}

/// @nodoc
abstract mixin class $NotificationAppFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $NotificationAppFailureCopyWith(NotificationAppFailure value, $Res Function(NotificationAppFailure) _then) = _$NotificationAppFailureCopyWithImpl;
@useResult
$Res call({
 NotificationFailure type, String? message
});




}
/// @nodoc
class _$NotificationAppFailureCopyWithImpl<$Res>
    implements $NotificationAppFailureCopyWith<$Res> {
  _$NotificationAppFailureCopyWithImpl(this._self, this._then);

  final NotificationAppFailure _self;
  final $Res Function(NotificationAppFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? type = null,Object? message = freezed,}) {
  return _then(NotificationAppFailure(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationFailure,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class PaymentAppFailure extends Failure {
  const PaymentAppFailure({required this.type, this.message, this.transactionId}): super._();
  

 final  PaymentFailure type;
 final  String? message;
 final  String? transactionId;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentAppFailureCopyWith<PaymentAppFailure> get copyWith => _$PaymentAppFailureCopyWithImpl<PaymentAppFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentAppFailure&&(identical(other.type, type) || other.type == type)&&(identical(other.message, message) || other.message == message)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId));
}


@override
int get hashCode => Object.hash(runtimeType,type,message,transactionId);

@override
String toString() {
  return 'Failure.payment(type: $type, message: $message, transactionId: $transactionId)';
}


}

/// @nodoc
abstract mixin class $PaymentAppFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $PaymentAppFailureCopyWith(PaymentAppFailure value, $Res Function(PaymentAppFailure) _then) = _$PaymentAppFailureCopyWithImpl;
@useResult
$Res call({
 PaymentFailure type, String? message, String? transactionId
});




}
/// @nodoc
class _$PaymentAppFailureCopyWithImpl<$Res>
    implements $PaymentAppFailureCopyWith<$Res> {
  _$PaymentAppFailureCopyWithImpl(this._self, this._then);

  final PaymentAppFailure _self;
  final $Res Function(PaymentAppFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? type = null,Object? message = freezed,Object? transactionId = freezed,}) {
  return _then(PaymentAppFailure(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PaymentFailure,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class SyncAppFailure extends Failure {
  const SyncAppFailure({required this.type, this.message}): super._();
  

 final  SyncFailure type;
 final  String? message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncAppFailureCopyWith<SyncAppFailure> get copyWith => _$SyncAppFailureCopyWithImpl<SyncAppFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncAppFailure&&(identical(other.type, type) || other.type == type)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,type,message);

@override
String toString() {
  return 'Failure.sync(type: $type, message: $message)';
}


}

/// @nodoc
abstract mixin class $SyncAppFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $SyncAppFailureCopyWith(SyncAppFailure value, $Res Function(SyncAppFailure) _then) = _$SyncAppFailureCopyWithImpl;
@useResult
$Res call({
 SyncFailure type, String? message
});




}
/// @nodoc
class _$SyncAppFailureCopyWithImpl<$Res>
    implements $SyncAppFailureCopyWith<$Res> {
  _$SyncAppFailureCopyWithImpl(this._self, this._then);

  final SyncAppFailure _self;
  final $Res Function(SyncAppFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? type = null,Object? message = freezed,}) {
  return _then(SyncAppFailure(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SyncFailure,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class UnknownAppFailure extends Failure {
  const UnknownAppFailure({this.error, this.stackTrace, this.message}): super._();
  

 final  Object? error;
 final  StackTrace? stackTrace;
 final  String? message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnknownAppFailureCopyWith<UnknownAppFailure> get copyWith => _$UnknownAppFailureCopyWithImpl<UnknownAppFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnknownAppFailure&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(error),stackTrace,message);

@override
String toString() {
  return 'Failure.unknown(error: $error, stackTrace: $stackTrace, message: $message)';
}


}

/// @nodoc
abstract mixin class $UnknownAppFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $UnknownAppFailureCopyWith(UnknownAppFailure value, $Res Function(UnknownAppFailure) _then) = _$UnknownAppFailureCopyWithImpl;
@useResult
$Res call({
 Object? error, StackTrace? stackTrace, String? message
});




}
/// @nodoc
class _$UnknownAppFailureCopyWithImpl<$Res>
    implements $UnknownAppFailureCopyWith<$Res> {
  _$UnknownAppFailureCopyWithImpl(this._self, this._then);

  final UnknownAppFailure _self;
  final $Res Function(UnknownAppFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = freezed,Object? stackTrace = freezed,Object? message = freezed,}) {
  return _then(UnknownAppFailure(
error: freezed == error ? _self.error : error ,stackTrace: freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
