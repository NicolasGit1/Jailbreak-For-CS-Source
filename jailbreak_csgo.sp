#include <morecolors>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <smlib>
#include <hosties>
#include <lastrequest>

#define terrorist 			2
#define counterTerrorist 	3
#define PREFIX "Blow-Corp"

#pragma newdecls required
#pragma semicolon 1

//int String:g_sLogsPath[PLATFORM_MAX_PATH];
int PlayerKillScore[MAXPLAYERS+1];
int ouivip[MAXPLAYERS+1];
bool vipfirstround[MAXPLAYERS+1];
int ChefDesCT[MAXPLAYERS+1];
int CT[MAXPLAYERS+1];
int NombreChef;
int NombreCT;
int VipDesCT[MAXPLAYERS+1];
int VipChef;
int AdminDesCT[MAXPLAYERS+1];
int AdminChef;
int ChefCT;
int roundfirst;
int DecompteJail[MAXPLAYERS+1];
int flag_spawnFirst[MAXPLAYERS+1];
// int Handle:g_hTimerSpawn;
Handle g_hTimerMenuJail[MAXPLAYERS+1];

//int offsetOne;
//int offsetTwo;
//int offsetThree;
//int offsetFour;

int g_offsCollisionGroup;
bool g_bTPOn[MAXPLAYERS+1];

public Plugin myinfo =
{
	name = "JailBreak For BCorp",
	description = "JailBreak Mod",
	author = "Neestrid, Dertione & Bixrow",
	version = "1.1",
	url = "https://blow-corporation.fr"
};

public void OnPluginStart()
{
	g_offsCollisionGroup = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
	//CreateLogPath();
	HookEvent("player_spawn", Event_PlayerSpawn, view_as<EventHookMode>(1));
	HookEvent("player_death", Event_PlayerDeath, view_as<EventHookMode>(0));
	HookEvent("round_start", Event_RoundStart, view_as<EventHookMode>(1));
	HookEvent("player_hurt", Event_PlayerHurt);
	RegAdminCmd("sm_ft", CMD_FT, ADMFLAG_SLAY, "sm_ft <#userid|name> [team]");
	RegAdminCmd("sm_color", CMD_color, ADMFLAG_SLAY, "sm_color <#userid|name> [color]");
	RegAdminCmd("sm_colorstop", CMD_colorstop, ADMFLAG_SLAY, "sm_colorstop");
	RegAdminCmd("sm_knive", CMD_knive, ADMFLAG_SLAY, "sm_knive <#userid|name>");
	//RegConsoleCmd("tp", Command_ThirdPerson, "Commande pour la vue a la troisième personne");
	// RegConsoleCmd("sm_regles", CMD_REGLES, "Commande pour afficher les règles");
	
	//-----------------------------------------
	// Create our ConVars
	//-----------------------------------------
	
	CreateConVar( "sm_jt", "1", "Enables the jail team ratio plugin.");
	CreateConVar( "sm_jt_ratio", "2", "The ratio of terrorists to counter-terrorists. (Default: 1CT = 3T)");
	CreateConVar( "sm_jt_version", "1.0.3", "There is no need to change this value.", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY );

	//-----------------------------------------
	// Generate config file
	//-----------------------------------------
	
	AutoExecConfig( true, "sm_jailteams" );
	
	//-----------------------------------------
	// Hook into join team command
	//-----------------------------------------
	
	AddCommandListener(Command_JoinTeam, "jointeam");
	
	//-----------------------------------------
	// No block
	//-----------------------------------------
	
	g_offsCollisionGroup = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
}

public void OnMapStart() 
{ 
	for (int i = 1; i <= 64; i++)
	{
		vipfirstround[i]=true;
	}
	//LoadLogPath();
	roundfirst = 5;

}


public void OnClientPutInServer(int client)
{
	if(IsAdmin(client))
	{
		SetClientListeningFlags(client, VOICE_NORMAL);
	}
	else
	{
		SetClientListeningFlags(client, VOICE_MUTED);
	}
	
	flag_spawnFirst[client] = 1;
	g_bTPOn[client] = false;
	g_hTimerMenuJail[client] = CreateTimer(1.0, TimerSec , client, TIMER_REPEAT);
}

public void OnClientDisconnect(int client)
{
	if (g_hTimerMenuJail[client] != INVALID_HANDLE)
	{
		KillTimer(g_hTimerMenuJail[client]);
		g_hTimerMenuJail[client] = INVALID_HANDLE;
	}
}




