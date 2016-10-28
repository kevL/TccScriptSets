// 'i_tcc_scanner_ac'
//
// Associated with the TCC scanner gem item.
// - script is run when the item's special ability is used
// - target an item with the ability to use it
// - echoes item property information to the chat window
//
// Created by Dashiel Nemeth, 12/12/06
// - for The Complete Craftsman
//
// kevL 2016 oct 9 - rewritten & updated.


#include "ginc_crafting"

// ___________________
// ** DECLARATIONS ***
// -------------------

// Gets property-type as a string.
string prop(int iPropType);
// Gets duration as a string.
string dur(int iDurType);
// Gets subtype as a string.
string subtype(int iPropType, int iSubType);
// Gets cost-table as a string.
string costtable(int iCostTable);
// Gets cost-value as a string.
string costvalue(int iCostValue, int iCostTable);
// Gets parameter-1 as a string.
string par1(int iPar1Table, int iPropType);
// Gets parameter-1 value as a string.
string par1value(int iPar1Value, int iPar1Table, int iPropType);

// Gets the base-material as a string.
string material(int iBaseMaterial);

// Tests the expanded pRNG.
//void TestRand();


// ___________
// ** MAIN ***
// -----------
void main()
{
	//SendMessageToPC(oPC, "Run ( i_tcc_scanner_ac ) " + GetName(OBJECT_SELF) + " ( " + GetTag(OBJECT_SELF) + " )");
//	TestRand();

	object oPC = GetItemActivator();
	object oTarget = GetItemActivatedTarget();

	if (GetObjectType(oTarget) != OBJECT_TYPE_ITEM)
	{
		SendMessageToPC(oPC, "error : Only items can be targeted !");
		return;
	}

	if (GetItemStackSize(oTarget) != 1)
		SendMessageToPC(oPC, "warning : Variables on items in stacks might not be consistent.");


	SendMessageToPC(oPC, "\nTCC Scan : <c=cornflowerblue>" + GetName(oTarget) + "</c> ( " + GetTag(oTarget) + " )");

	SendMessageToPC(oPC, ". plot : " + IntToString(GetPlotFlag(oTarget)));

	SendMessageToPC(oPC, ". Base Type : " + IntToString(GetBaseItemType(oTarget)));
	SendMessageToPC(oPC, ". TCC Type : "  + IntToString(GetTccType(oTarget)));

	int iBaseMaterial = GetItemBaseMaterialType(oTarget);
	SendMessageToPC(oPC, ". Base Material : " + IntToString(iBaseMaterial) + material(iBaseMaterial));
	int iMaterial = GetLocalInt(oTarget, TCC_VAR_MATERIAL); //GetMaterialType(oTarget) - not comprehensive, See tag.
	SendMessageToPC(oPC, ". TCC Material : " + IntToString(iMaterial));

	int bMasterwork = GetLocalInt(oTarget, TCC_VAR_MASTERWORK); //|| GetStringRight(GetTag(oTarget), 5) == TCC_MASTERWORK_SUF - not comprehensive, See tag.
	SendMessageToPC(oPC, ". TCC Masterwork : " + IntToString(bMasterwork));

	int iGroup = GetLocalInt(oTarget, TCC_VAR_SET_GROUP);
	if (iGroup)
	{
		SendMessageToPC(oPC, ". TCC Property Set");
		SendMessageToPC(oPC, ". . group : "		+ IntToString(iGroup));
		SendMessageToPC(oPC, ". . parts : "		+ IntToString(GetLocalInt(oTarget, TCC_VAR_SET_PARTS)));
		SendMessageToPC(oPC, ". . prepared : "	+ IntToString(GetLocalInt(oTarget, TCC_VAR_SET_PREP_ITEM)));
		SendMessageToPC(oPC, ". . latentip : "	+ GetLocalString(oTarget, TCC_VAR_SET_IP));
		// NOTE: Set Label does not get stored.
	}
	else
		SendMessageToPC(oPC, ". TCC Property Set : no Set");


	int iPropType, iDurType, iSubType, iCostTable, iCostValue, iPar1Table, iPar1Value;

	int i = 0;
	itemproperty ipScan = GetFirstItemProperty(oTarget);
	while (GetIsItemPropertyValid(ipScan))
	{
		SendMessageToPC(oPC, ". ip " + IntToString(++i));

		iPropType	= GetItemPropertyType(ipScan);
		iDurType	= GetItemPropertyDurationType(ipScan);
		iSubType	= GetItemPropertySubType(ipScan);
		iCostTable	= GetItemPropertyCostTable(ipScan);
		iCostValue	= GetItemPropertyCostTableValue(ipScan);
		iPar1Table	= GetItemPropertyParam1(ipScan);
		iPar1Value	= GetItemPropertyParam1Value(ipScan);

		SendMessageToPC(oPC, ". . PropType = "	+ IntToString(iPropType)	+ prop(iPropType));
		SendMessageToPC(oPC, ". . DurType = "	+ IntToString(iDurType)		+ dur(iDurType));
		SendMessageToPC(oPC, ". . SubType = "	+ IntToString(iSubType)		+ subtype(iPropType, iSubType));
		SendMessageToPC(oPC, ". . CostTable = "	+ IntToString(iCostTable)	+ costtable(iCostTable));
		SendMessageToPC(oPC, ". . CostValue = "	+ IntToString(iCostValue)	+ costvalue(iCostValue, iCostTable));
		SendMessageToPC(oPC, ". . Par1 = "		+ IntToString(iPar1Table)	+ par1(iPar1Table, iPropType));
		SendMessageToPC(oPC, ". . Par1Value = "	+ IntToString(iPar1Value)	+ par1value(iPar1Value, iPar1Table, iPropType));

		ipScan = GetNextItemProperty(oTarget);
	}
	if (!i) SendMessageToPC(oPC, ". no IP");
}


