// 'nx_s2_shapers_alembic'
/*
	The Shapers Alembic Spell Script
	Copyright (c) 2007 Obsidian Entertainment Inc.
*/
// ChazM OEI 3/14/07
// ChazM 7/3/07 - Changed Essence grade relation from 10 to 8; added some constants.
// ChazM 7/25/07 - Essence Groups more strictly defined to include element type as
//				   part of tag (prevents special essences from being improperly affected)
// kevL 160921 - refactored.
//			   - moved spell-constants to 'constants_inc'

// OC grades:
// - faint, weak, glowing, radiant
// MotB grades:
// - volatile, brilliant, pristine


#include "x2_inc_spellhook"
#include "ginc_crafting"

// ________________
// ** CONSTANTS ***
// ----------------
// essence tag/resref parts
const int ESSENCE_INVALID = 0; // catch-all for Invalid.

const int ESSENCE_OC				= 1; // OC essence-related ->
const int ESSENCE_OC_GRADE_MAX		= 4;
const int ESSENCE_OC_GRADE_REL		= 2;

const string ESSENCE_OC_PRE			= "cft_ess_";
const string ESSENCE_OC_TYPE_FIRE	= "cft_ess_fire";
const string ESSENCE_OC_TYPE_WATER	= "cft_ess_water";
const string ESSENCE_OC_TYPE_AIR	= "cft_ess_air";
const string ESSENCE_OC_TYPE_EARTH	= "cft_ess_earth";
const string ESSENCE_OC_TYPE_POWER	= "cft_ess_power";

const int ESSENCE_MOTB					= 2; // MotB essence-related ->
const int ESSENCE_MOTB_GRADE_MAX		= 3;
const int ESSENCE_MOTB_GRADE_REL		= 8;

const string ESSENCE_MOTB_PRE			= "nx1_cft_ess_";
const string ESSENCE_MOTB_TYPE_FIRE		= "nx1_cft_ess_fire0";
const string ESSENCE_MOTB_TYPE_WATER	= "nx1_cft_ess_water0";
const string ESSENCE_MOTB_TYPE_AIR		= "nx1_cft_ess_air0";
const string ESSENCE_MOTB_TYPE_EARTH	= "nx1_cft_ess_earth0";
const string ESSENCE_MOTB_TYPE_POWER	= "nx1_cft_ess_power0";
const string ESSENCE_MOTB_TYPE_SPIRIT	= "nx1_cft_ess_spirit0";

// type-strings
const string ELEMENT_AIR	= "air";
const string ELEMENT_EARTH	= "earth";
const string ELEMENT_FIRE	= "fire";
const string ELEMENT_WATER	= "water";
const string ELEMENT_POWER	= "power";
const string ELEMENT_SPIRIT	= "spirit";

// errors
//const int ERROR_ESS_INVALID_ESSENCE			= 186022; // "Target not an essence."
//const int ERROR_ESS_CANT_DIVIDE				= 186023; // "This essence can't be further divided."
//const int ERROR_ESS_CANT_COMBINE				= 186024; // "This essence can't be further combined."
//const int ERROR_ESS_INSUFFICIENT_TO_COMBINE	= 186025; // "Insufficient essences to combine."
//const int ERROR_ESS_CANT_CONVERT_SPIRIT		= 186026; // "Can't convert spirit essences."
//const int ERROR_ESS_CANT_CONVERT_LOW_GRADE	= 186027; // "Essence grade to low to convert."
//const int ERROR_ESS_INSUFFICIENT_TO_CONVERT	= 186028; // "Insufficient essences to convert."


// __________________
// ** DEFINITIONS ***
// ------------------

//
int IsPrefixMatch(string sString, string sPrefix)
{
	if (FindSubString(sString, sPrefix) == 0)
		return TRUE;

	return FALSE;
}