public Action Event_PlayerHurt(Handle event, const char []name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event,"userid")),
	attacker = GetClientOfUserId(GetEventInt(event,"attacker"));
	int damage = GetEventInt(event,"dmg_health");
	char VictimeName[64];
	GetClientName(client, VictimeName, 64);
	char VictimeAuth[64];
	GetClientAuthId(client, AuthId_Steam2, VictimeAuth, sizeof(VictimeAuth));
	char AttackerName[64];
	GetClientName(attacker, AttackerName, 64);
	char AttackerAuth[64];
	GetClientAuthId(client, AuthId_Steam2, AttackerAuth, sizeof(AttackerAuth));
	if(attacker)
	{
		int team = GetClientTeam(attacker);
		char weapon[10];
		GetEventString(event,"weapon", weapon, sizeof(weapon));
		int i = 1;

		while (GetMaxClients() >= i)
		{
			if (IsClientInGame(i))
			{
				if (IsAdmin(i)||IsRoot(i))
				{
					PrintToConsole(i, "                 [JailBreak Mod] Damage - Anti freeshot");
					PrintToConsole(i, "                 %s(%s) (team=%i) a toucher %s(%s) ! with %s  with %i HP", AttackerName, AttackerAuth, team, VictimeName, VictimeAuth,weapon, damage);
					i++;
				}
				else
				{
					i++;
				}
			}
			else
			{
				i++;
			}
		}
	}

	
	
}

public Action Command_JoinTeam(int client, const char []command, int argc) 
{
	//-----------------------------------------
	// Get the CVar T:CT ratio
	//-----------------------------------------

	int teamRatio = 2 ;
	
	//-----------------------------------------
	// Is it a human?
	//-----------------------------------------
	
	if ( ! client || ! IsClientInGame( client ) || IsFakeClient( client ) )
	{
		return Plugin_Continue;
	}
	
	//-----------------------------------------
	// Get int and old teams
	//-----------------------------------------
	
	char teamString[3];
	GetCmdArg( 1, teamString, sizeof( teamString ) );
	
	int newTeam = StringToInt(teamString);
	int oldTeam = GetClientTeam(client);
	
	//-----------------------------------------
	// Bypass for SM admins
	//-----------------------------------------
	
	if ( IsAdmin(client))
	{
		PrintToChat( client, "\x03[BCorp] \x04Admin, Bypass", teamRatio );
		PrintCenterText(client, "Admin, Bypass");
		return Plugin_Continue;
	}
	
	if(newTeam == 0)
	{
		PrintToChat( client, "\x03[BCorp] \x04Choix automatique désactivé !", teamRatio );
		PrintCenterText(client, "Choix automatique désactivé !");
		return Plugin_Handled;
	}
	
	
	//-----------------------------------------
	// Are we trying to switch to CT?
	//-----------------------------------------
	
	if ( newTeam == counterTerrorist && oldTeam != counterTerrorist )
	{
		int countTs 	= 0;
		int countCTs 	= 0;
		
		//-----------------------------------------
		// Count up our players!
		//-----------------------------------------
		
		countTs=GetTotalPlayer(CS_TEAM_T, false);
		countCTs=GetTotalPlayer(CS_TEAM_CT, false);
		
		//-----------------------------------------
		// Are we trying to unbalance the ratio?
		//-----------------------------------------

		if ( countCTs < ( ( countTs ) / teamRatio ) || ! countCTs || IsRoot(client) || IsAdmin(client))
		{
			return Plugin_Continue;
		}
		else
		{
			//-----------------------------------------
			// Send client sound
			//-----------------------------------------
			
			ClientCommand( client, "play ui/freeze_cam.wav" );
			
			//-----------------------------------------
			// Show client message
			//-----------------------------------------
			
			PrintCenterText(client, "L'equipe est pleine !");

			//-----------------------------------------
			// Kill the team change request
			//-----------------------------------------

			return Plugin_Handled;
		}		
	}
	
	return Plugin_Continue;
}

