// 'ginc_crafting'
/*
	Crafting related functions
*/
// ChazM 12/15/05
// kL 16.09.28 - rewritten.


// _______________
// ** INCLUDES ***
//----------------
#include "ginc_item"			// GetIsEquippable()
//#include "x2_inc_itemprop"	// IPGetItemPropertyByID(), IPSafeAddItemProperty(), IPGetIsMeleeWeapon(), IPGetWeaponEnhancementBonus()
								// X2_IP_ADDPROP_POLICY_IGNORE_EXISTING, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING
#include "ginc_param_const"		// GetIntParam(), GetStringParam()
#include "ginc_2da"				// GetIsLegalItemProp()
#include "x2_inc_switches"		// CAMPAIGN_SWITCH_CRAFTING_USE_TOTAL_LEVEL
#include "crafting_inc_const"

//#include "x0_i0_stringlib"	// Sort(), FindListElementIndex(), GetTotalTokens(), GetTokenByPosition()
								// GetStringTokenizer(), AdvanceTokenizer(), GetCurrentToken(), RemoveListElement()

// ________________
// ** CONSTANTS ***
// ----------------
const int TELLCRAFT = FALSE; // toggle for debug.


// ___________________
// ** DECLARATIONS ***
// -------------------

// Debug function for printing feedback to chat and logfile.
void TellCraft(string sText);

// Notifies the player of success or failure-type.
//void NotifyPlayer(object oCrafter, int iStrRef = -1, string sInfo = "");
void NotifyPlayer(object oCrafter, string sInfo);


// -----------------------------------------------------------------------------
// functions that check for valid placeable-containers:

// Checks if oTarget is any of the 3 valid bench-types (magical/smith/alchemy).
int IsWorkbench(object oTarget);

// Checks if oTarget is a valid Magical Workbench (trigger = spell).
int IsMagicalWorkbench(object oTarget);
// Checks if oTarget is a valid Smith Workbench (trigger = smithhammer).
int IsSmithWorkbench(object oTarget);
// Checks if oTarget is a valid Alchemy Workbench (trigger = mortar & pestle).
int IsAlchemyWorkbench(object oTarget);


// -----------------------------------------------------------------------------
// public functions for crafting:

// Does crafting at a Magical Workbench with a triggerspell.
void DoMagicCrafting(int iSpellId, object oCrafter);

// Does crafting at a Smith Workbench with a smith's hammer.
void DoMundaneCrafting(object oCrafter);

// Does crafting at an Alchemy Workbench with a mortar & pestle.
void DoAlchemyCrafting(object oCrafter);

// Distills oItem when mortar & pestle is used directly on it.
void DoDistillation(object oItem, object oCrafter);

// Helper for DoDistillation() -- but also used directly by the mortar & pestle
// on Fairy Dust and Shadow Reaver Bones.
void ExecuteDistillation(int iRankRQ,
						 object oItem,
						 object oCrafter,
						 string sResrefList);


// -----------------------------------------------------------------------------
// functions for general crafting:

// Gets the row of Crafting.2da that matches input-variables.
void GetRecipeMatchSorted();
// Gets all reagents sorted into an alphabetical list (case-sensitive).
void GetReagentTags();
// Gets a list of tags for any stacksize of oItem.
string GetStackableTags(object oItem);
// Gets the first row in Crafting.2da that's within a determined range of rows
// and that matches _sReagentTags, _sTriggerId, and is the correct TCC-type (TAGS).
void GetRecipeMatch();
// Gets a list of comma-delimited indices into Crafting.2da that will be valid
// recipes for SPELL_IMBUE_ITEM.
void GetRecipeMatches();
// Finds and erases Crafting.2da indices that would result in the same
// applied-ip or construction-resref.
void GetRecipeMatchesCropped();
// Takes a list of Crafting.2da indices and tells player what the candidate
// triggers for SPELL_IMBUE_ITEM are.
int DisplayRecipeMatches(object oCrafter);

// Gets the first and last rows in Crafting.2da for _sTriggerId.
void GetTriggerRange();
// Checks if _sTriggerId is a spell-id (is purely numeric).
int isSpellId(string sTriggerId);
// Finds the first match in Crafting.2da for a sorted string of reagent-tags.
void GetRecipeForReagents();
// Checks if the type of oItem matches permitted values in Crafting.2da TAGS.
int isTypeMatch(string sTypesValid);
// Gets the TCC-type of oItem.
int GetTccType(object oItem);

// Destroys the reagents in the crafting-container.
void DestroyReagents();
// Creates the items of sResrefList in the inventory of oContainer.
void CreateProducts(string sResrefList,
					object oContainer = OBJECT_SELF,
					int bFullStack = FALSE,
					int iBonus = -1);

// Applies bonuses to crafted masterwork oItem.
void ApplyMasterworkBonus(object oItem, int iBonus);


// -----------------------------------------------------------------------------
// private functions for Magical Crafting:

//
void GetEnchantable();
//
int GetIsException(object oItem);

// Gets if _oEnchantable has an ip that excludes that of _iRecipeId.
int hasExcludedProp();
// Gets the material of oItem if any.
int GetMaterialType(object oItem);
// Gets the quantity of ip's of iPropType on oItem.
int GetQtyPropsOfType(object oItem, int iPropType);

// Clears a corresponding Attack bonus when upgrading to an Enhancement bonus
// that is equal or greater.
int ReplaceAttackBonus(object oItem,
					   int iPropType,
					   int iCost,
					   int iSubtype);
// Clears iPropType from oItem if iCost is higher or equal to existing CostValue.
int ClearIpType(object oItem,
				int iPropType,
				int iCost,
				int iSubtype = -1);

// Searches oItem for an ip similar to ipProp.
int isIpUpgrade(object oItem, itemproperty ipProp);
// Gets variable prop-costs already used on oItem.
int GetCostSlotsUsed(object oItem);
// Gets the quantity of ip's on oItem.
int GetPropSlotsUsed(object oItem);

// Checks if an already existing ip should be ignored.
int isIgnoredIp(itemproperty ip);
// Checks if adding an ip should ignore subtype.
int isIgnoredSubtype(itemproperty ip);


// -----------------------------------------------------------------------------
// functions for Property Sets:

// Checks for and clears items from their Set.
int ClearSetParts(object oCrafter);

// Gets the quantity of Property Set ip's stored on oItem.
int GetQtyLatentIps(object oItem);
// Checks if any crafting-container content has been prepared to receive a
// latent-ip.
int CheckLatentPrepared(object oCrafter);
// Checks that Set-creation can proceed.
int CheckSetCreation(object oCrafter, int iPartsRequired);


// -----------------------------------------------------------------------------
// private functions for salvage operations:

// Scans the ip's of oItem and produces salvaged materials.
void ExecuteSalvage(object oItem, object oCrafter);

// -----------------------------------------------------------------------------
// helper functions for salvaging:

// Gets the index of the salvage row associated with ipProp.
int GetSalvageId(itemproperty ipProp);
// Gets the salvage grade for ipProp.
int GetSalvageGrade(itemproperty ipProp, int iSalvageId);
// Gets the skill DC related by iSalvageId and iGrade.
int GetSalvageDC(int iSalvageId, int iGrade);
// Gets the tag of the essence related by iSalvageId and iGrade.
string GetSalvageEssence(int iSalvageId, int iGrade);
// Gets the tag of the gem related by iSalvageId and iGrade.
string GetSalvageGem(int iSalvageId, int iGrade);


// -----------------------------------------------------------------------------
// functions that invoke GUI-inputboxes:

// Invokes a GUI-inputbox for player to relabel oItem.
void GuiEnchantedLabel(object oCrafter, object oItem);

// Opens a GUI inputbox for entering an Imbue_Item triggerspell.
void GuiTriggerSpell(object oCrafter);

// Opens a GUI-inputbox that creates a Set and allows player to label it.
void GuiCreateSet(object oCrafter);
// Opens a GUI-dialog that asks player whether to proceed with adding a
// latent-ip to a Property Set-prepared part.
void GuiPrepareLatent(object oCrafter, int iSpellId);


// -----------------------------------------------------------------------------
// public functions for mortar & pestle and shaper's alembic:

// Sets up a list of up to 10 elements.
string MakeList(string sReagent1,
				string sReagent2  = "",
				string sReagent3  = "",
				string sReagent4  = "",
				string sReagent5  = "",
				string sReagent6  = "",
				string sReagent7  = "",
				string sReagent8  = "",
				string sReagent9  = "",
				string sReagent10 = "");


// -----------------------------------------------------------------------------
// functions for SoZ crafting:

// Checks if all sEncodedIps qualify as an upgrade.
int GetAreAllEncodedEffectsAnUpgrade(object oItem, string sEncodedIps);
// Checks if sEncodedIp is an upgrade.
int GetIsEncodedEffectAnUpgrade(object oItem, string sEncodedIp);
// Constructs an ip from sEncodedIp.
itemproperty GetEncodedEffectItemProperty(string sEncodedIp);
// Gets whether ip will be treated as an upgrade.
int GetIsItemPropertyAnUpgrade(object oItem, itemproperty ip);
// Applies all sEncodedIps to oItem.
void ApplyEncodedEffectsToItem(object oItem, string sEncodedIps);
// Adds sEncodedIp to oItem.
void AddEncodedIp(object oItem, string sEncodedIp);


// -----------------------------------------------------------------------------
// functions that were factored into others or are unused:

//
//string MakeEncodedEffect(int iPropType, int iPar1 = 0, int iPar2 = 0, int iPar3 = 0, int iPar4 = 0);
//
//void AddItemPropertyAutoPolicy(object oItem, itemproperty ip, float fDuration = 0.f);

// revised enchantment targeting
// not used.
//object GetEnchantmentTarget(string sTagList, object oContainer);


// __________________
// ** DEFINITIONS ***
// ------------------

// Debug function for printing feedback to chat and logfile.
void TellCraft(string sText)
{
	if (TELLCRAFT)
	{
		PrintString(sText);
		SendMessageToPC(GetFirstPC(FALSE), sText);
	}
}

/* Notifies the player of success or failure-type.
// - if (iStrRef=-1) then send player sInfo
void NotifyPlayer(object oCrafter, int iStrRef = -1, string sInfo = "")
{
	if (iStrRef != -1)
		SendMessageToPCByStrRef(oCrafter, iStrRef);
	else
		SendMessageToPC(oCrafter, sInfo);
} */
// Notifies the player of success or failure-type.
void NotifyPlayer(object oCrafter, string sInfo)
{
	SendMessageToPC(oCrafter, sInfo);
}


// -----------------------------------------------------------------------------
// functions that check for valid placeable-containers
// -----------------------------------------------------------------------------

// Checks if oTarget is any of the 3 valid bench-types (magical/smith/alchemy).
int IsWorkbench(object oTarget)
{
	if (GetObjectType(oTarget) == OBJECT_TYPE_PLACEABLE)
	{
		int iLengthPre = GetStringLength(TAG_WORKBENCH_PREFIX1); // oh bother.

		string sTagPre = GetStringLeft(GetTag(oTarget), iLengthPre);
		if (sTagPre == TAG_WORKBENCH_PREFIX1 || sTagPre == TAG_WORKBENCH_PREFIX2)
			return TRUE;
	}

	if (   IsMagicalWorkbench(oTarget)
		|| IsSmithWorkbench(oTarget)
		|| IsAlchemyWorkbench(oTarget))
	{
		return TRUE;
	}

	return FALSE;
}

// Checks if oTarget is a valid Magical Workbench (trigger = spell).
// - magical workbench can be identified by its tag or by a local variable
int IsMagicalWorkbench(object oTarget)
{
	if (GetObjectType(oTarget) == OBJECT_TYPE_PLACEABLE)
	{
		if (GetLocalInt(oTarget, VAR_MAGICAL))
			return TRUE;

		string sTargetTag = GetTag(oTarget);
		if (   sTargetTag == TAG_MAGICAL_BENCH1
			|| sTargetTag == TAG_MAGICAL_BENCH2
			|| sTargetTag == TAG_MAGICAL_BENCH3
			|| sTargetTag == TAG_MAGICAL_BENCH4)
		{
			return TRUE;
		}
	}

	return FALSE;
}

// Checks if oTarget is a valid Smith Workbench (trigger = smithhammer).
// - smith workbench can be identified by its tag or by a local variable
int IsSmithWorkbench(object oTarget)
{
	if (GetObjectType(oTarget) == OBJECT_TYPE_PLACEABLE)
	{
		if (GetLocalInt(oTarget, VAR_BLACKSMITH))
			return TRUE;

		string sTargetTag = GetTag(oTarget);
		if (   sTargetTag == TAG_WORKBENCH1
			|| sTargetTag == TAG_WORKBENCH2
			|| sTargetTag == TAG_WORKBENCH3
			|| sTargetTag == TAG_WORKBENCH4)
		{
			return TRUE;
		}
	}

	return FALSE;
}

// Checks if oTarget is a valid Alchemy Workbench (trigger = mortar & pestle).
// - alchemy workbench can be identified by its tag or by a local variable
int IsAlchemyWorkbench(object oTarget)
{
	if (GetObjectType(oTarget) == OBJECT_TYPE_PLACEABLE)
	{
		if (GetLocalInt(oTarget, VAR_ALCHEMY))
			return TRUE;

		string sTargetTag = GetTag(oTarget);
		if (   sTargetTag == TAG_ALCHEMY_BENCH1
			|| sTargetTag == TAG_ALCHEMY_BENCH2
			|| sTargetTag == TAG_ALCHEMY_BENCH3
			|| sTargetTag == TAG_ALCHEMY_BENCH4)
		{
			return TRUE;
		}
	}

	return FALSE;
}


// kL: TODO ->
/*
int GetPrestigeCasterLevelByClassLevel(int nClass, int nClassLevel, object oTarget); 'cmi_includes'

int GetWarlockCasterLevel(object oCaster); 'cmi_ginc_spells'
int GetBlackguardCasterLevel(object oCaster);
int GetAssassinCasterLevel(object oCaster);

int GetPalRngCasterLevel(object oCaster = OBJECT_SELF); 'cmi_ginc_palrng'
int GetCasterLevelForPaladins(object oCaster = OBJECT_SELF);
int GetCasterLevelForRangers(object oCaster = OBJECT_SELF);
int GetRawPaladinCasterLevel(object oCaster = OBJECT_SELF);
int GetRawRangerCasterLevel(object oCaster = OBJECT_SELF);

int GetBardicClassLevelForUses(object oCaster); 'cmi_ginc_chars'
int GetBardicClassLevelForSongs(object oCaster);
*/
// -----------------------------------------------------------------------------
// public functions for crafting
// -----------------------------------------------------------------------------

// __________________
// ** SCRIPT VARS ***
// ------------------
object _oEnchantable;		// the item that will be enchanted
int    _iEnchantableParts;	// the quantity of items that can be enchanted (for Set creation)
string _sTriggerId;			// the Spell-ID/ mold prefix/ ALC- or DIS-string that triggers the recipe-id
string _sReagentTags;		// the list of reagent-tags in the crafting-container/enchanter's satchel
string _sRecipeList;		// the list of Crafting.2da indices for Imbue Item
int    _iRecipeId;			// the Crafting.2da index of the final recipe

int    _iRecipeIdFirst;		// the first possible recipe-id for the trigger
int    _iRecipeIdLast;		// the last possible recipe-id for the trigger


// ____________________________________________________________________________
//  ----------------------------------------------------------------------------
//   MAGICAL CRAFTING
// ____________________________________________________________________________
//  ----------------------------------------------------------------------------

