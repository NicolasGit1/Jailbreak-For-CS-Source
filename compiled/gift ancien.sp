#include <sourcemod>
#include <sdktools>
#include <smlib>
#include <cstrike>
#include <cssthrowingknives>

new gift[MAXPLAYERS+1];

public Plugin:myinfo = 
{
	name = "Gift",
	author = "Delachambre",
	description = "Plugin Gift",
	version = "1.0",
	url = "http://rp.team-magnetik.fr"
}

public OnPluginStart()
{
	RegConsoleCmd("sm_gift", Command_Gift);
	
	HookEvent("player_spawn", OnPlayerSpawn);
}

public OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (IsPlayerAlive(client))
	{
		PrintToChat(client, "Vous pouvez tapé !gift. C'est Gratuit!");
		gift[client] = 20;
	}
}

public Action:Command_Gift(client, args)
{
	if (IsPlayerAlive(client))
	{
		if (gift[client] > 0)
		{
			new bonus = GetRandomInt(1, 21);
				
			if ((bonus == 1) || (bonus == 2) || (bonus == 3))
			{
				new health = GetClientHealth(client);
				new nowhealth = health + 15;
					
				SetEntityHealth(client, nowhealth);
					
				PrintToChat(client, "Vous avez gagné 15 HP.");
				gift[client]--;
					
				return Plugin_Handled;
			}
			else if ((bonus == 4) || (bonus == 5) || (bonus == 6))
			{
				new armor = GetEntProp(client, Prop_Send, "m_ArmorValue", 4);
				new nowarmor = armor + 15;
					
				SetEntProp(client, Prop_Send, "m_ArmorValue", nowarmor, 1);
					
				PrintToChat(client, "Vous avez gagné 15 d'armure en plus.");
				gift[client]--;
				
				return Plugin_Handled;
			}
			else if (bonus == 7)
			{
				GivePlayerItem(client, "weapon_usp");
				Client_SetWeaponPlayerAmmo(client, "weapon_usp", 0);
				
				
				PrintToChat(client, "Vous avez gagné 1 USP.");
				gift[client]--;
					
				return Plugin_Handled;
			}
			else if ((bonus == 8) || (bonus == 9) || (bonus == 10))
			{
				new Float:speed = GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue");
				new Float:nowspeed = speed + 0.2;
					
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", nowspeed);
					
				PrintToChat(client, "Vous avez gagné de la vitesse.");
				gift[client]--;
					
				return Plugin_Handled;
			}
			else if ((bonus == 11) || (bonus == 12))
			{
				GivePlayerItem(client, "weapon_hegrenade");
				GivePlayerItem(client, "weapon_flashbang");
				GivePlayerItem(client, "weapon_smokegrenade");
					
				PrintToChat(client, "Vous avez gagné un pack de grenade.");
				gift[client]--;
					
				return Plugin_Handled;
			}
			else if ((bonus == 13) || (bonus == 14) || (bonus == 15))
			{
				PrintToChat(client, "Vous n'avez rien gagné.");
				gift[client]--;
					
				return Plugin_Handled;
			}
			else if ((bonus == 16))
			{
				new Float:speed = GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue");
				new Float:nowspeed = speed - 0.2;
					
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", nowspeed);
					
				PrintToChat(client, "Vous avez perdu de la vitesse.");
				gift[client]--;
					
				return Plugin_Handled;
			}
			else if ((bonus == 17))
			{
				new armor = GetEntProp(client, Prop_Send, "m_ArmorValue", 4);
				new nowarmor = armor - 15;
					
				SetEntProp(client, Prop_Send, "m_ArmorValue", nowarmor, 1);
					
				PrintToChat(client, "Vous avez perdu 15 d'armure en plus.");
				gift[client]--;
					
				return Plugin_Handled;
			}
			if ((bonus == 18))
			{
				new health = GetClientHealth(client);
				new nowhealth = health - 15;
					
				SetEntityHealth(client, nowhealth);
					
				PrintToChat(client, "Vous avez perdu 15 HP.");
				gift[client]--;
					
				return Plugin_Handled;
			}
			else if (bonus == 19)
			{
				GivePlayerItem(client, "weapon_glock");
					
				PrintToChat(client, "Vous avez gagné un Glock.");
				gift[client]--;
					
				return Plugin_Handled;
			}
			else if (bonus == 20)
			{
			CS_SetClientClanTag(client, "{Victime}");

			PrintToChat(client, "Vous êtes offiecelement une {Victime}.");
			gift[client]--;
					
			return Plugin_Handled;
			}
            else if (bonus == 21)
			{
			SetClientThrowingKnives(client, 3);

			PrintToChat(client, "Vous gagné 3 lancé de couteaux.");
			gift[client]--;
					
			return Plugin_Handled;
			}			
		}
		else
		{
			PrintToChat(client, "Vous avez déjà utilisé votre !gift.");
				
			return Plugin_Handled;
		}
	}
	else
	{
		PrintToChat(client, "Vous devez être vivant.");
		
		return Plugin_Handled;
	}
	return Plugin_Continue;
}