public Action Event_PlayerSpawn(Handle event, const char []name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsFakeClient(client) && IsClientConnected(client))
	{
		if(GetClientTeam(client) == 2)
		{
			PlayerKillScore[client] = 0;
		}
		else
		{
			PlayerKillScore[client] = 3;
		}
	}
	
	SetClientListeningFlags(client, VOICE_MUTED);
	if (GetPlayerWeaponSlot(client, 0) != -1) RemovePlayerItem(client, GetPlayerWeaponSlot(client, 0));
	if (GetPlayerWeaponSlot(client, 1) != -1) RemovePlayerItem(client, GetPlayerWeaponSlot(client, 1));
	SetEntData(client, g_offsCollisionGroup, 2, 4, true);
	if (IsAdmin(client))
	{
		if(GetClientTeam(client) == 3)
		{
			if (GetPlayerWeaponSlot(client, 1) != -1) RemovePlayerItem(client, GetPlayerWeaponSlot(client, 1));
			GivePlayerItem(client, "weapon_deagle", 0);
		}
		SetClientListeningFlags(client, VOICE_NORMAL);
	}
	if (GetClientTeam(client) == 2 && !IsAdmin(client) && !IsRoot(client) )
	{
		SetClientListeningFlags(client, VOICE_MUTED);
	}
	if (GetClientTeam(client) == 3 || IsAdmin(client) || IsRoot(client))
	{
		SetClientListeningFlags(client, VOICE_NORMAL);
		if(GetClientTeam(client) == 3)
		{
			SetEntProp(client, view_as<PropType>(0), "m_ArmorValue", view_as<any>(100), 1);
			SetEntProp(client, view_as<PropType>(0), "m_bHasHelmet", view_as<any>(1), 1);
			GivePlayerItem(client, "weapon_m4a1", 0);
		}
	}
	if(flag_spawnFirst[client] == 1 && ((IsVIP(client) || IsAdmin(client))))
	{
		ouivip[client] = 1;
		flag_spawnFirst[client] = 0;
	}
}

///////////////////////////////////////////////////////////////////////////////////
/////////////////// Menu du Chef des CT en debut de round /////////////////////////
///////////////////////////////////////////////////////////////////////////////////

public Action Event_RoundStart(Handle event, const char []name, bool dontBroadcast)
{
	NombreChef = 0;
	VipChef = 0;
	AdminChef = 0;
	roundfirst--;
	char ChefCTName[64];
	ChefCTName="...";
	CreateTimer(5.0, timer_menu);
	for (int i = 1; i <= GetMaxClients(); i++)
	{
		if(IsClientConnected(i))
		{
			DecompteJail[i] = 55;
		}
	} 
}

public Action timer_menu(Handle timer) 
{
	MenuChefCT();
}

public int MenuHandler1(Handle menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		NombreCT = NombreCT + 1;
		if(NombreCT<=MAXPLAYERS)
		{
			CT[NombreCT] = client ;
		}
		if(param2==0)
		{
			NombreChef += 1;
			ChefDesCT[NombreChef] = client;
			// CPrintToChat(client, "Merci, tirage au sort en cours !");
		}
		else if(param2==1)
		{
			
		}
		else if(param2==2)
		{
			VipChef += 1;
			VipDesCT[VipChef] = client;
		}
		else if(param2==3)
		{
			LogAction(client, -1, "\"%L\" a sélectionné le oui admin.", client);
			AdminChef += 1;
			AdminDesCT[AdminChef] = client;
		}
	}
	/* If the menu has ended, destroy it */
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

stock void MenuChefCT()
{
	for (int i = 1; i <= GetMaxClients(); i++)
	{
		if (IsClientInGame(i))
		{
			if (GetClientTeam(i) == 3)
			{
				Handle menu = CreateMenu(MenuHandler1);
				SetMenuTitle(menu, "Veux-tu être chef des gardiens ?");
				AddMenuItem(menu, "oui", "Oui");
				AddMenuItem(menu, "non", "Non");
				if(ouivip[i]>0)
				{
					AddMenuItem(menu, "ouivip", "Oui (vip)");
				}
				if(IsAdmin(i)||IsRoot(i))
				{
					AddMenuItem(menu, "ouiadmin", "Oui (admin)");
				}
				SetMenuExitButton(menu, false);
				if(IsClientConnected(i))
				{
					DisplayMenu(menu, i, 6);
				}
			}
			//WelcomeTimers = CreateTimer(2.5, ChefCTMenuTableau, i, TIMER_REPEAT);
		}
		
	}
	CreateTimer(15.0,ChefCTMenuFin);
}

