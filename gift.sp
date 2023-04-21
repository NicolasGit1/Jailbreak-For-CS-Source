		/* ----------- Bibliothèques/Libraries ----------- */

#include <sdktools>
#include <sourcemod>
#include <morecolors>
#include <smlib>
#include <hosties>
#include <cstrike>
#include <sdkhooks>
#include <lastrequest>
#include <cssthrowingknives>


		/* ----------- Variables des gifts ----------- */
		
//Pour chaque nouveau gift ajoutez une variable ici, ajoutez cette variable au calcul du gift total, et ajoutez un boucle tout en bas de ce code.
//Probabilité des gifts des T :
new T_HP15Up = 4;
new T_Armor20 = 4;
new T_SpeedUP = 3;
new T_HP30Down = 3;
new T_Grav = 3;
new T_KitGre = 3;
new T_GlockGivre = 2;
new T_BoostSprint = 2;
new T_ArmeVide = 2;
new T_GaySkin = 2;
new T_Rien = 2;
new T_SpeedDown = 2;
new T_Spy = 2;
new T_USP = 2;
new T_CutLancer = 2;
new T_GoldenGun = 1;
new T_1HP = 1;
new T_CutOS = 1;
new T_Resize = 2;

new T_ProbaGiftTotal; //Nombre total de proba, (calculé dans OnPluginStart())


//Probabilité des gifts des CT :
new CT_HP15Up = 4;
new CT_SpeedUP = 3;
new CT_GaySkin = 2;
new CT_Balise = 2;
new CT_Rien = 2;
new CT_SpeedDown = 2;
new CT_HP30Down = 2;
new CT_Rez = 1;
new CT_HP95Up = 1;
new CT_Serum = 1;
new CT_DmgBoost = 2;

new CT_ProbaGiftTotal; //Nombre total de proba, (calculé dans OnPluginStart())



		/* ----------- Skins dans les variables (optionnel) ----------- */

//new String:Prisonnier_orange = "models/player/techknow/prison/leet_p.mdl";
//new String:Prisonnier_blanc = "models/player/techknow/prison/leet_p2.mdl";
//new String:Prisonnier_jaune = "models/player/techknow/prison/leet_pc.mdl";



		/* ----------- Variables globales ----------- */
		
new T_tabgift[20000];
new CT_tabgift[20000];
new gift[MAXPLAYERS+1];
new freeze[MAXPLAYERS+1];
new golden[MAXPLAYERS+1];
new sprint[MAXPLAYERS+1];
new spy[MAXPLAYERS+1];
new rez[MAXPLAYERS+1];
new serum[MAXPLAYERS+1];
new balise[MAXPLAYERS+1];
new balised[MAXPLAYERS+1];
new couteauOS[MAXPLAYERS+1];
new resize[MAXPLAYERS + 1];
	
new Float:clientposition[3];
new Float:dmgbonus;

new String:SRez[ ] = "nico/Z_NISI1.WAV";
new String:SSpy[ ] = "nico/Spy.wav";
new String:SShot[ ] = "nico/CartoonShot.wav";
new String:SGiftP[ ] = "nico/PowerUp.wav";
new String:SGiftN[ ] = "nico/FailureWrongAction.wav";
new String:SGay[ ] = "nico/Nicggay.wav";
new String:SSprint[ ] = "nico/Sprint3.wav";


		/* ----------- Info Plugin ----------- */

public Plugin:myinfo = 
{
	name = "Gift for VIP",
	author = "Neestrid",
	description = "Donne accès à un gift pour les VIPs de Blow Corporation",
	version = "1.0.0",
	url = "https://blow-corporation.fr"
}


		/* ----------- Chargement des events, commandes, et fonctions ----------- */

public OnPluginStart()
{
	RegConsoleCmd("sm_gift", Command_Gift);
	RegConsoleCmd("sm_sprint", Command_Sprint);
	RegConsoleCmd("sm_spy", Command_Spy);
	RegConsoleCmd("sm_rez", Command_Rez);
	RegConsoleCmd("sm_balise", Command_Balise);
	//RegConsoleCmd("sm_freevip", Command_FreeVIP);
	HookEvent("player_spawn", OnPlayerSpawn);
	HookEvent("player_hurt", PlayerHurt);
	HookEvent("player_death", PlayerDeath);
	HookEvent("weapon_fire", WeaponFire);
	LoadTranslations("common.phrases");
	ProbaGift(); //C'est ici que sont calculés les probabilités.
	T_ProbaGiftTotal = (T_HP15Up + T_Armor20 + T_SpeedUP + T_HP30Down + T_Grav + T_KitGre + T_GlockGivre + T_BoostSprint + T_ArmeVide + T_GaySkin + T_Rien + T_SpeedDown + T_Spy + T_USP + T_CutLancer + T_GoldenGun + T_1HP + T_CutOS + T_Resize); //Nombre total de probabilités.
	CT_ProbaGiftTotal = (CT_HP15Up + CT_Balise+ CT_SpeedUP + CT_HP30Down + CT_GaySkin + CT_Rien + CT_SpeedDown + CT_Rez + CT_HP95Up + CT_Serum + CT_DmgBoost);
}


		/* ----------- Chargement des sons au lancement de la map ----------- */

