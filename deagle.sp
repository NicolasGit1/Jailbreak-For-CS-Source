#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <morecolors>


new WasherBoxArray;
new nbWasherBox;

public OnPluginStart()
{
	// RegConsoleCmd("sm_deagle", createDeagle);
	HookEvent("weapon_fire", EventWeaponFire);
	HookEvent("game_end", EventRoundEnd);
	HookEvent("round_end", EventRoundEnd);
	HookEvent("round_start", EventRoundStart);
}

public Action:EventRoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	WasherBoxArray = CreateArray();
	nbWasherBox = 0;
	return Plugin_Handled;
} 

public Action:EventRoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	ClearArray(WasherBoxArray);
	nbWasherBox = 0;
	return Plugin_Handled;
}

public Action:createDeagle(client, args)
{
	new wepIdx;
	for (new x = 0; x <= 3; x++)
	{
		if (x != 2 && (wepIdx = GetPlayerWeaponSlot(client, x)) != -1)
		{ 
			RemovePlayerItem(client, wepIdx);
			RemoveEdict(wepIdx);
		}
	}
	GivePlayerItem(client, "weapon_deagle");
	Client_SetWeaponPlayerAmmo(client, "weapon_deagle", 0);
	Client_SetWeaponClipAmmo(client, "weapon_deagle", 1);
	return Plugin_Handled;
}


/////////////////////// FONCTION TROUVER SUR LE NET POUR POSITION YEUX

public bool:TraceEntityFilterPlayer(entity, contentsMask, any:data)  
{ 
	return entity > MaxClients; 
}  

////////////////////////////////////////////////////////////////////////


public Action:EventWeaponFire(Handle:event,const String:name[],bool:dontBroadcast) // Si il tire au deagel
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	decl String:weapon[16];
	GetEventString(event, "weapon", weapon, sizeof(weapon));
	if (StrEqual(weapon, "deagle"))
	{
		new Float:posWasherBox[3];
		decl Float:start[3], Float:angle[3], Float:end[3], Float:normal[3]; 
		GetClientEyePosition(client, start); 
		GetClientEyeAngles(client, angle); 
		TR_TraceRayFilter(start, angle, MASK_SOLID, RayType_Infinite, TraceEntityFilterPlayer, client); 
		
		if (TR_DidHit(INVALID_HANDLE)) 
		{ 
			TR_GetEndPosition(posWasherBox, INVALID_HANDLE); 
			createWasherBox(posWasherBox[0], posWasherBox[1], posWasherBox[2], client);
		}		
	}
	return Plugin_Handled;
}

public createWasherBox(x, y, z, client)
{
	PushArrayCell(WasherBoxArray, CreateEntityByName("prop_dynamic"));
	new Float:posWasherBox[3];
	new bool:boxCanSpawn = true;
	posWasherBox[0] = x;
	posWasherBox[1] = y;
	posWasherBox[2] = z;
	if(GetArrayCell(WasherBoxArray, nbWasherBox) != -1 && IsValidEntity(GetArrayCell(WasherBoxArray, nbWasherBox)))
	{
		for (new clientt = 1; clientt <= MaxClients; clientt++)
		{
			if(IsClientInGame(clientt))
			{
				if(IsPlayerAlive(clientt))
				{
					new Float:origin[3];
					GetClientAbsOrigin(clientt, origin);
					if(origin[0] >= (posWasherBox[0]-50.0) && origin[0] <= (posWasherBox[0]+50.0) && origin[1] >= (posWasherBox[1]-40.0) && origin[1] <= (posWasherBox[1]+40.0) && origin[2] >= (posWasherBox[2]-5.0) && origin[2] <= (posWasherBox[2]+70.0))
					{
						boxCanSpawn = false;
					}
				}
			}
		}
		DispatchKeyValue(GetArrayCell(WasherBoxArray, nbWasherBox), "model", "models/props/cs_assault/dryer_box.mdl");
		DispatchKeyValue(GetArrayCell(WasherBoxArray, nbWasherBox), "solid", "6");
		DispatchSpawn(GetArrayCell(WasherBoxArray, nbWasherBox));
		TeleportEntity(GetArrayCell(WasherBoxArray, nbWasherBox), posWasherBox, NULL_VECTOR, NULL_VECTOR);
		if(boxCanSpawn == false)
		{
			CPrintToChat(client, "{CYAN}[Team-Family]{honeydew}[{skyblue}Mario {honeydew}vs {ancient}Bowser{honeydew}]Impossible de faire spawn une boîte.");
			AcceptEntityInput(GetArrayCell(WasherBoxArray, nbWasherBox), "kill");
			Client_SetWeaponPlayerAmmo(client, "weapon_deagle", 1);
		}
		else
		{
			CreateTimer(8.0, deleteWasherBox, GetArrayCell(WasherBoxArray, nbWasherBox));
		}
	}
	nbWasherBox++;
	return Plugin_Handled;
}

public Action:deleteWasherBox(Handle:timer, entity)
{
	AcceptEntityInput(entity, "kill");
}