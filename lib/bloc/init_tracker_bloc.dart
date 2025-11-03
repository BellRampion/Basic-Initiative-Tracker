import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:basic_initiative_tracker/constants.dart';
import 'package:basic_initiative_tracker/data_models/init_tracker_item.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'init_tracker_bloc_state.dart';
part 'init_tracker_bloc_event.dart';

class InitTrackerBloc extends Bloc<InitTrackerBlocEvent, InitTrackerBlocState> {
	bool sortOnNewRound = false;
	SystemChoices selectedSystem = SystemChoices.pathfinder;

	InitTrackerBloc() : super(InitTrackerBlocState.initial()){

		on<AddInitItem>(( event, emit) async {
			UniqueKey key;
			int newListPlace = 0;
			if (state.initList.isNotEmpty){
				//Save the key for the currently selected item so it doesn't lose its place
				key = state.initList[state.listPlace].key;
				//Add the new initiative step
				state.initList.add(event.item);
				//Sort list
				sortInitList(state.initList);

				//Find the item with the saved key and set it as the currently selected item
				for (int i = 0; i < state.initList.length; i++){
					if (state.initList[i].key == key){
						newListPlace = i;
						break;
					}
				}
			}
			else {
				state.initList.add(event.item);
			}

			emit(InitTrackerBlocState(
				initList: state.initList,
				listPlace: newListPlace,
        roundCounter: state.roundCounter,
			));
		});

		on<AdvanceTracker>((event, emit){
			int currentStep = state.listPlace;
			int newStep = currentStep;
			bool combatActionsFinished = true;
			
			newStep = currentStep + 1;

			if (state.initList.isEmpty){
				newStep = 0;
			}
			else if (newStep == state.initList.length)
			{
				newStep = 0;
				//Every round, combat action count should decrement down to 0
				for (InitTrackerItem item in state.initList){
					if (item.combatActions > 0){
						--item.combatActions;
						combatActionsFinished = false;
						//If it's 0 after decrementing, then don't rule out a new round starting
						if (item.combatActions == 0)
						{
							combatActionsFinished = true;
						}
					}
				}
			}
			// If the next step is 0 (start) and all combat actions have been used, start a new round
			if (newStep == 0 && combatActionsFinished){
        for (InitTrackerItem item in state.initList){
          item.reaction1Used = false;
          item.reaction2Used = false;
					item.combatActions = item.combatActionsTotal;
        }
				emit(InitTrackerBlocState(
					initList: state.initList,
					listPlace: newStep,
					isNewRound: true,
          roundCounter: ++state.roundCounter,
				));
			}
			// Otherwise, go to the next item in the list
			else {
				emit(InitTrackerBlocState(
					initList: state.initList,
					listPlace: newStep,
					isNewRound: false,
          roundCounter: state.roundCounter,
				));
			}
		});

		on<DeleteItem>((event, emit){
			int itemIndex = 0;
			UniqueKey currItemKey;
			int newListPlace = 0;

			//Save the key for the currently selected item so it doesn't lose its place
			currItemKey = state.initList[state.listPlace].key;

			//Find the item with the key that needs to be deleted
			for (int i = 0; i < state.initList.length; i++){
				if (event.key == state.initList[i].key){
					itemIndex = i;
				}
			}
			state.initList.removeAt(itemIndex);

			//Find the item with the saved key and set it as the currently selected item
			for (int i = 0; i < state.initList.length; i++){
				if (state.initList[i].key == currItemKey){
					newListPlace = i;
					break;
				}
			}

			emit(InitTrackerBlocState(
				initList: state.initList,
				listPlace: newListPlace,
        roundCounter: state.roundCounter,
			));
		});

		on<EditItem>((event, emit){
			UniqueKey currItemKey;
			int newListPlace = 0;

			//Save the key for the currently selected item so it doesn't lose its place
			currItemKey = state.initList[state.listPlace].key;

			//Find the item with the key that needs to be replaced and exchange all the fields
			for (int i = 0; i < state.initList.length; i++){
				if (event.key == state.initList[i].key){
					state.initList[i] = event.newItem;
				}
			}

      		//Sort list
			sortInitList(state.initList);

			//Find the item with the saved key and set it as the currently selected item
			for (int i = 0; i < state.initList.length; i++){
				if (state.initList[i].key == currItemKey){
					newListPlace = i;
					break;
				}
			}

			emit(InitTrackerBlocState(
				initList: state.initList,
				listPlace: newListPlace,
        roundCounter: state.roundCounter,
			));
		});

		on<DeleteAll>((event, emit){
			emit(InitTrackerBlocState(
				initList: [],
				listPlace: 0,
        roundCounter: 1,
			));
		});

		on<RestartTracker>((event, emit){
			emit(InitTrackerBlocState(
				initList: state.initList,
				listPlace: 0,
				isNewRound: true,
        roundCounter: 1,
			));
		});

		on<SaveTracker>((event, emit) async {
			File outputFile = File(event.filename);
			try {
				List<Map<String, dynamic>> outputJsonMap = state.initList.map((e) => e.toJson()).toList();
				String outputStr = const JsonEncoder().convert(outputJsonMap);
				log(outputStr);
				await outputFile.writeAsString(outputStr);
				emit(InitTrackerBlocState(
					initList: state.initList,
					listPlace: state.listPlace,
					isNewRound: false,
					displayString: "${event.filename} created successfully.",
					hasError: false,
          roundCounter: state.roundCounter,
				));
			}
			catch (ex){
				log("Error: $ex");
				emit(InitTrackerBlocState(
					initList: state.initList,
					listPlace: state.listPlace,
					isNewRound: false,
					displayString: "Error creating ${event.filename}. File not created.",
					hasError: true,
          roundCounter: state.roundCounter,
				));
			}

		});

		on<LoadTracker>((event, emit) async {
			try {					
				File file = File(event.filename);
				String fileContents = await file.readAsString();
				final List<dynamic> jsonMap = jsonDecode(fileContents);
				List<InitTrackerItem> initListTemp = [];
				for (Map<String, dynamic> item in jsonMap){
					initListTemp.add(InitTrackerItem.fromJson(item));
				}

				emit(InitTrackerBlocState(
					initList: initListTemp,
					listPlace: state.listPlace,
					isNewRound: false,
					displayString: "${event.filename} loaded successfully.",
					hasError: false,
          roundCounter: 0
				));
			}
			catch (ex){
				log("Error loading file: ", error: ex);
				emit(InitTrackerBlocState(
					initList: state.initList,
					listPlace: state.listPlace,
					isNewRound: false,
					displayString: "Error loading ${event.filename}. File not loaded.",
					hasError: true,
          roundCounter: 0,
				));
			}

		});

		on<SwitchSystem>((event, emit){
			selectedSystem = event.system;
		});

	}
	
	void sortInitList(List<InitTrackerItem> initList){

		//Sort high to low initative for most systems; otherwise, use custom sorting
		if (selectedSystem.computerReadableName == SystemChoices.vtm.computerReadableName){
			int categorySort(InitTrackerItem item1, InitTrackerItem item2) => item1.category.priority.compareTo(item2.category.priority);	
			int groupSort(InitTrackerItem item1, InitTrackerItem item2) => item1.group.compareTo(item2.group);	
			int initSort(InitTrackerItem item1, InitTrackerItem item2) => item1.initiative.compareTo(item2.initiative) * -1;	

			final compareItems = categorySort.then(groupSort).then(initSort);

			initList.sort(compareItems);
		}
		else {
			initList.sort((a, b) => a.initiative.compareTo(b.initiative) * -1);
		}
	}
}