public void OnMapStart() {
    AddFileToDownloadsTable("sound/nico/Z_NISI1.WAV");
    PrecacheSound(SRez, true);
    AddFileToDownloadsTable("sound/nico/PowerUp.wav");
    PrecacheSound(SGiftP, true);
    AddFileToDownloadsTable("sound/nico/FailureWrongAction.wav");
    PrecacheSound(SGiftN, true);
    AddFileToDownloadsTable("sound/nico/Spy.wav");
    PrecacheSound(SSpy, true);
    AddFileToDownloadsTable("sound/nico/CartoonShot.wav");
    PrecacheSound(SShot, true);
    AddFileToDownloadsTable("sound/nico/Nicggay.wav");
    PrecacheSound(SGay, true);
    AddFileToDownloadsTable("sound/nico/Sprint3.wav");
    PrecacheSound(SSprint, true);
	}


		/* ----------- Reset des gifts, boost HP et armure des VIPs ----------- */
		
public OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsVIP(client)) {
		CPrintToChat(client, "{green}[VIP] {default}Votre {lightgreen}!gift {default}est disponible.");
		gift[client] = 1;
		freeze[client] = 0;
		golden[client] = 0;
		sprint[client] = 0;
		spy[client] = 0;
		rez[client] = 0;
		serum[client] = 0;
		balise[client] = 0;
		couteauOS[client] = 0;
		resize[client] = 0;
		ServerCommand("sm_damage #%d 1.0",GetClientUserId(client));
		//Remise de la taille normal.
		if (resize[client] == 1) {
			ServerCommand("sm_resize #%d 1", GetClientUserId(client));
			resize[client] = 0;
		}
		//Boost vie et HP.
		SetEntityHealth(client, 105);
		if ((GetClientTeam(client) == 3)) {
			SetEntProp(client, Prop_Send, "m_ArmorValue", 50, 1);
		}
	}

	if (IsPlayerAlive(client)) {
	}
}



		/* ----------- Les Gifts ----------- */

