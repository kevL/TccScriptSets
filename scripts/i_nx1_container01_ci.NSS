// 'i_nx1_container01_ci'
/*
	Tag-based OnSpellCastAt script.
	This code runs when a PC or DM casts a spell from one of the standard
	spellbooks on the MotB enchanter's satchel.
*/
// ChazM 8/2/06


#include "crafting_inc_const"
#include "x2_inc_switches"

void main()
{
	object oModule = GetModule();
	SetLocalObject(oModule, CRAFT_VAR_CRAFTER, OBJECT_SELF);
	SetLocalInt(oModule, CRAFT_VAR_SPELLID, GetSpellId());

	ExecuteScript("gr_domagiccrafting", GetSpellTargetObject());

	SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_END);
}
