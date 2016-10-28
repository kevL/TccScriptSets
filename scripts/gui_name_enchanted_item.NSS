// 'gui_name_enchanted_item'
/*
	Renames an item w/ the input-string.
	Callback always runs with the player's OwnedPC as OBJECT_SELF.
*/
// ChazM 5/24/06
// ChazM 5/31/06 Update to reflect where Item object is now stored
// ChazM 9/29/06 Just comments
// kevL 160913 - delete a bunch of comments.
// kevL 160914 - fix.


#include "crafting_inc_const"
#include "ginc_param_const"

void main(string sLabel)
{
	//SendMessageToPC(GetFirstPC(FALSE), "run ( gui_name_enchanted_item ) " + GetName(OBJECT_SELF) + " ( " + GetTag(OBJECT_SELF) + " )");
	//SendMessageToPC(GetFirstPC(FALSE), ". sLabel= _" + sLabel + "_");

	object oModule = GetModule();

	sLabel = StringTrim(sLabel);
	if (sLabel != "")
	{
		//SendMessageToPC(GetFirstPC(FALSE), ". label= _" + sLabel + "_");
		object oItem = GetLocalObject(oModule, CRAFT_VAR_LABELITEM);
//		if (GetIsObjectValid(oItem)) // better be darn valid.
		SetFirstName(oItem, sLabel);
	}

	// clean up.
	DeleteLocalObject(oModule, CRAFT_VAR_LABELITEM);
}
