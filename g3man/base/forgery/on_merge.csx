using UndertaleModLib.Models;

UndertaleGameObject cloneObject(UndertaleGameObject sourceObj, string newName) {
	// Copied with some modifications from GameObjectCopyInternal.csx

	UndertaleGameObject obj = new UndertaleGameObject();
	obj.Name = Data.Strings.MakeString(newName);
	Data.GameObjects.Add(obj);
	obj.Visible = sourceObj.Visible;
	obj.Solid = sourceObj.Solid;
	obj.Depth = sourceObj.Depth;
	obj.Persistent = sourceObj.Persistent;
	obj.ParentId = sourceObj.ParentId;
	obj.Events.Clear();
	for (var i = 0; i < sourceObj.Events.Count; i++)
	{
		UndertalePointerList<UndertaleGameObject.Event> newEvent = new UndertalePointerList<UndertaleGameObject.Event>();
		foreach (UndertaleGameObject.Event evnt in sourceObj.Events[i])
		{
			UndertaleGameObject.Event newevnt = new UndertaleGameObject.Event();
			foreach (UndertaleGameObject.EventAction sourceAction in evnt.Actions)
			{
				UndertaleGameObject.EventAction action = new UndertaleGameObject.EventAction();
				newevnt.Actions.Add(action);
				action.LibID = sourceAction.LibID;
				action.ID = sourceAction.ID;
				action.Kind = sourceAction.Kind;
				action.UseRelative = sourceAction.UseRelative;
				action.IsQuestion = sourceAction.IsQuestion;
				action.UseApplyTo = sourceAction.UseApplyTo;
				action.ExeType = sourceAction.ExeType;
				action.ActionName = sourceAction.ActionName;
				action.CodeId = sourceAction.CodeId;
				action.ArgumentCount = sourceAction.ArgumentCount;
				action.Who = sourceAction.Who;
				action.Relative = sourceAction.Relative;
				action.IsNot = sourceAction.IsNot;
				action.UnknownAlwaysZero = sourceAction.UnknownAlwaysZero;
			}
			newevnt.EventSubtype = evnt.EventSubtype;
			newEvent.Add(newevnt);
		}
		obj.Events.Add(newEvent);
	}
	return obj;
}

// Duplicating generic objects
UndertaleGameObject obj_generic_item0 = Data.GameObjects.ByName("obj_generic_item0");
UndertaleGameObject obj_generic_perk0 = Data.GameObjects.ByName("obj_generic_perk0");
UndertaleGameObject obj_generic_supervisor0 = Data.GameObjects.ByName("obj_generic_supervisor0");
for (int i = 1; i < 1024; i++) {
	cloneObject(obj_generic_item0, "obj_generic_item" + i.ToString());
	cloneObject(obj_generic_perk0, "obj_generic_perk" + i.ToString());
	cloneObject(obj_generic_supervisor0, "obj_generic_supervisor" + i.ToString());
}