// Does crafting at a Magical Workbench with a spell trigger.
// - this covers two types of crafting:
// 1. Item Enchanting requires a set of reagents, an item to work on, and a
//    spell that triggers the recipe.
// 2. Item Construction requires a set of reagents and a spell that triggers the
//    recipe. A new item is created according to the resref given in the recipe.
// - reagents cannot be equippable items including weapons, armor, shields,
//   rings, amulets, etc. because those are ignored when looking at reagent
//   components (unless they're in the exclusion list); if more than 1 equippable
//   item is included with the reagents the one that will be inspected/affected
//   is not well defined -- the first is simply chosen.
void DoMagicCrafting(int iSpellId, object oCrafter)
{
	TellCraft("DoMagicCrafting() " + GetName(OBJECT_SELF) + " ( " + GetTag(OBJECT_SELF) + " )");
	TellCraft(". crafter : " + GetName(oCrafter));
	TellCraft(". spell-id= " + IntToString(iSpellId));
//	TellCraft(". init Script Vars :"
//			+ "\n. . _oEnchantable= "		+ GetName(_oEnchantable)
//			+ "\n. . _iEnchantableParts= "	+ IntToString(_iEnchantableParts)
//			+ "\n. . _sTriggerId= "			+ _sTriggerId
//			+ "\n. . _sReagentTags= "		+ _sReagentTags
//			+ "\n. . _sRecipeList= "		+ _sRecipeList
//			+ "\n. . _iRecipeId= "			+ IntToString(_iRecipeId)
//			+ "\n. . _iRecipeIdFirst= "		+ IntToString(_iRecipeIdFirst)
//			+ "\n. . _iRecipeIdLast= "		+ IntToString(_iRecipeIdLast));

	if (!GetIsObjectValid(GetFirstItemInInventory()))
	{
		TellCraft(". . no items in container : EXIT");
		return;
	}

	// check if player is removing a Property Set item from its Set
	TellCraft(". check Property Set clear items");
	if (ClearSetParts(oCrafter))
	{
		TellCraft(". . Set-items clearance checked : EXIT");
		GuiPrepareLatent(oCrafter, -1);
		return;
	}


	// start magical crafting sequence
	GetEnchantable();

	string sTell;
	if (GetIsObjectValid(_oEnchantable))
	{
		if ((sTell = GetName(_oEnchantable)) != "") sTell = sTell;
		else sTell = "blank";

		string sTell2;
		if ((sTell2 = GetTag(_oEnchantable)) != "") sTell += " ( " + sTell2 + " )";
		else sTell += " ( tag blank )";
	}
	else
		sTell = "_invalid_";

	TellCraft(". _oEnchantable : " + sTell);
	TellCraft(". _iEnchantableParts : " + IntToString(_iEnchantableParts));


	_sTriggerId = IntToString(iSpellId);

	if (iSpellId == SPELL_IMBUE_ITEM)
	{
		// if no matches or only one match, bypass trigger-spell GUI and let regular code handle it.
		GetRecipeMatches();
		TellCraft(". . IMBUE_ITEM : _sRecipeList= " + _sRecipeList);

		if (_sRecipeList != "")
		{
//			GetRecipeMatchesCropped();
//			TellCraft(". . . cropped _sRecipeList= " + _sRecipeList);

			if (DisplayRecipeMatches(oCrafter) > 0)
			{
				TellCraft(". . . . call GuiTriggerSpell() & exit");
				GuiTriggerSpell(oCrafter);
				return;
			}
			else TellCraft(". . . . only 1 trigger for Imbue_Item & continue");
		}
		else TellCraft(". . . no trigger for Imbue_Item & continue");
	}


	GetRecipeMatchSorted();
	TellCraft(". _iRecipeId= " + IntToString(_iRecipeId));

	if (_iRecipeId == -1 || StringToInt(Get2DAString(CRAFTING_2DA, COL_CRAFTING_DISABLED, _iRecipeId)))
	{
//		NotifyPlayer(oCrafter, ERROR_RECIPE_NOT_FOUND);
		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
					+ "This is not a valid recipe.");
		return;
	}

	if (GetLocalInt(GetModule(), TCC_VAR_SET_PREP_MOD))		// <- set via 'gui_tcc_enchant_latent'
	{
		TellCraft(". . delete TCC_VAR_SET_PREP_MOD");
		DeleteLocalInt(GetModule(), TCC_VAR_SET_PREP_MOD);	// player has okay'd a latent-ip enchantment
	}
	else													// <- check for latent-ip enchant
	{
		switch (CheckLatentPrepared(oCrafter))
		{
			case 0: // proceed with regular construction/enchanting or Property Set creation
				TellCraft(". . no latent items");
				break;

			case 1: // ask to proceed with latent-ip enchanting
				TellCraft(". . call GuiPrepareLatent() & exit");
				GuiPrepareLatent(oCrafter, iSpellId);
				return;

			default: // issue an error
				NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
							+ "There is more than one set-prepared parts in the container.");
				return;
		}
	}

// +++ check additional criteria ->

	// check if caster is of sufficient level
	int iCasterLevel = GetCasterLevel(oCrafter);
	if (GetGlobalInt(CAMPAIGN_SWITCH_CRAFTING_USE_TOTAL_LEVEL))
	{
		int iTotalLevel = GetTotalLevels(oCrafter, FALSE);
		if (iCasterLevel < iTotalLevel)
			iCasterLevel = iTotalLevel;
	}
	TellCraft(". iCasterLevel= " + IntToString(iCasterLevel));

	if (StringToInt(Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 3)) // TCC_Toggle_RequireCasterLevel
		&& iCasterLevel < StringToInt(Get2DAString(CRAFTING_2DA, COL_CRAFTING_SKILL_LEVEL, _iRecipeId)))
	{
//		NotifyPlayer(oCrafter, ERROR_INSUFFICIENT_CASTER_LEVEL);
		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
					+ "Your caster level is not high enough to craft this recipe.");
		return;
	}

	int iTccType = GetTccType(_oEnchantable);
	TellCraft(". iTccType= " + IntToString(iTccType));

	// check if caster has the required feat
	if (StringToInt(Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 4))) // TCC_Toggle_RequireFeats
	{
		// Crafting.2da "SKILL" for magical Crafting
		// -2  : no feat required
		// -1  : check feat based on TCC-type of _oEnchantable
		//  0+ : check corresponding feat in Feat.2da
		string sFeat = Get2DAString(CRAFTING_2DA, COL_CRAFTING_CRAFT_SKILL, _iRecipeId);
		int iFeat = StringToInt(sFeat);
		if (iFeat != -2)
		{
			if (sFeat == ""
				|| iFeat == -1	// TODO: update Crafting.2da column ("SKILL") values that currently read "0" to "-1" OR "****".
				|| iFeat ==  0)	// <- 0 is Alertness but should be removed altogether, both here and in the 2da.
			{
				switch (iTccType)
				{
					case TCC_TYPE_ARMOR:
					case TCC_TYPE_SHIELD:
					case TCC_TYPE_BOW:
					case TCC_TYPE_XBOW:
					case TCC_TYPE_SLING:
					case TCC_TYPE_AMMO:
					case TCC_TYPE_MELEE:
						iFeat = FEAT_CRAFT_MAGIC_ARMS_AND_ARMOR;
						break;

					case TCC_TYPE_HEAD:
					case TCC_TYPE_NECK:
					case TCC_TYPE_WAIST:
					case TCC_TYPE_FEET:
					case TCC_TYPE_GLOVES:
					case TCC_TYPE_RING:
					case TCC_TYPE_BACK:
					case TCC_TYPE_INSTRUMENT:
					case TCC_TYPE_CONTAINER:
					case TCC_TYPE_OTHER: // "Other" should never happen.
						iFeat = FEAT_CRAFT_WONDROUS_ITEMS;
						break;

					default:
					case TCC_TYPE_NONE:	// <- construct "OUTPUT" Resref - these *need* a value
						break;			// under Crafting.2da "SKILL" ("0" won't cut it, see TODO above^)
				}
			}

			if (!GetHasFeat(iFeat, oCrafter))
			{
				int iFeatLabel = StringToInt(Get2DAString("feat", "FEAT", iFeat));
				NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
							+ "You do not have the " + GetStringByStrRef(iFeatLabel) + " feat.");
				return;
			}
		}
		TellCraft(". . iFeat= " + IntToString(iFeat));
	}

	object oOwnedPC = GetOwnedCharacter(oCrafter);

	// check if gold required
	int iGP = 0;
	if (Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 36) != "0") // TCC_Toggle_UseRecipeGPCosts
		iGP = StringToInt(Get2DAString(CRAFTING_2DA, "GP", _iRecipeId));
	TellCraft(". iGP= " + IntToString(iGP));

	if (iGP > GetGold(oOwnedPC))
	{
		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
					+ "You don't have enough gold to create that.");
		return;
	}

	// check if experience required
	int iXP = 0;
	if (Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 35) != "0") // TCC_Toggle_UseRecipeXPCosts
		iXP = StringToInt(Get2DAString(CRAFTING_2DA, "XP", _iRecipeId));
	TellCraft(". iXP= " + IntToString(iXP));

	if (iXP > GetXP(oOwnedPC))
	{
		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
					+ "You don't have enough experience to create that.");
		return;
	}

	// determine if a new item is getting created or an existing one is being enchanted
	string sResrefList = Get2DAString(CRAFTING_2DA, COL_CRAFTING_OUTPUT, _iRecipeId);
	TellCraft(". sResrefList= " + sResrefList);

	int bEnchant = FALSE;
	if (sResrefList == "") bEnchant = TRUE;
	TellCraft(". bEnchant= " + IntToString(bEnchant));

	if (bEnchant)
	{
		// validate that an item was succesfully retrieved
//		if (!GetIsObjectValid(_oEnchantable)	// <- this is likely impossible. unless Set Creation with more than 1 part ....
//			&& _iEnchantableParts == 1)			// TODO: Check to ensure that _oEnchantable is equippable and not a creature-slot-item.
		if (_iEnchantableParts == 0) // safety, i guess.
		{
//			NotifyPlayer(oCrafter, ERROR_TARGET_NOT_FOUND_FOR_RECIPE);
			NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
						+ "No enchantable item was found.");
			return;
		}

		int iSetRecipeFirst = StringToInt(Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 32)); // TCC_Value_FirstSetRecipeLine
		int iSetRecipeLast	= StringToInt(Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 2)) + iSetRecipeFirst; // TCC_Value_MaximumSetProperties
		TellCraft(". . PropSet indices : first= " + IntToString(iSetRecipeFirst) + " last= " + IntToString(iSetRecipeLast));

		if (_iRecipeId >= iSetRecipeFirst && _iRecipeId <= iSetRecipeLast)
		{
			TellCraft(". . . Property Set : creation");
			// TODO: Lots ... since this skips all checks on whether latent-ip's
			// will be valid.
			// Devise a method for reverting all items in a Property Set.

			int iPartsRequired = _iRecipeId - iSetRecipeFirst + 1; // NOTE: currently a 1-item Set is permissible.
			if (CheckSetCreation(oCrafter, iPartsRequired))
			{
				TellCraft(". . . . check set creation TRUE");
				TellCraft(". . . . call GuiCreateSet() & exit");
				GuiCreateSet(oCrafter);	// -> assign set-label, group, parts, OR cancel/reject ->
			}							// -> finish DoMagicCrafting() Property Set creation if check passed.
			else TellCraft(". . . . check set creation FALSE & exit");

			return;
		}


		// collect the required recipe information
		string sEncodedIp = Get2DAString(CRAFTING_2DA, COL_CRAFTING_EFFECTS, _iRecipeId);
		TellCraft(". . sEncodedIp= " + sEncodedIp);

		int iPropType = GetIntParam(sEncodedIp, 0, REAGENT_LIST_DELIMITER);
		TellCraft(". . iPropType= " + IntToString(iPropType));
		itemproperty ipEnchant = IPGetItemPropertyByID(iPropType,
													   GetIntParam(sEncodedIp, 1, REAGENT_LIST_DELIMITER),
													   GetIntParam(sEncodedIp, 2, REAGENT_LIST_DELIMITER),
													   GetIntParam(sEncodedIp, 3, REAGENT_LIST_DELIMITER),
													   GetIntParam(sEncodedIp, 4, REAGENT_LIST_DELIMITER));

		// do a validity check although it's probably not thorough
		if (!GetIsItemPropertyValid(ipEnchant))
		{
			TellCraft(". . . ERROR : DoMagicCrafting() ipEnchant is invalid ( " + sEncodedIp
					+ " ) for _iRecipeId= " + IntToString(_iRecipeId));
			NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_ERROR
						+ "The itemproperty in Crafting.2da is malformed for its recipe. Sry bout that . . .");
			return;
		}

		// is the ip-type legal for _oEnchantable
		if (!GetIsLegalItemProp(GetBaseItemType(_oEnchantable), iPropType))
		{
//			NotifyPlayer(oCrafter, ERROR_TARGET_NOT_LEGAL_FOR_EFFECT);
			NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
						+ "Not a valid enchantment for that particular type of item.");
			return;
		}

		// check for properties that arrogate this one
		if (StringToInt(Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 33)) // TCC_Toggle_UseRecipeExclusion
			&& hasExcludedProp())
		{
			NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
						+ "This recipe can't be combined with properties already on the item.");
			return;
		}

		// check for available slots on item for enchants;
		// if good, Do ENCHANTMENTS.
		if (StringToInt(Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 5))) // TCC_Toggle_LimitNumberOfProps
		{
// Check Upgrade ->
			// look for an existing ip being replaced or upgraded
			// NOTE: This is not necessarily an upgarde; an ip can be downgraded
			// or exactly the same ip can even be applied.
			int bUpgrade = FALSE;
			// check if an Enhancement bonus is equal or better than existing Attack bonuses
			if (iTccType == TCC_TYPE_MELEE) // note: Not sure what else should do this ->
				bUpgrade = ReplaceAttackBonus(_oEnchantable,
											  iPropType,
											  GetItemPropertyCostTableValue(ipEnchant),
											  GetItemPropertySubType(ipEnchant));

			if (!bUpgrade)
				bUpgrade = isIpUpgrade(_oEnchantable, ipEnchant);

			TellCraft(". . . bUpgrade= " + IntToString(bUpgrade));


			if (!bUpgrade)
			{
// Check FreeProp ->
				// check if ip to be added is free
				int bTCC_UseVariableSlotCosts	= StringToInt(Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 34)); // TCC_Toggle_UseVariableSlotCosts
				int bTCC_SetPropsAreFree		= StringToInt(Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 25)); // TCC_Toggle_SetPropsAreFree

				int bTCC_LimitationPropsAreFree	= StringToInt(Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 22)); // TCC_Toggle_LimitationPropsAreFree
				int bTCC_LightPropsAreFree		= StringToInt(Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 23)); // TCC_Toggle_LightPropsAreFree
				int bTCC_VFXPropsAreFree		= StringToInt(Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 24)); // TCC_Toggle_VFXPropsAreFree

				int bFreeProp = FALSE;
				if (bTCC_UseVariableSlotCosts
					&& !StringToInt(Get2DAString(ITEM_PROP_DEF_2DA, COL_ITEM_PROP_DEF_SLOTS, iPropType)))
				{
					bFreeProp = TRUE;
				}
				else if (bTCC_SetPropsAreFree && GetLocalInt(_oEnchantable, TCC_VAR_SET_PREP_ITEM))
					bFreeProp = TRUE;
				else
				{
					switch (iPropType)
					{
						case ITEM_PROPERTY_USE_LIMITATION_CLASS:
						case ITEM_PROPERTY_USE_LIMITATION_RACIAL_TYPE:
						case ITEM_PROPERTY_USE_LIMITATION_ALIGNMENT_GROUP:
						case ITEM_PROPERTY_USE_LIMITATION_SPECIFIC_ALIGNMENT:
							if (bTCC_LimitationPropsAreFree)
								bFreeProp = TRUE;
							break;

						case ITEM_PROPERTY_LIGHT:
							if (bTCC_LightPropsAreFree)
								bFreeProp = TRUE;
							break;

						case ITEM_PROPERTY_VISUALEFFECT:
							if (bTCC_VFXPropsAreFree)
								bFreeProp = TRUE;
					}
				}
				TellCraft(". . . bFreeProp= " + IntToString(bFreeProp));


				if (!bFreeProp)
				{
// Tally Bonuses & Discounts ->
					int iBonus = 0; // NOTE: Bonus & Discount amount to the same thing.
					int iDiscount = 0;

// masterwork ->
					// grant a bonus if the item is masterwork
					int iMasterworkBonus = StringToInt(Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 6)); // TCC_Value_GrantMasterworkBonusSlots
					if (iMasterworkBonus
						&& (GetLocalInt(_oEnchantable, TCC_VAR_MASTERWORK)
							|| GetStringRight(GetTag(_oEnchantable), 5) == TCC_MASTERWORK_SUF)) // see also "mi_mwk" & "mst_"
					{
						iBonus += iMasterworkBonus;
						TellCraft(". . . . iMasterworkBonus= " + IntToString(iBonus));
					}

// material ->
					if (StringToInt(Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 8))) // TCC_Toggle_GrantMaterialBonusSlots
					{
						// increase limit by material code if available
						string sCategory;
						switch (iTccType)
						{
							case TCC_TYPE_BOW:
							case TCC_TYPE_XBOW:
							case TCC_TYPE_SLING: sCategory = TCC_BONUS_RANGED; break;
							case TCC_TYPE_AMMO:
							case TCC_TYPE_MELEE: sCategory = TCC_BONUS_WEAPON; break;
							case TCC_TYPE_SHIELD:
							case TCC_TYPE_ARMOR: sCategory = TCC_BONUS_ARMOR;
						}

						if (sCategory != "")
						{
							switch (GetMaterialType(_oEnchantable))
							{
								case GMATERIAL_METAL_ADAMANTINE:														// #1 // 1 - MAT_ADA
									iBonus    += StringToInt(Get2DAString(TCC_CONFIG_2da, sCategory + TCC_BONUS, 18));	// adamantine
									iDiscount += StringToInt(Get2DAString(TCC_CONFIG_2da, sCategory + TCC_ALLOW, 18));	// TCC_Value_AdamantinePropSlots
									break;
								case GMATERIAL_METAL_COLD_IRON:															// #2 // 2 - MAT_CLD
									iBonus    += StringToInt(Get2DAString(TCC_CONFIG_2da, sCategory + TCC_BONUS, 17));	// cold iron
									iDiscount += StringToInt(Get2DAString(TCC_CONFIG_2da, sCategory + TCC_ALLOW, 17));	// TCC_Value_ColdIronPropSlots
									break;
								case GMATERIAL_METAL_DARKSTEEL:															// #3 // 3 - MAT_DRK
									iBonus    += StringToInt(Get2DAString(TCC_CONFIG_2da, sCategory + TCC_BONUS,  9));	// darksteel
									iDiscount += StringToInt(Get2DAString(TCC_CONFIG_2da, sCategory + TCC_ALLOW,  9));	// TCC_Value_DarksteelPropSlots
									break;
								case GMATERIAL_WOOD_DUSKWOOD:															// #7 // 4 - MAT_DSK
									iBonus    += StringToInt(Get2DAString(TCC_CONFIG_2da, sCategory + TCC_BONUS, 14));	// duskwood
									iDiscount += StringToInt(Get2DAString(TCC_CONFIG_2da, sCategory + TCC_ALLOW, 14));	// TCC_Value_DuskwoodPropSlots
									break;
								case GMATERIAL_METAL_MITHRAL:															// #5 // 5 - MAT_MTH
									iBonus    += StringToInt(Get2DAString(TCC_CONFIG_2da, sCategory + TCC_BONUS, 10));	// mithral
									iDiscount += StringToInt(Get2DAString(TCC_CONFIG_2da, sCategory + TCC_ALLOW, 10));	// TCC_Value_MithralPropSlots
									break;
								case GMATERIAL_CREATURE_RED_DRAGON:														// #9 // 6 - MAT_RDH
									iBonus    += StringToInt(Get2DAString(TCC_CONFIG_2da, sCategory + TCC_BONUS, 20));	// red dragon hide
									iDiscount += StringToInt(Get2DAString(TCC_CONFIG_2da, sCategory + TCC_ALLOW, 20));	// TCC_Value_RedDragonPropSlots
									break;
								case GMATERIAL_WOOD_SHEDERRAN:															// #13 - kL_add // 7 - MAT_SHD
									iBonus    += StringToInt(Get2DAString(TCC_CONFIG_2da, sCategory + TCC_BONUS, 15));	// shederran
									iDiscount += StringToInt(Get2DAString(TCC_CONFIG_2da, sCategory + TCC_ALLOW, 15));	// TCC_Value_ShederranPropSlots
									break;
								case GMATERIAL_CREATURE_SALAMANDER:														// #10 // 8 - MAT_SLH
									iBonus    += StringToInt(Get2DAString(TCC_CONFIG_2da, sCategory + TCC_BONUS, 11));	// salamander hide
									iDiscount += StringToInt(Get2DAString(TCC_CONFIG_2da, sCategory + TCC_ALLOW, 11));	// TCC_Value_SalamanderPropSlots
									break;
								case GMATERIAL_METAL_ALCHEMICAL_SILVER:													// #6 // 9 - MAT_SLV
									iBonus    += StringToInt(Get2DAString(TCC_CONFIG_2da, sCategory + TCC_BONUS, 16));	// alchemical silver
									iDiscount += StringToInt(Get2DAString(TCC_CONFIG_2da, sCategory + TCC_ALLOW, 16));	// TCC_Value_AlchemicalSilverPropSlots
									break;
								case GMATERIAL_CREATURE_UMBER_HULK:														// #11 // 10 - MAT_UHH
									iBonus    += StringToInt(Get2DAString(TCC_CONFIG_2da, sCategory + TCC_BONUS, 12));	// umber hulk hide
									iDiscount += StringToInt(Get2DAString(TCC_CONFIG_2da, sCategory + TCC_ALLOW, 12));	// TCC_Value_UmberHulkPropSlots
									break;
								case GMATERIAL_CREATURE_WYVERN:															// #12 // 11 - MAT_WYH
									iBonus    += StringToInt(Get2DAString(TCC_CONFIG_2da, sCategory + TCC_BONUS, 13));	// wyvern hide
									iDiscount += StringToInt(Get2DAString(TCC_CONFIG_2da, sCategory + TCC_ALLOW, 13));	// TCC_Value_WyvernPropSlots
									break;
								case GMATERIAL_WOOD_DARKWOOD:															// #8 // 12 - MAT_ZAL
									iBonus    += StringToInt(Get2DAString(TCC_CONFIG_2da, sCategory + TCC_BONUS, 19));	// zalantar
									iDiscount += StringToInt(Get2DAString(TCC_CONFIG_2da, sCategory + TCC_ALLOW, 19));	// TCC_Value_ZalantarPropSlots
							}
						}
						TellCraft(". . . . material type= " + IntToString(GetMaterialType(_oEnchantable))
								+ " category= " + sCategory
								+ " iBonus= " + IntToString(iBonus)
								+ " iDiscount= " + IntToString(iDiscount));
					}

