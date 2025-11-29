import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

/// Base cubit class for all application cubits
///
/// Provides common functionality and state management patterns
abstract class BaseCubit<T extends BaseState> extends Cubit<T> {
  BaseCubit(super.initialState);

  /// Emit state safely (prevents emission after close)
  void safeEmit(T state) {
    if (!isClosed) {
      emit(state);
    }
  }
}

/// Base state class for all application states
abstract class BaseState extends Equatable {
  const BaseState();
}