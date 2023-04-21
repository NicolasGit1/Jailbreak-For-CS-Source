#include <sdktools>
#include <sourcemod>
#include <morecolors>
#include <smlib>
#include <cstrike>
#include <sdkhooks>

#define PLUGIN_VERSION "1.0"

new T_NbJoueur;

public Plugin:myinfo = 
{
	name = "Play sound for jb server",
	author = "Neestrid",
	description = "",
	version = PLUGIN_VERSION,
	url = ""
};

public OnPluginStart() {
	HookEvent("player_death", PlayerDeath);
}

public void OnMapStart() {
	AddFileToDownloadsTable("sound/SF-violentsex1.mp3"); 
	PrecacheSound("SF-violentsex1.mp3",true);
	AddFileToDownloadsTable("sound/adming_plugin/SF-violentsex1.mp3"); 
	PrecacheSound("adming_plugin/SF-violentsex1.mp3",true);
	AddFileToDownloadsTable("sound/adming_plugin/SF-violentsex1.wav"); 
	PrecacheSound("adming_plugin/SF-violentsex1.wav",true); 
	AddFileToDownloadsTable("sound/adming_plugin/dvsound.wav"); 
	PrecacheSound("adming_plugin/dvsound.wav",true); 
}
public OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (GetClientTeam(client) == 2) {
	T_NbJoueur++;
	}
}
//On Death :
public Action:PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (GetClientTeam(client) == 2) {
		T_NbJoueur--;
		if (T_NbJoueur == 1){
			ServerCommand("sm_play @all SF-violentsex1.mp3");
		}
	}
}