// limitation ->
					int iLimitationSlots = 0;
					int iLimitationProps = 0;

					int iQty;
					int iLimitationType;
					for (iLimitationType = ITEM_PROPERTY_USE_LIMITATION_ALIGNMENT_GROUP; iLimitationType < ITEM_PROPERTY_BONUS_HITPOINTS; ++iLimitationType)
					{
						iQty = GetQtyPropsOfType(_oEnchantable, iLimitationType);

						iLimitationProps += iQty;
						iLimitationSlots += iQty * StringToInt(Get2DAString(ITEM_PROP_DEF_2DA, COL_ITEM_PROP_DEF_SLOTS, iLimitationType));
						TellCraft(". . . . check limitation propType= " + IntToString(iLimitationType) + " iQty= " + IntToString(iQty));
					}

					// grant discount slot credit to offset each limitation property;
					// also grant a bonus slot if the item has any limitation property.
					if (iLimitationProps)
					{
						if (bTCC_LimitationPropsAreFree)
						{
							if (!bTCC_UseVariableSlotCosts)
								iDiscount += iLimitationProps;
							else
								iDiscount += iLimitationSlots;
						}

						if (StringToInt(Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 21))) // TCC_Toggle_GrantLimitationBonusSlot
							++iBonus;
					}
					TellCraft(". . . limitation props - iBonus= " + IntToString(iBonus) + " iDiscount= " + IntToString(iDiscount));

// light ->
					// grant discount slot for each existing light effect
					if (bTCC_LightPropsAreFree)
					{
						int iLightProps = GetQtyPropsOfType(_oEnchantable, ITEM_PROPERTY_LIGHT);

						if (!bTCC_UseVariableSlotCosts)
							iDiscount += iLightProps;
						else
							iDiscount += iLightProps * StringToInt(Get2DAString(ITEM_PROP_DEF_2DA, COL_ITEM_PROP_DEF_SLOTS, ITEM_PROPERTY_LIGHT));
					}
					TellCraft(". . . light props - iBonus= " + IntToString(iBonus) + " iDiscount= " + IntToString(iDiscount));

// visual effect ->
					// grant discount slot for each existing vFx property
					if (bTCC_VFXPropsAreFree)
					{
						int iVfxProps = GetQtyPropsOfType(_oEnchantable, ITEM_PROPERTY_VISUALEFFECT);

						if (!bTCC_UseVariableSlotCosts)
							iDiscount += iVfxProps;
						else
							iDiscount += iVfxProps * StringToInt(Get2DAString(ITEM_PROP_DEF_2DA, COL_ITEM_PROP_DEF_SLOTS, ITEM_PROPERTY_VISUALEFFECT));
					}
					TellCraft(". . . VFX props - iBonus= " + IntToString(iBonus) + " iDiscount= " + IntToString(iDiscount));


// Count Extant Props ->
					// get quantity of existing ip's
					int iPropCount;
					if (bTCC_UseVariableSlotCosts)
						iPropCount = GetCostSlotsUsed(_oEnchantable);
					else
						iPropCount = GetPropSlotsUsed(_oEnchantable);

					// add the quantity of potential ip's from SetProps
					if (!bTCC_SetPropsAreFree)
						iPropCount += GetQtyLatentIps(_oEnchantable);

					TellCraft(". . . iPropCount= " + IntToString(iPropCount));

					int iLowCutoff = iPropCount - iDiscount - iBonus;
					TellCraft(". . . iLowCutoff= " + IntToString(iLowCutoff));


// Get Base Prop Slots ->
					int iTCC_BasePropSlots		= StringToInt(Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE,  7)); // TCC_Value_BasePropSlots
					int iTCC_EpicPropSlotBonus	= StringToInt(Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 37)); // TCC_Value_EpicPropSlotBonus
					TellCraft(". . . iTCC_BasePropSlots= " + IntToString(iTCC_BasePropSlots));
					TellCraft(". . . iTCC_EpicPropSlotBonus= " + IntToString(iTCC_EpicPropSlotBonus));

// Final Check ->
					// perform final slot check
					// grant a bonus if the Caster is of Epic Level (21+)
					if (iCasterLevel < 21 && iTCC_BasePropSlots <= iLowCutoff)
					{
						if (iTCC_BasePropSlots + iTCC_EpicPropSlotBonus > iLowCutoff)
						{
//							NotifyPlayer(oCrafter, ERROR_TARGET_HAS_MAX_ENCHANTMENTS_NON_EPIC);
							NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
										+ "The item can not be further enchanted. Only an epic character can further enchant the item.");
						}
						else
						{
//							NotifyPlayer(oCrafter, ERROR_TARGET_HAS_MAX_ENCHANTMENTS);
							NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
										+ "The item can not be further enchanted.");
						}
						return;
					}
					else if (iCasterLevel > 20 && iTCC_BasePropSlots + iTCC_EpicPropSlotBonus <= iLowCutoff)
					{
//						NotifyPlayer(oCrafter, ERROR_TARGET_HAS_MAX_ENCHANTMENTS);
						NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
									+ "The item can not be further enchanted.");
						return;
					}
				}
			}
		}


// +++ all criteria good to go, add ItemProperty ->
		TellCraft(". . ALL CHECKS PASSED");

		// if this is a Property Set recipe handle it
		if (GetLocalInt(_oEnchantable, TCC_VAR_SET_PREP_ITEM))
		{
			TellCraft(". . . Property Set : add latent ip");

			// NOTE: reagents are NOT destroyed.
			DeleteLocalInt(_oEnchantable, TCC_VAR_SET_PREP_ITEM);

			SetLocalString(_oEnchantable, TCC_VAR_SET_IP, sEncodedIp);

			NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_SUCCESS
						+ "The Set-item has been enchanted ! The reagents are intact.");
		}
		else // not part of a Set
		{
			TellCraft(". . . add ip !");

			DestroyReagents();

			int iPolicy = X2_IP_ADDPROP_POLICY_REPLACE_EXISTING;
			if (isIgnoredIp(ipEnchant))
				iPolicy = X2_IP_ADDPROP_POLICY_IGNORE_EXISTING;

			IPSafeAddItemProperty(_oEnchantable,
								  ipEnchant,
								  0.f,
								  iPolicy,
								  FALSE,
								  isIgnoredSubtype(ipEnchant));

			if (!GetPlotFlag(_oEnchantable))
				GuiEnchantedLabel(oCrafter, _oEnchantable);

			NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_SUCCESS
						+ " The item has been enchanted !");
		}
	}
	else // CONSTRUCTION of a new Item
	{
		TellCraft(". . construct resref(s) !");

		DestroyReagents();
		CreateProducts(sResrefList, OBJECT_SELF, TRUE);

		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_SUCCESS
					+ "The item has been constructed !");
	}


//	NotifyPlayer(oCrafter, OK_CRAFTING_SUCCESS);

	// charge gold coins if required
	if (iGP > 0)
		TakeGoldFromCreature(iGP, oOwnedPC, TRUE);

	// charge experience points if required
	if (iXP != 0)
		GiveXPToCreature(oOwnedPC, -iXP);	// note: Prob should use Get/GiveXP() so it affects only the OwnedPC.
//		SetXP(oOwnedPC, iBaseXP - iXP);		// note: If a negative value is set in Crafting.2da crafters can earn XP.

	effect eVis = EffectVisualEffect(VFX_FNF_CRAFT_MAGIC);
	ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF);
}


// -----------------------------------------------------------------------------
// functions for general crafting
// -----------------------------------------------------------------------------

// Gets the row of Crafting.2da that matches input-variables.
// - note: Distillation uses GetRecipeMatch() directly.
void GetRecipeMatchSorted()
{
	//TellCraft("GetRecipeMatchSorted() _sTriggerId= " + _sTriggerId);
	GetReagentTags();
	//TellCraft(". _sReagentTags= " + _sReagentTags);
	GetRecipeMatch();
	//TellCraft(". _iRecipeId= " + _iRecipeId);
}

// Gets all reagents sorted into an alphabetical list (case-sensitive).
void GetReagentTags()
{
	string sTags;

	object oItem = GetFirstItemInInventory();
	if (!_iEnchantableParts)
	{
		while (GetIsObjectValid(oItem))
		{
			if (sTags != "") sTags += REAGENT_LIST_DELIMITER;
			sTags += GetStackableTags(oItem);

			oItem = GetNextItemInInventory();
		}
	}
	else
	{
		while (GetIsObjectValid(oItem))
		{
			if (!GetIsEquippable(oItem) || GetIsException(oItem))
			{
				if (sTags != "") sTags += REAGENT_LIST_DELIMITER;
				sTags += GetStackableTags(oItem);
			}
			oItem = GetNextItemInInventory();
		}
	}
	_sReagentTags = Sort(sTags);
}

// Gets a list of tags for any stacksize of oItem.
// - never starts or ends w/ a delimiter so it can be a single tag
// - helper for GetReagentTags()
string GetStackableTags(object oItem)
{
	string sTags;

	string sTag = GetTag(oItem);
	if (sTag != "")
	{
		int iStackSize = GetItemStackSize(oItem);
		int i;
		for (i = 0; i != iStackSize; ++i)
		{
			if (i != 0) sTags += REAGENT_LIST_DELIMITER;
			sTags += sTag;
		}
	}
	return sTags;
}

// Gets the first row in Crafting.2da that's within a determined range of rows
// and that matches _sReagentTags, _sTriggerId, and is the correct TCC-type (TAGS).
// - if _oEnchantable is invalid ITEM_CATEGORY_NONE will return a match.
// - finds index of _sReagentTags for _sTriggerId (-1 if not found)
void GetRecipeMatch()
{
	//TellCraft("GetRecipeMatch() _sReagentTags= " + _sReagentTags);
	string sTypesValid;

	GetTriggerRange(); // Crafting.2da rows
	//TellCraft(". _iRecipeIdFirst= " + IntToString(_iRecipeIdFirst) + " _iRecipeIdLast= " + IntToString(_iRecipeIdLast));

	while (_iRecipeIdFirst != -1)
	{
		//TellCraft(". . _iRecipeIdFirst[0]= " + IntToString(_iRecipeIdFirst));
		GetRecipeForReagents();
		//TellCraft(". . _iRecipeIdFirst[1]= " + IntToString(_iRecipeIdFirst));

		switch (_iRecipeIdFirst)
		{
			case -1:
				//TellCraft(". . . RET _iRecipeId -1");
				_iRecipeId = -1;
				return;

			default:
				sTypesValid = Get2DAString(CRAFTING_2DA, COL_CRAFTING_TAGS, _iRecipeIdFirst);
				//TellCraft(". . . sTypesValid= " + sTypesValid);
				if (isTypeMatch(sTypesValid)) // || !GetIsObjectValid(_oEnchantable) <- taken care of by setting Tcc_Config.2da "TAGS" to "0" (TCC-type none)
				{																		// for all Sets *except Set #1* which is "-1" (TCC-type any)
					//TellCraft(". . . . TypeMatch TRUE");
					_iRecipeId = _iRecipeIdFirst;
					return;
				}
		}

		if (++_iRecipeIdFirst > _iRecipeIdLast)
			break;
	}
	//TellCraft(". overshot range RET -1");
	_iRecipeId = -1;
}

// Gets a list of comma-delimited indices into Crafting.2da that will be valid
// recipes for SPELL_IMBUE_ITEM.
// @return - a comma-delimited list of ints that are Crafting.2da rows
//			 ie. the triggerspells for Imbue_Item recipes ("" if none found)
void GetRecipeMatches()
{
	//TellCraft("GetRecipeMatches() ( " + GetName(_oEnchantable) + " )");

	GetReagentTags();
	//TellCraft(". _sReagentTags= " + _sReagentTags);

	string sTypesValid;
	int iPropType;

	GetTriggerRange(); // get Crafting.2da rows per Crafting_Index.2da for SPELL_IMBUE_ITEM
	//TellCraft(". _iRecipeIdFirst= " + IntToString(_iRecipeIdFirst) + " _iRecipeIdLast=" + IntToString(_iRecipeIdLast));

	while (_iRecipeIdFirst != -1)
	{
		//TellCraft(". _iRecipeIdFirst[0]= " + IntToString(_iRecipeIdFirst));
		GetRecipeForReagents();
		//TellCraft(". _iRecipeIdFirst[1]= " + IntToString(_iRecipeIdFirst));

		switch (_iRecipeIdFirst)
		{
			case -1:
				//TellCraft(". . _sRecipeList= " + _sRecipeList);
				return;

			default:
				sTypesValid = Get2DAString(CRAFTING_2DA, COL_CRAFTING_TAGS, _iRecipeIdFirst);
				//TellCraft(". . sTypesValid #" + IntToString(_iRecipeIdFirst) + "= " + sTypesValid);
				if (isTypeMatch(sTypesValid)) // || !GetIsObjectValid(_oEnchantable) <- taken care of by setting Tcc_Config.2da "TAGS" to "0" (TCC-type none)
				{																		// for all Sets *except Set #1* which is "-1" (TCC-type any)
					//TellCraft(". . . TYPEMATCH _iRecipeIdFirst= " + IntToString(_iRecipeIdFirst));
//					int bAdd = TRUE;
//					if (GetIsObjectValid(_oEnchantable))
//					{
						// NOTE: This is also checked in DoMagicCrafting() under bEnchant.
						// Should probably let it happen there (it gives player an error
						// message if failed)... or else repeat what's here in GetRecipeMatch()
						// above^ and take it out of DoMagicCrafting().

						//TellCraft(". . . . _oEnchantable Valid - check for Legal proptype !");
//						iPropType = GetIntParam(Get2DAString(CRAFTING_2DA, COL_CRAFTING_EFFECTS, _iRecipeIdFirst), 0, REAGENT_LIST_DELIMITER);
//						if (!GetIsLegalItemProp(GetBaseItemType(_oEnchantable), iPropType))
//						{
							//TellCraft(". . . . . ip is NOT Legal for type !");
//							bAdd = FALSE;
//						}
						//else TellCraft(". . . . . ip is Legal for type !");
//					}
					//else TellCraft(". . . . _oEnchantable NOT Valid - NO check for Legal proptype !");
//					if (bAdd)
//					{
					if (_sRecipeList != "") _sRecipeList += REAGENT_LIST_DELIMITER;
					_sRecipeList += IntToString(_iRecipeIdFirst);
					//TellCraft(". . . _sRecipeList= " + _sRecipeList);
//					}
				}
		}

		if (++_iRecipeIdFirst > _iRecipeIdLast)
		{
			//TellCraft(". overshot range");
			break;
		}
	}
	//TellCraft(". _sRecipeList= " + _sRecipeList);
}