public Action TimerSec(Handle timer, any client)
{
	int totalCT;
	int totalT;
	int totalCTAlive;
	int totalTAlive;
	Handle hBuffer = StartMessageOne("KeyHintText", client);
	if (0 < DecompteJail[client])
	{
		DecompteJail[client] -= 1;
	}
	totalTAlive = GetTotalPlayer(CS_TEAM_T, true);
	totalCTAlive = GetTotalPlayer(CS_TEAM_CT, true);
	totalT = GetTotalPlayer(CS_TEAM_T, false);
	totalCT = GetTotalPlayer(CS_TEAM_CT, false);
	if (totalTAlive <= 5 && totalTAlive >= 4)
	{
		int r = 1;
		while (GetMaxClients() >= r)
		{
			if (IsClientInGame(r)&&IsPlayerAlive(r))
			{
				SetClientListeningFlags(r, 0);
				r++;
			}
			r++;
		}
	}
	if (IsClientConnected(client))
	{
		char Text[256];
		Format(Text, sizeof(Text), "");
		if (DecompteJail[client])
		{
			//Format(Text, sizeof(Text), "%s\n", Text);
		}
		if (ChefCT)
		{
			char ChefCTName[64];
			if(IsClientInGame(ChefCT))
			{
				GetClientName(ChefCT, ChefCTName, 64);
				Format(Text, sizeof(Text), "blow-corporation.fr\n\n%Chef Gardiens : %s\n", ChefCTName);
			}
			else
			{
				Format(Text, sizeof(Text), "blow-corporation.fr\n\nChef Gardiens : ...\n");
			}
		}
		else
		{
			Format(Text, sizeof(Text), "blow-corporation.fr\n\nChef Gardiens : ...\n");
		}
		Format(Text, sizeof(Text), "%sGardiens : %i / %i\n", Text, totalCTAlive, totalCT);
		Format(Text, sizeof(Text), "%sPrisonniers : %i / %i\n", Text, totalTAlive, totalT);
		int Talk = GetClientListeningFlags(client);
		if (Talk == VOICE_MUTED)
		{
			Format(Text, sizeof(Text), "%sMicrophone [MUTE]\n", Text);
		}
		else
		{
			Format(Text, sizeof(Text), "%sMicrophone [ACTIF]\n", Text);
		}
		if (DecompteJail[client])
		{
			Format(Text, sizeof(Text), "%sOuverture auto dans %i sec\n", Text, DecompteJail[client]);
		}
		if (hBuffer == INVALID_HANDLE)
		{
			PrintToChat(client, "INVALID_HANDLE");
		}
		else
		{	
			BfWriteByte(hBuffer, 1); 
			BfWriteString(hBuffer, Text); 
			EndMessage();
		}
		//Format(Text, 254, "%s\n", Text);
		//PrintHintText(client, "%s", Text);
	}
	else
	{
		if (g_hTimerMenuJail[client] != INVALID_HANDLE)
		{
			KillTimer(g_hTimerMenuJail[client]);
			g_hTimerMenuJail[client] = INVALID_HANDLE;
		}
	}
}

public Action ChefCTMenuFin(Handle timer)
{
	if(AdminChef>0)
	{
		ChefCT=AdminDesCT[1];
	}
	else if(VipChef>0)
	{
		ChefCT = VipDesCT[GetRandomInt(1, VipChef)];
		ouivip[ChefCT]=0;
	}
	else
	{
		int i = 1;
		while (GetMaxClients() >= i)
		{
			if (IsClientInGame(i))
			{
				if (GetClientTeam(i) == 3 && IsPlayerAlive(i))
				{
					NombreChef += 1;
					ChefDesCT[NombreChef] = i;
					i++;
				}
				i++;
			}
			i++;
		}
		ChefCT = ChefDesCT[GetRandomInt(1, NombreChef)];
	}
	char ChefCTName[64];
	GetClientName(ChefCT, ChefCTName, 64);
	CPrintToChatAll("{cornflowerblue}[JB] {lightgreen}%s {cornflowerblue}est le chef des gardiens !", ChefCTName);
	PrintCenterTextAll("%s est le chef des gardiens !", ChefCTName);
	// PrintHintTextToAll("%s est le chef des gardiens !", ChefCTName);
	VipChef = 0;
	AdminChef = 0;
	NombreChef = 0;
}

///////////////////////////////////////////////////////////////////////////////////
///////////////  fin du Menu du Chef des CT en debut de round /////////////////////
///////////////////////////////////////////////////////////////////////////////////



