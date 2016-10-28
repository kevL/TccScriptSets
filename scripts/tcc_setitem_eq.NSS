// 'tcc_setitem_eq'
//
// Script runs whenever a TCC Property Set item is equipped.
// - processes all equipped items setting properties based on TCC variables


#include "ginc_crafting"

void main()
{
	object oPC = GetPCItemLastEquippedBy();
	object oItem = GetPCItemLastEquipped();

	int iGroup = GetLocalInt(oItem, TCC_VAR_SET_GROUP);
	int iParts = 0;

	object oGroup;
	int iSlot;
	for (iSlot = INVENTORY_SLOT_HEAD; iSlot != INVENTORY_SLOT_ARROWS; ++iSlot)
	{
		oGroup = GetItemInSlot(iSlot, oPC);
		if (GetIsObjectValid(oGroup)
			&& GetLocalInt(oGroup, TCC_VAR_SET_GROUP) == iGroup)
		{
			++iParts;
		}
	}

	if (iParts == GetLocalInt(oItem, TCC_VAR_SET_PARTS))
	{
		string sLatentIp;
		itemproperty ipLatent;
		int iLatentType;
		string sLatentType;

		int iSlot;
		for (iSlot = INVENTORY_SLOT_HEAD; iSlot != INVENTORY_SLOT_ARROWS; ++iSlot)
		{
			oGroup = GetItemInSlot(iSlot, oPC);
			if (GetIsObjectValid(oGroup)
				&& GetLocalInt(oGroup, TCC_VAR_SET_GROUP) == iGroup
				&& !GetLocalInt(oGroup, TCC_VAR_SET_PREP_ITEM)) // prepared items don't have a latent-ip yet.
			{
				sLatentIp = GetLocalString(oGroup, TCC_VAR_SET_IP);
				iLatentType = GetIntParam(sLatentIp, 0, REAGENT_LIST_DELIMITER);
				ipLatent = IPGetItemPropertyByID(iLatentType,
												 GetIntParam(sLatentIp, 1, REAGENT_LIST_DELIMITER),
												 GetIntParam(sLatentIp, 2, REAGENT_LIST_DELIMITER),
												 GetIntParam(sLatentIp, 3, REAGENT_LIST_DELIMITER),
												 GetIntParam(sLatentIp, 4, REAGENT_LIST_DELIMITER));
				IPSafeAddItemProperty(oGroup, ipLatent, 0.f, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);

				sLatentType = GetStringByStrRef(StringToInt(Get2DAString(ITEM_PROP_DEF_2DA, COL_ITEM_PROP_DEF_NAME, iLatentType)));
				NotifyPlayer(oPC, "<c=seagreen>_ Property Set :</c> Activate : <c=cornflowerblue>"
							+ GetName(oGroup) + " ( " + sLatentType + " )</c>");
			}
		}
	}
}
