import 'package:flutter/material.dart';

class Constants {
	
}

enum SystemChoices {
	pathfinder(humanReadableName: "Pathfinder", computerReadableName: "pf"), 
	rogueTrader(humanReadableName: "Rogue Trader", computerReadableName: "rt"),
	runequest(humanReadableName: "Runequest II/Legend", computerReadableName: "rq"),
	vtm(humanReadableName: "Vampire The Masquerade", computerReadableName: "vtm"),
  hoc(humanReadableName: "Hearts of Coal", computerReadableName: "hoc");

  const SystemChoices({
    required this.computerReadableName, required this.humanReadableName
  });

  final String humanReadableName;
  final String computerReadableName;
}

enum CombatCategory {
	/// These three are VTM/WoD specific categories
	estabMelee(humanReadableName: "Estab. Melee", computerReadableName: "estabmelee", priority: 0),
	ranged(humanReadableName: "Ranged", computerReadableName: "ranged", priority: 1),
	newMelee(humanReadableName: "New Melee", computerReadableName: "newmelee", priority: 2),
	///Other is the catch-all
	other(humanReadableName: "Other", computerReadableName: "other", priority: 3);

	final String humanReadableName;
	final String computerReadableName;
	final int priority;

	const CombatCategory({
		required this.humanReadableName, 
		required this.computerReadableName, 
		required this.priority
	});

	/// Returns the category with the matching [computerReadableName]. 
	static CombatCategory getByComputerName(String computerName){
		for (CombatCategory cat in CombatCategory.values){
			if (cat.computerReadableName == computerName){
				return cat;
			}
		}
		// Default
		return CombatCategory.other;
	}

}

class UIStyles {
	static const TextStyle _regularText = TextStyle(fontSize: 14);
	static const TextStyle _textButtonText =
			TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
	static const TextStyle _headerText =
			TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

	static TextStyle getRegularText(BuildContext context) {
		return _regularText.copyWith(
				fontSize: MediaQuery.sizeOf(context).height > 500 ? 14 : 10);
	}

	static TextStyle getTextButtonText(BuildContext context) {
		return _textButtonText.copyWith(
				fontSize: MediaQuery.sizeOf(context).height > 500 ? 12 : 8);
	}

	static TextStyle getHeaderText(BuildContext context) {
		return _headerText.copyWith(
				fontSize: MediaQuery.sizeOf(context).height > 500 ? 16 : 12);
	}
}