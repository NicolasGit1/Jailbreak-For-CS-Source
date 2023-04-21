#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <cstrike>
#include <cssthrowingknives>
#include <morecolors>

new gift[MAXPLAYERS+1];
new String:user[65];

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
		PrintToChat(client, "\x01\x03 Vous pouvez tapé !gift. C'est Gratuit!");
		gift[client] = 1;
	}
}

public Action:Command_Gift(client, args)
{
	if (IsPlayerAlive(client))
	{
		if (gift[client] > 0)
		{
			new bonus = GetRandomInt(1, 26);
				
			if ((bonus == 1) || (bonus == 2) || (bonus == 3))
			{
				new health = GetClientHealth(client);
				new nowhealth = health + 15;
					
				SetEntityHealth(client, nowhealth);
					
				PrintToChat(client, "\x01\x04 Vous avez gagné 15 HP.");
				gift[client]--;
					
				return Plugin_Handled;
			}
			else if ((bonus == 4) || (bonus == 5) || (bonus == 6))
			{
				new armor = GetEntProp(client, Prop_Send, "m_ArmorValue", 4);
				new nowarmor = armor + 15;
					
				SetEntProp(client, Prop_Send, "m_ArmorValue", nowarmor, 1);
					
				PrintToChat(client, "\x01\x04 Vous avez gagné 15 d'armure en plus.");
				gift[client]--;
				
				return Plugin_Handled;
			}
			else if (bonus == 7)
			{
				GivePlayerItem(client, "weapon_usp");
				Client_SetWeaponPlayerAmmo(client, "weapon_usp", 0);
				
				
				PrintToChat(client, "\x01\x04 Vous avez gagné 1 USP.");
				gift[client]--;
					
				return Plugin_Handled;
			}
			else if ((bonus == 8) || (bonus == 9) || (bonus == 10))
			{
				new Float:speed = GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue");
				new Float:nowspeed = speed + 0.2;
					
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", nowspeed);
					
				PrintToChat(client, "\x01\x04 Vous avez gagné de la vitesse.");
				gift[client]--;
					
				return Plugin_Handled;
			}
			else if ((bonus == 11) || (bonus == 12))
			{
				GivePlayerItem(client, "weapon_hegrenade");
				GivePlayerItem(client, "weapon_flashbang");
				GivePlayerItem(client, "weapon_smokegrenade");
					
				PrintToChat(client, "\x01\x04 Vous avez gagné un pack de grenade.");
				gift[client]--;
					
				return Plugin_Handled;
			}
			else if ((bonus == 13) || (bonus == 14) || (bonus == 15))
			{
				PrintToChat(client, "\x01\x04 Vous n'avez rien gagné.");
				gift[client]--;
					
				return Plugin_Handled;
			}
			else if ((bonus == 16))
			{
				new Float:speed = GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue");
				new Float:nowspeed = speed - 0.2;
					
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", nowspeed);
					
				PrintToChat(client, "\x01\x04 Vous avez perdu de la vitesse.");
				gift[client]--;
					
				return Plugin_Handled;
			}
			else if ((bonus == 17))
			{
				new armor = GetEntProp(client, Prop_Send, "m_ArmorValue", 4);
				new nowarmor = armor - 15;
					
				SetEntProp(client, Prop_Send, "m_ArmorValue", nowarmor, 1);
					
				PrintToChat(client, "\x01\x04 Vous avez perdu 15 d'armure en plus.");
				gift[client]--;
					
				return Plugin_Handled;
			}
			if ((bonus == 18))
			{
				new health = GetClientHealth(client);
				new nowhealth = health - 15;
					
				SetEntityHealth(client, nowhealth);
					
				PrintToChat(client, "\x01\x04 Vous avez perdu 15 HP.");
				gift[client]--;
					
				return Plugin_Handled;
			}
			else if (bonus == 19)
			{
				new health = GetClientHealth(client);
				new nowhealth = 1;
					
				SetEntityHealth(client, nowhealth);
					
				PrintToChat(client, "\x01\x04 Vous avez 1 HP. Bonne Chance :)");
				gift[client]--;
					
				return Plugin_Handled;
			}
			else if (bonus == 20)
			{
			    CS_SetClientClanTag(client, "{Victime}");
                 
			    PrintToChat(client, "\x01\x04 Vous êtes offiecelement une {Victime}.");
			    gift[client]--;
					
			    return Plugin_Handled;
			}
            else if (bonus == 21)
			{
				SetClientThrowingKnives(client, GetClientThrowingKnives(client) +3);
			    PrintToChat(client, "\x01\x04 Vous gagné 3 lancés de couteaux.");
			    gift[client]--;
					
			    return Plugin_Handled;
			}
			else if (bonus == 22)
            {
				GetClientName(client,user, sizeof(user));
                ServerCommand("sm_drug %s 1", user);
                PrintToChat(client, "\x01\x04 Vous êtes drogué pour 20 secondes !");
				CreateTimer(20.0, Stop_Drug, GetClientUserId(client));
                    
                return Plugin_Handled;
            }
            else if (bonus == 23)
            {
				GetClientName(client,user, sizeof(user));
                ServerCommand("sm_blind %s 220", user);
                PrintToChat(client, "\x01\x04 Vous êtes semi-aveuglé pour 20 secondes !");
                CreateTimer(20.0, Stop_Aveugle, GetClientUserId(client));
					
                return Plugin_Handled;
            }
            else if (bonus == 24)
            {
				GetClientName(client,user, sizeof(user));
                ServerCommand("sm_beacon %s 1", user);
                PrintToChat(client, "\x01\x04 Vous êtes balisé pendant 30 secondes !");
                CreateTimer(30.0, Stop_Beacon, GetClientUserId(client));
					
                return Plugin_Handled;
            }
            else if (bonus == 25)
            {
			    GetClientName(client,user, sizeof(user));
            	ServerCommand("sm_resize %s 0.5", user);
				PrintToChat(client, "\x01\x04 Vous êtes petit !");
				
                return Plugin_Handled;
            }			
            else if (bonus == 26)
            {
			    GetClientName(client,user, sizeof(user));
            	ServerCommand("sm_resize %s 1.2", user);
				PrintToChat(client, "\x01\x04 Vous gagnez 2 cm de taille !");
				
                return Plugin_Handled;
            }
		}
		else
		{
			PrintToChat(client, "\x01\x03 Vous avez déjà utilisé votre !gift.");
				
			return Plugin_Handled;
		}
	}
	else
	{
		PrintToChat(client, "\x01\x03 Vous devez être vivant.");
		
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
public Action:Stop_Drug(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	new String:user[65];
	GetClientName(client,user, sizeof(user));
					
	ServerCommand("sm_drug %s 0", user); 
		
	CPrintToChat(client, "{lightgreen}L'effet de la drogue est Partit !");
}
public Action:Stop_Aveugle(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	new String:user[65];
	GetClientName(client,user, sizeof(user));
					
	ServerCommand("sm_blind %s 0", user); 
		
	CPrintToChat(client, "{lightgreen}L'effet aveuglement s'est disipé !");
}
public Action:Stop_Beacon(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	new String:user[65];
	GetClientName(client,user, sizeof(user));
					
	ServerCommand("sm_beacon %s 0", user); 
		
}