public Action AlertDernierCT(Handle timer)
{
	int totalCTAlive = 0;
	int i = 1;
	while (GetMaxClients() >= i)
	{
		if (IsClientInGame(i))
		{
			if (GetClientTeam(i) == 3)
			{
				totalCTAlive++;
				i++;
			}
			i++;
		}
		i++;
	}
	if (totalCTAlive == 1)
	{
		CPrintToChatAll("{ancient}[JB] {fullred}Dernier gardien en vie ! ");
		PrintCenterTextAll("Dernier gardien en vie !");
		// PrintHintTextToAll("Dernier gardien en vie !");
		
	}
	return Plugin_Continue;
}


public Action Event_PlayerDeath(Handle event, const char []name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if (IsRoot(client)||IsAdmin(client))
	{
		SetClientListeningFlags(client, VOICE_NORMAL);
	}
	else
	{
		SetClientListeningFlags(client, VOICE_MUTED);
	}
	char AttackerWeapon[64];
	GetEventString(event, "weapon", AttackerWeapon, 64);
	if (StrEqual(AttackerWeapon, "knife", true))
	{
		PlayerKillScore[attacker] = PlayerKillScore[attacker] + 1;
	}
	if (StrEqual(AttackerWeapon, "glock18", true))
	{
		PlayerKillScore[attacker] = PlayerKillScore[attacker] + 2;
	}
	if (StrEqual(AttackerWeapon, "usp", true))
	{
		PlayerKillScore[attacker] = PlayerKillScore[attacker] + 2;
	}
	if (StrEqual(AttackerWeapon, "p228", true))
	{
		PlayerKillScore[attacker] = PlayerKillScore[attacker] + 2;
	}
	if (StrEqual(AttackerWeapon, "deagle", true))
	{
		PlayerKillScore[attacker] = PlayerKillScore[attacker] + 2;
	}
	if (StrEqual(AttackerWeapon, "fiveseven", true))
	{
		PlayerKillScore[attacker] = PlayerKillScore[attacker] + 2;
	}
	if (StrEqual(AttackerWeapon, "elite", true))
	{
		PlayerKillScore[attacker] = PlayerKillScore[attacker] + 2;
	}
	if (StrEqual(AttackerWeapon, "hegrenade", true))
	{
		PlayerKillScore[attacker] = PlayerKillScore[attacker] + 2;
	}
	if (StrEqual(AttackerWeapon, "ak47", true))
	{
		PlayerKillScore[attacker] = PlayerKillScore[attacker] + 3;
	}
	if (StrEqual(AttackerWeapon, "m4a1", true))
	{
		PlayerKillScore[attacker] = PlayerKillScore[attacker] + 3;
	}
	if (StrEqual(AttackerWeapon, "mp5navy", true))
	{
		PlayerKillScore[attacker] = PlayerKillScore[attacker] + 3;
	}
	if (StrEqual(AttackerWeapon, "awp", true))
	{
		PlayerKillScore[attacker] = PlayerKillScore[attacker] + 3;
	}
	if (StrEqual(AttackerWeapon, "sg522", true))
	{
		PlayerKillScore[attacker] = PlayerKillScore[attacker]+ 3;
	}
	if (StrEqual(AttackerWeapon, "aug", true))
	{
		PlayerKillScore[attacker] = PlayerKillScore[attacker]+ 3;
	}
	if (StrEqual(AttackerWeapon, "scout", true))
	{
		PlayerKillScore[attacker] = PlayerKillScore[attacker] + 3;
	}
	if (StrEqual(AttackerWeapon, "sg550", true))
	{
		PlayerKillScore[attacker] = PlayerKillScore[attacker] + 3;
	}
	if (StrEqual(AttackerWeapon, "g3sg1", true))
	{
		PlayerKillScore[attacker] = PlayerKillScore[attacker] + 3;
	}
	if (StrEqual(AttackerWeapon, "mac10", true))
	{
		PlayerKillScore[attacker] = PlayerKillScore[attacker] + 3;
	}
	if (StrEqual(AttackerWeapon, "tmp", true))
	{
		PlayerKillScore[attacker] = PlayerKillScore[attacker]+ 3;
	}
	if (StrEqual(AttackerWeapon, "ump45", true))
	{
		PlayerKillScore[attacker] = PlayerKillScore[attacker] + 3;
	}
	if (StrEqual(AttackerWeapon, "p90", true))
	{
		PlayerKillScore[attacker] = PlayerKillScore[attacker] + 3;
	}
	if (StrEqual(AttackerWeapon, "m3", true))
	{
		PlayerKillScore[attacker] = PlayerKillScore[attacker]+ 3;
	}
	if (StrEqual(AttackerWeapon, "xm1014", true))
	{
		PlayerKillScore[attacker] = PlayerKillScore[attacker] + 3;
	}
	if (StrEqual(AttackerWeapon, "m249", true))
	{
		PlayerKillScore[attacker] = PlayerKillScore[attacker] + 3;
	}
	char VictimeName[64];
	GetClientName(client, VictimeName, 64);
	char VictimeAuth[64];
	GetClientAuthId(client, AuthId_Steam2, VictimeAuth, sizeof(VictimeAuth));
	char AttackerName[64];
	GetClientName(attacker, AttackerName, 64);
	char AttackerAuth[64];
	GetClientAuthId(client, AuthId_Steam2, AttackerAuth, sizeof(AttackerAuth));
	int i = 1;
	while (GetMaxClients() >= i)
	{
		if (IsClientConnected(i))
		{
			if (GetUserFlagBits(i) & 16384)
			{
				PrintToConsole(i, " ");
				PrintToConsole(i, "   [BC-JailBreak] Kill");
				PrintToConsole(i, "       %s(%s) a tué %s(%s) !", AttackerName, AttackerAuth, VictimeName, VictimeAuth);
				PrintToConsole(i, " ");
				i++;
			}
			i++;
		}
		i++;
	}
	if (GetClientTeam(client) == 3 && IsClientConnected(attacker))
	{
		CPrintToChatAll("{green} -=> Un gardien vient d'être tué ! <=-");
		if(GetClientTeam(attacker)==2 && PlayerKillScore[attacker]<3)
		{
			SetEventInt(event, "attacker", 0);
			SetEventString(event, "weapon", "");
			SetEventBool(event, "headshot", false);
			SetEventInt(event, "dominated", 0);
			SetEventInt(event, "revenge", 0);
			return Plugin_Changed;
		}
		
		int totalCTAlive;
		i = 1;
		while (GetMaxClients() >= i)
		{
			if (IsClientInGame(i))
			{
				if (GetClientTeam(i) == 3)
				{
					totalCTAlive++;
					i++;
				}
			}
			i++;
		}
		if (client == ChefCT)
		{
			ChefCT = 0;
			NombreChef = 0;
			CreateTimer(1.0, ChefCTMenuFin, view_as<any>(0), 0);
		}
		if (totalCTAlive == 1)
		{
			CreateTimer(1.0, AlertDernierCT, view_as<any>(0), 0);
		}
	}
	if (GetClientTeam(client) == 2)
	{
		int totalTAlive;
		i = 1;
		while (GetMaxClients() >= i)
		{
			if (IsClientInGame(i))
			{
				if (GetClientTeam(i) == 2)
				{
					totalTAlive++;
					i++;
				}
			}
			i++;
		}
		/*if (totalTAlive == 5) // Si le total de personnes = 5 alors les terroristes sont demutes
		{
			//CPrintToChatAll("{lightgray}[JAILBEAK-BC] Les prisonniers ont été démutés !");
		}*/
	}
	
	return Plugin_Continue;
}