//
string GetEssenceResRef(int iGroup, string sElement, int iGrade)
{
	string sGroup;
	switch (iGroup)
	{
		case ESSENCE_OC:
			sGroup = ESSENCE_OC_PRE;
			break;
		case ESSENCE_MOTB:
			sGroup = ESSENCE_MOTB_PRE;
			sElement += "0";
	}

	return sGroup + sElement + IntToString(iGrade);
}

// the OC essences.
int GetIsEssenceOc(object oTarget)
{
	string sTag = GetTag(oTarget);
	if (   IsPrefixMatch(sTag, ESSENCE_OC_TYPE_FIRE)
		|| IsPrefixMatch(sTag, ESSENCE_OC_TYPE_WATER)
		|| IsPrefixMatch(sTag, ESSENCE_OC_TYPE_AIR)
		|| IsPrefixMatch(sTag, ESSENCE_OC_TYPE_EARTH)
		|| IsPrefixMatch(sTag, ESSENCE_OC_TYPE_POWER))
	{
		return TRUE;
	}

	return FALSE;
}

// the NX1 essence additions.
int GetIsEssenceMotb(object oTarget)
{
	string sTag = GetTag(oTarget);
	if (   IsPrefixMatch(sTag, ESSENCE_MOTB_TYPE_FIRE)
		|| IsPrefixMatch(sTag, ESSENCE_MOTB_TYPE_WATER)
		|| IsPrefixMatch(sTag, ESSENCE_MOTB_TYPE_AIR)
		|| IsPrefixMatch(sTag, ESSENCE_MOTB_TYPE_EARTH)
		|| IsPrefixMatch(sTag, ESSENCE_MOTB_TYPE_POWER)
		|| IsPrefixMatch(sTag, ESSENCE_MOTB_TYPE_SPIRIT))
	{
		return TRUE;
	}

	return FALSE;
}

//
int GetEssenceGroup(object oEssence)
{
	if (GetIsEssenceOc(oEssence))
		return ESSENCE_OC;

	if (GetIsEssenceMotb(oEssence))
		return ESSENCE_MOTB;

	return ESSENCE_INVALID;
}

// assumes oEssence is an essence
int GetEssenceGrade(object oEssence)
{
	return StringToInt(GetStringRight(GetTag(oEssence), 1));
}

//
string GetEssenceType(object oEssence)
{
	string sTag = GetTag(oEssence);
	return GetStringLeft(sTag, GetStringLength(sTag) - 1);
}

//
void SetStackSize(object oItem, int iLeftover)
{
	switch (iLeftover)
	{
		case 0:
			DestroyObject(oItem);
			break;
		default:
			SetItemStackSize(oItem, iLeftover);
	}
}


// skill check for distillation
int DoDistillationSkillCheck(int iSkillReq, object oCrafter)
{
	if (GetSkillRank(SKILL_CRAFT_ALCHEMY, oCrafter) < iSkillReq)
	{
//		NotifyPlayer(oCrafter, ERROR_INSUFFICIENT_CRAFT_ALCHEMY_SKILL);
		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
					+ "You do not have enough ranks in Craft Alchemy.");
		return FALSE;
	}

//	NotifyPlayer(oCrafter, OK_CRAFTING_SUCCESS);
	NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_SUCCESS
				+ "Distillation complete.");

	effect eVis = EffectVisualEffect(VFX_FNF_CRAFT_SELF);
	location lLoc = GetLocation(oCrafter);
	ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, lLoc);

	return TRUE;
}

//
void CreateProductsIterated(int iIterations, string sResrefList, object oTarget)
{
	int i;
	for (i = 0; i != iIterations; ++i)
	{
		CreateProducts(sResrefList, oTarget);
	}
}

//
int GetMaxGrade(int iGroup)
{
	switch (iGroup)
	{
		case 1: return ESSENCE_OC_GRADE_MAX;
		case 2: return ESSENCE_MOTB_GRADE_MAX;
	}
	return ESSENCE_INVALID;
}