// __________________
// ** DEFINITIONS ***
// ------------------

// Gets property-type as a string.
string prop(int iPropType)
{
	string sRet = GetStringByStrRef(StringToInt(Get2DAString(ITEM_PROP_DEF_2DA, COL_ITEM_PROP_DEF_NAME, iPropType)));
	return " <c=cornflowerblue>( " + sRet + " )</c>";
}

// Gets duration as a string.
string dur(int iDurType)
{
	string sRet = " <c=cornflowerblue>( ";
	switch (iDurType)
	{
		case DURATION_TYPE_TEMPORARY: sRet += "TEMPORARY"; break; // 1
		case DURATION_TYPE_PERMANENT: sRet += "PERMANENT"; break; // 2

		default: sRet += "error";
	}
	return sRet + " )</c>";
}

// Gets subtype as a string.
string subtype(int iPropType, int iSubType)
{
	string sRet = Get2DAString(ITEM_PROP_DEF_2DA, COL_ITEM_PROP_DEF_SUBTYPE, iPropType);
	if (sRet != "")
	{
		string sRet1 = GetStringByStrRef(StringToInt(Get2DAString(sRet, "Name", iSubType)));
		return " <c=cornflowerblue>( " + sRet + " / " + sRet1 + " )</c>";
	}
	return " <c=cornflowerblue>( none )</c>";
}

// Gets cost-table as a string.
string costtable(int iCostTable)
{
	string sRet = Get2DAString("iprp_costtable", "Name", iCostTable);
	if (sRet == "") sRet = "none";
	return " <c=cornflowerblue>( " + sRet + " )</c>";
}

// Gets cost-value as a string.
string costvalue(int iCostValue, int iCostTable)
{
	string sRet = Get2DAString("iprp_costtable", "Name", iCostTable);
	if (sRet != "")
		sRet = GetStringByStrRef(StringToInt(Get2DAString(sRet, "Name", iCostValue)));
	else
		sRet = "none";
	return " <c=cornflowerblue>( " + sRet + " )</c>";
}