/*public Action:CMD_regle(client, args)
{
    CreateTimer(1.0, Timer_Motd, client);
}
 
public Action:Timer_Motd(Handle:timer, any:client)
{
    decl String:MotdURL[256];
    Format(MotdURL, 256, "http://s.supreme-elite.fr/regle/reglese.html");
    ShowMOTDPanel(client, "Les regles du JailBreak", MotdURL, 2);
}*/


public Action CMD_FT(int client, int args)
{
	if (args < 2 )
	{
		ReplyToCommand(client, "[SM] Usage : sm_ft <name> <team>");
		return Plugin_Handled ;
	}
	int Alive;
	int ThePlayer;
	char sArg1[64];
	char sArg2[64];
	GetCmdArg(1, sArg1, sizeof(sArg2));
	GetCmdArg(2, sArg2, sizeof(sArg2));
	if (IsAdmin(client)||IsRoot(client))
	{
		if (!StrEqual(sArg1, "", true))
		{
			ThePlayer = FindTarget(client,sArg1, false, false);
			if (IsPlayerAlive(ThePlayer))
			{
				Alive = 1;
			}
			if (ThePlayer)
			{
				char name[64];
				GetClientName(ThePlayer, name, 64);
				if (StrEqual(sArg2, "1", true))
				{
					ChangeClientTeam(ThePlayer, 1);
					CPrintToChatAll("{olive}[JAILBEAK-BC] Le joueur %s a été swapé en spectateur.", name);
					LogAction(client, ThePlayer, "\"%L\" a ft \"%L\" (team : \"%s\")", client, ThePlayer, sArg2);
				}
				if (StrEqual(sArg2, "2", true))
				{
					ChangeClientTeam(ThePlayer, 2);
					CPrintToChatAll("{olive}[JAILBEAK-BC] Le joueur %s a été swapé en terroriste.", name);
					if (Alive == 1)
					{
						CS_RespawnPlayer(ThePlayer);
						LogAction(client, ThePlayer, "\"%L\" a ft \"%L\" (team : \"%s\") (la personne est toujours en vie)", client, ThePlayer, sArg2);
					}
					else
					{
						LogAction(client, ThePlayer, "\"%L\" a ft \"%L\" (team : \"%s\") (la personne est morte)", client, ThePlayer, sArg2);
					}
				}
				if (StrEqual(sArg2, "3", true))
				{
					ChangeClientTeam(ThePlayer, 3);
					CPrintToChatAll("{olive}[JAILBEAK-BC] Le joueur %s a été swapé en anti-terroriste.", name);
					if (Alive == 1)
					{
						CS_RespawnPlayer(ThePlayer);
						LogAction(client, ThePlayer, "\"%L\" a ft \"%L\" (team : \"%s\") (la personne est toujours en vie)", client, ThePlayer, sArg2);
					}
					else
					{
						LogAction(client, ThePlayer, "\"%L\" a ft \"%L\" (team : \"%s\") (la personne est morte)", client, ThePlayer, sArg2);
					}
				}
			}
			else
			{
				CPrintToChat(client, "{red}[JAILBEAK-BC] Joueur introuvable", sArg1);
			}
		}
		else
		{
			CPrintToChat(client, "{tomato}[JAILBEAK-BC] Erreur.");
		}
		return view_as<Action>(3);
	}
	CPrintToChat(client, "{tomato}[JAILBEAK-BC] Tu n'as pas les droits nécessaires ");
	return Plugin_Handled;
}