public Action:Command_Gift(client, args) {
	if (!IsVIP(client)) {
		CPrintToChat(client, "{green}[VIP] Commande réservée aux VIPs.");
		return Plugin_Handled;
	}
	else if (IsClientInLastRequest(client))  {
		CPrintToChat(client, "{green}[VIP] Erreur ! Vous êtes en dv.");
		return Plugin_Handled;
	}
	else if (IsVIP(client)) {
		
				/* ----------- PARTIE TERRORISTE ----------- */
				
		if ((GetClientTeam(client) == 2) && (IsPlayerAlive(client))) {
			if (gift[client] > 0) {
				new bonus = GetRandomInt(1,T_ProbaGiftTotal);

				//HP+15 :
				if (T_tabgift[bonus] == 1)  {
					new health = GetClientHealth(client);
					new nowhealth = health + 15;
					EmitSoundToClient(client,SGiftP);
					SetEntityHealth(client, nowhealth);
					CPrintToChat(client, "{green}[VIP] {default}Vous avez {lightgreen}gagné 15 HP{default}.");
					gift[client]--;
					return Plugin_Handled;
				}
				
				//Armor UP :
				if (T_tabgift[bonus] == 2)  {
					EmitSoundToClient(client,SGiftP);
					new armor = GetEntProp(client, Prop_Send, "m_ArmorValue", 4);
					new nowarmor = armor + 50;
					SetEntProp(client, Prop_Send, "m_ArmorValue", nowarmor, 1);
					CPrintToChat(client, "{green}[VIP] {default}Vous avez {lightgreen}gagné 50 de kevlar{default}.");
					gift[client]--;
					return Plugin_Handled;
				}

				//Speed + :
				else if (T_tabgift[bonus] == 3) {
					new Float:speed = GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue");
					new Float:nowspeed = speed + 0.2;
					EmitSoundToClient(client,SGiftP);
					SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", nowspeed);
					CPrintToChat(client, "{green}[VIP] {default}Vous avez {lightgreen}gagné de la vitesse{default}.");
					gift[client]--;
					return Plugin_Handled;
				}
				
				//HP-30 :
				else if (T_tabgift[bonus] == 4) {
					new health = GetClientHealth(client);
					new nowhealth = health - 30;
					SetEntityHealth(client, nowhealth);
					CPrintToChat(client, "{green}[VIP] {default}Vous avez {ancient}perdu 30 HP{default}.");
					EmitSoundToClient(client, SGiftN);
					gift[client]--;
					return Plugin_Handled;
				}
				
				//Gravity :
				else if (T_tabgift[bonus] == 5) {
					CPrintToChat(client, "{green}[VIP] {default}Vous vous sentez plus léger, votre {blue}gravité {default}passe à {blue}0.8 !");
					SetEntityGravity(client, 0.8)
					EmitSoundToClient(client,SGiftP);
					gift[client]--;
				}
				
				//Kit de grenade :
				else if (T_tabgift[bonus] == 6) {
					GivePlayerItem(client, "weapon_hegrenade");
					GivePlayerItem(client, "weapon_flashbang");
					GivePlayerItem(client, "weapon_smokegrenade");
					EmitSoundToClient(client,SGiftP);
					CPrintToChat(client, "{green}[VIP] {default}Vous avez {lightgreen}gagné un pack de grenade{default}.");
					gift[client]--;
					return Plugin_Handled;
				}
	
				//Glock givrant :
				else if (T_tabgift[bonus] == 7) {
					GivePlayerItem(client, "weapon_glock");
					Client_SetWeaponAmmo(client, "weapon_glock", 0, 0, 1, 0);
					EmitSoundToClient(client,SGiftP);
					CPrintToChat(client, "{green}[VIP] {default}Vous avez gagné {aqua}un glock givrant {default}!");
					gift[client]--;
					freeze[client]=1;
					return Plugin_Handled;
				}
				
				//Sprint :
				else if (T_tabgift[bonus] == 8) {
					EmitSoundToClient(client,SGiftP);
					CPrintToChat(client, "{green}[VIP] {default}Vous avez gagné {lightgreen}une seringue de noradrenaline, {default}tapez {lightgreen}/sprint {default}pour profiter de 3s de sprint !");
					sprint[client] = 1;
					gift[client]--;
				}
				
				//AK ou M4 Vide :
				else if (T_tabgift[bonus] == 9) {
					new m4ak = GetRandomInt(1, 2)
					if (m4ak == 1) {
						GivePlayerItem(client, "weapon_ak47");
						Client_SetWeaponAmmo(client, "weapon_ak47", 0, 0, 0, 0);
						CPrintToChat(client, "{green}[VIP] {default}Vous avez gagné une AK47 {ancient}(vide){default}.");
						gift[client]--;
					}
					else if (m4ak == 2) {
						GivePlayerItem(client, "weapon_m4a1");
						Client_SetWeaponAmmo(client, "weapon_m4a1", 0, 0, 0, 0);
						CPrintToChat(client, "{green}[VIP] {default}Vous avez gagné une M4A1 {ancient}(vide){default}.");
						gift[client]--;
					}
				}
				
				//Gay :
				else if (T_tabgift[bonus] == 10) {
					SetEntityModel(client, "models/player/slow/gaycat_v2/gaycat_v2.mdl");
					CPrintToChat(client, "{green}[VIP] {default}Vous avez gagné {deeppink}un skin ridicule{default}.");
					CPrintToChatAll("{violet}On dirait bien que {red}%N {violet}va nous faire son coming out...",client);
					EmitSoundToAll(SGay);
					gift[client]--;
					return Plugin_Handled;
				}

				//Rien gagné :
				else if (T_tabgift[bonus] == 11) {
					CPrintToChat(client, "{green}[VIP] {default}Vous n'avez {lightyellow}rien gagné{default}.");
					gift[client]--;
					return Plugin_Handled;
				}

				//Slow :
				else if (T_tabgift[bonus] == 12) {
					EmitSoundToClient(client, SGiftN);
					new Float:speed = GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue");
					new Float:nowspeed = speed - 0.2;	
					SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", nowspeed);	
					CPrintToChat(client, "{green}[VIP] {default}Vous avez {ancient}perdu de la vitesse{default} pendant 2 minutes.");
					gift[client]--;
					CreateTimer(120.0, Player_Slow, client, TIMER_FLAG_NO_MAPCHANGE);
					return Plugin_Handled;
				}
				
				//Spy :
				else if (T_tabgift[bonus] == 13) {
					EmitSoundToClient(client,SGiftP);
					CPrintToChat(client, "{green}[VIP] {default}Vous avez gagné un spy, tapez {frozen}/spy {default}pour profiter de 30s de skin en CT !");
					spy[client] = 1;
					gift[client]--;
				}
				
				//Usp 7 balles :
				else if (T_tabgift[bonus] == 14) {
					EmitSoundToClient(client,SGiftP);
					GivePlayerItem(client, "weapon_usp");
					Client_SetWeaponAmmo(client, "weapon_usp", 0, 0, 7, 0);
					CPrintToChat(client, "{green}[VIP] {default}Vous avez {lightgreen}gagné 1 USP (avec 7 balles){default}.");
					gift[client]--;
					return Plugin_Handled;
				}
				
				//Couteaux de lancer :
				else if (T_tabgift[bonus] == 15) {
					EmitSoundToClient(client,SGiftP);
					GetClientThrowingKnives(client); 
					SetClientThrowingKnives(client, 2);
					CPrintToChat(client, "{green}[VIP] {default}Vous avez gagné {lightgreen}deux couteaux de lancer{default}.");
					gift[client]--;
					return Plugin_Handled;
				}
				
				//Golden Gun :
				else if (T_tabgift[bonus] == 16) {
					EmitSoundToClient(client,SGiftP);
					CPrintToChat(client, "{green}[VIP] {default}Vous avez gagné {yellow}un Golden Gun {default}!");
					GivePlayerItem(client, "weapon_deagle");
					Client_SetWeaponAmmo(client, "weapon_deagle", 0, 0, 1, 0);
					gift[client]--;
					golden[client] = 1;
					return Plugin_Handled;
				}


				//1 HP :
				else if (T_tabgift[bonus] == 17) {
					EmitSoundToClient(client, SGiftN);
					CPrintToChat(client, "{green}[VIP] {default}Vous vous sentez très faible, {ancient}vos HP ont été réduit à 1 !");
					CPrintToChatAll("{darkolivegreen}%N ne se sent pas très bien...",client);
					SetEntityHealth(client, 1);
					gift[client]--;
				}
				
				//Couteau OS :
				else if (T_tabgift[bonus] == 18) {
					EmitSoundToClient(client,SGiftP);
					CPrintToChat(client, "{green}[VIP] {default}Vous recevez un {blue}couteau OS, {default}tuez les gardiens en un coup de couteaux jusqu'à votre mort !");
					couteauOS[client] = 1;
					gift[client]--;
				}
				//Resize 0.75 :
				else if (T_tabgift[bonus] == 19) {
					EmitSoundToClient(client,SGiftP);
					CPrintToChat(client, "{green}[VIP] {default}Vous avez été {blue}rétréci {default}de 25% !");
					ServerCommand("sm_resize #%d 0.75",GetClientUserId(client));
					resize[client] = 1;
					gift[client]--;
				}
			}

			//Si gift déjà utilisé :
			else if (gift[client] == 0) {
				CPrintToChat(client, "{green}[VIP] {ancient}Vous avez déjà utilisé votre gift.");
				return Plugin_Handled;
			}
		}

		/* ----------- PARTIE ANTI-TERRORISTE ----------- */
		
		else if ((GetClientTeam(client) == 3) && (IsPlayerAlive(client))) {
			if (gift[client] > 0) {
				new bonus = GetRandomInt(1,CT_ProbaGiftTotal);
				
				//Balise :
				if (CT_tabgift[bonus] == 1) {
					CPrintToChat(client, "{green}[VIP] {default}Vous avez gagné une {lightgreen}balise{default}, tapez {lightgreen}/balise <joueur> {default}pour marquer un joueur.");
					EmitSoundToClient(client,SGiftP);
					gift[client]--;
					balise[client] = 1;
					return Plugin_Handled;
				}
				
				//HP+95 :
				if (bonus == 9) {
					new health = GetClientHealth(client);
					new nowhealth = health + 95;
					EmitSoundToClient(client,SGiftP);
					SetEntityHealth(client, nowhealth);
					CPrintToChat(client, "{green}[VIP] {default}Vous avez {lightgreen}gagné 95 HP{default}.");
					gift[client]--;
					return Plugin_Handled;
				}
				
				//HP+25 :
				else if (CT_tabgift[bonus] == 2) {
					EmitSoundToClient(client,SGiftP);
					new health = GetClientHealth(client);
					new nowhealth = health + 25;
					SetEntityHealth(client, nowhealth);
					CPrintToChat(client, "{green}[VIP] {default}Vous avez {lightgreen}gagné 25 HP{default}.");
					gift[client]--;
					return Plugin_Handled;
				}

				//Speed + :
				else if (CT_tabgift[bonus] == 3) {
					EmitSoundToClient(client,SGiftP);
					new Float:speed = GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue");
					new Float:nowspeed = speed + 0.2;
					SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", nowspeed);
					CPrintToChat(client, "{green}[VIP] {default}Vous avez {lightgreen}gagné de la vitesse{default}.");
					gift[client]--;	
					return Plugin_Handled;
				}

				//Rien gagné :
				else if (CT_tabgift[bonus] == 5) {
					CPrintToChat(client, "{green}[VIP] {default}Vous n'avez {lightyellow}rien gagné{default}.");
					gift[client]--;
					return Plugin_Handled;
				}

				//Gay :
				else if (CT_tabgift[bonus] == 4) {
					SetEntityModel(client, "models/player/slow/pink_soldier_fix/ct_urban.mdl");
					CPrintToChat(client, "{green}[VIP] {default}Vous avez gagné {deeppink}un skin ridicule{default}.");
					CPrintToChatAll("{violet}On dirait bien que {blue}%N {violet}va nous faire son coming out...",client);
					EmitSoundToAll(SGay);
					gift[client]--;
					return Plugin_Handled;
				}

				//Slow :
				else if (CT_tabgift[bonus] == 6) {
					EmitSoundToClient(client, SGiftN);
					new Float:speed = GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue");
					new Float:nowspeed = speed - 0.2;
					SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", nowspeed);
					CPrintToChat(client, "{green}[VIP] {default}Vous avez {ancient}perdu de la vitesse{default} pendant 2 minutes.");
					CreateTimer(120.0, Player_Slow, client, TIMER_FLAG_NO_MAPCHANGE);
					gift[client]--;
					return Plugin_Handled;
				}

				//-30HP :
				else if (CT_tabgift[bonus] == 7) {
					EmitSoundToClient(client, SGiftN);
					new health = GetClientHealth(client);
					new nowhealth = health - 30;
					SetEntityHealth(client, nowhealth);
					CPrintToChat(client, "{green}[VIP]{default} Vous avez {ancient}perdu 30 HP{default}.");
					gift[client]--;
					return Plugin_Handled;
				}

				//Resurection :
				else if (CT_tabgift[bonus] == 8) {
					EmitSoundToClient(client,SGiftP);
					CPrintToChat(client, "{green}[VIP] {default}Vous avez gagné un {lime}totem de résurrection{default}, tapez {lime}/rez <joueur> {default}pour réssuciter un joueur mort !");
					gift[client]--;
					rez[client] = 1;
					return Plugin_Handled;
				}

				//Serum :
				else if (CT_tabgift[bonus] == 10) {
					EmitSoundToClient(client,SGiftP);
					CPrintToChat(client, "{green}[VIP] {default}Vous vous injectez {lime}un Sérum-t, {default}si vous mourrez ce round, vous reviendrez à la vie 15s après !");
					gift[client] = 0;
					serum[client] = 1;
					return Plugin_Handled;
				}
				
				//Boost DMG :
				else if (CT_tabgift[bonus] == 11) {
					EmitSoundToClient(client,SGiftP);
					dmgbonus = 1.20;
					CPrintToChat(client, "{green}[VIP] {default}Vous avez gagné un {blue}boost de dégats{default}, vos dégats seront multipliés par {blue}%.1f {default}jusqu'à votre mort !",dmgbonus);
					gift[client] = 0;
					ServerCommand("sm_damage #%d %f",GetClientUserId(client),dmgbonus);
					return Plugin_Handled;
				}
			}
			//Gift déjà utilisé :
			else if (gift[client] == 0) {
				CPrintToChat(client, "{green}[VIP] {ancient}Vous avez déjà utilisé votre gift.");
				return Plugin_Handled;
			}
		}

		//Mort ou Spectateur :
		else {
			CPrintToChat(client, "{green}[VIP] {default}Vous devez être vivant.");
			return Plugin_Handled;
		}
	}
	return Plugin_Handled;
}


				/* ----------- Fonctions utilisés par les gifts et autres ----------- */

