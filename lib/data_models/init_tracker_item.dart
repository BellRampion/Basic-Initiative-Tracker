import 'package:flutter/material.dart';

class InitTrackerItem {
	double initiative;
	String name;
	String notes;
	int totalHp = 0;
	int currentHp = 0;
	//Distinct identifier to refer to this initiative card by
	UniqueKey key = UniqueKey();

	//Default HP to 0 because not every character needs to have hitpoints recorded
	InitTrackerItem({required this.initiative, required this.name, required this.notes, this.totalHp = 0, this.currentHp = 0});

	InitTrackerItem.fromJson(Map<String, dynamic> json) :
			initiative = (json['initiative'] as double?) ?? 0,
			name = (json['name'] as String?) ?? "",
			notes = (json['notes'] as String?) ?? "",
			totalHp = (json['totalHp'] as int?) ?? 0,
			currentHp = (json['currentHp'] as int?) ?? 0;
		

	Map<String, dynamic> toJson(){
		return {
			"initiative": initiative,
			"name": name,
			"notes": notes,
			"totalHp": totalHp,
			"currentHp": currentHp
		};
	}
}