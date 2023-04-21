#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <morecolors>


public OnPluginStart()
{
	HookEvent("weapon_fire", EventCut);
}

public Action:EventWeaponFire(Handle:event,const String:name[],bool:dontBroadcast) // Si il tire au deagel
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	decl String:weapon[16];
	GetEventString(event, "weapon", weapon, sizeof(weapon));
	if (StrEqual(weapon, "knife"))
	{
		new Float:speed = GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue");
		new Float:nowspeed = speed + 0.2;
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", nowspeed);
	}
}