// CURRENTLY BYPASSED ->
// Finds and erases Crafting.2da indices that would result in the same
// applied-ip or construction-resref.
// - if matches are found it will be the last index that is kept, however the
//   trigger itself will still be the first index.
// - at least 1 index will be kept and returned as long as _sRecipeList is not
//   blank
// - note that blank strings can be handled albeit redundantly at the call pt.
void GetRecipeMatchesCropped()
{
	//TellCraft("GetRecipeMatchesCropped() _sRecipeList= " + _sRecipeList);

	switch (_iEnchantableParts)
	{
		default: return; // 2+ enchantable parts: Set Creation - other factors ensure there are no redundant indices.

		case 1: // enchant an item with an IP. Or a 1-item Set Creation ...
		{
			string sSetRecipeFirst = Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 32); // TCC_Value_FirstSetRecipeLine
			int    iSetRecipeFirst = StringToInt(sSetRecipeFirst);

			string sReagentsFirst = Get2DAString(CRAFTING_2DA, COL_CRAFTING_REAGENTS, iSetRecipeFirst);
			//TellCraft(". . sSetRecipeFirst= " + sSetRecipeFirst + " sReagentsFirst= " + sReagentsFirst);

			GetReagentTags();
			//TellCraft(". . _sReagentTags= " + _sReagentTags);

			if (_sReagentTags != sReagentsFirst)
			{
				//TellCraft(". . . NOT 1st Set recipe");
				int iSetRecipeLast = iSetRecipeFirst + StringToInt(Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 2)); // TCC_Value_MaximumSetProperties

				string sSetRecipe;
				int i;
				for (i = iSetRecipeFirst + 1; i != iSetRecipeLast; ++i)
				{
					sSetRecipe = IntToString(i);
					//TellCraft(". . . . iter= " + sSetRecipe);
					if (FindListElementIndex(_sRecipeList, sSetRecipe, REAGENT_LIST_DELIMITER) != -1)
					{
						//TellCraft(". . . MATCH Found : call RemoveListElement()");
						_sRecipeList = RemoveListElement(_sRecipeList, sSetRecipe, REAGENT_LIST_DELIMITER);
						break; // there'd better be only 1.
					}
				}
			}
			// no break;
		}

		case 0: // create output resref construction
		{
			string sRecipeList;

			string sRecipeId, sRecipeIdTest, sResult, sResultTest;
			int bFound;

			string sCol;
			if (GetIsObjectValid(_oEnchantable))
				sCol = COL_CRAFTING_EFFECTS;
			else
				sCol = COL_CRAFTING_OUTPUT;

			int iTokens = GetTotalTokens(_sRecipeList, REAGENT_LIST_DELIMITER);
			//TellCraft(". iTokens= " + IntToString(iTokens));

			int i, j;
			for (i = 0; i != iTokens; ++i)
			{
				bFound = FALSE;

				sRecipeId = GetTokenByPosition(_sRecipeList, i, REAGENT_LIST_DELIMITER);
				sResult = Get2DAString(CRAFTING_2DA, sCol, StringToInt(sRecipeId));
				//TellCraft(". . sRecipeId= " + sRecipeId + " / sResult= " + sResult);

				for (j = i + 1; j != iTokens; ++j)
				{
					sRecipeIdTest = GetTokenByPosition(_sRecipeList, j, REAGENT_LIST_DELIMITER);
					sResultTest = Get2DAString(CRAFTING_2DA, sCol, StringToInt(sRecipeIdTest));
					//TellCraft(". . . sRecipeIdTest= " + sRecipeIdTest + " / sResultTest= " + sResultTest);

					if (sResultTest == sResult)
					{
						//TellCraft(". . . . MATCH bFound= TRUE");
						bFound = TRUE;
						break;
					}
				}

				if (!bFound)
				{
					//TellCraft(". . bFound is FALSE - add sRecipeId");
					if (sRecipeList != "") sRecipeList += REAGENT_LIST_DELIMITER;
					sRecipeList += sRecipeId;
				}
			}
			_sRecipeList = sRecipeList;
		}
	}
	//TellCraft(". _sRecipeList= " + _sRecipeList);
}

// Takes a list of Crafting.2da indices and tells player what the candidate
// triggers for SPELL_IMBUE_ITEM are.
// @param oCrafter	- the character to send the parsed info to
// @return			- how to proceed:
//					   1 - (or greater) show triggerspell candidates
//					   0 - don't show candidates, only one match, proceed with standard recipe
//					  -1 - no match found, abort recipe
// @note '_sRecipeList' will be in format: "234,34,0,2343" eg. -- no trailing
// delimiter, keeps things compatible with 'x0_i0_stringlib'.
int DisplayRecipeMatches(object oCrafter)
{
	//TellCraft("DisplayRecipeMatches() _sRecipeList= " + _sRecipeList);

	// NOTE: '_sRecipeList' will not be blank; it was checked in DoMagicCrafting().

	string sCol;
	switch (_iEnchantableParts)
	{
		case 0: // construct output resref
			sCol = COL_CRAFTING_OUTPUT; // <- output resref
			break;

		case 1: // enchant an item with an IP. Or a 1-item Set Creation ...
			sCol = COL_CRAFTING_EFFECTS; // <- encoded-ip

//		default: // 2+ EnchantableParts - multi-part Set Creation: don't worry about it (should never get here).
	}

	// First, get all possible results from '_sRecipeList'.
	// - store each uniquely in ResultList
	string sResult, sResultList;

	struct tokenizer rTok = GetStringTokenizer(_sRecipeList, REAGENT_LIST_DELIMITER);
	while (CheckMoreTokens(rTok))
	{
		rTok = AdvanceTokenizer(rTok);

		sResult = Get2DAString(CRAFTING_2DA, sCol, StringToInt(GetCurrentToken(rTok)));
		if (sResult != "") // could be a 1-item Set Creation ...
		{
			if (FindListElementIndex(sResultList, sResult, ENCODED_IP_LIST_DELIMITER) == -1)
			{
				if (sResultList != "") sResultList += ENCODED_IP_LIST_DELIMITER;
				sResultList += sResult;
			}
		}
		else // 1-item Set Creation
		{
			if (sResultList != "") sResultList += ENCODED_IP_LIST_DELIMITER;
			sResultList += TCC_SET_CREATION; // ... there will be only 1.
		}
	}

	// Second, beneath each Result list all the RecipeMatch's for it.
	string sInfoSpells, sResultLabel, sResultTest, sSpellId, sSpellLabel;
	int iPropType, iRecipeId;

	int iProceed = -1;

	struct tokenizer rTok2 = GetStringTokenizer(sResultList, ENCODED_IP_LIST_DELIMITER);
	while (CheckMoreTokens(rTok2))
	{
		++iProceed;

		rTok2 = AdvanceTokenizer(rTok2);
		sResult = GetCurrentToken(rTok2);

		// construct a header for each Result
		switch (_iEnchantableParts) // note: This value won't change between tokens.
		{
			case 0: // create output resref construction
				sInfoSpells += "\n\n<c=seagreen>Construct Item (</c> <c=antiquewhite>" + sResult + "</c> <c=seagreen> )</c>";
				break;

			case 1: // enchant an item with an IP. Or a 1-item Set Creation ...
				if (sResult != TCC_SET_CREATION)
				{
					iPropType = GetIntParam(sResult, 0, REAGENT_LIST_DELIMITER);
					sResultLabel = GetStringByStrRef(StringToInt(Get2DAString(ITEM_PROP_DEF_2DA, COL_ITEM_PROP_DEF_NAME, iPropType)));

					sInfoSpells += "\n\n<c=seagreen>Enchant Property : " + sResultLabel + " (</c> <c=antiquewhite>" + sResult + "</c> <c=seagreen>)</c>";
				}
				else // 1-item Set Creation
					sInfoSpells += "\n\n<c=seagreen>Set Creation (</c> <c=antiquewhite>1 part</c> <c=seagreen>)</c>";
		}

		// list all RecipeMatch's beneath the header
		rTok = GetStringTokenizer(_sRecipeList, REAGENT_LIST_DELIMITER);
		while (CheckMoreTokens(rTok))
		{
			rTok = AdvanceTokenizer(rTok);
			iRecipeId = StringToInt(GetCurrentToken(rTok));

			sResultTest = Get2DAString(CRAFTING_2DA, sCol, iRecipeId);
			if (sResultTest == sResult
				|| (sResult == TCC_SET_CREATION && sResultTest == ""))
			{
				sSpellId = Get2DAString(CRAFTING_2DA, COL_CRAFTING_CATEGORY, iRecipeId);
				sSpellLabel = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", StringToInt(sSpellId))));

				sInfoSpells += "\n" + NOTE_II_SPELLID + "<b>" + sSpellId + "</b>" + NOTE_II_COLOR_SPELL + sSpellLabel + NOTE_II_COLOR_CLOSE;
			}
		}
	}

	string sInfo;
	switch (iProceed)
	{
		case -1: return -1; // 'iProceed' will NOT be "-1" as along as '_sRecipeList' is NOT blank.

		case 0:
			sInfo = NOTE_CRAFT;
			break;
		default:
			sInfo = "\n" + NOTE_CRAFT + NOTE_IMBUE_ITEM
				  + "There is more than one recipe that is possible with your reagents."
				  + "\nEnter a Spell ID for the desired recipe . . .";
	}
	NotifyPlayer(oCrafter, sInfo + sInfoSpells);

	return iProceed;
}

// Gets the first and last rows in Crafting.2da for _sTriggerId.
// - note: Crafting_Index.2da shall not have blank rows.
// - note: Spells shall be listed first in Crafting_Index.2da and therefore in
//   Crafting.2da also.
void GetTriggerRange()
{
	//TellCraft("GetTriggerRange() _sTriggerId= " + _sTriggerId);

	if (_sTriggerId != "1081") // note: ImbueItem acts as a trigger for any magical recipe.
	{
		int bFound = FALSE;

		int iIndTotal = GetNum2DARows(CRAFTING_INDEX_2DA);
		//TellCraft(". Crafting Index total rows= " + IntToString(iIndTotal));
		int iInd;
		for (iInd = 0; iInd != iIndTotal; ++iInd)
		{
			if (Get2DAString(CRAFTING_INDEX_2DA, COL_CRAFTING_CATEGORY, iInd) == _sTriggerId)
			{
				//TellCraft(". . FOUND= " + IntToString(iInd));
				bFound = TRUE;
				break;
			}
		}

		if (!bFound)
		{
			//TellCraft(". . Crafting Index not found _iRecipeIdFirst -1");
			_iRecipeIdFirst = -1;
//			_iRecipeIdLast  = -1;
		}
		else
		{
			_iRecipeIdFirst = StringToInt(Get2DAString(CRAFTING_INDEX_2DA, COL_CRAFTING_START_ROW, iInd));
			//TellCraft(". . _iRecipeIdFirst= " + IntToString(_iRecipeIdFirst));

			if (iIndTotal - 1 == _iRecipeIdFirst)
				_iRecipeIdLast = _iRecipeIdFirst;
			else
				_iRecipeIdLast = StringToInt(Get2DAString(CRAFTING_INDEX_2DA, COL_CRAFTING_START_ROW, iInd + 1)) - 1;

			//TellCraft(". . _iRecipeIdLast= " + IntToString(_iRecipeIdLast));
		}
	}
	else // Imbue_Item will search all spell-id's ->
	{
		if (_iEnchantableParts > 1) // if more than 1 equippable item then get only the Set-creation recipe-range.
		{
			int iSetRecipeFirst = StringToInt(Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 32)); // TCC_Value_FirstSetRecipeLine
			_iRecipeIdFirst = iSetRecipeFirst + 1; // skip the first Set-creation recipe since it requires only 1 equippable item.
			_iRecipeIdLast  = StringToInt(Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 2)) + iSetRecipeFirst; // TCC_Value_MaximumSetProperties;
		}
		else
		{
			int iInd = 0;
			while (isSpellId(Get2DAString(CRAFTING_INDEX_2DA, COL_CRAFTING_CATEGORY, iInd)))
				++iInd;

			_iRecipeIdFirst = 0;
			_iRecipeIdLast  = StringToInt(Get2DAString(CRAFTING_INDEX_2DA, COL_CRAFTING_START_ROW, iInd)) - 1;
		}
	}
}

// Checks if _sTriggerId is a spell-ID (is purely numeric).
int isSpellId(string sTriggerId)
{
	int iLength = GetStringLength(sTriggerId);
	int i;
	for (i = 0; i != iLength; ++i)
	{
		if (!TestStringAgainstPattern("**" + GetSubString(sTriggerId, i, 1) + "**", DIGITS))
			return FALSE;
	}
	return TRUE;
}

// Finds the first match in Crafting.2da for a sorted string of reagent-tags.
// - note The search does NOT stop at an empty string.
void GetRecipeForReagents()
{
	//TellCraft("GetRecipeForReagents() _sReagentTags= " + _sReagentTags + " _iRecipeIdLast= " + IntToString(_iRecipeIdLast));
	while (_iRecipeIdFirst <= _iRecipeIdLast)
	{
		//TellCraft(". #" + IntToString(_iRecipeIdFirst) + "= " + Get2DAString(CRAFTING_2DA, COL_CRAFTING_REAGENTS, _iRecipeIdFirst));
		if (Get2DAString(CRAFTING_2DA, COL_CRAFTING_REAGENTS, _iRecipeIdFirst) == _sReagentTags)
		{
			//TellCraft(". . FOUND Reagent tags MATCH");
			return;
		}
		++_iRecipeIdFirst;
	}
	//TellCraft(". no match _iRecipeIdFirst -1");
	_iRecipeIdFirst = -1;
}


// Destroys the reagents in the crafting-container.
void DestroyReagents()
{
	object oItem = GetFirstItemInInventory();
	if (!_iEnchantableParts)
	{
		while (GetIsObjectValid(oItem))
		{
			DestroyObject(oItem);
			oItem = GetNextItemInInventory();
		}
	}
	else
	{
		while (GetIsObjectValid(oItem))
		{
			if (!GetIsEquippable(oItem))
				DestroyObject(oItem);

			oItem = GetNextItemInInventory();
		}
	}
}

// Creates the items of sResrefList in the inventory of oContainer.
void CreateProducts(string sResrefList,
					object oContainer = OBJECT_SELF,
					int bFullStack = FALSE,
					int iBonus = -1)
{
	//TellCraft("CreateProducts() ( " + sResrefList + " )");
	object oCreate;

	int i = 0;
	string sResref = GetStringParam(sResrefList, i);
	while (sResref != "")
	{
		//TellCraft(". resref= " + sResref);
		if (iBonus != -1)
		{
			//TellCraft(". masterwork !");
			oCreate = CreateItemOnObject(sResref + TCC_MASTERWORK_SUF, oContainer);
			if (!GetIsObjectValid(oCreate))
			{
				//TellCraft(". . WARNING : no masterwork resref ( " + sResref + TCC_MASTERWORK_SUF + " )");
				oCreate = CreateItemOnObject(sResref, oContainer);
			}
		}
		else
		{
			//TellCraft("creating : " + sResref);
			oCreate = CreateItemOnObject(sResref, oContainer);
		}

		if (GetIsObjectValid(oCreate))
		{
			if (iBonus != -1)
			{
				SetLocalInt(oCreate, TCC_VAR_MASTERWORK, TRUE);	// TODO: remove +1 Attack bonus from .Uti's
																// ie. Allow masterwork items to have no attack bonus
				if (iBonus > 0)									// but are still eligible for extra enchanted IPs.
					ApplyMasterworkBonus(oCreate, iBonus);		// TODO: how does this play with damage bonuses from base-materials
			}

			// TODO: Set the base-material of a crafted item per the ingot-type used when forging it.
			// TODO: in fact just get rid of the masterwork .Uti's and handle it w/ script ...

			SetIdentified(oCreate, TRUE);

			if (bFullStack)
				SetItemStackSize(oCreate,
								 StringToInt(Get2DAString(BASEITEMS_2DA, COL_BASEITEMS_STACKING, GetBaseItemType(oCreate))));
		}
		//else TellCraft(". . ERROR : failed to create ( " + sResref + " )");
		sResref = GetStringParam(sResrefList, ++i);
	}
}

// Applies bonuses to crafted masterwork oItem.
void ApplyMasterworkBonus(object oItem, int iBonus)
{
	int bMelee = IPGetIsMeleeWeapon(oItem);
	if (bMelee || GetWeaponRanged(oItem))
	{
		if (iBonus > 20) iBonus = 20; // jic.

		itemproperty ipBonus = ItemPropertyAttackBonus(iBonus);
		IPSafeAddItemProperty(oItem, ipBonus);

		if (iBonus /= 2)
		{
			if (bMelee)
			{
				switch (iBonus)
				{
					default: // should never happen.
					case  1: iBonus = IP_CONST_DAMAGEBONUS_1; break;
					case  2: iBonus = IP_CONST_DAMAGEBONUS_2; break;
					case  3: iBonus = IP_CONST_DAMAGEBONUS_3; break;
					case  4: iBonus = IP_CONST_DAMAGEBONUS_4; break;
					case  5: iBonus = IP_CONST_DAMAGEBONUS_5; break;
					case  6: iBonus = IP_CONST_DAMAGEBONUS_6; break;
					case  7: iBonus = IP_CONST_DAMAGEBONUS_7; break;
					case  8: iBonus = IP_CONST_DAMAGEBONUS_8; break;
					case  9: iBonus = IP_CONST_DAMAGEBONUS_9; break;
					case 10: iBonus = IP_CONST_DAMAGEBONUS_10;
				}

				int iType = GetWeaponType(oItem);
				switch (iType)
				{
//					case WEAPON_TYPE_NONE: break; // better not happen.
					case WEAPON_TYPE_PIERCING:				iType = IP_CONST_DAMAGETYPE_PIERCING;		break;
					case WEAPON_TYPE_BLUDGEONING:			iType = IP_CONST_DAMAGETYPE_BLUDGEONING;	break;
					case WEAPON_TYPE_SLASHING:				iType = IP_CONST_DAMAGETYPE_SLASHING;		break;
					default:
					case WEAPON_TYPE_PIERCING_AND_SLASHING:	iType = IP_CONST_DAMAGETYPE_SLASHING; // this could use the additive-const bug ...
					// note that http://nwn2.wikia.com/wiki/Baseitems.2da
					// says there's also bludgeoning-piercing type.
				}

				ipBonus = ItemPropertyDamageBonus(iType, iBonus);
			}
			else // ranged.
				ipBonus = ItemPropertyMaxRangeStrengthMod(iBonus);

			IPSafeAddItemProperty(oItem, ipBonus);
		}
	}
}


