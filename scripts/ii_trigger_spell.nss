// 'ii_trigger_spell'
//
// kevL 2016 sept 13
// Script that runs when a trigger-spell is accepted via GUI-inputbox.


#include "ginc_crafting" // DoMagicCrafting()

void main()
{
	object oModule = GetModule();

	object oCrafter = GetLocalObject(oModule, CRAFT_VAR_CRAFTER);
	int iSpellId = GetLocalInt(oModule, CRAFT_VAR_SPELLID_II);

	DoMagicCrafting(iSpellId, oCrafter);
}
