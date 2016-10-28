// 'gui_trigger_spell_set'
//
// kevL 2016 sept 13
// Callback for the GUI-inputbox that sets the trigger-spell to be used for
// crafting with ImbueItem.


#include "ginc_crafting"

void main(string sSpellId)
{
	//TellCraft("Run ( gui_trigger_spell_set ) " + GetName(OBJECT_SELF) + " ( " + GetTag(OBJECT_SELF) + " )");
	//TellCraft(". sSpellId= _" + sSpellId + "_");

	object oModule = GetModule();

	// NOTE: GUI sends 'sSpellId' with a space tacked on the end, even if blank.
	// NOTE: GUI considers Escape-key as Okay instead of Cancel.
	// NOTE: 'backoutkey=false' doesn't work in GUI.

	sSpellId = StringTrim(sSpellId);
	if (sSpellId != "" && isSpellId(sSpellId))
	{
		TellCraft(". sSpellId= _" + sSpellId + "_");

		object oCrafter = GetControlledCharacter(OBJECT_SELF);

		if (sSpellId == "1081") // Imbue_Item is NOT allowed here.
			NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_ERROR
						+ "Spell ID <b>1081</b> ( Imbue Item ) is NOT allowed. Try again.");
		else
		{
			SetLocalObject(oModule, CRAFT_VAR_CRAFTER, oCrafter);

			int iSpellId = StringToInt(sSpellId);
			SetLocalInt(oModule, CRAFT_VAR_SPELLID_II, iSpellId);

			string sRef = Get2DAString("spells", "Name", iSpellId);
			sRef = GetStringByStrRef(StringToInt(sRef));
			NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_II_SPELLID + "<b>" + sSpellId + "</b>" + NOTE_II_COLOR_SPELL + sRef + NOTE_II_COLOR_CLOSE + "\n");

			object oContainer = GetLocalObject(oModule, CRAFT_VAR_CONTAINER_II);
			ExecuteScript("ii_trigger_spell", oContainer);

			// clean up.
			DeleteLocalInt(oModule, CRAFT_VAR_SPELLID_II);
			DeleteLocalObject(oModule, CRAFT_VAR_CRAFTER);
		}
	}

	// clean up.
	//TellCraft(". delete CRAFT_VAR_CONTAINER_II");
	DeleteLocalObject(oModule, CRAFT_VAR_CONTAINER_II);
}