//
int GetGradeRelationship(int iGroup)
{
	switch (iGroup)
	{
		case 1: return ESSENCE_OC_GRADE_REL;
		case 2: return ESSENCE_MOTB_GRADE_REL;
	}
	return ESSENCE_INVALID;
}

// Divides the essences into lower value.
int DivideEssences(object oEssence, object oCrafter)
{
	int iGrade = GetEssenceGrade(oEssence);
	if (iGrade < 2)
	{
		//PrettyDebug("This Essence can't be further divided");
//		NotifyPlayer(oCrafter, ERROR_ESS_CANT_DIVIDE);
		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
					+ "This essence can't be further divided.");
		return FALSE;
	}

	if (DoDistillationSkillCheck(iGrade * 2, oCrafter)) // skill required = twice the grade of the essence
	{
		int iStackSize = GetItemStackSize(oEssence); // can distill multiple objects at once.
		int iGroup = GetEssenceGroup(oEssence);
		int iGradeRelationship = GetGradeRelationship(iGroup);
		int iNewStackSize = iStackSize * iGradeRelationship;

		string sType = GetEssenceType(oEssence);
		int iNewGrade = iGrade - 1;
		string sResrefList = sType + IntToString(iNewGrade);

		DestroyObject(oEssence);
		CreateProductsIterated(iNewStackSize, sResrefList, oCrafter);

		return TRUE;
	}

	return FALSE;
}

// Combines the essences to higher value.
int CombineEssences(object oEssence, object oCrafter)
{
	int iGrade = GetEssenceGrade(oEssence);
	int iGroup = GetEssenceGroup(oEssence);
	if (iGrade == GetMaxGrade(iGroup))
	{
		//PrettyDebug("This essence can't be further combined");
//		NotifyPlayer(oCrafter, ERROR_ESS_CANT_COMBINE);
		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
					+ "This essence can't be further combined.");
		return FALSE;
	}

	int iStackSize = GetItemStackSize(oEssence); // can distill multiple objects at once.
	int iGradeRelationship = GetGradeRelationship(iGroup);
	if (iStackSize < iGradeRelationship)
	{
		//PrettyDebug("Insufficient essences to combine");
//		NotifyPlayer(oCrafter, ERROR_ESS_INSUFFICIENT_TO_COMBINE);
		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
					+ "Insufficient essences to combine.");
		return FALSE;
	}

	int iNewGrade = iGrade + 1;
	if (DoDistillationSkillCheck(iNewGrade * 2, oCrafter)) // skill required = twice the new grade of the essence
	{
		// all requirements passed
		int iLeftover = iStackSize % iGradeRelationship;
		SetStackSize(oEssence, iLeftover);

		int iNewStackSize = iStackSize / iGradeRelationship;
		string sType = GetEssenceType(oEssence);
		string sResrefList = sType + IntToString(iNewGrade);
		CreateProductsIterated(iNewStackSize, sResrefList, oCrafter);

		return TRUE;
	}

	return FALSE;
}

