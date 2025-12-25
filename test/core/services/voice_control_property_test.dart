import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/services/voice_control_service.dart';

void main() {
  group('Voice Control Support Property Tests', () {
    late VoiceControlService voiceService;

    setUp(() {
      voiceService = VoiceControlService.instance;
    });

    tearDown(VoiceControlHelper.clearAllCommands);

    /// **Feature: prvin-integrated-calendar, Property 32: 语音控制支持**
    /// 对于任何语音命令，应该支持基本的语音控制操作
    /// **验证需求: 需求 10.5**
    group('Property 32: Voice Control Support', () {
      test(
        'should initialize voice control service for any platform',
        () async {
          // Test initialization on different platform conditions
          final initResults = <bool>[];

          // Test multiple initialization attempts
          for (var i = 0; i < 5; i++) {
            final result = await voiceService.initialize();
            initResults.add(result);
          }

          // Voice control should either consistently work or consistently fail
          // based on platform capabilities
          final allSame = initResults.every(
            (result) => result == initResults.first,
          );
          expect(
            allSame,
            isTrue,
            reason: 'Initialization results should be consistent',
          );

          // Service should report correct availability status
          expect(voiceService.isAvailable, equals(initResults.first));
        },
      );

      test(
        'should handle language switching for any supported language',
        () async {
          await voiceService.initialize();

          final supportedLanguages = ['zh', 'en'];
          final initialLanguage = voiceService.currentLanguage;

          for (final language in supportedLanguages) {
            voiceService.setLanguage(language);

            // Language should be set correctly
            expect(voiceService.currentLanguage, equals(language));

            // All commands should have phrases in the current language
            final commands = voiceService.getSupportedCommands();
            for (final command in commands) {
              final phrase = voiceService.getCommandPhrase(command);
              expect(phrase.isNotEmpty, isTrue);

              // Phrase should match the expected language pattern
              if (language == 'zh') {
                // Chinese phrases should contain Chinese characters
                expect(phrase, matches(r'[\u4e00-\u9fff]'));
              } else {
                // English phrases should contain only ASCII characters
                expect(phrase, matches(r'^[a-zA-Z\s]+$'));
              }
            }
          }

          // Restore initial language
          voiceService.setLanguage(initialLanguage);
        },
      );

      test(
        'should register and execute commands for any command type',
        () async {
          await voiceService.initialize();

          final commandExecutions = <VoiceCommand, int>{};
          const allCommands = VoiceCommand.values;

          // Register callbacks for all commands
          for (final command in allCommands) {
            commandExecutions[command] = 0;
            voiceService.registerCommand(command, () {
              commandExecutions[command] = commandExecutions[command]! + 1;
            });
          }

          // Execute each command multiple times
          for (final command in allCommands) {
            for (var i = 0; i < 3; i++) {
              voiceService.executeCommand(command);
            }
          }

          // Verify all commands were executed correctly
          for (final command in allCommands) {
            expect(
              commandExecutions[command],
              equals(3),
              reason: 'Command ${command.name} should be executed 3 times',
            );
          }
        },
      );

      test('should recognize commands from text for any language', () async {
        await voiceService.initialize();

        final testCases = [
          {
            'language': 'zh',
            'text': '切换语言',
            'expected': VoiceCommand.toggleLanguage,
          },
          {
            'language': 'zh',
            'text': '创建任务',
            'expected': VoiceCommand.createTask,
          },
          {
            'language': 'zh',
            'text': '开始番茄钟',
            'expected': VoiceCommand.startPomodoro,
          },
          {
            'language': 'en',
            'text': 'switch language',
            'expected': VoiceCommand.toggleLanguage,
          },
          {
            'language': 'en',
            'text': 'create task',
            'expected': VoiceCommand.createTask,
          },
          {
            'language': 'en',
            'text': 'start pomodoro',
            'expected': VoiceCommand.startPomodoro,
          },
        ];

        for (final testCase in testCases) {
          final language = testCase['language']! as String;
          final text = testCase['text']! as String;
          final expected = testCase['expected']! as VoiceCommand;

          final recognized = VoiceCommand.fromText(text, language);
          expect(
            recognized,
            equals(expected),
            reason: 'Should recognize "$text" as ${expected.name} in $language',
          );
        }
      });

      test(
        'should handle partial and fuzzy text matching for any input',
        () async {
          await voiceService.initialize();

          final fuzzyTestCases = [
            {
              'language': 'zh',
              'text': '切换',
              'expected': VoiceCommand.toggleLanguage,
            },
            {
              'language': 'zh',
              'text': '切换语言吧',
              'expected': VoiceCommand.toggleLanguage,
            },
            {
              'language': 'zh',
              'text': '请切换语言',
              'expected': VoiceCommand.toggleLanguage,
            },
            {
              'language': 'en',
              'text': 'switch',
              'expected': VoiceCommand.toggleLanguage,
            },
            {
              'language': 'en',
              'text': 'switch language please',
              'expected': VoiceCommand.toggleLanguage,
            },
            {
              'language': 'en',
              'text': 'please switch language',
              'expected': VoiceCommand.toggleLanguage,
            },
          ];

          for (final testCase in fuzzyTestCases) {
            final language = testCase['language']! as String;
            final text = testCase['text']! as String;
            final expected = testCase['expected']! as VoiceCommand;

            final recognized = VoiceCommand.fromText(text, language);
            expect(
              recognized,
              equals(expected),
              reason:
                  'Should recognize fuzzy match "$text" as ${expected.name}',
            );
          }
        },
      );

      test(
        'should maintain state consistency for any operation sequence',
        () async {
          await voiceService.initialize();

          // Test state transitions
          expect(voiceService.state, equals(VoiceRecognitionState.ready));

          // Start listening
          if (voiceService.isAvailable) {
            final startResult = await voiceService.startListening();
            if (startResult) {
              expect(
                voiceService.state,
                equals(VoiceRecognitionState.listening),
              );

              // Stop listening
              await voiceService.stopListening();
              expect(voiceService.state, equals(VoiceRecognitionState.ready));
            }
          }

          // Test language changes don't affect state
          final originalState = voiceService.state;
          voiceService.setLanguage('en');
          expect(voiceService.state, equals(originalState));
          voiceService.setLanguage('zh');
          expect(voiceService.state, equals(originalState));
        },
      );

      test(
        'should provide helper functions for any integration scenario',
        () async {
          // Test VoiceControlHelper static methods
          final initResult = await VoiceControlHelper.initialize();
          expect(initResult, isA<bool>());

          // Test availability check
          final isAvailable = VoiceControlHelper.isAvailable;
          expect(isAvailable, isA<bool>());

          // Test state access
          final state = VoiceControlHelper.state;
          expect(state, isA<VoiceRecognitionState>());

          // Test command setup methods don't throw
          expect(() {
            VoiceControlHelper.setupLanguageToggleCommand(() {});
            VoiceControlHelper.setupCreateTaskCommand(() {});
            VoiceControlHelper.setupPomodoroCommands(
              onStart: () {},
              onStop: () {},
            );
            VoiceControlHelper.setupNavigationCommands(
              onViewCalendar: () {},
              onGoHome: () {},
              onHelp: () {},
            );
          }, returnsNormally);

          // Test cleanup
          expect(VoiceControlHelper.clearAllCommands, returnsNormally);
        },
      );

      test(
        'should handle error conditions gracefully for any failure scenario',
        () async {
          // Test initialization when already initialized
          await voiceService.initialize();
          final secondInit = await voiceService.initialize();
          expect(secondInit, isA<bool>());

          // Test operations when not available
          if (!voiceService.isAvailable) {
            final startResult = await voiceService.startListening();
            expect(startResult, isFalse);
          }

          // Test invalid language codes
          expect(() => voiceService.setLanguage('invalid'), returnsNormally);
          expect(() => voiceService.setLanguage(''), returnsNormally);

          // Test unregistering non-existent commands
          expect(
            () => voiceService.unregisterCommand(VoiceCommand.help),
            returnsNormally,
          );

          // Test executing unregistered commands
          voiceService.unregisterCommand(VoiceCommand.help);
          expect(
            () => voiceService.executeCommand(VoiceCommand.help),
            returnsNormally,
          );
        },
      );

      test(
        'should support result stream for any recognition scenario',
        () async {
          await voiceService.initialize();

          // Test result stream is available
          expect(
            voiceService.resultStream,
            isA<Stream<VoiceRecognitionResult>>(),
          );

          // Test helper result stream
          expect(
            VoiceControlHelper.resultStream,
            isA<Stream<VoiceRecognitionResult>>(),
          );

          // Test stream can be listened to without errors
          var streamWorking = false;
          final subscription = voiceService.resultStream.listen(
            (result) {
              streamWorking = true;
              expect(result, isA<VoiceRecognitionResult>());
              expect(result.text, isA<String>());
              expect(result.confidence, isA<double>());
              expect(result.confidence, inInclusiveRange(0.0, 1.0));
            },
            onError: (error) {
              // Stream should handle errors gracefully
              expect(error, isNotNull);
            },
          );

          // Give some time for potential stream events
          await Future.delayed(const Duration(milliseconds: 100));

          await subscription.cancel();

          // Stream should be accessible even if no events occurred
          expect(voiceService.resultStream, isNotNull);
        },
      );

      test('should provide command information for any query', () async {
        await voiceService.initialize();

        // Test getting all supported commands
        final commands = voiceService.getSupportedCommands();
        expect(commands, isNotEmpty);
        expect(commands, containsAll(VoiceCommand.values));

        // Test getting phrases for all commands
        final allPhrases = voiceService.getAllCommandPhrases();
        expect(allPhrases.length, equals(VoiceCommand.values.length));

        for (final command in VoiceCommand.values) {
          // Each command should have a phrase
          expect(allPhrases.containsKey(command), isTrue);
          expect(allPhrases[command], isNotEmpty);

          // Individual phrase getter should match
          final individualPhrase = voiceService.getCommandPhrase(command);
          expect(individualPhrase, equals(allPhrases[command]));
        }
      });
    });
  });
}
