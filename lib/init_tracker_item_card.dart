// ignore_for_file: must_be_immutable

import 'package:basic_initiative_tracker/bloc/settings_bloc.dart';
import 'package:basic_initiative_tracker/constants.dart';
import 'package:basic_initiative_tracker/data_models/init_tracker_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinbox/material.dart';

class InitTrackerItemCard extends StatefulWidget{
	InitTrackerItem initTrackerItem;
	TextEditingController currentHpController = TextEditingController();
	TextEditingController notesController = TextEditingController();
	TextEditingController superficialHpDmgController =
				TextEditingController();
		TextEditingController aggravatedHpDmgController =
				TextEditingController();
		TextEditingController superficialWillDmgController =
				TextEditingController();
		TextEditingController aggravatedWillDmgController = TextEditingController();
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
		superficialHpDmgController.text = initTrackerItem.vtmSpecific.healthSuperficial.toString();
		aggravatedHpDmgController.text = initTrackerItem.vtmSpecific.healthAggravated.toString();
		superficialWillDmgController.text = initTrackerItem.vtmSpecific.willSuperficial.toString();
		aggravatedWillDmgController.text = initTrackerItem.vtmSpecific.willAggravated.toString();
	}
  
  @override
  State<StatefulWidget> createState() => InitTrackerItemCardState();

}

class InitTrackerItemCardState extends State<InitTrackerItemCard> {

