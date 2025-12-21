import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/bloc/app_bloc.dart';

void main() {
  group('AppBloc', () {
    late AppBloc appBloc;

    setUp(() {
      appBloc = AppBloc();
    });

    tearDown(() {
      appBloc.close();
    });

    test('initial state is AppInitialState', () {
      expect(appBloc.state, equals(const AppInitialState()));
    });

    blocTest<AppBloc, AppState>(
      'emits [AppLoadingState, AppReadyState] when AppInitializeEvent is added',
      build: () => appBloc,
      act: (bloc) => bloc.add(const AppInitializeEvent()),
      wait: const Duration(seconds: 3),
      expect: () => [const AppLoadingState(), const AppReadyState()],
    );

    blocTest<AppBloc, AppState>(
      'emits updated AppReadyState when AppThemeChangedEvent is added',
      build: () => appBloc,
      seed: () => const AppReadyState(),
      act: (bloc) => bloc.add(const AppThemeChangedEvent(true)),
      expect: () => [const AppReadyState(isDarkMode: true)],
    );

    blocTest<AppBloc, AppState>(
      'emits updated AppReadyState when AppLanguageChangedEvent is added',
      build: () => appBloc,
      seed: () => const AppReadyState(),
      act: (bloc) => bloc.add(const AppLanguageChangedEvent('en')),
      expect: () => [const AppReadyState(languageCode: 'en')],
    );

    test('AppReadyState copyWith works correctly', () {
      const originalState = AppReadyState(
        
      );

      final updatedState = originalState.copyWith(isDarkMode: true);

      expect(updatedState.isDarkMode, isTrue);
      expect(updatedState.languageCode, equals('zh'));
    });
  });
}
