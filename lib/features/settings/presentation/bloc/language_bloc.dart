import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/language_repository.dart';
import 'language_event.dart';
import 'language_state.dart';

@singleton
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final ILanguageRepository _languageRepository;

  LanguageBloc(this._languageRepository) : super(LanguageInitial()) {
    on<LoadLanguage>(_onLoadLanguage);
    on<ChangeLanguage>(_onChangeLanguage);
  }

  Future<void> _onLoadLanguage(
    LoadLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    try {
      emit(LanguageLoading());
      final locale = await _languageRepository.getLanguage();
      emit(LanguageLoaded(locale));
    } catch (e) {
      emit(LanguageError(e.toString()));
    }
  }

  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    try {
      await _languageRepository.setLanguage(event.newLocale);
      emit(LanguageLoaded(event.newLocale));
    } catch (e) {
      emit(LanguageError(e.toString()));
    }
  }
}
