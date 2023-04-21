#include <sdktools>
#include <sourcemod>
#include <morecolors>
#include <cstrike>
#include <sdkhooks>


#define PLUGIN_VERSION "1.0"


public Plugin:myinfo = 
{
	name = "Fix for model glitches",
	author = "Neestrid",
	description = "Give a gift to vip users.",
	version = PLUGIN_VERSION,
	url = "https://blow-corporation.fr"
}


public OnPluginStart()
{
	RegConsoleCmd("sm_m", Command_Models);
	RegConsoleCmd("sm_m2", Command_Models2);
	HookEvent("player_spawn", OnPlayerSpawn);
}

public void OnMapStart()
{
	
	PrecacheModel("models/player/slow/gaycat_v2/gaycat_v2.mdl", true);
	PrecacheModel("models/player/slow/pink_soldier_fix/ct_urban.mdl", true);
	PrecacheModel("models/player/elis/po/police.mdl", true);
	PrecacheModel("models/player/techknow/prison/leet_p.mdl", true);
    
   }

public OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	//Au spawn, si le joueur n'est pas spectateur :
	if(GetClientTeam(client) != 1) {
		CreateTimer(0.1, TFixModel_Player, client, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:Command_Models(client, args) {
	StopSound();
	}
	
public Action:Command_Models2(client, args) {
	EmitSoundToAll(lr);
	}
	
public Action:TFixModel_Player(Handle:timer, client) {

	new String:modelname[128];
	GetEntPropString(client, Prop_Data, "m_ModelName", modelname, 128);
	new ModelEqual = strncmp(modelname, "models/", 7);
	
	//Si le joueur n'a pas de skin :
	if (ModelEqual == -1) {
		//T :
		if (GetClientTeam(client) == 2) {
			SetEntityModel(client, "models/player/techknow/prison/leet_p.mdl");
		}
		//CT :
		else if (GetClientTeam(client) == 3){
			SetEntityModel(client, "models/player/elis/po/police.mdl");
		}

	}
}
