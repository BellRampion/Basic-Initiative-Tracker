// ignore_for_file: must_be_immutable

import 'package:basic_initiative_tracker/data_models/init_tracker_item.dart';
import 'package:basic_initiative_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InitTrackerItemCard extends StatelessWidget{
	InitTrackerItem initTrackerItem;
	TextEditingController currentHpController = TextEditingController();
	TextEditingController notesController = TextEditingController();
	IconButton deleteButton;
	IconButton copyButton;
	IconButton editButton;
	bool isSelected;

	InitTrackerItemCard({
		super.key, 
		required this.initTrackerItem, 
		required this.deleteButton, 
		required this.copyButton, 
		required this.isSelected,
		required this.editButton,
	}){
		currentHpController.text = initTrackerItem.currentHp.toString();
		notesController.text = initTrackerItem.notes;
	}

	@override
	Widget build(BuildContext context){
		return Card(
			color: isSelected ? Theme.of(context).colorScheme.surfaceVariant : Theme.of(context).colorScheme.surface,
			child: Padding(
				padding: const EdgeInsets.all(8.0),
				child: Row(
					children: [
						Expanded(
							child: Text(initTrackerItem.name, style: UIStyles.getRegularText(context)),
						),
						Flexible(
							child: TextField(
								controller: notesController,
								decoration: InputDecoration(
									border: UnderlineInputBorder(
										borderSide: BorderSide(color: Theme.of(context).colorScheme.outline)
									),
									filled: true,
								),
								style: TextStyle(fontSize: MediaQuery.sizeOf(context).width > 500 ? 12 : 10,),
								onChanged: (value){
									initTrackerItem.notes = value;
								}
							),
						),
						SizedBox(width: MediaQuery.sizeOf(context).width > 500 ? 20 : 10,),
						Container(
							padding: const EdgeInsets.fromLTRB(6.0, 1.0, 6.0, 2.0),
							decoration: BoxDecoration(
								borderRadius: const BorderRadius.all(Radius.circular(10)),
								border: Border.all(
									color: Theme.of(context).colorScheme.outlineVariant,
									width: 1.5,
								),
								color: Theme.of(context).colorScheme.outlineVariant,
							),
							child: Row( 
								children: [
									SizedBox(
										width: 50,
										child: TextField(
											controller: currentHpController,
											decoration: InputDecoration(
												border: UnderlineInputBorder(
													borderSide: BorderSide(color: Theme.of(context).colorScheme.outline)
												),
												filled: true
											),
											keyboardType: TextInputType.number,
											inputFormatters: <TextInputFormatter>[
												FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
											], 
											onChanged: (value){
												initTrackerItem.currentHp = int.tryParse(value) ?? 0;
											},
											style: UIStyles.getRegularText(context),
											textAlign: TextAlign.right,
										),
									),
									const Text("/ "),
									Text(initTrackerItem.totalHp.toString(), style: UIStyles.getRegularText(context)),
								]
							),
						),
						SizedBox(
							width: MediaQuery.sizeOf(context).width > 500 ? 20 : 10,
						),
						Container(
							padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
							decoration: BoxDecoration(
								borderRadius: const BorderRadius.all(Radius.circular(10)),
								border: Border.all(
									color: Theme.of(context).colorScheme.outlineVariant,
									width: 1.5,
								),
								color: Theme.of(context).colorScheme.outlineVariant
								
							),
							child: Text(
				//Pad left "4" because of the decimal point and the trailing digit
								initTrackerItem.initiative.toString().padLeft(4, "0"),
								style: UIStyles.getRegularText(context).copyWith(
									fontWeight: FontWeight.bold, 
									fontSize: MediaQuery.sizeOf(context).width > 500 ? 22 : 18,
								)
							),
						),
						SizedBox(
							width: MediaQuery.sizeOf(context).width > 500 ? 5 : 2,
						),
			editButton,
						copyButton,
						deleteButton,
					]
				),
			)
		);
	}
}