import 'package:freezed_annotation/freezed_annotation.dart';

part 'stateful_data.freezed.dart';

@freezed
class StatefulData<T> with _$StatefulData<T> {
  factory StatefulData.result(T result) = ResultData<T>;
  factory StatefulData.loading() = LoadingData<T>;
  factory StatefulData.error(dynamic error) = ErrorData<T>;
}