public Action CMD_color(int client, int args)
{
	if (args < 2 )
	{
		ReplyToCommand(client, "[SM] Usage : sm_color <name> <color>");
		return Plugin_Handled;
	}
	int ThePlayer;
	char sArg1[64];
	char sArg2[64];
	GetCmdArg(1, sArg1, sizeof(sArg2));
	GetCmdArg(2, sArg2, sizeof(sArg2));

	if (IsAdmin(client) || IsRoot(client))
	{
		if (!StrEqual(sArg1, "", true))
		{
			if (StrEqual(sArg1, "terro", true))
			{
				int p = 1;
				while (GetMaxClients() >= p)
				{
					if (IsPlayerAlive(p))
					{
						if(p==0||p==2||p==4||p==6||p==8||p==10||p==12||p==14||p==16)
						{
							SetEntityRenderColor(ThePlayer, 0, 0, 0, 255);
							p++;
						}
						else
						{
							SetEntityRenderColor(p, 0, 0, 255, 255);
							p++;
						}
					}
					else
					{
						p++;
					}
				}
				LogAction(client, -1, "\"%L\" a coloré tout les terroristes", client);
			}
			else
			{
				ThePlayer = FindTarget(client,sArg1, false, false);
			}
			if (ThePlayer)
			{
				if (StrEqual(sArg2, "rouge", true))
				{
					SetEntityRenderColor(ThePlayer, 255, 0, 0, 255);
				}
				if (StrEqual(sArg2, "bleu", true))
				{
					SetEntityRenderColor(ThePlayer, 0, 0, 255, 255);
				}
				if (StrEqual(sArg2, "jaune", true))
				{
					SetEntityRenderColor(ThePlayer, 255, 240, 0, 255);
				}
				if (StrEqual(sArg2, "vert", true))
				{
					SetEntityRenderColor(ThePlayer, 0, 138, 0, 255);
				}
				if (StrEqual(sArg2, "rose", true))
				{
					SetEntityRenderColor(ThePlayer, 255, 180, 180, 255);
				}
				if (StrEqual(sArg2, "noir", true))
				{
					SetEntityRenderColor(ThePlayer, 0, 0, 0, 255);
				}
				char name[64];
				GetClientName(ThePlayer, name, 64);
				CPrintToChatAll("{snow}[JAILBEAK-BC] Tu as coloré %s en %s.", name, sArg2);
				LogAction(client, ThePlayer, "\"%L\" a coloré \"%L\" en \"%s\"", client, ThePlayer, sArg2);
			}
			else
			{
				CPrintToChatAll("{tomato}[JAILBEAK-BC] Joueur introuvable.");
			}
		}
		else
		{
			CPrintToChat(client, "{tomato}[JAILBEAK-BC] Erreur de syntaxe : /color <name> <colorname>.");
		}
	}
	else
	{
		CPrintToChat(client, "{tomato}[JAILBEAK-BC] Tu n'as pas le droit de colorer !");
	}
	return Plugin_Continue;
}

