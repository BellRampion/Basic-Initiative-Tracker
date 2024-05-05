import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ThemeColorBloc extends Bloc<ThemeColorBlocEvent, ThemeColorBlocState> {
	bool sortOnNewRound = false;

	ThemeColorBloc() : super(ThemeColorBlocState.initial()){
		
		on<ChangeThemeMode>(( event, emit) async {
			emit(
				ThemeColorBlocState(
					selectedThemeMode: event.newThemeMode, 
					selectedColorSeed: state.selectedColorSeed,
				),
			);
		});

		on<ChangeThemeColor>(( event, emit) async {
			emit(
				ThemeColorBlocState(
					selectedThemeMode: state.selectedThemeMode, 
					selectedColorSeed: event.newSeedColor,
				),
			);
		});
	}

}

class ThemeColorBlocState {
	ThemeMode selectedThemeMode = ThemeMode.dark;
	Color selectedColorSeed = Colors.red;

	ThemeColorBlocState({
		required this.selectedThemeMode,
		required this.selectedColorSeed,
	});

	ThemeColorBlocState.initial();
}

class ThemeColorBlocEvent {
	ThemeColorBlocEvent();
}

class ChangeThemeColor extends ThemeColorBlocEvent {
	Color newSeedColor;

	ChangeThemeColor({required this.newSeedColor});
}

class ChangeThemeMode extends ThemeColorBlocEvent {
	ThemeMode newThemeMode;

	ChangeThemeMode({required this.newThemeMode});
}