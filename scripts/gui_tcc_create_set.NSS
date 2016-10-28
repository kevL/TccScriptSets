// 'gui_tcc_create_set'
//
// Turns an item into a Property Set item, which prepares it to receive a latent-ip.


#include "ginc_crafting"

// ________________
// ** CONSTANTS ***
// ----------------
const string CHAR_ALPHA = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ':"; // alphabet + " " and "'" and ":"

// ___________________
// ** DECLARATIONS ***
// -------------------

// Checks if sSetLabel is purely alphabetical.
int isAlpha(string sSetLabel);

// Gets a rand# from the positive half of a signed 32-bit integer.
int GetRand32a();


// ___________
// ** MAIN ***
// -----------
void main(string sSetLabel)
{
	TellCraft("Run ( gui_tcc_create_set ) " + GetName(OBJECT_SELF));

	object oCrafter = GetControlledCharacter(OBJECT_SELF);
	object oModule = GetModule();

	sSetLabel = StringTrim(sSetLabel);
	if (sSetLabel != "" && isAlpha(sSetLabel)) // TODO (if possible) check that sSetLabel is not already being used. (not possible/feasible.)
	{
		int iParts = 0;

		object oContainer = GetLocalObject(oModule, CRAFT_VAR_CONTAINER);
		//TellCraft(". oContainer= " + GetName(oContainer) + " ( " + GetTag(oContainer) + " )");
		object oItem = GetFirstItemInInventory(oContainer);
		while (GetIsObjectValid(oItem))
		{
			//TellCraft(". . iter " + GetName(oItem));
			if (GetIsEquippable(oItem))
				++iParts;

			oItem = GetNextItemInInventory(oContainer);
		}
		string sParts = IntToString(iParts);

		int iGroup = 0;
		while (iGroup == 0) iGroup = GetRand32a();
		string sGroup = IntToString(iGroup);

		oItem = GetFirstItemInInventory(oContainer);
		while (GetIsObjectValid(oItem))
		{
			//TellCraft(". . iter " + GetName(oItem));
			if (!GetIsEquippable(oItem))
				DestroyObject(oItem);
			else
			{
				SetPlotFlag(oItem, TRUE);
				SetLocalInt(oItem, TCC_VAR_SET_PREP_ITEM, TRUE);
				SetLocalInt(oItem, TCC_VAR_SET_GROUP, iGroup);
				SetLocalInt(oItem, TCC_VAR_SET_PARTS, iParts);

				SetFirstName(oItem, sSetLabel + " " + GetFirstName(oItem));
//				SetDescription(oItem, GetDescription(oItem) + "\n\nProperty Set : " + sSetLabel	// TODO: GetDescription() is buggy in that it won't get
//															+ "\ngroup : " + sGroup				// the initial description from a resref -- it works only
//															+ "\nparts : " + sParts);			// after a description has been set on an item.

				NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_SET_PREPARED
							+ GetName(oItem) + " ( " + GetTag(oItem) + " )");
			}
			oItem = GetNextItemInInventory(oContainer);
		}

		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_SUCCESS
					+ "The Property Set is forged !"
					+ "\n. label : " + sSetLabel
					+ "\n. group : " + sGroup
					+ "\n. parts : " + sParts);

		effect eVis = EffectVisualEffect(VFX_FNF_CRAFT_MAGIC);
//		TellCraft(". oContainer= " + GetName(oContainer));
//		ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oContainer); // wtf. This appears on the OwnedPC ...
		location lLoc = GetLocation(oContainer);
		ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, lLoc);
	}
	else
		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_ERROR
					+ "The label of your Property Set must be alphabetical,"
					+ " including spaces, single-quotes, and colons, and have"
					+ " at least one character other than a space.");

	//TellCraft(". delete CRAFT_VAR_CONTAINER");
	DeleteLocalObject(oModule, CRAFT_VAR_CONTAINER);
}


// __________________
// ** DEFINITIONS ***
// ------------------

// Checks if sSetLabel is purely alphabetical.
int isAlpha(string sSetLabel)
{
	int iLength = GetStringLength(sSetLabel);
	int i;
	for (i = 0; i != iLength; ++i)
	{
		if (!TestStringAgainstPattern("**" + GetSubString(sSetLabel, i, 1) + "**", CHAR_ALPHA))
			return FALSE;
	}
	return TRUE;
}

// Gets a rand# from the positive half of a signed 32-bit integer.
// - return: 0..2147483647 (inclusive)
int GetRand32a()
{
	int iRand = 0;

	int i = 1;
	while (TRUE)
	{
		iRand |= Random(2);
		if (++i == 32) break;
		iRand <<= 1;
	}
	return iRand;
}
