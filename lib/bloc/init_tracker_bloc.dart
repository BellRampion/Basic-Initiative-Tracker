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

      //Set current stamina and movement to equal total stamina and movement
      state.initList[state.listPlace].hocSpecific.currentMovement = state.initList[state.listPlace].hocSpecific.totalMovement;
      state.initList[state.listPlace].hocSpecific.currentStamina = state.initList[state.listPlace].hocSpecific.totalStamina;

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
					if ( item.combatActions > 0){
						--item.combatActions;
            //If we haven't hit 0 on these combat actions, can't start a new round yet
						if (item.combatActions != 0)
						{
							combatActionsFinished = false;
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
          item.hocSpecific.currentMovement = item.hocSpecific.totalMovement;
        }
        //Sort in case groups or combat category have changed
        sortInitList(state.initList);

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
      //Sort in case category or group values have changed
      sortInitList(state.initList);
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
          roundCounter: 1
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
          roundCounter: 1,
				));
			}

		});

		on<SwitchSystem>((event, emit){
			selectedSystem = event.system;
      if (state.initList.isNotEmpty){
        emit(
          InitTrackerBlocState(
            initList: state.initList,
            listPlace: 0,
            isNewRound: false,
            roundCounter: 1,
            hasError: true,
            displayString: "Warning: Switching systems after creating initiative items can cause strange behavior if any system-specific fields are filled out! E.g. if you gave a character combat actions, the round counter will not behave correctly.",
          )
        );
      }
		});

	}
	
	void sortInitList(List<InitTrackerItem> initList){

		//Sort first by category, then by group within category, then by initiative within group
    int categorySort(InitTrackerItem item1, InitTrackerItem item2) => item1.category.priority.compareTo(item2.category.priority);	
    int groupSort(InitTrackerItem item1, InitTrackerItem item2) => item1.group.compareTo(item2.group);	
    int initSort(InitTrackerItem item1, InitTrackerItem item2) => item1.initiative.compareTo(item2.initiative) * -1;	

    final compareItems = categorySort.then(groupSort).then(initSort);

    initList.sort(compareItems);
	}
}
