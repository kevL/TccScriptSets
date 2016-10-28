// 'gui_tcc_enchant_latent'
//
// kevL 2016 oct 5


#include "ginc_crafting"

void main()
{
	//TellCraft("Run ( gui_tcc_enchant_latent ) " + GetName(OBJECT_SELF));

	object oModule = GetModule();

	object oContainer = GetLocalObject(oModule, CRAFT_VAR_CONTAINER);
	object oCrafter = GetControlledCharacter(OBJECT_SELF);

	if (GetLocalInt(oModule, CRAFT_VAR_SPELLID) != -1)
	{
		SetLocalInt(oModule, TCC_VAR_SET_PREP_MOD, TRUE);

		SetLocalObject(oModule, CRAFT_VAR_CRAFTER, oCrafter);

		ExecuteScript("set_enchant_latent", oContainer);
	}
	else // wipe all Set-vars off a Set-item
	{
		object oItem = GetFirstItemInInventory(oContainer);
		while (GetIsObjectValid(oItem))
		{
			if (GetTag(oItem) == "NW_IT_GEM007") // malachite
				DestroyObject(oItem);
			else
			{
				SetPlotFlag(oItem, FALSE);						// erase the plot-flag**
				DeleteLocalInt(oItem, TCC_VAR_SET_PREP_ITEM);	// erase the prep. flag
				DeleteLocalInt(oItem, TCC_VAR_SET_GROUP);		// erase the set-group
				DeleteLocalInt(oItem, TCC_VAR_SET_PARTS);		// erase the qty of parts
				DeleteLocalString(oItem, TCC_VAR_SET_IP);		// erase the latent-ip
			}

			oItem = GetNextItemInInventory(oContainer);
		}

		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_SUCCESS
					+ "All items in the container have been removed from their Property Set.");
	}

	// clean up.
	DeleteLocalObject(oModule, CRAFT_VAR_CONTAINER);
	DeleteLocalObject(oModule, CRAFT_VAR_CRAFTER);
	DeleteLocalInt(oModule, CRAFT_VAR_SPELLID);
}

// **Items that were turned into Set-parts were NOT plot, so clearing the
// plot-flag here ought be reasonably safe.