// -----------------------------------------------------------------------------
// private functions for Magical Crafting
// -----------------------------------------------------------------------------

//
void GetEnchantable()
{
	_iEnchantableParts = 0;

	object oItem = GetFirstItemInInventory();
	while (GetIsObjectValid(oItem))
	{
		if (GetIsEquippable(oItem) && !GetIsException(oItem))
		{
			_oEnchantable = oItem;
			++_iEnchantableParts;
		}
		oItem = GetNextItemInInventory();
	}

	if (_iEnchantableParts > 1)
		_oEnchantable = OBJECT_INVALID;
}

//
// - these equippable items can never be enchanted; instead they are used as
//   reagents for resref construction recipes
// - exceptions to these exceptions could be made for equippable items that
//   become parts of Property Sets ... they could be examined for a Set-prepared
//   flag
int GetIsException(object oItem)
{
	if (GetTag(oItem) == "NW_IT_MNECK022") // gold necklace for Mephasm charm
		return TRUE;

	return FALSE;
}

// Checks if the type of _oEnchantable matches allowed values in Crafting.2da "TAGS".
// - if TAGS is prepended with a "B" the search is by BaseItem.2da type
// - if not then search is done by TCC-type
int isTypeMatch(string sTypesValid)
{
	//TellCraft("isTypeMatch() ( " + GetName(_oEnchantable) + " BaseType= "
	//		+ IntToString(GetBaseItemType(_oEnchantable)) + " ) sTypesValid= " + sTypesValid);

	if (!GetIsObjectValid(_oEnchantable))
	{
		//TellCraft(". object invalid");
		if (FindSubString(sTypesValid, REAGENT_LIST_DELIMITER) == -1	// is not multi-TAG'd (would convert to 0)
			&& StringToInt(sTypesValid) == 0)							// TAGS shall be "0" or "****" only.
		{
			//TellCraft(". . ret TRUE");
			return TRUE;
		}
		//TellCraft(". . ret FALSE");
		return FALSE;
	}

	if (GetStringLeft(sTypesValid, 1) == "B")
	{
		//TellCraft(". search by Base-types for " + IntToString(GetBaseItemType(_oEnchantable)));
		sTypesValid = GetStringRight(sTypesValid, GetStringLength(sTypesValid) - 1);
		if (FindListElementIndex(sTypesValid, IntToString(GetBaseItemType(_oEnchantable))) != -1)
		{
			//TellCraft(". . ret TRUE");
			return TRUE;
		}
	}
	else
	{
		//TellCraft(". search by TCC-type");
		int iTccType = GetTccType(_oEnchantable);
		//TellCraft(". iTccType= " + IntToString(iTccType));

		if (sTypesValid == "-1")					// TCC_TYPE_ANY: TAGS shall be "-1" only.
		{
			//TellCraft(". . match Any");
			switch (iTccType)
			{
//				case TCC_TYPE_MELEE:				// NOTE: does *not* include TCC_TYPE_MELEE (why not) ....
				case TCC_TYPE_OTHER:				// Fix done -- unless these items can be adjusted to have
				case TCC_TYPE_CONTAINER:			// active ip's when not equipped since by default an item
					//TellCraft(". . . ret FALSE");	// must be equipped for any ip's it has to be activated. cf Set/GetItemPropActivation()
					return FALSE;					// See below, however, where they can still
			}										// be specifically targeted for enchanting.
			//TellCraft(". . . ret TRUE");			// NOTE, however, that all non-equippable items will get destroyed (anyway) if enchanting.
			return TRUE;							// And if not enchanting but constructing, *all* items including equippable get destroyed.
		}											// So basically, as the code currently is, type-other and type-container are fucko'd ....
													// They get consumed/destroyed period.

		switch (iTccType) // cases include only the possible returns from GetTccType()
		{
			case TCC_TYPE_MELEE:										//  1
				if (FindListElementIndex(sTypesValid, "1") != -1)
					return TRUE;
				break;

			case TCC_TYPE_BOW:											//  3
				if (   FindListElementIndex(sTypesValid,  "3") != -1
					|| FindListElementIndex(sTypesValid, "10") != -1)	// TCC_TYPE_RANGED
				{
					return TRUE;
				}
				break;

			case TCC_TYPE_XBOW:											//  4
				if (   FindListElementIndex(sTypesValid,  "4") != -1
					|| FindListElementIndex(sTypesValid, "10") != -1)	// TCC_TYPE_RANGED
				{
					return TRUE;
				}
				break;

			case TCC_TYPE_SLING:										//  5
				if (   FindListElementIndex(sTypesValid,  "5") != -1
					|| FindListElementIndex(sTypesValid, "10") != -1)	// TCC_TYPE_RANGED
				{
					return TRUE;
				}
				break;

			case TCC_TYPE_AMMO:											//  6
				if (FindListElementIndex(sTypesValid, "6") != -1)
					return TRUE;
				break;

			case TCC_TYPE_ARMOR:										//  7
				if (   FindListElementIndex(sTypesValid, "7") != -1
					|| FindListElementIndex(sTypesValid, "2") != -1)	// TCC_TYPE_ARMOR_SHIELD
				{
					return TRUE;
				}
				break;

			case TCC_TYPE_SHIELD:										//  8
				if (   FindListElementIndex(sTypesValid, "8") != -1
					|| FindListElementIndex(sTypesValid, "2") != -1)	// TCC_TYPE_ARMOR_SHIELD
				{
					return TRUE;
				}
				break;

			case TCC_TYPE_OTHER:										//  9
				if (FindListElementIndex(sTypesValid, "9") != -1)		// NOTE: this type is excluded from TCC_TYPE_ANY.
					return TRUE;
				break;

			case TCC_TYPE_INSTRUMENT:									// 15
				if (FindListElementIndex(sTypesValid, "15") != -1)
					return TRUE;
				break;

			case TCC_TYPE_CONTAINER:									// 16
				if (FindListElementIndex(sTypesValid, "16") != -1)		// NOTE: this type is excluded from TCC_TYPE_ANY.
					return TRUE;
				break;

			case TCC_TYPE_HEAD:											// 17
				if (   FindListElementIndex(sTypesValid, "17") != -1
					|| FindListElementIndex(sTypesValid, "-2") != -1)	// TCC_TYPE_MISC_EQUIPPABLE
				{
					return TRUE;
				}
				break;

			case TCC_TYPE_NECK:											// 19
				if (   FindListElementIndex(sTypesValid, "19") != -1
					|| FindListElementIndex(sTypesValid, "-2") != -1)	// TCC_TYPE_MISC_EQUIPPABLE
				{
					return TRUE;
				}
				break;

			case TCC_TYPE_WAIST:										// 21
				if (   FindListElementIndex(sTypesValid, "21") != -1
					|| FindListElementIndex(sTypesValid, "-2") != -1)	// TCC_TYPE_MISC_EQUIPPABLE
				{
					return TRUE;
				}
				break;

			case TCC_TYPE_FEET:											// 26
				if (   FindListElementIndex(sTypesValid, "26") != -1
					|| FindListElementIndex(sTypesValid, "-2") != -1)	// TCC_TYPE_MISC_EQUIPPABLE
				{
					return TRUE;
				}
				break;

			case TCC_TYPE_GLOVES:										// 36
				if (   FindListElementIndex(sTypesValid, "36") != -1
					|| FindListElementIndex(sTypesValid, "11") != -1	// TCC_TYPE_WRISTS
					|| FindListElementIndex(sTypesValid, "-2") != -1)	// TCC_TYPE_MISC_EQUIPPABLE
				{
					return TRUE;
				}
				break;

			case TCC_TYPE_RING:											// 52
				if (   FindListElementIndex(sTypesValid, "52") != -1
					|| FindListElementIndex(sTypesValid, "-2") != -1)	// TCC_TYPE_MISC_EQUIPPABLE
				{
					return TRUE;
				}
				break;

			case TCC_TYPE_BACK:											// 80
				if (   FindListElementIndex(sTypesValid, "80") != -1
					|| FindListElementIndex(sTypesValid, "-2") != -1)	// TCC_TYPE_MISC_EQUIPPABLE
				{
					return TRUE;
				}
		}
	}

	//TellCraft(". ret FALSE");
	return FALSE;
}
/*
const int TCC_TYPE_MISC_EQUIPPABLE	= -2;
const int TCC_TYPE_ANY				= -1;
const int TCC_TYPE_NONE 			=  0;
const int TCC_TYPE_MELEE			=  1;
const int TCC_TYPE_ARMOR_SHIELD 	=  2;
const int TCC_TYPE_BOW				=  3;
const int TCC_TYPE_XBOW 			=  4;
const int TCC_TYPE_SLING			=  5;
const int TCC_TYPE_AMMO 			=  6;
const int TCC_TYPE_ARMOR			=  7;
const int TCC_TYPE_SHIELD			=  8;
const int TCC_TYPE_OTHER			=  9;
const int TCC_TYPE_RANGED			= 10;
const int TCC_TYPE_WRISTS			= 11;
const int TCC_TYPE_INSTRUMENT		= 15;
const int TCC_TYPE_CONTAINER		= 16;

const int TCC_TYPE_HEAD 			= 17; // BASE_ITEM_HELMET
const int TCC_TYPE_NECK 			= 19; // BASE_ITEM_AMULET
const int TCC_TYPE_WAIST			= 21; // BASE_ITEM_BELT
const int TCC_TYPE_FEET 			= 26; // BASE_ITEM_BOOTS
const int TCC_TYPE_GLOVES			= 36; // BASE_ITEM_GLOVES
const int TCC_TYPE_RING 			= 52; // BASE_ITEM_RING
const int TCC_TYPE_BACK 			= 80; // BASE_ITEM_CLOAK
*/
// Gets the TCC-type of oItem.
// - this returns one of the following TCC-types. If oItem needs to be compared
//   to a multi-TCC-type like TCC_TYPE_MISC_EQUIPPABLE or TCC_TYPE_ARMOR_SHIELD
//   that needs to be done elsewhere, eg. isTypeMatch()
// @return -
// - TCC_TYPE_NONE
// - TCC_TYPE_HEAD
// - TCC_TYPE_NECK
// - TCC_TYPE_WAIST
// - TCC_TYPE_FEET
// - TCC_TYPE_GLOVES
// - TCC_TYPE_RING
// - TCC_TYPE_BACK
// - TCC_TYPE_INSTRUMENT
// - TCC_TYPE_CONTAINER
// - TCC_TYPE_ARMOR
// - TCC_TYPE_SHIELD
// - TCC_TYPE_BOW
// - TCC_TYPE_XBOW
// - TCC_TYPE_SLING
// - TCC_TYPE_AMMO
// - TCC_TYPE_MELEE
// - TCC_TYPE_OTHER
int GetTccType(object oItem)
{
	if (!GetIsObjectValid(oItem))		return TCC_TYPE_NONE;

	switch (GetBaseItemType(oItem))
	{
		case BASE_ITEM_HELMET:			return TCC_TYPE_HEAD;
		case BASE_ITEM_AMULET:			return TCC_TYPE_NECK;
		case BASE_ITEM_BELT:			return TCC_TYPE_WAIST;
		case BASE_ITEM_BOOTS:			return TCC_TYPE_FEET;
		case BASE_ITEM_GLOVES:
		case BASE_ITEM_BRACER:			return TCC_TYPE_GLOVES; // also, kPrC #201 spiked gloves, #202 bladed gloves
		case BASE_ITEM_RING:			return TCC_TYPE_RING;
		case BASE_ITEM_CLOAK:			return TCC_TYPE_BACK;

		case BASE_ITEM_DRUM:
		case BASE_ITEM_FLUTE:
		case BASE_ITEM_MANDOLIN:		return TCC_TYPE_INSTRUMENT;

		case BASE_ITEM_BAG:				return TCC_TYPE_CONTAINER; // also #66 BASE_ITEM_LARGEBOX

		case BASE_ITEM_ARMOR:			return TCC_TYPE_ARMOR;

		case BASE_ITEM_SMALLSHIELD:
		case BASE_ITEM_LARGESHIELD:
		case BASE_ITEM_TOWERSHIELD:		return TCC_TYPE_SHIELD;

		case BASE_ITEM_LONGBOW:
		case BASE_ITEM_SHORTBOW:		return TCC_TYPE_BOW;

		case BASE_ITEM_HEAVYCROSSBOW:
		case BASE_ITEM_LIGHTCROSSBOW:	return TCC_TYPE_XBOW;

		case BASE_ITEM_SLING:			return TCC_TYPE_SLING;

		case BASE_ITEM_ARROW:
		case BASE_ITEM_BOLT:
		case BASE_ITEM_BULLET:			return TCC_TYPE_AMMO;

		case BASE_ITEM_SHORTSWORD:
		case BASE_ITEM_LONGSWORD:
		case BASE_ITEM_BATTLEAXE:
		case BASE_ITEM_BASTARDSWORD:
		case BASE_ITEM_LIGHTFLAIL:
		case BASE_ITEM_WARHAMMER:
		case BASE_ITEM_LIGHTMACE:
		case BASE_ITEM_HALBERD:
		case BASE_ITEM_GREATSWORD:
		case BASE_ITEM_GREATAXE:
		case BASE_ITEM_DAGGER:
		case BASE_ITEM_CLUB:
		case BASE_ITEM_LIGHTHAMMER:
		case BASE_ITEM_HANDAXE:
		case BASE_ITEM_KAMA:
		case BASE_ITEM_KATANA:
		case BASE_ITEM_KUKRI:
		case BASE_ITEM_MORNINGSTAR:
		case BASE_ITEM_QUARTERSTAFF:
		case BASE_ITEM_RAPIER:
		case BASE_ITEM_SCIMITAR:
		case BASE_ITEM_SCYTHE:
		case BASE_ITEM_SICKLE:
		case BASE_ITEM_BALORSWORD:
		case BASE_ITEM_BALORFALCHION:
		case BASE_ITEM_DWARVENWARAXE:
		case BASE_ITEM_WHIP:
		case BASE_ITEM_FALCHION:
		case BASE_ITEM_FLAIL:
		case BASE_ITEM_SPEAR:
		case BASE_ITEM_GREATCLUB:
		case BASE_ITEM_TRAINING_CLUB:
		case BASE_ITEM_WARMACE:
		case BASE_ITEM_STEIN: // needs test.
		case BASE_ITEM_SPOON: // needs test.
		case BASE_ITEM_CGIANT_SWORD:
		case BASE_ITEM_CGIANT_AXE:
		case BASE_ITEM_ALLUSE_SWORD:	return TCC_TYPE_MELEE;
	}
	return TCC_TYPE_OTHER;	// incl. torch, spoon, book, scroll, potion, rod/staff/wand,
}							// gem/essence, trapkit, key, inkwell, largebox, misc's, etc.

/* int isMelee(object oItem)
{
	int iType = GetBaseItemType(oItem);
	return StringToInt(Get2DAString(BASEITEMS, "DieToRoll", iType)) != 0
		&& StringToInt(Get2DAString(BASEITEMS, "RangedWeapon", iType)) == 0; // isRanged()=FALSE.
}
int isRanged(object oItem)
{
	int iType = GetBaseItemType(oItem);
	return StringToInt(Get2DAString(BASEITEMS, "RangedWeapon", iType)) != 0;
}
int isArmor(object oItem)
{
	int iType = GetBaseItemType(oItem);
	string sSlots = Get2DAString(BASEITEMS, "EquipableSlots", iType);
	int iSlots = kL_HexStringToInt(sSlots);
	if (iSlots != -1) return (iSlots & 2); // 0x2 (2) is chest-slot.

	return FALSE;
}
int isShield(object oItem)
{
	int iType = GetBaseItemType(oItem);
	if (StringToInt(Get2DAString(BASEITEMS, "BaseAC", iType)) != 0)
	{
		string sSlots = Get2DAString(BASEITEMS, "EquipableSlots", iType);
		int iSlots = kL_HexStringToInt(sSlots);
		if (iSlots != -1) return (iSlots & 32); // 0x20 (32) is lefthand-slot.
	}
	return FALSE;
} */

// Gets if _oEnchantable has an ip that excludes that of _iRecipeId.
int hasExcludedProp()
{
	string sExclusions = Get2DAString(CRAFTING_2DA, "EXCLUDE", _iRecipeId);
	if (sExclusions != "")
	{
		itemproperty ipScan;

		int iTokens = GetTotalTokens(sExclusions, REAGENT_LIST_DELIMITER);
		int i;
		for (i = 0; i != iTokens; ++i)
		{
			ipScan = GetFirstItemProperty(_oEnchantable);
			while (GetIsItemPropertyValid(ipScan))
			{
				if (GetItemPropertyDurationType(ipScan) == DURATION_TYPE_PERMANENT
					&& GetItemPropertyType(ipScan) == GetIntParam(sExclusions, i, REAGENT_LIST_DELIMITER))
				{
					return TRUE;
				}
				ipScan = GetNextItemProperty(_oEnchantable);
			}
		}
	}
	return FALSE;
}


//int GMATERIAL_NONSPECIFIC				= 0;
//int GMATERIAL_METAL_ADAMANTINE		= 1;
//int GMATERIAL_METAL_COLD_IRON			= 2;
//int GMATERIAL_METAL_DARKSTEEL			= 3;
//int GMATERIAL_METAL_IRON				= 4;
//int GMATERIAL_METAL_MITHRAL			= 5;
//int GMATERIAL_METAL_ALCHEMICAL_SILVER	= 6;
//int GMATERIAL_WOOD_DUSKWOOD			= 7;
//int GMATERIAL_WOOD_DARKWOOD			= 8; // zalantir
//int GMATERIAL_CREATURE_RED_DRAGON		= 9;
//int GMATERIAL_CREATURE_SALAMANDER		= 10;
//int GMATERIAL_CREATURE_UMBER_HULK		= 11;
//int GMATERIAL_CREATURE_WYVERN			= 12;
//
//int GetItemBaseMaterialType(object oItem);
//void SetItemBaseMaterialType(object oItem, int nMaterialType);

