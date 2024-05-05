part of 'init_tracker_bloc.dart';

class InitTrackerBlocEvent {
	InitTrackerBlocEvent();
}

class AddInitItem extends InitTrackerBlocEvent {
	InitTrackerItem item;

	AddInitItem({required this.item});
}

class AdvanceTracker extends InitTrackerBlocEvent {
	AdvanceTracker();
}

class DeleteItem extends InitTrackerBlocEvent {
	UniqueKey key;

	DeleteItem({required this.key});
}

class DeleteAll extends InitTrackerBlocEvent {
	DeleteAll();
}

class RestartTracker extends InitTrackerBlocEvent {
	RestartTracker();
}

class EditItem extends InitTrackerBlocEvent {
  UniqueKey key;
  InitTrackerItem newItem;

  EditItem({required this.key, required this.newItem});
}
class SaveTracker extends InitTrackerBlocEvent {
	String filename;
	SaveTracker({required this.filename});
}

class LoadTracker extends InitTrackerBlocEvent {
	String filename;
	LoadTracker({required this.filename});
}