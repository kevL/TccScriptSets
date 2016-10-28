// 'gr_domagiccrafting'
/*
	Calls magic crafting on an item-container.
*/
// MDiekmann_3/14/07


#include "ginc_crafting"

void main()
{
	//TellCraft("Run ( gr_domagiccrafting ) " + GetName(OBJECT_SELF));

	object oModule = GetModule();
	object oCrafter = GetLocalObject(oModule, CRAFT_VAR_CRAFTER);
	int iSpellId = GetLocalInt(oModule, CRAFT_VAR_SPELLID);

	//TellCraft(". iSpellId= " + IntToString(iSpellId) + " crafter= " + GetName(oCrafter));

	DoMagicCrafting(iSpellId, oCrafter);

	// clean up.
	DeleteLocalObject(oModule, CRAFT_VAR_CRAFTER);
	DeleteLocalInt(oModule, CRAFT_VAR_SPELLID);
}