// Gets the material of oItem if any.
int GetMaterialType(object oItem)
{
	//TellCraft("GetMaterialType() " + GetTag(oItem));

	int iMaterial = GetItemBaseMaterialType(oItem);
	if (iMaterial != GMATERIAL_NONSPECIFIC)
		return iMaterial;

//	int iMaterial = GetLocalInt(oItem, TCC_VAR_MATERIAL); // NOTE: I don't believe this is ever set/used elsewhere, not even in .Uti's.
//	if (iMaterial != 0) // MAT_NUL
//	{
		//TellCraft(". local material= " + IntToString(iMaterial));
//		return iMaterial;
//	}

	string sMaterial;

	string sTag = GetTag(oItem);
	int iLength = GetStringLength(sTag);
	if (iLength > 4)
	{
		iLength -= 4;
		int i;
		for (i = 0; i != iLength; ++i)
		{
			sMaterial = GetSubString(sTag, i, 5);
			//TellCraft(". . test= " + sMaterial);
			if (sMaterial == "_ada_") iMaterial = GMATERIAL_METAL_ADAMANTINE;			//  1
			if (sMaterial == "_cld_") iMaterial = GMATERIAL_METAL_COLD_IRON;			//  2
			if (sMaterial == "_drk_") iMaterial = GMATERIAL_METAL_DARKSTEEL;			//  3
			if (sMaterial == "_dsk_") iMaterial = GMATERIAL_WOOD_DUSKWOOD;				//  4 ->  7
			if (sMaterial == "_mth_") iMaterial = GMATERIAL_METAL_MITHRAL;				//  5
			if (sMaterial == "_rdh_") iMaterial = GMATERIAL_CREATURE_RED_DRAGON;		//  6 ->  9
			if (sMaterial == "_shd_") iMaterial = GMATERIAL_WOOD_SHEDERRAN;				//  7 -> 13 - shederran ( GMATERIAL_METAL_IRON - not )
			if (sMaterial == "_slh_") iMaterial = GMATERIAL_CREATURE_SALAMANDER;		//  8 -> 10
			if (sMaterial == "_slv_") iMaterial = GMATERIAL_METAL_ALCHEMICAL_SILVER;	//  9 ->  6
			if (sMaterial == "_uhh_") iMaterial = GMATERIAL_CREATURE_UMBER_HULK;		// 10 -> 11
			if (sMaterial == "_wyh_") iMaterial = GMATERIAL_CREATURE_WYVERN;			// 11 -> 12
			if (sMaterial == "_zal_") iMaterial = GMATERIAL_WOOD_DARKWOOD;				// 12 ->  8

//x2_it_iwoodshldl	Heavy Ironwood Shield
//x2_it_ironwshlds	Light Ironwood Shield
//x2_it_ironwshldt	Ironwood Tower Shield
//x2_it_iwoodclub	Ironwood Club
//nw_wdbmma008		Ironwood Warmace +1
//nw_wdbmma009		Ironwood Warmace +3
//x2_it_iwoodstaff	Ironwood Quarterstaff
//nw_it_msmlmisc18	Ironwood

//nw_wblmcl005		Tethir-wood Cudgel
/*			if (sMaterial == "_ada_") return  1; // MAT_ADA
			if (sMaterial == "_cld_") return  2; // MAT_CLD
			if (sMaterial == "_drk_") return  3; // MAT_DRK
			if (sMaterial == "_dsk_") return  4; // MAT_DSK
			if (sMaterial == "_mth_") return  5; // MAT_MTH
			if (sMaterial == "_rdh_") return  6; // MAT_RDH
			if (sMaterial == "_shd_") return  7; // MAT_SHD
			if (sMaterial == "_slh_") return  8; // MAT_SLH
			if (sMaterial == "_slv_") return  9; // MAT_SLV
			if (sMaterial == "_uhh_") return 10; // MAT_UHH
			if (sMaterial == "_wyh_") return 11; // MAT_WYH
			if (sMaterial == "_zal_") return 12; // MAT_ZAL */
		}
	}

	SetItemBaseMaterialType(oItem, iMaterial); // <- just do it.

	return iMaterial; // MAT_NUL - nothing was found, assume no particular material
}

// Gets the quantity of ip's of iPropType on oItem.
int GetQtyPropsOfType(object oItem, int iPropType)
{
	int i = 0;

	itemproperty ipScan = GetFirstItemProperty(oItem);
	while (GetIsItemPropertyValid(ipScan))
	{
		if (GetItemPropertyDurationType(ipScan) == DURATION_TYPE_PERMANENT
			&& GetItemPropertyType(ipScan) == iPropType)
		{
			++i;
		}
		ipScan = GetNextItemProperty(oItem);
	}
	return i;
}

// Clears a corresponding Attack bonus ip when upgrading to an Enhancement bonus
// ip that is equal or greater.
// - the AttackBonus can be safely removed because w/ bUpgrade the enchanting
//   will go through w/ Success.
int ReplaceAttackBonus(object oItem, int iPropType, int iCost, int iSubtype)
{
	switch (iPropType)
	{
		case ITEM_PROPERTY_ENHANCEMENT_BONUS:
		{
			int bFound = ClearIpType(oItem, ITEM_PROPERTY_ATTACK_BONUS, iCost);
			bFound = ClearIpType(oItem,
								 ITEM_PROPERTY_ATTACK_BONUS_VS_ALIGNMENT_GROUP,
								 iCost) || bFound;
			bFound = ClearIpType(oItem,
								 ITEM_PROPERTY_ATTACK_BONUS_VS_RACIAL_GROUP,
								 iCost) || bFound;
			bFound = ClearIpType(oItem,
								 ITEM_PROPERTY_ATTACK_BONUS_VS_SPECIFIC_ALIGNMENT,
								 iCost) || bFound;
			return bFound;
		}

		case ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_ALIGNMENT_GROUP:
			return ClearIpType(oItem,
							   ITEM_PROPERTY_ATTACK_BONUS_VS_ALIGNMENT_GROUP,
							   iCost,
							   iSubtype);

		case ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_RACIAL_GROUP:
			return ClearIpType(oItem,
							   ITEM_PROPERTY_ATTACK_BONUS_VS_RACIAL_GROUP,
							   iCost,
							   iSubtype);

		case ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_SPECIFIC_ALIGNEMENT:
			return ClearIpType(oItem,
							   ITEM_PROPERTY_ATTACK_BONUS_VS_SPECIFIC_ALIGNMENT,
							   iCost,
							   iSubtype);
	}
	return FALSE;
}

// Clears iPropType from oItem if iCost is higher or equal to existing CostValue.
int ClearIpType(object oItem, int iPropType, int iCost, int iSubtype = -1)
{
	int bFound = FALSE;

	itemproperty ipScan = GetFirstItemProperty(oItem);
	while (GetIsItemPropertyValid(ipScan))
	{
		if (GetItemPropertyDurationType(ipScan) == DURATION_TYPE_PERMANENT
			&& GetItemPropertyType(ipScan) == iPropType
			&& (iSubtype == -1 || GetItemPropertySubType(ipScan) == iSubtype) // iSubtype will always have a valid value when called by ReplaceAttackBonus()
			&& GetItemPropertyCostTableValue(ipScan) <= iCost)
		{
			bFound = TRUE;
			RemoveItemProperty(oItem, ipScan);
			ipScan = GetFirstItemProperty(oItem);
		}
		else
			ipScan = GetNextItemProperty(oItem);
	}
	return bFound;
}

// Searches oItem for an ip similar to ipProp.
// - this is functionally identical to GetIsItemPropertyAnUpgrade()
// - similar properties have the same type and subtype but may have different
//   parameters beyond that
// - only permanent ip's are checked
// - returns TRUE if a suitable match is found for ipProp
int isIpUpgrade(object oItem, itemproperty ipProp)
{
	//TellCraft("isIpUpgrade()");
	if (!isIgnoredIp(ipProp))
	{
		// NOTE: could use: IPGetItemHasProperty(oItem, ip, DURATION_TYPE_PERMANENT, isIgnoredSubtype(ip));
		int iPropType = GetItemPropertyType(ipProp);
		int iSubtype = GetItemPropertySubType(ipProp);
		int bIgnoreSubtype = isIgnoredSubtype(ipProp);
		//TellCraft(". iPropType= " + IntToString(iPropType));
		//TellCraft(". iSubtype= " + IntToString(iSubtype));
		//TellCraft(". bIgnoreSubtype= " + IntToString(bIgnoreSubtype));

		itemproperty ipScan = GetFirstItemProperty(oItem);
		while (GetIsItemPropertyValid(ipScan))
		{
			//TellCraft(". . scan PropType= " + IntToString(GetItemPropertyType(ipScan)));
			//TellCraft(". . scan subtype= " + IntToString(GetItemPropertySubType(ipScan)));
			if (GetItemPropertyDurationType(ipScan) == DURATION_TYPE_PERMANENT
				&& GetItemPropertyType(ipScan) == iPropType
				&& (bIgnoreSubtype || GetItemPropertySubType(ipScan) == iSubtype))
			{
				return TRUE;
			}
			ipScan = GetNextItemProperty(oItem);
		}
	}
	return FALSE;
}

// Gets variable prop-costs already used on oItem.
int GetCostSlotsUsed(object oItem)
{
	int i = 0;

	itemproperty ipScan = GetFirstItemProperty(oItem);
	while (GetIsItemPropertyValid(ipScan))
	{
		if (GetItemPropertyDurationType(ipScan) == DURATION_TYPE_PERMANENT)
			i += StringToInt(Get2DAString(ITEM_PROP_DEF_2DA, COL_ITEM_PROP_DEF_SLOTS, GetItemPropertyType(ipScan)));

		ipScan = GetNextItemProperty(oItem);
	}
	return i;
}

// Gets the quantity of ip's on oItem.
int GetPropSlotsUsed(object oItem)
{
	int i = 0;

	itemproperty ipScan = GetFirstItemProperty(oItem);
	while (GetIsItemPropertyValid(ipScan))
	{
		if (GetItemPropertyDurationType(ipScan) == DURATION_TYPE_PERMANENT)
			++i;

		ipScan = GetNextItemProperty(oItem);
	}
	return i;
}

// Checks if an already existing ip should be ignored.
int isIgnoredIp(itemproperty ip)
{
	if (GetItemPropertyType(ip) == ITEM_PROPERTY_BONUS_SPELL_SLOT_OF_LEVEL_N)
		return TRUE;

	return FALSE;
}

// Checks if adding an ip should ignore subtype.
int isIgnoredSubtype(itemproperty ip)
{
	int iPropType = GetItemPropertyType(ip);
	if (iPropType == ITEM_PROPERTY_VISUALEFFECT
//		|| iPropType == ITEM_PROPERTY_AC_BONUS											// <- dodge/deflection/etc. should be okay (is handled globally by BaseItems.2da).
		|| Get2DAString(ITEM_PROP_DEF_2DA, COL_ITEM_PROP_DEF_SUBTYPE, iPropType) == "")	// NOTE: Determine if subType needs to be compared;
	{																					// because even if there is no subType to an ip,
		return TRUE;																	// it might be set at "-1" or "0", etc. doh!
	}
	return FALSE;
}


// -----------------------------------------------------------------------------
// functions for Property Sets
// -----------------------------------------------------------------------------

// Checks for and clears items from their Set.
int ClearSetParts(object oCrafter)
{
	//TellCraft("ClearSetParts()");

	int iTotal = 0;
	int iSetParts = 0;
	int iMalachite = 0;

	object oItem = GetFirstItemInInventory();
	while (GetIsObjectValid(oItem))
	{
		iTotal += GetItemStackSize(oItem); // note: 'iTotal' will not be 0 because the container has already been checked for at least 1 valid item.

		if (GetTag(oItem) == "NW_IT_GEM007") // malachite
			iMalachite += GetItemStackSize(oItem);
		else if (GetLocalInt(oItem, TCC_VAR_SET_GROUP))
		{
			++iSetParts; // Set-items cannot be stackable, eg. not ranged-ammo
			NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_SET_ITEM
						+ GetName(oItem) + " (" + GetTag(oItem) + " )");
		}
		oItem = GetNextItemInInventory();
	}
	//TellCraft(". iTotal= " + IntToString(iTotal)
	//		+ "\n. iSetParts= " + IntToString(iSetParts)
	//		+ "\n. iMalachite= " + IntToString(iMalachite));

	if (iSetParts == iMalachite
		&& iSetParts + iMalachite == iTotal)
	{
		return TRUE;
	}
	return FALSE;
}

// Gets the quantity of Property Set ip's stored on oItem.
int GetQtyLatentIps(object oItem)
{
	if (GetLocalInt(oItem, TCC_VAR_SET_GROUP))	// currently only 1 latent-ip can be applied to each Set item
		return 1;								// This is bound to change ....

	return 0;
//	int iTotal = 0;
//	int iSetProps = StringToInt(Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 2)) + 1; // TCC_Value_MaximumSetProperties
//	int iGroup = 2;
//	while (iGroup <= iSetProps)
//	{
//		if (GetLocalString(oItem, TCC_VAR_SET_GROUP + IntToString(iGroup)) != "") // TODO: Fix.
//			++iTotal;
//		++iGroup;
//	}
//	return iTotal;
}

// Checks if any crafting-container content has been prepared to receive a
// latent-ip.
// - if so inform/ask the player what to do with a GUI.
// - when this runs there should be none or only 1 prepared-part in the container
// - if there are more then stop DoMagicCrafting() and give player an error
int CheckLatentPrepared(object oCrafter)
{
	int iParts = 0;

	object oItem = GetFirstItemInInventory();
	while (GetIsObjectValid(oItem))
	{
		if (GetLocalInt(oItem, TCC_VAR_SET_PREP_ITEM))
		{
			++iParts;
			NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_SET_PREPITEM
						+ GetName(oItem) + " (" + GetTag(oItem) + " )");
		}
		oItem = GetNextItemInInventory();
	}
	return iParts;
}

// Checks that Set-creation can proceed.
int CheckSetCreation(object oCrafter, int iPartsRequired)
{
	//TellCraft("CheckSetCreation()");

	int bRejected = FALSE;

	// Zeroth check for membership in a different Property Set:
	// - note this could be subsumed in the check for plot below, but that's
	//   confusing since this has different ramifications (eg. the plot-flag
	//   can be removed from these items but not from those that get trapped
	//   by the plot-check below)
	object oItem = GetFirstItemInInventory();
	while (GetIsObjectValid(oItem))
	{
		if (GetLocalInt(oItem, TCC_VAR_SET_PREP_ITEM)) // don't need to check GetIsEquippable(), just run over all items.
		{
			bRejected = TRUE; // do not break the loop, allow all Set-prepared items to get listed
			NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_SET_PREPITEM
						+ GetName(oItem) + " ( " + GetTag(oItem) + " )");
			//TellCraft(". prep flag set " + GetName(oItem));
		}
		oItem = GetNextItemInInventory();
	}

	if (bRejected)
	{
		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_SET_REJECTED
					+ "Items that are already prepared for a different Property Set"
					+ " cannot be enchanted in this Set. If you wish to remove"
					+ " a prepared item from its previous Set place it alone in a Magical"
					+ " Workbench and cast any spell on it, then click Cancel in the"
					+ " dialog that appears. That would remove its current membership in that"
					+ " Set and allow it to become a part of a different Set.");
		return FALSE;
	}

	// First check that item is equippable on the body or hands:
	int iSlotsValid = 2047;
	int iSlot;

	oItem = GetFirstItemInInventory();
	while (GetIsObjectValid(oItem))
	{
		if (GetIsEquippable(oItem))	// note: don't worry about exceptions since at present they're
		{							// used only for construction, not enchanting of any sort.
			iSlot = HexStringToInt(Get2DAString(BASEITEMS_2DA, COL_BASEITEMS_SLOTS, GetBaseItemType(oItem)));
			if (iSlot == -1 || (iSlotsValid & iSlot) == 0)
			{
				NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_SET_REJECTED
							+ "All Set-items must be equippable on the body or hands.");
				//TellCraft(". not equippable " + GetName(oItem));
				return FALSE;
			}
		}
		oItem = GetNextItemInInventory();
	}

	// Second & third check for no plot-flags and the right quantity of parts:
	int iParts = 0;
	oItem = GetFirstItemInInventory();
	while (GetIsObjectValid(oItem))
	{
		if (GetIsEquippable(oItem))
		{
			if (GetPlotFlag(oItem))
			{
				bRejected = TRUE; // do not break the loop, allow all Plot items to get listed
				NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_SET_PLOT
							+ GetName(oItem) + " ( " + GetTag(oItem) + " )");
			}
			++iParts;
		}
		oItem = GetNextItemInInventory();
	}

	if (bRejected)
	{
		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_SET_REJECTED
					+ "Plot items are not allowed in Property Sets.");
		return FALSE;
	}

	if (iParts != iPartsRequired)
	{
		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_SET_REJECTED
					+ "The quantity of Set-parts does not match that required by the recipe.");
		return FALSE;
	}

//int INVENTORY_SLOT_ARROWS    = 11; - disallowed above! ->
//int INVENTORY_SLOT_BULLETS   = 12;
//int INVENTORY_SLOT_BOLTS     = 13;
//int INVENTORY_SLOT_CWEAPON_L = 14;
//int INVENTORY_SLOT_CWEAPON_R = 15;
//int INVENTORY_SLOT_CWEAPON_B = 16;
//int INVENTORY_SLOT_CARMOUR   = 17; <-

