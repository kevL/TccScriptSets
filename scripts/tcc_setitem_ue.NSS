// 'tcc_setitem_ue'
//
// Script runs whenever a TCC Property Set item is unequipped.
// - processes all equipped items setting properties based on TCC variables


#include "ginc_crafting"

void main()
{
	object oPC = GetPCItemLastUnequippedBy();
	object oItem = GetPCItemLastUnequipped(); // note: The item is still considered equipped.

	int iGroup = GetLocalInt(oItem, TCC_VAR_SET_GROUP);
	object oGroup;

	itemproperty ipLatent, ipScan;

	int iLatentType, iLatentSubtype, iLatentCostTable, iLatentCost;
	int iScanType,   iScanSubtype,   iScanCostTable,   iScanCost;

	string sLatentIp, sLatentType;

	int bIgnoreSubtype;

	int iSlot;
	for (iSlot = INVENTORY_SLOT_HEAD; iSlot != INVENTORY_SLOT_ARROWS; ++iSlot)
	{
		oGroup = GetItemInSlot(iSlot, oPC);
		if (GetIsObjectValid(oGroup)
			&& GetLocalInt(oGroup, TCC_VAR_SET_GROUP) == iGroup
			&& !GetLocalInt(oGroup, TCC_VAR_SET_PREP_ITEM)) // prepared items don't have a latent-ip yet.
		{
			sLatentIp = GetLocalString(oGroup, TCC_VAR_SET_IP);
			ipLatent = IPGetItemPropertyByID(GetIntParam(sLatentIp, 0),
											 GetIntParam(sLatentIp, 1),
											 GetIntParam(sLatentIp, 2),
											 GetIntParam(sLatentIp, 3),
											 GetIntParam(sLatentIp, 4));

			iLatentType			= GetItemPropertyType(ipLatent);
			iLatentSubtype		= GetItemPropertySubType(ipLatent);
			iLatentCostTable	= GetItemPropertyCostTable(ipLatent);
			iLatentCost			= GetItemPropertyCostTableValue(ipLatent);
			// NOTE: does not consider Param1 or Param1Value.

			bIgnoreSubtype = isIgnoredSubtype(ipLatent);
			// <- shouldn't have to ignore the SubType since ipScan was applied with
			// sLatentIp. So in fact you'd *want* them to match no matter what.
			// But do it anyway, this is NwN2.

			ipScan = GetFirstItemProperty(oGroup);
			while (GetIsItemPropertyValid(ipScan))
			{
				if (GetItemPropertyDurationType(ipScan) == DURATION_TYPE_PERMANENT)
				{
					iScanType		= GetItemPropertyType(ipScan);
					iScanSubtype	= GetItemPropertySubType(ipScan);
					iScanCostTable	= GetItemPropertyCostTable(ipScan);
					iScanCost		= GetItemPropertyCostTableValue(ipScan);

					if (   iScanType		== iLatentType
						&& (iScanSubtype	== iLatentSubtype || bIgnoreSubtype)
						&& iScanCostTable	== iLatentCostTable
						&& iScanCost		== iLatentCost)
					{
						sLatentType = GetStringByStrRef(StringToInt(Get2DAString(ITEM_PROP_DEF_2DA, COL_ITEM_PROP_DEF_NAME, iLatentType)));
						NotifyPlayer(oPC, "<c=seagreen>_ Property Set :</c> De-activate : <c=cornflowerblue>"
									+ GetName(oGroup) + " ( " + sLatentType + " )");

						RemoveItemProperty(oGroup, ipScan);
						ipScan = GetFirstItemProperty(oGroup);
					}
					else
						ipScan = GetNextItemProperty(oGroup);
				}
				else
					ipScan = GetNextItemProperty(oGroup);
			}
		}
	}
}
