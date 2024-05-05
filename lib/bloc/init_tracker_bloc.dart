import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:basic_initiative_tracker/data_models/init_tracker_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'init_tracker_bloc_state.dart';
part 'init_tracker_bloc_event.dart';

class InitTrackerBloc extends Bloc<InitTrackerBlocEvent, InitTrackerBlocState> {
	bool sortOnNewRound = false;

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
			));
		});

		on<AdvanceTracker>((event, emit){
			int currentStep = state.listPlace;
			int newStep;
			newStep = currentStep + 1;

			if (state.initList.isEmpty){
				newStep = 0;
			}
			else if (newStep == state.initList.length)
			{
				newStep = 0;
			}      
			if (newStep == 0){
				emit(InitTrackerBlocState(
					initList: state.initList,
					listPlace: newStep,
					isNewRound: true,
				));
			}
			else {
				emit(InitTrackerBlocState(
					initList: state.initList,
					listPlace: newStep,
					isNewRound: false,
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
			));
		});

		on<DeleteAll>((event, emit){
			emit(InitTrackerBlocState(
				initList: [],
				listPlace: 0,
			));
		});

		on<RestartTracker>((event, emit){
			emit(InitTrackerBlocState(
				initList: state.initList,
				listPlace: 0,
				isNewRound: true,
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
				));
			}

		});

	}
	
	void sortInitList(List<InitTrackerItem> initList){
		//Sort high to low initative
		initList.sort((a, b) => a.initiative.compareTo(b.initiative) * -1);
	}
}