//int INVENTORY_SLOT_HEAD      =  0; 0x0001 - 1				1
//int INVENTORY_SLOT_CHEST     =  1; 0x0002 - 10			2
//int INVENTORY_SLOT_BOOTS     =  2; 0x0004 - 100			4
//int INVENTORY_SLOT_ARMS      =  3; 0x0008 - 1000			8
//int INVENTORY_SLOT_RIGHTHAND =  4; 0x0010 - 10000			16
//int INVENTORY_SLOT_LEFTHAND  =  5; 0x0020 - 100000		32
//int INVENTORY_SLOT_CLOAK     =  6; 0x0040 - 1000000		64
//int INVENTORY_SLOT_LEFTRING  =  7; 0x0080 - 10000000		128
//int INVENTORY_SLOT_RIGHTRING =  8; 0x0100 - 100000000		256
//int INVENTORY_SLOT_NECK      =  9; 0x0200 - 1000000000	512
//int INVENTORY_SLOT_BELT      = 10; 0x0400 - 10000000000	1024

	// Fourth check that the equipment in the Set can all be worn at once:
	// bitwise galore
	int iTally = 0; // a bitmask that gets filled as slots are taken.

	int iHandsTaken = 0;

	oItem = GetFirstItemInInventory();
	while (GetIsObjectValid(oItem) && bRejected == FALSE)
	{
		iSlot = HexStringToInt(Get2DAString(BASEITEMS_2DA, COL_BASEITEMS_SLOTS, GetBaseItemType(oItem)));
		//TellCraft(". iter " + GetName(oItem) + " baseType= " + IntToString(GetBaseItemType(oItem)) + " iSlot= " + IntToString(iSlot));
		switch (iSlot)
		{
			case   -1:
				//TellCraft("CheckSetCreation() ERROR : item has a malformed EquipableSlots entry.");
				return FALSE;

			case    0: // not equippable -> ignore.
				//TellCraft(". . not equippable");
				break;

//			case   16: // righthand
//			case   32: // lefthand
//			case   48: // righthand OR lefthand
//				// handled under 'default'
//				break;

//			case  128: // leftring
//			case  256: // rightring
			case  384: // ring left OR right -> NOTE: Rings are eligible in either right or left ring-slots, per BaseItems.2da.
				//TellCraft(". . ring slot");
				if ((iTally & 128) && (iTally & 256))
				{
					//TellCraft(". . . both slots taken");
					bRejected = TRUE;
				}
				else if ((iTally & 128) == 0)
				{
					//TellCraft(". . . take one");
					iTally |= 128;
				}
				else if ((iTally & 256) == 0)
				{
					//TellCraft(". . . take two");
					iTally |= 256;
				}
				break;

			case    1: // head -> NOTE: These items are eligible in only 1 slot apiece, per BaseItems.2da.
			case    2: // chest
			case    4: // boots
			case    8: // arms
			case   64: // cloak
			case  512: // neck
			case 1024: // belt
				//TellCraft(". . body slot");
				if (iTally & iSlot)
				{
					//TellCraft(". . . slot taken");
					bRejected = TRUE;
				}
				else
				{
					//TellCraft(". . . take slot");
					iTally |= iSlot;
				}
				break;

			default: // -> only hand-held items should get here.
				// items that can be equipped in hands are tricky ...
				// NOTE: Does not account for Monkey Grip, which seems to use
				// hardcode to place a right-only weapon in the left-hand. c'est la vie.
				// NOTE: In fact, two-handed weapons are *not* taken into account
				// at all here; whether or not a weapon is two-handed is determined
				// by the size of creature wielding the weapon(s).

				//TellCraft(". . hand slot iHandsTaken= " + IntToString(iHandsTaken));

				if (++iHandsTaken == 3)
				{
					//TellCraft(". . . both hands already taken");
					bRejected = TRUE;
				}
				else if ((iSlot & 16) && (iSlot & 32)) // righthand AND lefthand, either.
				{
					//TellCraft(". . . check both slots");
					if ((iTally & 16) && (iTally & 32))
					{
						//TellCraft(". . . . iHandsTaken= " + IntToString(iHandsTaken));
						//TellCraft(". . . . both slots taken= " + IntToString((iTally & 16) && (iTally & 32)));
						bRejected = TRUE;
					}
				}
				else if (iSlot & 16) // righthand only.
				{
					//TellCraft(". . . take slot right");
					if (iTally & 16)
					{
						//TellCraft(". . . . iHandsTaken= " + IntToString(iHandsTaken));
						//TellCraft(". . . . right slot taken= " + IntToString(iTally & 16));
						bRejected = TRUE;
					}
					else
					{
						//TellCraft(". . . . take right");
						iTally |= 16;
					}
				}
				else if (iSlot & 32) // lefthand only.
				{
					//TellCraft(". . . take slot left");
					if (iTally & 32)
					{
						//TellCraft(". . . . iHandsTaken= " + IntToString(iHandsTaken));
						//TellCraft(". . . . left slot taken= " + IntToString(iTally & 32));
						bRejected = TRUE;
					}
					else
					{
						//TellCraft(". . . . take left");
						iTally |= 32;
					}
				}
				// ranged-ammo or creature slots -> rejected above in check for "equippable".
		}
		oItem = GetNextItemInInventory();
	}

	if (bRejected)
	{
		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_SET_REJECTED
					+ "The items cannot all be equipped together.");
		return FALSE;
	}
	return TRUE;
}


// ____________________________________________________________________________
//  ----------------------------------------------------------------------------
//   MUNDANE CRAFTING
// ____________________________________________________________________________
//  ----------------------------------------------------------------------------

// Does crafting at a Smith Workbench with a smith's hammer.
// - requires a set of reagents, a specific skill level, and a smith hammer to
//   activate it.
// - reagents can be of any item type
void DoMundaneCrafting(object oCrafter)
{
	int iPrefixLength = GetStringLength(MUNDANE_RECIPE_TRIGGER);

	object oItem = GetFirstItemInInventory();
	while (GetIsObjectValid(oItem))
	{
		if (GetStringLeft(GetTag(oItem), iPrefixLength) == MUNDANE_RECIPE_TRIGGER)
		{
			_sTriggerId = GetTag(oItem);
			break;
		}
		oItem = GetNextItemInInventory();
	}
	//TellCraft("DoMundaneCrafting() _sTriggerId= " + _sTriggerId);

	if (_sTriggerId == "")
	{
//		NotifyPlayer(oCrafter, ERROR_MISSING_REQUIRED_MOLD);
		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
					+" No mold found.");
		return;
	}

	GetRecipeMatchSorted();
	//TellCraft(". _iRecipeId= " + IntToString(_iRecipeId));

	if (_iRecipeId == -1)
	{
//		NotifyPlayer(oCrafter, ERROR_RECIPE_NOT_FOUND);
		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
					+ "This is not a valid recipe.");
		return;
	}

	int iRankRQ		= StringToInt(Get2DAString(CRAFTING_2DA, COL_CRAFTING_SKILL_LEVEL, _iRecipeId));
	int iSkillId	= StringToInt(Get2DAString(CRAFTING_2DA, COL_CRAFTING_CRAFT_SKILL, _iRecipeId));
	int iRankPC		= GetSkillRank(iSkillId, oCrafter);

	if (iRankPC < iRankRQ)
	{
//		int iError;
		string sError;
		switch (iSkillId)
		{
			default:
			case SKILL_CRAFT_WEAPON:
//				iError = ERROR_INSUFFICIENT_CRAFT_WEAPON_SKILL;
				sError = "Weapon";
				break;
			case SKILL_CRAFT_ARMOR:
//				iError = ERROR_INSUFFICIENT_CRAFT_ARMOR_SKILL;
				sError = "Armor";
				break;
			case SKILL_CRAFT_TRAP:
//				iError = ERROR_INSUFFICIENT_CRAFT_TRAP_SKILL;
				sError = "Trap";
		}
//		NotifyPlayer(oCrafter, iError);
		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
					+ "You do not have enough ranks in Craft " + sError + ".");
		return;
	}

	DestroyReagents();

	string sInfo = "The item has been crafted.";

	string sResrefList = Get2DAString(CRAFTING_2DA, COL_CRAFTING_OUTPUT, _iRecipeId);
	int iBonus = -1;

	if (Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 26) != "0") // TCC_Toggle_CreateMasterworkItems
	{
		int iTCC_MasterworkSkillModifier = StringToInt(Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 31)); // TCC_Value_MasterworkSkillModifier
		if (iTCC_MasterworkSkillModifier + iRankRQ <= iRankPC)
		{
			sInfo = "You have created a masterpiece !";

			iBonus = (iRankPC - iRankRQ) / iTCC_MasterworkSkillModifier;
			if (iBonus < 0) iBonus = 0; // safety.
		}
	}
	CreateProducts(sResrefList, OBJECT_SELF, TRUE, iBonus);

//	NotifyPlayer(oCrafter, OK_CRAFTING_SUCCESS);
	NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_SUCCESS + sInfo);

	effect eVis = EffectVisualEffect(VFX_FNF_CRAFT_BLACKSMITH);
	ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF);
}


// ____________________________________________________________________________
//  ----------------------------------------------------------------------------
//   ALCHEMICAL CRAFTING
// ____________________________________________________________________________
//  ----------------------------------------------------------------------------

// Does crafting at an Alchemy Workbench with a mortar & pestle.
// - alchemy crafting requires a set of reagents, a specific skill level in
//   Alchemy, and a mortar & pestle to activate it
// - reagents can be of any item type
// - alchemy has no index
void DoAlchemyCrafting(object oCrafter)
{
	_sTriggerId = ALCHEMY_RECIPE_TRIGGER;

	GetRecipeMatchSorted();
	//TellCraft("_iRecipeId = " + IntToString(_iRecipeId));

	if (_iRecipeId == -1)
	{
//		NotifyPlayer(oCrafter, ERROR_RECIPE_NOT_FOUND);
		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
					+ "This is not a valid recipe.");
		return;
	}

	int iRankRQ = StringToInt(Get2DAString(CRAFTING_2DA, COL_CRAFTING_SKILL_LEVEL, _iRecipeId));
	if (GetSkillRank(SKILL_CRAFT_ALCHEMY, oCrafter) < iRankRQ)
	{
//		NotifyPlayer(oCrafter, ERROR_INSUFFICIENT_CRAFT_ALCHEMY_SKILL);
		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
					+ "You do not have enough ranks in Craft Alchemy.");
		return;
	}

	DestroyReagents();

	string sResrefList = Get2DAString(CRAFTING_2DA, COL_CRAFTING_OUTPUT, _iRecipeId);
	CreateProducts(sResrefList);

//	NotifyPlayer(oCrafter, OK_CRAFTING_SUCCESS);
	NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_SUCCESS
				+ "Alchemy complete.");

	effect eVis = EffectVisualEffect(VFX_FNF_CRAFT_ALCHEMY);
	ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF);
}


// ____________________________________________________________________________
//  ----------------------------------------------------------------------------
//   DISTILLATION
// ____________________________________________________________________________
//  ----------------------------------------------------------------------------

// Distills oItem when mortar & pestle is used directly on it.
// - distillation requires an acted upon item (reagent), a specific skill level
//   in Alchemy, and a mortar & pestle to activate it
// - reagent can be of any item type
// - also begins a salavage operation
// - distillation has no index
void DoDistillation(object oItem, object oCrafter)
{
	_sReagentTags = GetTag(oItem);
	_sTriggerId = DISTILLATION_RECIPE_TRIGGER;

	GetRecipeMatch();
	//TellCraft("_iRecipeId = " + IntToString(_iRecipeId));

	if (_iRecipeId != -1)
	{
		//TellCraft("Distilling ...");
		int iRankRQ = StringToInt(Get2DAString(CRAFTING_2DA, COL_CRAFTING_SKILL_LEVEL, _iRecipeId));
		string sResrefList = Get2DAString(CRAFTING_2DA, COL_CRAFTING_OUTPUT, _iRecipeId);
		ExecuteDistillation(iRankRQ, oItem, oCrafter, sResrefList);
	}
	else if (!StringToInt(Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 27))) // TCC_Toggle_AllowItemSalvaging
	{
		//TellCraft("Nothing to see here ...");
//		NotifyPlayer(oCrafter, ERROR_ITEM_NOT_DISTILLABLE);
		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
					+ "This is not a distillable item.");
	}
	else // ITEM SALVAGE SECTION ->
	{
		switch (GetTccType(oItem))
		{
			default:
				if (!GetPlotFlag(oItem))
				{
					ExecuteSalvage(oItem, oCrafter);
					break;
				}
				// no break;

			case TCC_TYPE_NONE:
			case TCC_TYPE_OTHER:
				NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
							+ "You cannot salvage any materials.");
		}
	}
}


// Helper for DoDistillation() -- but also used directly by the mortar & pestle
// on Fairy Dust and Shadow Reaver Bones.
void ExecuteDistillation(int iRankRQ, object oItem, object oCrafter, string sResrefList)
{
	if (GetSkillRank(SKILL_CRAFT_ALCHEMY, oCrafter) < iRankRQ)
	{
//		NotifyPlayer(oCrafter, ERROR_INSUFFICIENT_CRAFT_ALCHEMY_SKILL);
		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
					+ "You do not have enough ranks in Craft Alchemy.");
		return;
	}

	int iStackSize = GetItemStackSize(oItem); // can distill multiple objects at once.
	DestroyObject(oItem);

	int i;
	for (i = 0; i != iStackSize; ++i)
	{
		CreateProducts(sResrefList, oCrafter);
	}

//	NotifyPlayer(oCrafter, OK_CRAFTING_SUCCESS);
	NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_SUCCESS
				+ "Distillation complete.");

	effect eVis = EffectVisualEffect(VFX_FNF_CRAFT_SELF);
	ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, GetLocation(oCrafter));
}


// -----------------------------------------------------------------------------
// private functions for salvage operations
// -----------------------------------------------------------------------------

// Scans the ip's of oItem and produces salvaged materials.
// - creates salvaged materials in the same way as distilled items
void ExecuteSalvage(object oItem, object oCrafter)
{
	int iSalvageId, iSalvageGrade, iScanDC;

	int iSalvageDC = 1;
	int iRankRQ = 9999;

	string sResrefsFailure = "";
	string sResrefsSuccess = "";

	string sEss;

	itemproperty ipScan = GetFirstItemProperty(oItem);
	while (GetIsItemPropertyValid(ipScan))
	{
		iSalvageId = GetSalvageId(ipScan);
		if (iSalvageId != -1)									// process only if ip is valid for salvage
		{
			iSalvageGrade = GetSalvageGrade(ipScan, iSalvageId);

			iScanDC = GetSalvageDC(iSalvageId, iSalvageGrade);	// 'iSalvageDC' will be the highest DC
			if (iScanDC > iSalvageDC)
				iSalvageDC = iScanDC;

			if (iScanDC < iRankRQ)								// 'iRankRQ' will be the lowest DC
				iRankRQ = iScanDC;

			if (sResrefsFailure != "")							// assemble each ip's salvage-product
				sResrefsFailure += ",";

			if (sResrefsSuccess != "")
				sResrefsSuccess += ",";

			sEss = GetSalvageEssence(iSalvageId, iSalvageGrade);
			sResrefsFailure += sEss;
			sResrefsSuccess += sEss + "," + GetSalvageGem(iSalvageId, iSalvageGrade);
		}
		ipScan = GetNextItemProperty(oItem);
	}

	if (sResrefsFailure == "")
	{
		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
					+ "There are no materials that can be salvaged.");
		return;
	}

	if (iRankRQ - 5 > GetSkillRank(SKILL_SPELLCRAFT, oCrafter) // check required skill level
		&& StringToInt(Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 28))) // TCC_Toggle_SalvagingRequiresMinSkill
	{
		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
					+ "Your Spellcraft is not high enough to salvage any materials.");
		return;
	}

	int iStackMax = StringToInt(Get2DAString(BASEITEMS_2DA, COL_BASEITEMS_STACKING, GetBaseItemType(oItem)));
	if (iStackMax > 1) // check the chance of distilling a stack
	{
		int iStackSize = GetItemStackSize(oItem);
		int iChance = FloatToInt(100.f * (IntToFloat(iStackSize) / IntToFloat(iStackMax)));

		int iRoll = d100();
		if (iRoll > iChance) // fail.
		{
			NotifyPlayer(oCrafter, "<c=turquoise>Salvage Stack :</c> <c=red>* Failure *</c> <c=blue>( d100 : "
						+ IntToString(iRoll) + " vs " + IntToString(iChance) + " )</c>");
			NotifyPlayer(oCrafter, "There was not enough left of the stack to salvage anything."); //huh

			DestroyObject(oItem);
			return;
		}
		else
			NotifyPlayer(oCrafter, "<c=turquoise>Salvage Stack :</c> <c=green>* Success *</c> <c=blue>( d100 : "
						+ IntToString(iRoll) + " vs " + IntToString(iChance) + " )</c>");
	}

	string sResrefList; // auto success if no skillcheck required
	if (!StringToInt(Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 29)) // TCC_Toggle_SalvagingUsesSkillCheck
		|| GetIsSkillSuccessful(oCrafter, SKILL_SPELLCRAFT, iSalvageDC))
	{
		sResrefList = sResrefsSuccess;
	}
	else
		sResrefList = sResrefsFailure;

	DestroyObject(oItem);
	CreateProducts(sResrefList, oCrafter);
}

// -----------------------------------------------------------------------------
// helper functions for salvaging
// -----------------------------------------------------------------------------

// Gets the index of the salvage row associated with ipProp.
// -1 if there is no match
int GetSalvageId(itemproperty ipProp)
{
	int iPropType = GetItemPropertyType(ipProp);

	int iTotal = GetNum2DARows(TCC_SALVAGE_2da);
	int iSalvageId;
	for (iSalvageId = 0; iSalvageId != iTotal; ++iSalvageId)
	{
		if (StringToInt(Get2DAString(TCC_SALVAGE_2da, "PROPERTY", iSalvageId)) == iPropType)
			return iSalvageId;
	}
	return -1;
}