// Gets parameter-1 as a string.
string par1(int iPar1Table, int iPropType)
{
	if (Get2DAString(ITEM_PROP_DEF_2DA, "Param1ResRef", iPropType) != "")
	{
		string sRet = GetStringByStrRef(StringToInt(Get2DAString("iprp_paramtable", "Name", iPar1Table)));
		return " ( " + sRet + " )</c>";
	}
	return " <c=cornflowerblue>( none )</c>";
}

// Gets parameter-1 value as a string.
string par1value(int iPar1Value, int iPar1Table, int iPropType)
{
	if (Get2DAString(ITEM_PROP_DEF_2DA, "Param1ResRef", iPropType) != "")
	{
		string sRet = Get2DAString("iprp_paramtable", "TableResRef", iPar1Table);
		sRet = GetStringByStrRef(StringToInt(Get2DAString(sRet, "Name", iPar1Value)));
		return " <c=cornflowerblue>( " + sRet + " )</c>";
	}
	return " <c=cornflowerblue>( none )</c>";
}

// Gets the base-material as a string.
string material(int iBaseMaterial)
{
	string sRet = GetStringByStrRef(StringToInt(Get2DAString("iprp_materials", "NAME", iBaseMaterial)));
	return " <c=cornflowerblue>( " + sRet + " )</c>";
}

/*
// -----------------------------------------------------------------------------
// functions for Rand# tests

// Gets an integer as a string of separated digits.
string digits(int i)
{
	string sRet = IntToString(i);
	sRet = InsertString(sRet, " ", GetStringLength(sRet) - 3);
	sRet = InsertString(sRet, " ", GetStringLength(sRet) - 7);
	return InsertString(sRet, " ", GetStringLength(sRet) - 11);
}

// Gets an unsigned 16-bit rand# between 0..65535 (inclusive).
int GetRand16()
{
	int iRand = Random(32768);		// low register      0..32767
	if (Random(2)) iRand += 32768;	// high register 32768..65535

	SendMessageToPC(GetFirstPC(FALSE), "<c=sandybrown>GetRand16 : " + digits(iRand) + "</c>");
	return iRand;
}

// Gets the positive half of a signed 32-bit rand# between 0...2147483647 (inclusive).
// - note that (type)int in NwScript has a range of -2147483648 to +2147483647
int GetRand32()
{
	int iRand0 = GetRand16(); // 0..65535 = 0xffff = 1111 1111 1111 1111

	iRand0 <<= 16;

	int iRand1 = GetRand16();

	int iRand = iRand0 | iRand1; // -> 1111 1111 1111 1111 1111 1111 1111 1111 = 0xffff ffff = 4294967295

	if (iRand == -2147483648) iRand = 0; // equal the odds of a positive or negative result.

//	iRand &= 0x7FFFFFFF; // max 2147483647 = 7FFFFFFF = 0111 1111 1111 1111 1111 1111 1111 1111
	iRand = abs(iRand); // disallow negative range.

	SendMessageToPC(GetFirstPC(FALSE), "<c=cornflowerblue>GetRand32 : " + digits(iRand) + "</c>");
	return iRand; // 0..2147483647
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
	SendMessageToPC(GetFirstPC(FALSE), "<c=cornflowerblue>GetRand32a : " + digits(iRand) + "</c>");
	return iRand;
}

// Tests the expanded pRNG.
void TestRand()
{
	int iRand;
	int iHigh = -1;
	int iLow = 2147483647;

	int i;
	for (i = 0; i != 100; ++i)
	{
		iRand = GetRand32a();

		if (iRand < iLow) iLow = iRand;
		if (iRand > iHigh) iHigh = iRand;
	}
	SendMessageToPC(GetFirstPC(FALSE), ". low = " + digits(iLow));
	SendMessageToPC(GetFirstPC(FALSE), ". high = " + digits(iHigh));
	SendMessageToPC(GetFirstPC(FALSE), ". . below Max= " + digits(2147483647 - iHigh));
}
*/