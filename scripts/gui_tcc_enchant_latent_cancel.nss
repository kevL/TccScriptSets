// 'gui_tcc_enchant_latent_cancel'
//
// kevL 2016 oct 5


#include "crafting_inc_const"

void main()
{
	//SendMessageToPC(GetFirstPC(FALSE), "Run ( gui_tcc_enchant_latent_cancel ) " + GetName(OBJECT_SELF));

	object oModule = GetModule();

	// clean up.
	DeleteLocalObject(oModule, CRAFT_VAR_CONTAINER);
	DeleteLocalInt(oModule, CRAFT_VAR_SPELLID);
}