// Gets the salvage grade for ipProp.
// - returns 1..4
int GetSalvageGrade(itemproperty ipProp, int iSalvageId)
{
	int iRange = StringToInt(Get2DAString(TCC_SALVAGE_2da, "RANGE", iSalvageId));
	if (iRange == 1) // note: Range 1 properties require only Grade 1 skillz.
		return 1;

	int iCost = GetItemPropertyCostTableValue(ipProp); // else solve for the ip-cost
	if (iCost <= iRange / 4)
		return 1;

	if (iCost <= iRange / 2)
		return 2;

	if (iCost <= iRange * 3 / 4)
		return 3;

	return 4;
}

// Gets the skill DC related by iSalvageId and iGrade.
int GetSalvageDC(int iSalvageId, int iGrade)
{
	int iDC;
	switch (iGrade)
	{
		default: // should never happen.
		case 1: iDC = StringToInt(Get2DAString(TCC_SALVAGE_2da, "SKILL1", iSalvageId));
		case 2: iDC = StringToInt(Get2DAString(TCC_SALVAGE_2da, "SKILL2", iSalvageId));
		case 3: iDC = StringToInt(Get2DAString(TCC_SALVAGE_2da, "SKILL3", iSalvageId));
		case 4: iDC = StringToInt(Get2DAString(TCC_SALVAGE_2da, "SKILL4", iSalvageId));
	}
	return iDC + StringToInt(Get2DAString(TCC_CONFIG_2da, TCC_COL_VALUE, 0)); // TCC_Value_SalvageDCModifier
}

// Gets the tag of the essence related by iSalvageId and iGrade.
// - should be the resref but whatever. See Tcc_Salvage.2da
string GetSalvageEssence(int iSalvageId, int iGrade)
{
	switch (iGrade)
	{
		case 1: return Get2DAString(TCC_SALVAGE_2da, "ESSENCE1", iSalvageId);
		case 2: return Get2DAString(TCC_SALVAGE_2da, "ESSENCE2", iSalvageId);
		case 3: return Get2DAString(TCC_SALVAGE_2da, "ESSENCE3", iSalvageId);
		case 4: return Get2DAString(TCC_SALVAGE_2da, "ESSENCE4", iSalvageId);
	}
	return ""; // should never happen.
}

// Gets the tag of the gem related by iSalvageId and iGrade.
// - should be the resref but whatever. See Tcc_Salvage.2da
string GetSalvageGem(int iSalvageId, int iGrade)
{
	switch (iGrade)
	{
		case 1: return Get2DAString(TCC_SALVAGE_2da, "GEM1", iSalvageId);
		case 2: return Get2DAString(TCC_SALVAGE_2da, "GEM2", iSalvageId);
		case 3: return Get2DAString(TCC_SALVAGE_2da, "GEM3", iSalvageId);
		case 4: return Get2DAString(TCC_SALVAGE_2da, "GEM4", iSalvageId);
	}
	return ""; // should never happen.
}


// -----------------------------------------------------------------------------
// functions that invoke GUI-inputboxes
// -----------------------------------------------------------------------------

// Invokes a GUI-inputbox for player to relabel oItem.
// @param oCrafter	- a currently controlled character;
//					  either the crafter or the user of a Smith Hammer on oItem
// @param oItem		- the item to relabel
void GuiEnchantedLabel(object oCrafter, object oItem)
{
	SetLocalObject(GetModule(), CRAFT_VAR_LABELITEM, oItem);

	int iMessageStrRef		= 181743;	// "How shall this item be known henceforth?"
	string sMessage 		= "";
	string sOkCB			= "gui_name_enchanted_item";
	string sCancelCB		= "gui_name_enchanted_item_cancel";
	int bShowCancel 		= TRUE;		// kL_note: was FALSE; but it shows anyway.
	string sScreenName		= "";		// SCREEN_STRINGINPUT_MESSAGEBOX (default)
	int iOkStrRef			= 181744;	// "Okay"
	string sOkString		= "";
	int iCancelStrRef		= 181745;	// "Cancel"
	string sCancelString	= "";
	string sDefaultString	= GetFirstName(oItem);
	string sVariableString	= "";

	// The gui-script will always run on the Owned PC regardless of who the
	// player has possessed. So switch player-controlled-character to Owned PC
	// for this purpose only. Note that this is not strictly necessary to do
	// explicitly.

	DisplayInputBox(GetOwnedCharacter(oCrafter),
					iMessageStrRef,
					sMessage,
					sOkCB,
					sCancelCB,
					bShowCancel,
					sScreenName,
					iOkStrRef,
					sOkString,
					iCancelStrRef,
					sCancelString,
					sDefaultString,
					sVariableString);
}

// Opens a GUI inputbox for entering an Imbue_Item triggerspell.
// @param oCrafter - the crafter
void GuiTriggerSpell(object oCrafter)
{
	//TellCraft("GuiTriggerSpell() " + GetName(OBJECT_SELF));

	//TellCraft(". set CRAFT_VAR_CONTAINER_II");
	SetLocalObject(GetModule(), CRAFT_VAR_CONTAINER_II, OBJECT_SELF);

	int iMessageStrRef		= 0;
	string sMessage 		= "Enter a Spell ID ( see chat for options )";
	string sOkCB			= "gui_trigger_spell_set";
	string sCancelCB		= "gui_trigger_spell_cancel";
	int bShowCancel 		= TRUE;
	string sScreenName		= "";		// SCREEN_STRINGINPUT_MESSAGEBOX (default)
	int iOkStrRef			= 181744;	// "Okay"
	string sOkString		= "";
	int iCancelStrRef		= 181745;	// "Cancel"
	string sCancelString	= "";
	string sDefaultString	= "";
	string sVariableString	= "";

	// The gui-script will always run on the Owned PC regardless of who the
	// player has possessed. So switch oCrafter to Owned PC for this purpose
	// only. Note that this is not strictly necessary to do explicitly.

	DisplayInputBox(GetOwnedCharacter(oCrafter),
					iMessageStrRef,
					sMessage,
					sOkCB,
					sCancelCB,
					bShowCancel,
					sScreenName,
					iOkStrRef,
					sOkString,
					iCancelStrRef,
					sCancelString,
					sDefaultString,
					sVariableString);
}

// Opens a GUI-inputbox that creates a Set and allows player to label it.
// - this will convert all Set-flagged items in the crafting container into
//   Set-parts and destroy any reagent items
void GuiCreateSet(object oCrafter)
{
	//TellCraft("GuiCreateSet() " + GetName(OBJECT_SELF));

	// NOTE: The space for a message at the top of the Gui-inputbox is very
	// limited; the up/down scroll-buttons get mashed almost on top of each
	// other. So, put the body of text in chat ...
	NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_SET_LABEL
				+ "Only alphabetical characters, spaces, single-quotes, and colons are"
				+ " allowed. There must be at least one character other than a space."

				+ "\n\nThe label will appear before the name of each item in the Set."

				+ "\n\n<c=firebrick>WARNING :</c> Items that are in a Property Set cannot"
				+ " be re-labeled or sold, nor can they be part of a different Set.");

	//TellCraft(". set CRAFT_VAR_CONTAINER");
	SetLocalObject(GetModule(), CRAFT_VAR_CONTAINER, OBJECT_SELF);

	int iMessageStrRef		= 0;
	string sMessage 		= "Give your Property Set a label :";
	string sOkCB			= "gui_tcc_create_set";
	string sCancelCB		= "";
	int bShowCancel 		= FALSE;
	string sScreenName		= "";		// SCREEN_STRINGINPUT_MESSAGEBOX (default)
	int iOkStrRef			= 181744;	// "Okay"
	string sOkString		= "";
	int iCancelStrRef		= 0;
	string sCancelString	= "";
	string sDefaultString	= "";
	string sVariableString	= "";

	// The gui-script will always run on the Owned PC regardless of who the
	// player has possessed. So switch oCrafter to Owned PC for this purpose
	// only. Note that this is not strictly necessary to do explicitly.

	DisplayInputBox(GetOwnedCharacter(oCrafter),
					iMessageStrRef,
					sMessage,
					sOkCB,
					sCancelCB,
					bShowCancel,
					sScreenName,
					iOkStrRef,
					sOkString,
					iCancelStrRef,
					sCancelString,
					sDefaultString,
					sVariableString);
}

// Opens a GUI-dialog that asks player whether to proceed with adding a
// latent-ip to a Property Set-prepared part.
// - if ( iSpellId=-1 ) the player will be asked whether he/she wishes to remove
//   the item(s) from their current Property Set(s)
void GuiPrepareLatent(object oCrafter, int iSpellId)
{
	object oModule = GetModule();
	SetLocalObject(oModule, CRAFT_VAR_CONTAINER, OBJECT_SELF);
	SetLocalInt(oModule, CRAFT_VAR_SPELLID, iSpellId);

	int iMessageStrRef		= 0;
	string sMessage;
	string sOkCB			= "gui_tcc_enchant_latent";
	string sCancelCB		= "gui_tcc_enchant_latent_cancel";
	int bShowCancel			= TRUE;
	string sScreenName		= "";		// SCREEN_MESSAGEBOX_DEFAULT (default)
	int iOkStrRef			= 181744;	// "Okay"
	string sOkString		= "";
	int iCancelStrRef		= 181745;	// "Cancel"
	string sCancelString	= "";

	if (iSpellId != -1)
		sMessage = NOTE_CRAFT + NOTE_SET_PREPITEM
				 + "Crafting has detected an item that is grouped in a Property Set."
				 + "\n\nOkay will try to apply the recipe to the Set-item.";
	else // wipe all Set-vars off a Set-item
		sMessage = NOTE_CRAFT + NOTE_SET_ITEM
				 + "Crafting has detected an item that is grouped in a Property Set."
				 + "\n\n<c=firebrick>WARNING :</c> Okay will clear the item"
				 + " from its Set and that Set will no longer be valid.";

	// The gui-script will always run on the Owned PC regardless of who the
	// player has possessed. So switch oCrafter to Owned PC for this purpose
	// only. Note that this is not strictly necessary to do explicitly.

	DisplayMessageBox(GetOwnedCharacter(oCrafter),
					  iMessageStrRef,
					  sMessage,
					  sOkCB,
					  sCancelCB,
					  bShowCancel,
					  sScreenName,
					  iOkStrRef,
					  sOkString,
					  iCancelStrRef,
					  sCancelString);
}


// -----------------------------------------------------------------------------
// public functions for mortar & pestle and shaper's alembic
// -----------------------------------------------------------------------------

// Sets up a list of up to 10 elements.
// - the list is simply a comma delimited string
// - only first element is required
string MakeList(string sReagent1,
				string sReagent2  = "",
				string sReagent3  = "",
				string sReagent4  = "",
				string sReagent5  = "",
				string sReagent6  = "",
				string sReagent7  = "",
				string sReagent8  = "",
				string sReagent9  = "",
				string sReagent10 = "")
{
	string sList = sReagent1;

	if (sReagent2  != "") sList += REAGENT_LIST_DELIMITER + sReagent2;
	if (sReagent3  != "") sList += REAGENT_LIST_DELIMITER + sReagent3;
	if (sReagent4  != "") sList += REAGENT_LIST_DELIMITER + sReagent4;
	if (sReagent5  != "") sList += REAGENT_LIST_DELIMITER + sReagent5;
	if (sReagent6  != "") sList += REAGENT_LIST_DELIMITER + sReagent6;
	if (sReagent7  != "") sList += REAGENT_LIST_DELIMITER + sReagent7;
	if (sReagent8  != "") sList += REAGENT_LIST_DELIMITER + sReagent8;
	if (sReagent9  != "") sList += REAGENT_LIST_DELIMITER + sReagent9;
	if (sReagent10 != "") sList += REAGENT_LIST_DELIMITER + sReagent10;

	return sList;
}



// -----------------------------------------------------------------------------
// functions for SoZ crafting
// -----------------------------------------------------------------------------

// Checks if all sEncodedIps qualify as an upgrade.
int GetAreAllEncodedEffectsAnUpgrade(object oItem, string sEncodedIps)
{
	string sEncodedIp;
	struct tokenizer rEncodedIps = GetStringTokenizer(sEncodedIps, ENCODED_IP_LIST_DELIMITER);
	while (CheckMoreTokens(rEncodedIps))
	{
		rEncodedIps = AdvanceTokenizer(rEncodedIps);
		sEncodedIp = GetCurrentToken(rEncodedIps);

		if (!GetIsEncodedEffectAnUpgrade(oItem, sEncodedIp))
			return FALSE; // if any is not an upgrade then all are not an upgrade
	}
	return TRUE;
}

// Checks if sEncodedIp is an upgrade.
int GetIsEncodedEffectAnUpgrade(object oItem, string sEncodedIp)
{
	itemproperty ip = GetEncodedEffectItemProperty(sEncodedIp);
	if (GetIsItemPropertyValid(ip))
		return GetIsItemPropertyAnUpgrade(oItem, ip);

	return FALSE;
}

// Constructs an ip from sEncodedIp.
itemproperty GetEncodedEffectItemProperty(string sEncodedIp)
{
	return IPGetItemPropertyByID(GetIntParam(sEncodedIp, 0, REAGENT_LIST_DELIMITER),
								 GetIntParam(sEncodedIp, 1, REAGENT_LIST_DELIMITER),
								 GetIntParam(sEncodedIp, 2, REAGENT_LIST_DELIMITER),
								 GetIntParam(sEncodedIp, 3, REAGENT_LIST_DELIMITER),
								 GetIntParam(sEncodedIp, 4, REAGENT_LIST_DELIMITER));
}

// Gets whether ip will be treated as an upgrade.
// - this is functionally identical to isIpUpgrade()
int GetIsItemPropertyAnUpgrade(object oItem, itemproperty ip)
{
	if (isIgnoredIp(ip))
		return FALSE;

	return IPGetItemHasProperty(oItem, ip, DURATION_TYPE_PERMANENT, isIgnoredSubtype(ip));
}

// Applies all sEncodedIps to oItem.
// - effects are delimited with a semicolon ";"
void ApplyEncodedEffectsToItem(object oItem, string sEncodedIps)
{
	//TellCraft("applying sEncodedIps " + sEncodedIps);
	string sEncodedIp;
	struct tokenizer rEncodedIps = GetStringTokenizer(sEncodedIps, ENCODED_IP_LIST_DELIMITER);
	while (CheckMoreTokens(rEncodedIps))
	{
		rEncodedIps = AdvanceTokenizer(rEncodedIps);
		sEncodedIp = GetCurrentToken(rEncodedIps);
		AddEncodedIp(oItem, sEncodedIp);
	}
}

// Adds sEncodedIp to oItem.
void AddEncodedIp(object oItem, string sEncodedIp)
{
	itemproperty ipEnchant = IPGetItemPropertyByID(GetIntParam(sEncodedIp, 0, REAGENT_LIST_DELIMITER),
												   GetIntParam(sEncodedIp, 1, REAGENT_LIST_DELIMITER),
												   GetIntParam(sEncodedIp, 2, REAGENT_LIST_DELIMITER),
												   GetIntParam(sEncodedIp, 3, REAGENT_LIST_DELIMITER),
												   GetIntParam(sEncodedIp, 4, REAGENT_LIST_DELIMITER));
	if (GetIsItemPropertyValid(ipEnchant))
	{
		int iPolicy; // AddItemPropertyAutoPolicy(oItem, ipEnchant);
		if (isIgnoredIp(ipEnchant))
			iPolicy = X2_IP_ADDPROP_POLICY_IGNORE_EXISTING;
		else
			iPolicy = X2_IP_ADDPROP_POLICY_REPLACE_EXISTING;

		IPSafeAddItemProperty(oItem,
							  ipEnchant,
							  0.f,
							  iPolicy,
							  FALSE,
							  isIgnoredSubtype(ipEnchant));
	}
	//else TellCraft("ERROR : AddEncodedIp() ipEnchant is invalid ( " + sEncodedIp + " )");
}


// -----------------------------------------------------------------------------
// functions that were factored into others or are unused
// -----------------------------------------------------------------------------

/* Creates a list containing the property and parameters of an effect to apply.
// - property-ID required
// - see IPSafeAddItemProperty() in 'x2_inc_itemprop' for supported values
string MakeEncodedEffect(int iPropType, int iPar1 = 0, int iPar2 = 0, int iPar3 = 0, int iPar4 = 0)
{
	return IntToString(iPropType)
		 + REAGENT_LIST_DELIMITER + IntToString(iPar1)	// note: Yes these use commas.
		 + REAGENT_LIST_DELIMITER + IntToString(iPar2)	// But the delimiter between each encoded ip
		 + REAGENT_LIST_DELIMITER + IntToString(iPar3)	// when there are multiple encoded ip's
		 + REAGENT_LIST_DELIMITER + IntToString(iPar4);	// is ENCODED_IP_LIST_DELIMITER (semi-colon).
} */

/* Determine policies to use before sending off to IPSafeAddItemProperty()
void AddItemPropertyAutoPolicy(object oItem, itemproperty ip, float fDur = 0.f)
{
	int nAddItemPropertyPolicy = X2_IP_ADDPROP_POLICY_REPLACE_EXISTING;
	if (isIgnoredIp(ip))
		nAddItemPropertyPolicy = X2_IP_ADDPROP_POLICY_IGNORE_EXISTING;

	IPSafeAddItemProperty(oItem, ip, fDur, nAddItemPropertyPolicy, FALSE, isIgnoredSubtype(ip));
} */

// =============================================================================
// New Enchantment-tag Handling System
// =============================================================================
/* Looks in oContainer for an item of any of the types in sTagList.
object GetEnchantmentTarget(string sTagList, object oContainer)
{
	object oTarget;

	int i = 0;
	int iTag = GetIntParam(sTagList, i);
	while (iTag != 0)
	{
		if (GetIsObjectValid(oTarget = GetTargetOfTccType(iTag, oContainer)))
			return oTarget;
		iTag = GetIntParam(sTagList, ++i);
	}
	return OBJECT_INVALID;
} */