public Action CMD_colorstop(int client, int args)
{
	if (IsAdmin(client) || IsRoot(client))
	{
		int x = 1;
		while (GetMaxClients() >= x)
		{
			if (IsClientConnected(x))
			{
				SetEntityRenderColor(x, 255, 255, 255, 255);
				x++;
			}
			x++;
		}
	}
}

public Action CMD_knive(int client, int args)
{
	if (args < 1 )
	{
		ReplyToCommand(client, "[SM] Usage : sm_knive <name>");
		return Plugin_Handled;
	}
	int ThePlayer;
	char sArg1[64];
	GetCmdArg(1, sArg1, sizeof(sArg1));
	if (IsAdmin(client))
	{
		ThePlayer = FindTarget(client,sArg1, false, false);
		if (ThePlayer)
		{
			GivePlayerItem(client, "weapon_knife", 0);
		}
	}
	else
	{
		CPrintToChat(client, "{tomato}[JAILBEAK-BC] Tu n'as pas le droit de donner des couteaux ! ");
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

//public Action Command_ThirdPerson(int client, int args)
//{
	//if (!IsVIP(client)) CPrintToChat(client, "{green}[VIP] Commande réservée aux VIPs.");
	//else if (IsClientInLastRequest(client)) CPrintToChat(client, "{green}[VIP] Erreur ! Vous êtes en dv.");
	//else if (!IsPlayerAlive(client)) CPrintToChat(client, "{green}[VIP] Erreur ! Vous êtes mort.");
	//else if (!g_bTPOn[client]) SetThirdPersonView(client,true);
	//else SetThirdPersonView(client,false);
//}

// public void SetThirdPersonView(int client, bool third)
//{
	//if(third)
	//{
		//SetEntData(client, offsetOne, 0);
		//SetEntData(client, offsetTwo, 1);
		//SetEntData(client, offsetThree, 0);
		//SetEntData(client, offsetFour, 120);
		//g_bTPOn[client] = true;
		
	//}
	//else
	//{
		
		//SetEntData(client, offsetOne, 0);
		//SetEntData(client, offsetTwo, 0);
		//SetEntData(client, offsetThree, 1);
		//SetEntData(client, offsetFour, 90);
		//g_bTPOn[client] = false;		
	//}
//}

stock bool IsVIP(int client)
{
	if (GetUserFlagBits(client) & ADMFLAG_CUSTOM1) return true;
	else return false;
}

stock bool IsRoot(int client)
{
	if (GetUserFlagBits(client) & ADMFLAG_ROOT) return true;
	else return false;
}

stock bool IsAdmin(int client)
{
	if (GetUserFlagBits(client) & ADMFLAG_SLAY) return true;
	else if (GetUserFlagBits(client) & ADMFLAG_GENERIC) return true;
	else if (GetUserFlagBits(client) & ADMFLAG_BAN) return true;
	else return false;
}

stock bool IsClientValid(int client, bool alive)
{
	if(client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client))
	{
		if(alive && !IsPlayerAlive(client))
			return false;
		
		return true;
	}
	return false;
}

stock int GetTotalPlayer(int team, bool alive)
{
	int amount;
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientValid(i, false))
			continue;
		
		if(!IsPlayerAlive(i) && alive)
			continue;
		
		if(GetClientTeam(i) != team)
			continue;
		
		amount++;
	}
	
	return amount;
}