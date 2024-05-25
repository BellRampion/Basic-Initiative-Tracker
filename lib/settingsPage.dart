// ignore_for_file: file_names, must_be_immutable, use_build_context_synchronously, prefer_const_constructors_in_immutables

import 'package:basic_initiative_tracker/bloc/theme_color_bloc.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatefulWidget {
	SettingsPage({super.key});

	@override
	State<StatefulWidget> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
	@override
	Widget build(BuildContext context) {
	return Scaffold(
		appBar: AppBar(
		backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
		title: const Text("Settings"),
		),
		// Show the color picker in sized box in a raised card.
		body: Column(children: [
		Switch(
			value: BlocProvider.of<ThemeColorBloc>(context).state.selectedThemeMode == ThemeMode.dark ? true : false,
			onChanged: (value) {
				BlocProvider.of<ThemeColorBloc>(context).add(
					ChangeThemeMode( newThemeMode: value == true ? ThemeMode.dark : ThemeMode.light)
				);
			},
		),
		// Pick color in a dialog.
		ListTile(
			title: const Text('Click this color to change it in a dialog'),
			trailing: ColorIndicator(
			borderRadius: 4,
			color: BlocProvider.of<ThemeColorBloc>(context).state.selectedColorSeed,
			onSelectFocus: false,
			onSelect: () async {
				// Store current color before we open the dialog.
				final Color colorBeforeDialog = BlocProvider.of<ThemeColorBloc>(context).state.selectedColorSeed;
				// Wait for the picker to close, if dialog was dismissed,
				// then restore the color we had before it was opened.
				if (!(await colorPickerDialog(context))) {
					BlocProvider.of<ThemeColorBloc>(context).add( ChangeThemeColor(newSeedColor: colorBeforeDialog) );
				}
			},
			),
		),
		]),
	);
	}

	Future<bool> colorPickerDialog(BuildContext context) async {
	return ColorPicker(
		// Use the dialogPickerColor as start color.
		color: BlocProvider.of<ThemeColorBloc>(context).state.selectedColorSeed,		// Update the dialogPickerColor using the callback.
		onColorChanged: (Color color) =>
			BlocProvider.of<ThemeColorBloc>(context).add( ChangeThemeColor(newSeedColor: color) ),
		height: 40,
		borderRadius: 4,
		spacing: 5,
		runSpacing: 5,
		wheelDiameter: 155,
		heading: Text(
		'Select color',
		style: Theme.of(context).textTheme.titleSmall,
		),
		subheading: Text(
		'Select color shade',
		style: Theme.of(context).textTheme.titleSmall,
		),
		wheelSubheading: Text(
		'Selected color and its shades',
		style: Theme.of(context).textTheme.titleSmall,
		),
		showMaterialName: true,
		showColorName: true,
		showColorCode: true,
		copyPasteBehavior: const ColorPickerCopyPasteBehavior(
			longPressMenu: true,
		),
		enableShadesSelection: false,
		materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
		colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
		colorCodeTextStyle: Theme.of(context).textTheme.bodySmall,
		pickersEnabled: const <ColorPickerType, bool>{
			ColorPickerType.primary: false,
			ColorPickerType.accent: false,
			ColorPickerType.wheel: true,
		},
	).showPickerDialog(
		context,
		// New in version 3.0.0 custom transitions support.
		transitionBuilder: (BuildContext context, Animation<double> a1,
			Animation<double> a2, Widget widget) {
		final double curvedValue =
			Curves.easeInOutBack.transform(a1.value) - 1.0;
		return Transform(
			transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
			child: Opacity(
			opacity: a1.value,
			child: widget,
			),
		);
		},
		transitionDuration: const Duration(milliseconds: 400),
		constraints:
			const BoxConstraints(minHeight: 460, minWidth: 300, maxWidth: 320),
	);
	}
}