//Tir au Glock Givrant / Golden Gun :
public Action:WeaponFire(Handle:event, const String:name[], bool:dontBroadcast) {
	new String:weapon[64];
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	GetEventString(event,"weapon",weapon,64);
	if (StrEqual(weapon, "glock") && freeze[client] == 1) {
		CreateTimer(0.1, Remove_FreezePower, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	else if (StrEqual(weapon, "deagle") && golden[client] == 1) {
		CreateTimer(0.1, Remove_GoldenPower, client, TIMER_FLAG_NO_MAPCHANGE);
	}
}

//Hit Miss Givrant :
public Action:Remove_FreezePower(Handle:timer, client) {
	freeze[client] = 0;
}

//Hit Miss Golden Gun :
public Action:Remove_GoldenPower(Handle:timer, client) {
	golden[client] = 0;
}

//On Hit :
public Action:PlayerHurt(Handle:event, const String:name[], bool:dontBroadcast) {
	new String:weapon[64];
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	//new weapon =  GetClientOfUserId(GetEventInt(event, "weapon"));
	GetEventString(event,"weapon",weapon,64);


	//Glock Givrant :
	if (StrEqual(weapon, "glock") && freeze[attacker] == 1) {
		CPrintToChat(client, "{ancient} [Alerte] : Vous avez été freeze 3s !.");
		CPrintToChat(attacker, "{green}[VIP] {default}Vous avez {aqua}freeze {default}le gardien {blue}%N pendant 3s {default}!",client);
		/*SetEntityMoveType(client, MOVETYPE_NONE);
		SetEntityRenderColor(client, 0, 128, 255, 192);
		CreateTimer(3.0, Freeze_Player, client, TIMER_FLAG_NO_MAPCHANGE);*/
		ServerCommand("sm_freeze #%d 3", GetClientUserId(client));
		freeze[attacker] = 0;
	}
	//Golden Gun :
	else if (StrEqual(weapon, "deagle") && golden[attacker] == 1) {
		CPrintToChat(client, "{ancient} [Alerte] {default}Vous avez été tué par le {yellow}Golden Gun !");
		CPrintToChat(attacker, "{green}[VIP] {default}Vous avez tué le gardien {blue}%N {default}avec le {yellow}Golden Gun !.",client);
		new health = GetClientHealth(client);
		new nowhealth = health - 9999999;
		SetEntityHealth(client, nowhealth);
		EmitSoundToAll(SShot);
		golden[attacker] = 0;
	}
	//Couteau OS :
	else if (StrEqual(weapon, "knife") && couteauOS[attacker] == 1){
		CPrintToChat(client, "{ancient} [Alerte] {default}Vous avez été tué par le {blue}Couteau OS !");
		CPrintToChat(attacker, "{green}[VIP] {default}Vous avez tué le gardien {blue}%N {default}avec votre {blue}couteau OS !",client);
		new health = GetClientHealth(client);
		new nowhealth = health - 9999999;
		SetEntityHealth(client, nowhealth);
	}
	else {
		return;
	}
}

//On Death :
public Action:PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	StopSound(client, 0, SSpy);
	StopSound(client, 0, SSprint);
	balised[client] = 0;
	if (serum[client] == 1) {
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", clientposition);
		/*new Handle:ClientAndPos;
		WritePackCell(ClientAndPos, client);
		WritePackString(ClientAndPos, clientposition);*/
		CreateTimer(15.0, TSerum_Player, client, TIMER_FLAG_NO_MAPCHANGE);
		CPrintToChat(client, "{green}[VIP] {default}Vous serez ressucité grâce à votre {lime}serum-t {default}dans 15 secondes, tenez vous prêt !");
		serum[client] = 0;
	}
}

//Commande de Rez :
public Action:Command_Rez(int client, args) {
	char target[64];
	GetCmdArg(1, target, sizeof(target));
	new tar = FindTarget(0,target);
	//S'il a un rez
	if (rez[client] == 1) {
		if (IsPlayerAlive(client)) {
			if  (StrEqual(target,"")) {
				CPrintToChat(client, "{green}[VIP] {ancient}Veuillez utiliser /rez <joueur> !");
			}
			else if (tar == -1){
				CPrintToChat(client, "{green}[VIP] {default}Joueur introuvable, veuillez utiliser /rez <joueur> !");
			}
			else if (tar==client) {
				CPrintToChat(client, "{green}[VIP] {ancient}Vous ne pouvez pas vous rez vous-même!");
			}
			else if ((tar !=-1) && (GetClientTeam(tar) == 3) && (IsPlayerAlive(tar)))  {
				CPrintToChat(client, "{green}[VIP] {ancient}Le joueur {blue}%N {ancient}est en vie !",tar);
			}
			else if ((tar !=-1) && (GetClientTeam(tar) != 3))  {
				CPrintToChat(client, "{green}[VIP] {ancient}Vous ne pouvez réssuciter qu'un CT !");
			}
			else if ((tar !=-1) && (GetClientTeam(tar) == 3) && (!IsPlayerAlive(tar)))  {
				CS_RespawnPlayer(tar);
				SetEntityModel(tar, "models/player/elis/po/police.mdl");
				CPrintToChatAll("{blue}%N {default}a été réssucité par {blue}%N !",tar,client);
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", clientposition);
				TeleportEntity(tar, clientposition, NULL_VECTOR, NULL_VECTOR);
				SetEntityRenderColor(tar, 0, 255, 0, 255);
				EmitSoundToAll(SRez);
				CreateTimer(3.0, Green_Player, tar, TIMER_FLAG_NO_MAPCHANGE);
				rez[client] = 0;
			}
		}
		else if (!IsPlayerAlive(client)) {
			CPrintToChat(client, "{green}[VIP] {ancient}Vous devez être en vie pour faire cette commande !");
		}
	}

	//S'il a pas de rez
	else if (rez[client] == 0) {
		CPrintToChat(client, "{green}[VIP] {ancient}Vous n'avez pas de /rez");
	}
}

//Commande de Balise :
public Action:Command_Balise(int client, args) {
	char target[64];
	GetCmdArg(1, target, sizeof(target));
	new tar = FindTarget(0,target);
	//S'il a une balise
	if (balise[client] == 1) {
		if (IsPlayerAlive(client)) {
			if  (StrEqual(target,"")) {
				CPrintToChat(client, "{green}[VIP] {ancient}Veuillez utiliser /balise <joueur> !");
			}
			else if (tar == -1){
				CPrintToChat(client, "{green}[VIP] {default}Joueur introuvable, veuillez utiliser /balise <joueur> !");
			}
			else if (tar==client) {
				CPrintToChat(client, "{green}[VIP] {ancient}Vous ne pouvez pas vous baliser vous-même !");
			}
			else if ((tar !=-1) && (GetClientTeam(tar) == 2) && (IsPlayerAlive(tar)))  {
				CPrintToChatAll("{green}[VIP] {default}Une balise a été placé sur {red}%N {default} pendant 15s !",tar);
				ServerCommand("sm_beacon #%d",GetClientUserId(tar));
				CreateTimer(15.0, CTBalise_Player, tar, TIMER_FLAG_NO_MAPCHANGE);
				balise[client] = 0;
				balised[tar] = 1;
			}
			else if ((tar !=-1) && (GetClientTeam(tar) != 2))  {
				CPrintToChat(client, "{green}[VIP] {ancient}Vous ne pouvez baliser que les prisonniers !");
			}
			else if ((tar !=-1) && (GetClientTeam(tar) == 2) && (!IsPlayerAlive(tar)))  {
				CPrintToChat(client, "{green}[VIP] {ancient}Le joueur {orange}%N {ancient}est en mort !",tar);
			}
		}
		else if (!IsPlayerAlive(client)) {
			CPrintToChat(client, "{green}[VIP] {ancient}Vous devez être en vie pour faire cette commande !");
		}
	}

	//S'il n'a pas de balise
	else if (balise[client] == 0) {
		CPrintToChat(client, "{green}[VIP] {ancient}Vous n'avez pas de /balise");
	}
}

//Commande de Sprint :
public Action:Command_Sprint(client, args) {
	if (sprint[client] == 1) {
		new Float:speed = GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue");
		//CPrintToChatAll("Speed = %f",speed);
		new Float:nowspeed = speed + 1.5;
		//CPrintToChatAll("NowSpeed = %f",nowspeed);
		EmitSoundToAll(SSprint, client);
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", nowspeed);
		CPrintToChat(client, "{green}[VIP] {default}Sprint {green}activé.");
		CreateTimer(3.5, TSprint_Player, client, TIMER_FLAG_NO_MAPCHANGE);
		sprint[client] = 0;
	}
	else {
		return;
	}
}

//Timed : Sprint :
public Action:TSprint_Player(Handle:timer, client) {
	new Float:speed = GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue");
	new Float:afterspeed = speed - 1.5;
	StopSound(client, 0, SSprint);
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", afterspeed);
	CPrintToChat(client, "{green}[VIP] {default}Sprint {ancient}désactivé.");
}



//Fonction Spy :
public Action:Command_Spy(client, args) {
	if (spy[client] == 1) {
		SetEntityModel(client, "models/player/elis/po/police.mdl");
		CPrintToChat(client, "{green}[VIP] {default}Mode Spy {green}activé.");
		CreateTimer(30.0, TSpy_Player, client, TIMER_FLAG_NO_MAPCHANGE);
		EmitSoundToClient(client, SSpy,_,0);
		spy[client] = 0;
	}
	else {
		return;
	}
}

/*//Fonction FreeVIP :
public Action:Command_FreeVIP(client, args) {
	char sID[64];
	char playername[64];
	if (IsFreeVIPUsed(client)) {
		CPrintToChat(client, "{red}Vous avez déjà utilisé votre !freevip !");
	}
	else {
		//char sID[64];
		//char playername[64];
		GetClientAuthString(client, sID, sizeof(sID));
		GetClientName(client, playername, 64);
		ServerCommand("sm_addvip %s 1440 %s 1", sID, playername);
		AddUserFlags(client, ADMFLAG_CUSTOM2);
		CPrintToChatAll("Jamais utilisé");
	}
	CPrintToChatAll("sID = %s et playername = %s",sID,playername);
}*/

//Timed : Spy :
public Action:TSpy_Player(Handle:timer, client) {
	SetEntityModel(client, "models/player/techknow/prison/leet_p.mdl");
	CPrintToChat(client, "{green}[VIP] {default}Mode spy {ancient}désactivé.");
}


//Timed : Serum :
public Action:TSerum_Player(Handle:timer, client) {
	if (!IsPlayerAlive(client)) {
		CS_RespawnPlayer(client);
		TeleportEntity(client, clientposition, NULL_VECTOR, NULL_VECTOR);
		CPrintToChatAll("{blue}%N {default}a été réssucité grâce à son {lime}Sérum-t{green} !",client);
		SetEntityRenderColor(client, 0, 255, 0, 255);
		EmitSoundToAll(SRez);
		CreateTimer(3.0, Green_Player, client, TIMER_FLAG_NO_MAPCHANGE);
	}
}

//Timed : Colored to Not Colored :
public Action:Green_Player(Handle:timer, client) {
	if (IsPlayerAlive(client)) {
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
}


//Timed : Balise :
public Action:CTBalise_Player(Handle:timer, tar) {
	if (IsPlayerAlive(tar) && (balised[tar] == 1)){
		ServerCommand("sm_beacon #%d",GetClientUserId(tar));
		CPrintToChatAll("{green}[VIP] {default}La balise a été retiré de {red}%N {default} !",tar);
		balised[tar] = 0;
	}
}

//Timed : Slow to Normal :
public Action:Player_Slow(Handle:timer, client) {
	if (IsPlayerAlive(client)) {
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.00);	
		CPrintToChat(client, "{green}[VIP] {default}Vous avez retrouvé votre vitesse {green}normale.");
	}
}


		/* ----------- Remplissage du tableau de probabilités pour les gifts ----------- */
	
stock int ProbaGift (){
	//Remplissage T :
	new j = 1;
	new i = 1;
	new k = 1;
	for (; i <= T_HP15Up; i++) {
		T_tabgift[k] = j;
		k++;
	}
	j++;
	i = 1;
	for (; i <= T_Armor20; i++) {
		T_tabgift[k] = j;
		k++;
	}
	j++
	i = 1;
	for (; i <= T_SpeedUP; i++) {
		T_tabgift[k] = j;
		k++;
	}
	j++
	i = 1;
	for (; i <= T_HP30Down; i++) {
		T_tabgift[k] = j;
		k++;
	}
	j++
	i = 1;
	for (; i <= T_Grav; i++) {
		T_tabgift[k] = j;
		k++;
	}
	j++
	i = 1;
	for (; i <= T_KitGre; i++) {
		T_tabgift[k] = j;
		k++;
	}
	j++
	i = 1;
	for (; i <= T_GlockGivre; i++) {
		T_tabgift[k] = j;
		k++;
	}
	j++
	i = 1;
	for (; i <= T_BoostSprint; i++) {
		T_tabgift[k] = j;
		k++;
	}
	j++
	i = 1;
	for (; i <= T_ArmeVide; i++) {
		T_tabgift[k] = j;
		k++;
	}
	j++
	i = 1;
	for (; i <= T_GaySkin; i++) {
		T_tabgift[k] = j;
		k++;
	}
	j++
	i = 1;
	for (; i <= T_Rien; i++) {
		T_tabgift[k] = j;
		k++;
	}
	j++
	i = 1;
	for (; i <= T_SpeedDown; i++) {
		T_tabgift[k] = j;
		k++;
	}
	j++
	i = 1;
	for (; i <= T_Spy; i++) {
		T_tabgift[k] = j;
		k++;
	}
	j++
	i = 1;
	for (; i <= T_USP; i++) {
		T_tabgift[k] = j;
		k++;
	}
	j++
	i = 1;
	for (; i <= T_CutLancer; i++) {
		T_tabgift[k] = j;
		k++;
	}
	j++
	i = 1;
	for (; i <= T_GoldenGun; i++) {
		T_tabgift[k] = j;
		k++;
	}
	j++
	i = 1;
	for (; i <= T_1HP; i++) {
		T_tabgift[k] = j;
		k++;
	}
	j++
	i = 1;
	for (; i <= T_CutOS; i++) {
		T_tabgift[k] = j;
		k++;
	}
	j++
	i = 1;
	for (; i <= T_Resize; i++) {
		T_tabgift[k] = j;
		k++;
	}
	
	//Remplissage CT :
	j = 1;
	i = 1;
	k = 1;
	for (; i <= CT_Balise; i++) {
		CT_tabgift[k] = j;
		k++;
	}
	j++;
	i = 1;
	for (; i <= CT_HP15Up; i++) {
		CT_tabgift[k] = j;
		k++;
	}
	j++
	i = 1;
	for (; i <= CT_SpeedUP; i++) {
		CT_tabgift[k] = j;
		k++;
	}
	j++
	i = 1;
	for (; i <= CT_GaySkin; i++) {
		CT_tabgift[k] = j;
		k++;
	}
	j++
	i = 1;
	for (; i <= CT_Rien; i++) {
		CT_tabgift[k] = j;
		k++;
	}
	j++
	i = 1;
	for (; i <= CT_SpeedDown; i++) {
		CT_tabgift[k] = j;
		k++;
	}
	j++
	i = 1;
	for (; i <= CT_HP30Down; i++) {
		CT_tabgift[k] = j;
		k++;
}
	j++
	i = 1;
	for (; i <= CT_Rez; i++) {
		CT_tabgift[k] = j;
		k++;
	}
	j++
	i = 1;
	for (; i <= CT_HP95Up; i++) {
		CT_tabgift[k] = j;
		k++;
	}
	j++
	i = 1;
	for (; i <= CT_Serum; i++) {
		CT_tabgift[k] = j;
		k++;
	}
	j++
	i = 1;
	for (; i <= CT_DmgBoost; i++) {
		CT_tabgift[k] = j;
		k++;
	}


}


stock bool IsVIP(int client) {
	if (GetUserFlagBits(client) & ADMFLAG_CUSTOM1) return true;
	else return false;
}

stock bool IsFreeVIPUsed(int client) {
	if (GetUserFlagBits(client) & ADMFLAG_CUSTOM2) return true;
	else return false;
}