// Converts the essences.
int ConvertEssences(object oEssence, object oCrafter)
{
	string sType = GetEssenceType(oEssence);
	if (sType == ESSENCE_MOTB_TYPE_SPIRIT)
	{
		//PrettyDebug("Can't convert spirit essences");
//		NotifyPlayer(oCrafter, ERROR_ESS_CANT_CONVERT_SPIRIT);
		NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
					+ "Spirit essences can't be converted.");
		return FALSE;
	}

	int iGrade = GetEssenceGrade(oEssence);
	if (DoDistillationSkillCheck(iGrade * 2, oCrafter)) // skill required = twice the new grade of the essence
	{
		string sResrefList;
		int iNewStackSize;
		int iLeftover;

		int iGroup = GetEssenceGroup(oEssence);
		int iStackSize = GetItemStackSize(oEssence); // can distill multiple objects at once.

		if (   sType == ESSENCE_OC_TYPE_POWER
			|| sType == ESSENCE_MOTB_TYPE_POWER)
		{
			// convert 1 power essence into x/3 of each elemental essence 1 grade lower.
			// where x = Conversion Rate rounded down.
			if (iGrade == 1)
			{
				//PrettyDebug("essence grade to low for conversion");
//				NotifyPlayer(oCrafter, ERROR_ESS_CANT_CONVERT_LOW_GRADE);
				NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
							+ "Essence grade is too low to convert.");
				return FALSE;
			}

			int iGradeRelationship = GetGradeRelationship(iGroup);
			iNewStackSize = iGradeRelationship / 3;
			if (iNewStackSize < 1)
				iNewStackSize = 1;
			iLeftover = iStackSize - 1;
			int iNewGrade = iGrade - 1;
			sResrefList = MakeList(GetEssenceResRef(iGroup, ELEMENT_AIR,   iNewGrade),
								   GetEssenceResRef(iGroup, ELEMENT_EARTH, iNewGrade),
								   GetEssenceResRef(iGroup, ELEMENT_FIRE,  iNewGrade),
								   GetEssenceResRef(iGroup, ELEMENT_WATER, iNewGrade));
		}
		else // fire, earth, air or water essence of both groups
		{
			// convert 2 elemental essences into 1 power essence of same grade.
			if (iStackSize < 2)
			{
				//PrettyDebug("Two elemental essences required for conversion");
//				NotifyPlayer(oCrafter, ERROR_ESS_INSUFFICIENT_TO_CONVERT);
				NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
							+ "Insufficient essences to convert.");
				return FALSE;
			}

			iNewStackSize = 1;
			iLeftover = iStackSize - 2;
			sResrefList = GetEssenceResRef(iGroup, ELEMENT_POWER, iGrade);
		}

		// all requirements passed
		SetStackSize(oEssence, iLeftover);
		CreateProductsIterated(iNewStackSize, sResrefList, oCrafter);

		return TRUE;
	}

	return FALSE;
}


// ___________
// ** MAIN ***
// -----------
void main()
{
	// If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run
	// this spell.
	if (X2PreSpellCastCode())
	{
		object oCrafter = OBJECT_SELF;
		object oTarget = GetSpellTargetObject();
		//PrettyDebug("Shapers Alembic script called with spell ID " + IntToString(iSpellId));

		// This "spell" only affects specific types of items - no guff.
		if (GetObjectType(oTarget) != OBJECT_TYPE_ITEM
			|| GetEssenceGroup(oTarget) == ESSENCE_INVALID)
		{
			//PrettyDebug("Target not an item type");
			//PrettyDebug("Target not an essence");
//			NotifyPlayer(oCrafter, ERROR_ESS_INVALID_ESSENCE);
			NotifyPlayer(oCrafter, NOTE_CRAFT + NOTE_RESULT_FAIL
						+ "Target is not an essence.");
			return;
		}

		int iSpellId = GetSpellId();
		switch (iSpellId)
		{
			case SPELL_SHAPERS_ALEMBIC_DIVIDE:
				//PrettyDebug("Divide essence");
				DivideEssences(oTarget, oCrafter);
				break;

			case SPELL_SHAPERS_ALEMBIC_COMBINE:
				//PrettyDebug("Combine essence");
				CombineEssences(oTarget, oCrafter);
				break;

			case SPELL_SHAPERS_ALEMBIC_CONVERT:
				//PrettyDebug("Convert essence");
				// Convert normal essences to Power, and Power to normal.
				// Spirit Essences aren't convertible.
				ConvertEssences(oTarget, oCrafter);

			//break;
			//default: PrettyDebug("Unrecognized spell id");
		}

		SignalEvent(oTarget, EventSpellCastAt(oCrafter, iSpellId, FALSE));
	}
}