  @override
	Widget build(BuildContext context){
		return Card(
			color: widget.isSelected ? Theme.of(context).colorScheme.surfaceVariant : Theme.of(context).colorScheme.surface,
			child: Padding(
				padding: const EdgeInsets.all(8.0),
				child: Row(
					children: [
						Expanded(
							flex: 0,
							child: Text(widget.initTrackerItem.name, style: UIStyles.getRegularText(context)),
						),
						SizedBox(
							width: MediaQuery.sizeOf(context).width > 500 ? 20 : 10,
						),
						Expanded(
							//The notes field should take up as much space as it has available. 
							flex: 1,
							child: TextField(
								controller: widget.notesController,
								decoration: standardDecoration(),
								style: TextStyle(fontSize: MediaQuery.sizeOf(context).width > 500 ? 12 : 10,),
								onChanged: (value){
									widget.initTrackerItem.notes = value;
								}
							),
						),
            rogueTraderSpecific(context),
						runequestSpecific(context),
						health(context),
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
								widget.initTrackerItem.initiative.toString().padLeft(4, "0"),
								style: UIStyles.getRegularText(context).copyWith(
									fontWeight: FontWeight.bold, 
									fontSize: MediaQuery.sizeOf(context).width > 500 ? 22 : 18,
								)
							),
						),
						SizedBox(
							width: MediaQuery.sizeOf(context).width > 500 ? 5 : 2,
						),
						widget.editButton,
						widget.copyButton,
						widget.deleteButton,
					]
				),
			)
		);
	}

	/// All rogue-trader specific widgets.
	Widget rogueTraderSpecific(BuildContext context){
		if (SystemChoices.rogueTrader.computerReadableName == context.watch<SettingsBloc>().state.selectedSystem.computerReadableName) 
		{
			return Flexible(
				//Needs a bit more space than flex 1 provides
				flex: 2,
				child: Row(
					mainAxisAlignment: MainAxisAlignment.end,
					children: [
						SizedBox(width: MediaQuery.sizeOf(context).width > 500 ? 20 : 10,),
						Text(
							"1st",
							style: UIStyles.getRegularText(context)
						),
						Checkbox(
							value: widget.initTrackerItem.reaction1Used,
							onChanged: (value){  
								setState(() {
									widget.initTrackerItem.reaction1Used = value ?? false;
								});
							}
						),
						Text(
							"2nd",
							style: UIStyles.getRegularText(context)
						),
						Checkbox(
							value: widget.initTrackerItem.reaction2Used,
							onChanged: (value){  
								setState(() {
									widget.initTrackerItem.reaction2Used = value ?? false;
								});
							}
						),
					]
				),
			);
		}
		else {
			return const SizedBox(height: 0, width: 0);
		}
	}

	Widget runequestSpecific(BuildContext context){
		if (SystemChoices.runequest.computerReadableName == context.watch<SettingsBloc>().state.selectedSystem.computerReadableName){
			return Flexible(
				child: SpinBox(
					incrementIcon: const Icon(Icons.arrow_right),
					decrementIcon: const Icon(Icons.arrow_left),
					value: widget.initTrackerItem.combatActions.toDouble(),
					spacing: 0.5,
					textStyle: UIStyles.getRegularText(context),
					onChanged:(value) {
						widget.initTrackerItem.combatActionsTotal += value.toInt() - widget.initTrackerItem.combatActions;
						widget.initTrackerItem.combatActions = value.toInt();
						
					},
				),
			);
		}
		else {
			return const SizedBox(height: 0, width: 0);
		}
	}

	Widget health(BuildContext context){
		//Vampire The Masquerade Health and Stamina
		if (SystemChoices.vtm.computerReadableName == context.watch<SettingsBloc>().state.selectedSystem.computerReadableName){
			return Flexible(
				flex: 0,
				child: Row(
					children: [
						SizedBox(width: MediaQuery.sizeOf(context).width > 500 ? 4 : 2,),
						SizedBox(
							width: 75,
							child: TextField(
								controller: widget.superficialHpDmgController,
								style: UIStyles.getRegularText(context),
								decoration: standardDecoration().copyWith(
									labelText: "S. HP",
									floatingLabelAlignment: FloatingLabelAlignment.center
								),
								onChanged:(value) {
									widget.initTrackerItem.vtmSpecific.healthSuperficial = int.tryParse(value) ?? 0;
								},
								textAlign: TextAlign.center,
							),
						),
						SizedBox(width: MediaQuery.sizeOf(context).width > 500 ? 4 : 2,),
						SizedBox(
							width: 75,
							child: TextField(
								controller: widget.aggravatedHpDmgController,
								style: UIStyles.getRegularText(context),
								decoration: standardDecoration().copyWith(
									labelText: "A. HP",
									floatingLabelAlignment: FloatingLabelAlignment.center
								),
								onChanged:(value) {
									widget.initTrackerItem.vtmSpecific.healthAggravated = int.tryParse(value) ?? 0;
								},
								textAlign: TextAlign.center,
							),
						),
						SizedBox(width: MediaQuery.sizeOf(context).width > 500 ? 4 : 2,),
						SizedBox(
							width: 75,
							child: TextField(
								controller: TextEditingController(text: widget.initTrackerItem.totalHp.toString()), 
								style: UIStyles.getRegularText(context),
								decoration: standardDecoration().copyWith(
									labelText: "T. HP",
									floatingLabelAlignment: FloatingLabelAlignment.center,
									labelStyle: TextStyle(
										color: Theme.of(context).colorScheme.onBackground,
									),
									fillColor: Theme.of(context).colorScheme.background
								),
								textAlign: TextAlign.center,
								readOnly: true,
							),
						),
						SizedBox(width: MediaQuery.sizeOf(context).width > 500 ? 4 : 2,),
						SizedBox(
							width: 75,
							child: TextField(
								controller: widget.superficialWillDmgController,
								style: UIStyles.getRegularText(context),
								decoration: standardDecoration().copyWith(
									labelText: "S. WP",
									floatingLabelAlignment: FloatingLabelAlignment.center
								),
								onChanged:(value) {
									widget.initTrackerItem.vtmSpecific.willSuperficial = int.tryParse(value) ?? 0;
								},
								textAlign: TextAlign.center,
							),
						),
						SizedBox(width: MediaQuery.sizeOf(context).width > 500 ? 4 : 2,),
						SizedBox(
							width: 75,
							child: TextField(
								controller: widget.aggravatedWillDmgController,
								style: UIStyles.getRegularText(context),
								decoration: standardDecoration().copyWith(
									labelText: "A. WP",
									floatingLabelAlignment: FloatingLabelAlignment.center
								),
								onChanged:(value) {
									widget.initTrackerItem.vtmSpecific.willAggravated = int.tryParse(value) ?? 0;
								},
								textAlign: TextAlign.center,
							),
						),
						SizedBox(width: MediaQuery.sizeOf(context).width > 500 ? 4 : 2,),
						SizedBox(
							width: 75,
							child: TextField(
								controller: TextEditingController(text: widget.initTrackerItem.vtmSpecific.willTotal.toString()), 
								style: UIStyles.getRegularText(context),
								decoration: standardDecoration().copyWith(
									labelText: "T. WP",
									floatingLabelAlignment: FloatingLabelAlignment.center,
									labelStyle: TextStyle(
										color: Theme.of(context).colorScheme.onBackground,
									),
									fillColor: Theme.of(context).colorScheme.background
								),
								textAlign: TextAlign.center,
								readOnly: true,
							),
						)
					]
				)
			);
		}
		//Default health display
		else {
			return Row(
				children: [
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
										controller: widget.currentHpController,
										decoration: standardDecoration(),
										keyboardType: TextInputType.number,
										inputFormatters: <TextInputFormatter>[
											FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
										], 
										onChanged: (value){
											widget.initTrackerItem.currentHp = int.tryParse(value) ?? 0;
										},
										style: UIStyles.getRegularText(context),
										textAlign: TextAlign.right,
									),
								),
								const Text("/ "),
								Text(widget.initTrackerItem.totalHp.toString(), style: UIStyles.getRegularText(context)),
							]
						),
					),
				]
			);
		}
	}

	InputDecoration standardDecoration(){
		return InputDecoration(
			border: OutlineInputBorder(
				borderSide: BorderSide(color: Theme.of(context).colorScheme.outline)
			),
			filled: true
		);
	}
}