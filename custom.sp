#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1

new resizePlayerArray[MAXPLAYERS+1];

public OnPluginStart()
{
    HookEntityOutput("trigger_multiple", "OnStartTouch", Trigger_Multiple);
	HookEvent("round_start", eventReset);
	HookEvent("round_end", eventReset);
	HookEvent("player_spawn", eventResetSpawn);
}

public Action:eventReset(Handle:event,const String:name[],bool:dontBroadcast)
{
	for (new client = 1; client <= MaxClients; client++)
	{
		resizePlayerArray[client] = false;
	}
	return Plugin_Handled;
}

public Action:eventResetSpawn(Handle:event,const String:name[],bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsClientInGame(client))
	{
		resizePlayerArray[client] = false;
	}
	return Plugin_Handled;
}

public Trigger_Multiple(const String:output[], caller, activator, Float:delay)
{
	decl String:name[64];
	GetEntPropString(caller, Prop_Data, "m_iName", name, sizeof(name));
	if(StrEqual("trigger_resize2", name))
	{
		if(IsClientInGame(activator))
		{
			if(IsPlayerAlive(activator))
			{
				decl String:namePseudo[32];
				GetClientName(activator, namePseudo, sizeof(namePseudo));
				if(resizePlayerArray[activator] != true)
				{
					PrintToChatAll(namePseudo);
					ServerCommand("sm_resize %s 0.5", namePseudo);
				}
				else
				{
					ServerCommand("sm_resize %s 1.0", namePseudo);
				}
			}
		}
	}
	return Plugin_Handled;
}  