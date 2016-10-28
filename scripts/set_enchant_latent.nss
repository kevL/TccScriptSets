// 'set_enchant_latent'
//
// kevL 2016 oct 7


#include "ginc_crafting"

void main()
{
	object oModule = GetModule();

	object oCrafter = GetLocalObject(oModule, CRAFT_VAR_CRAFTER);
	int iSpellId = GetLocalInt(oModule, CRAFT_VAR_SPELLID);

	DoMagicCrafting(iSpellId, oCrafter);
}
