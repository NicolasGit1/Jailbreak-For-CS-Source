#pragma semicolon 1
 
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <morecolors>
#include <cstrike>
#include <hosties>
#include <cssthrowingknives>
#pragma tabsize 0
 
 
 
new Handle:roundTimer;
new Handle:updateTimer;
new Handle:overlayTimer;
new bool:isRoundStart = false;
new roundTime;
new realRoundTime;
new PhraseTimer;
new cAlive = 0;
new tAlive = 0;
new xAlive = 0;
new aAlive = 0;
new randomSatan = 0;
new randomMere = 0;
new randomPere = 0;
new Float:speeed = 1.0;
new blueColor[4] = {75, 75, 255, 255};
new g_BeamSprite = -1;
new g_HaloSprite = -1;
new trailMere;
new trailSatan;
new cantCut[MAXPLAYERS+1];
 
 
public OnPluginStart()
{
    ServerCommand("sv_skyname mpa120"); // On change le ciel
    ServerCommand("sv_ignoregrenaderadio 1"); // On désactive les bruits de radios
    ServerCommand("mp_buytime 0");
    HookEvent("round_start", EventRoundStart);
    HookEvent("player_spawn", EventSpawn);
    HookEvent("round_end", EventReset);
    HookEvent("game_start", EventReset);
    HookEvent("player_connect", EventConnect);
    HookEvent("player_death", EventDeath);
    HookEvent("game_end", EventReset);
    PrecacheModel("models/player/techknow/demon/demon.mdl", true);
    PrecacheModel("models/player/techknow/wingedelf/wingedelf.mdl", true);
    PrecacheModel("models/mapeadores/kaem/diablo3/diablo3.mdl", true);
    PrecacheModel("models/player/techknow/grimreaper/grim.mdl", true);
	PrecacheModel("models/player/natalya/zelda/zelda.mdl", true);
	PrecacheModel("models/mapeadores/kaem/bahamut/bahamut.mdl", true);
	g_BeamSprite = PrecacheModel("materials/sprites/laser.vmt");
    g_HaloSprite = PrecacheModel("materials/sprites/halo01.vmt");
}
 
 
 
 
 
public Action:EventRoundStart(Handle:event,const String:name[],bool:dontBroadcast)
{
    // Pendant 30 secondes seuls les anges peuvent bouger et rien n'est lancé
    CPrintToChatAll("{CYAN}[New-Gaming]{honeydew}[{skyblue}Anges {honeydew}& {ancient}Demons{honeydew}] \n{default} Crée par {green}Elliot{default}, inspiré du mode par {green}Steven{default}.");
    CPrintToChatAll("{CYAN}[New-Gaming]{honeydew}[{skyblue}Anges {honeydew}& {ancient}Demons{honeydew}] \n{default} Team Speak: {green}ts3.new-gaming.eu{default}");
	                getAliveTeam();
					if(cAlive > 0 && tAlive > 0)
					{
						CPrintToChatAll("{CYAN}[New-Gaming]{honeydew}[{skyblue}Anges {honeydew}& {ancient}Demons{honeydew}] \n{default} Les {red}Démons{default} seront relachés dans {green}20{default} secondes.");
					}	
    ServerCommand("sv_skyname mpa120"); // On change le ciel
    ServerCommand("sv_ignoregrenaderadio 1"); // On désactive les bruits de radios
    PrecacheModel("models/player/techknow/demon/demon.mdl", true);
    PrecacheModel("models/player/techknow/wingedelf/wingedelf.mdl", true);
    PrecacheModel("models/mapeadores/kaem/diablo3/diablo3.mdl", true);
    PrecacheModel("models/player/techknow/grimreaper/grim.mdl", true);
	PrecacheModel("models/player/natalya/zelda/zelda.mdl", true);
	PrecacheModel("models/mapeadores/kaem/bahamut/bahamut.mdl", true);
    g_BeamSprite = PrecacheModel("materials/sprites/laser.vmt");
    g_HaloSprite = PrecacheModel("materials/sprites/halo01.vmt");
    randomSatan = 0;
    randomMere = 0;
	randomPere = 0;
	
    for (new clientt = 1; clientt <= MaxClients; clientt++)
    {
        if(IsClientInGame(clientt))
        {
            if(IsPlayerAlive(clientt))
            {
                if(GetClientTeam(clientt) == 2)
                {
                    StripAllWeapons(clientt);
                    CS_SetClientClanTag(clientt, "{Demon}");
                    SetEntityModel(clientt, "models/player/techknow/demon/demon.mdl"); // on leur met le démon
					getAliveTeam();
					if(cAlive > 0 && tAlive > 0)
					{	
						SetEntityMoveType(clientt, MOVETYPE_NONE); // On freeze les Demons pendant les 30 secondes avant le début de la partie
					} 
                    GivePlayerItem(clientt, "weapon_knife");
					
                }
                else if(GetClientTeam(clientt) == 3)
                {
                    StripAllWeapons(clientt);
                    CS_SetClientClanTag(clientt, "{Ange}");
                    SetEntityModel(clientt, "models/player/techknow/wingedelf/wingedelf.mdl"); // on leur met l'angle
                    new Float:nowspeed = speeed + 0.5;
                    SetEntPropFloat(clientt, Prop_Data, "m_flLaggedMovementValue", nowspeed); // on donne la vitesse
                    GivePlayerItem(clientt, "weapon_knife");
                }
                // Remove arme
               
            }
            else
            {
                CS_SetClientClanTag(clientt, "{Mort}");
            }
        }
    }
    roundTime = GetTime()+20;
    realRoundTime = GetTime()+200;
	PhraseTimer = GetTime()+200;
    updateTimer = CreateTimer(1.0, theUpdate, _, TIMER_REPEAT); // On rafraichit toutes les secondes le menu
    roundTimer = CreateTimer(20.0, roundStart);
    return Plugin_Handled;
}
 
public Action:EventSpawn(Handle:event,const String:name[],bool:dontBroadcast)
{
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if(IsClientInGame(client))
    {
        if(IsPlayerAlive(client))
        {
		new Team = GetClientTeam(client);
		new T_Team_Count = GetTeamClientCount(CS_TEAM_T);
        new CT_Team_Count = GetTeamClientCount(CS_TEAM_CT);
		if(CT_Team_Count >= 1 && CT_Team_Count <= 4 && T_Team_Count >= 2 || CT_Team_Count >= 5 && CT_Team_Count <= 7 && T_Team_Count >= 3 || CT_Team_Count >= 8 && CT_Team_Count <= 11 && T_Team_Count >= 4 || CT_Team_Count >= 12 && CT_Team_Count <= 15 && T_Team_Count >= 5 || CT_Team_Count >= 16 && CT_Team_Count <= 19 && T_Team_Count >= 6 || CT_Team_Count >= 20 && CT_Team_Count <= 23 && T_Team_Count >= 7)
            {		
                if(Team == CS_TEAM_T)
				{
					CS_SwitchTeam(client,CS_TEAM_CT);
				}
			}
            if(GetClientTeam(client) == 2)
            {
                StripAllWeapons(client);
                GivePlayerItem(client, "weapon_knife");
                CS_SetClientClanTag(client, "{Demon}");
                SetEntityModel(client, "models/player/techknow/demon/demon.mdl"); // on leur met le démon
				getAliveTeam();
                if(cAlive > 0 && tAlive > 0)
				{	SetEntityMoveType(client, MOVETYPE_NONE); // On freeze le demon qui vient de se connecter
				}
            }
            else if(GetClientTeam(client) == 3)
            {
                StripAllWeapons(client);
                GivePlayerItem(client, "weapon_knife");
                CS_SetClientClanTag(client, "{Ange}"); // on met tag
                SetEntityModel(client, "models/player/techknow/wingedelf/wingedelf.mdl"); // on leur met l'angle
                new Float:nowspeed = speeed + 0.5;
                SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", nowspeed); // On donne la vitesse
				
					
            }
            // Trouver u truc qui remoevarme
        }
    }
    return Plugin_Handled;
}
 
 
 
 
////// ENVOIE DE FAUX MESSAGES DE MORT PRIS SUR LE NET /////
 
 
public SendDeathMessage(attacker, victim, const String:weapon[], bool:headshot)
{
    new Handle:event = CreateEvent("player_death");
    if (event == INVALID_HANDLE)
    {
        return;
    }
 
    SetEventInt(event, "userid", GetClientUserId(victim));
    SetEventInt(event, "attacker", GetClientUserId(attacker));
    SetEventString(event, "weapon", weapon);
    SetEventBool(event, "headshot", headshot);
    FireEvent(event);
}
 
///////////////////////////////////////////////////////
 
 

 
 
 
 
 
 
 
///// LES DOMMAGES A 0  ET COUTEAU /////////////
 
public OnClientPutInServer(client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}
 
public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
    decl String:sWeapont[32];
    GetEdictClassname(inflictor, sWeapont, sizeof(sWeapont));
    // func_physbox env_explosion trigger_hurt
    if(StrEqual(sWeapont, "trigger_hurt"))
    {
            damage = 9000.0;
            return Plugin_Changed;
    }
    else
    {
        if(isRoundStart == true)
        {
            decl String:sWeapon[32];
            GetClientWeapon(attacker, sWeapon, sizeof(sWeapon));
            damage = 0.0;
            if(StrEqual(sWeapon, "weapon_knife"))
            {
                new String:tmpTag[50];
                CS_GetClientClanTag(victim, tmpTag, sizeof(tmpTag));
                new String:tmpTag2[50];
                CS_GetClientClanTag(attacker, tmpTag2, sizeof(tmpTag2));
				new String:tmpTag3[50];
                CS_GetClientClanTag(attacker, tmpTag2, sizeof(tmpTag3));
				if(GetClientTeam(victim) == 3 && GetClientTeam(attacker) == 2  && GetClientHealth(victim) > 1 && cantCut[attacker] != true)
                {
                    if(StrEqual(tmpTag, "{Mort}") || StrEqual(tmpTag, "{Mort | MereDe") || StrEqual(tmpTag, "{Mort | PereDe"))
                    {
                    }
                    else
                    {
                        damage = 14.0;
                        CS_SetClientClanTag(victim, "{Mort}");
                        if(victim == randomMere)
                        {
                            damage = 19.0;
                            CS_SetClientClanTag(victim, "{Mort | MereDesAnges}");
                        }
						if(victim == randomPere)
                        {
                            damage = 24.0;
                            CS_SetClientClanTag(victim, "{Mort | PereDesAnges}");
                        }
                        if(PrecacheSound("avd/ange_dead.wav", false)) // on precache le son de la mort des anges
                        {
                            EmitSoundToAll("avd/ange_dead.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 0.8); // Tout le monde entend la musique
                        }
                        SendDeathMessage(attacker, victim, "worldspawn", false);
                        SetEntityMoveType(victim, MOVETYPE_NONE);
                        SetEntityModel(victim, "models/player/techknow/grimreaper/grim.mdl");
                        getAliveTeam();
                        if(aAlive == 0)
                        {
                            CS_TerminateRound(7.0, CSRoundEnd_TerroristsEscaped, false);
                            SetEntityMoveType(victim, MOVETYPE_NONE);
                            return Plugin_Handled;
                        }
                    }
                }
                else if(GetClientTeam(victim) == 3 && GetClientTeam(attacker) == 3 && !StrEqual("weapon_tknife", sWeapont) && !StrEqual("weapon_tknifehs", sWeapont) && IsAlive(attacker))
                {
				
                    if(StrEqual(tmpTag, "{Mort}") || StrEqual(tmpTag, "{Mort | MereDe") || StrEqual(tmpTag, "{Mort | PereDe"))
                    {
				    
					if(GetClientHealth(attacker) == 15)
                            SetEntityHealth(victim, GetClientHealth(victim) + 1);
                        else if(GetClientHealth(attacker) == 20)
                            SetEntityHealth(victim, GetClientHealth(victim) + 2);
							else if(GetClientHealth(attacker) == 25)
                            SetEntityHealth(victim, GetClientHealth(victim) + 3);
			            //SetEntityHealth(victim, GetClientHealth(victim) + GetClientHealth(attacker) == 15 ? 1:2);
                        if(PrecacheSound("avd/angel_heal.wav", false)) // on precache le son des cuts
                        {
                            new Float:eyePos1[3];
                            GetClientEyePosition(victim, eyePos1);
                            EmitSoundToAll("avd/angel_heal.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1 ,eyePos1);
                            // EmitAmbientSound("avd/angel_heal.wav", eyePos1, SOUND_FROM_PLAYER, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.8);
                        }
                        new Float:eyePos[3];
                        GetClientAbsOrigin(victim, eyePos);
                        TE_SetupBeamRingPoint(eyePos, 1.0, 60.0, g_BeamSprite, g_HaloSprite, 0, 10, 0.6, 10.0, 0.5, {255,255,255,255}, 10, 0);
                        TE_SendToAll();
                        eyePos[2] += 20.0;
                        TE_SetupBeamRingPoint(eyePos, 1.0, 50.0, g_BeamSprite, g_HaloSprite, 0, 10, 0.6, 10.0, 0.5, {255,255,255,255}, 10, 0);
                        TE_SendToAll();
                        eyePos[2] += 20.0;
                        TE_SetupBeamRingPoint(eyePos, 1.0, 20.0, g_BeamSprite, g_HaloSprite, 0, 10, 0.6, 10.0, 0.5, {255,255,255,255}, 10, 0);
                        TE_SendToAll();
                        if(GetClientHealth(victim) >= 15 && GetClientHealth(victim) <= 17 && victim != randomMere && victim != randomPere)
                        {
                            SetEntityMoveType(victim, MOVETYPE_WALK);
                            SetEntityModel(victim, "models/player/techknow/wingedelf/wingedelf.mdl");
                            SendDeathMessage(attacker, victim, "worldspawn", false);
                            CS_SetClientClanTag(victim, "{Ange}");
							SetEntData(victim, FindDataMapOffs(randomMere, "m_iMaxHealth"),15, 4, true);
                            SetEntData(victim, FindDataMapOffs(randomMere, "m_iHealth"), 15, 4, true);
                            if(PrecacheSound("avd/delivrer.wav", false)) // on precache le son de la libération des anges
                            {
                                EmitSoundToAll("avd/delivrer.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 0.8); // Tout le monde entend la musique
                            }
                        }
                        else if(GetClientHealth(victim) >= 20 && GetClientHealth(victim) <= 22 && victim == randomMere)
                        {
                            SetEntityMoveType(victim, MOVETYPE_WALK);
                            SetEntityModel(victim, "models/player/natalya/zelda/zelda.mdl");
                            SendDeathMessage(attacker, victim, "worldspawn", false);
                            CS_SetClientClanTag(victim, "{Mere}");
							SetEntData(randomMere, FindDataMapOffs(randomMere, "m_iMaxHealth"),20, 4, true);
                            SetEntData(randomMere, FindDataMapOffs(randomMere, "m_iHealth"), 20, 4, true);
							
							if(PrecacheSound("avd/delivrer.wav", false)) // on precache le son de la libération des anges
                            {
                                EmitSoundToAll("avd/delivrer.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 0.8); // Tout le monde entend la musique
                            }
							}
							
						else if(GetClientHealth(victim) >= 25 && GetClientHealth(victim) <= 27 && victim == randomPere)
                        {
                            SetEntityMoveType(victim, MOVETYPE_WALK);
                            SetEntityModel(victim, "models/mapeadores/kaem/bahamut/bahamut.mdl");
                            SendDeathMessage(attacker, victim, "worldspawn", false);
                            CS_SetClientClanTag(victim, "{Pere}");
							SetEntData(randomPere, FindDataMapOffs(randomPere, "m_iMaxHealth"),25, 4, true);
                            SetEntData(randomPere, FindDataMapOffs(randomPere, "m_iHealth"), 25, 4, true);
							
                            if(PrecacheSound("avd/delivrer.wav", false)) // on precache le son de la libération des anges
                            {
                                EmitSoundToAll("avd/delivrer.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 0.8); // Tout le monde entend la musique
                            }
                        }
                    
                }
			}	
                else if(GetClientTeam(victim) != GetClientTeam(attacker))
                {
                    if(StrEqual(tmpTag2, "{Mort}") || StrEqual(tmpTag2, "{Mort | Mere") || StrEqual(tmpTag2, "{Mort | Pere"))
                    {
                        if(victim != randomSatan) // LES ANGES MORT NE PEUVENT PAS CUT SATAN
                        {
                            SetEntPropFloat(victim, Prop_Data, "m_flLaggedMovementValue", 0.5);
							CreateTimer(3.0, makeRalenti, victim);
                        }
                    }
                    else
                    {
					if(GetClientHealth(victim) == 100)
					{
                        SetEntPropFloat(victim, Prop_Data, "m_flLaggedMovementValue", 0.5);
                        cantCut[victim] = true;
                        CreateTimer(2.0, cantCutAction, victim);
                        CreateTimer(3.0, makeRalenti, victim);
						}
                        if (victim == randomSatan)
                        {
                            SetClientThrowingKnives(attacker, 1);
                        }
                    }
                    decl Float:clientposition[3], Float:targetposition[3], Float:vector[3];
                    GetClientEyePosition(attacker, clientposition);
                    GetClientEyePosition(victim, targetposition);
                    MakeVectorFromPoints(clientposition, targetposition, vector);
                    NormalizeVector(vector, vector);
                    ScaleVector(vector, 100.0);
                    TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, vector);
                }
               
               
            }
            return Plugin_Changed;
        }
        else
        {
            damage = 0.0;
            if(StrEqual(sWeapont, "trigger_hurt"))
            {
                damage = 9000.0;
            }
            return Plugin_Changed;
        }
    }
 
}
 
public Action:cantCutAction(Handle:timer, client)
{
    cantCut[client] = false;
    return Plugin_Handled;
}
 
 
public Action:makeRalenti(Handle:timer, client)
{
    SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.5);
    if(client == randomMere)
    {
        SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.7);
    }
	if(client == randomPere)
    {
        SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.7);
    }
    return Plugin_Handled;
}
 
////////////////////////////////////////////////////////////////////////////////////////
 
 
 
 
 
 
 
//////////////////// FUNCTION DES BEACONS /////////////////////////////////////////////////
public KillBeacon(client)
{
    if (IsClientInGame(client))
    {
        SetEntityRenderColor(client, 255, 255, 255, 255);
    }
}
 
public KillAllBeacons()
{
    for (new i = 1; i <= MaxClients; i++)
    {
        KillBeacon(i);
    }
}
 
 
/////////////////////////////////////////////////////////////////////////////////////////////
 
 
 
 
 
 
 
public Action:EventDeath(Handle:event,const String:name[],bool:dontBroadcast)
{
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    CS_SetClientClanTag(client, "{Mort}"); // Quand une personne meurt, elle a clan tag mort
    if(client == randomSatan)
    {
        if(PrecacheSound("avd/deamon_dead.wav", false)) // on precache le son de la mort du démon
        {
            EmitSoundToAll("avd/deamon_dead.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 0.8); // Tout le monde entend la musique
        }
    }
    return Plugin_Handled;
}
 
public Action:EventConnect(Handle:event,const String:name[],bool:dontBroadcast)
{
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    CS_SetClientClanTag(client, "{Mort}"); // une personne qui se connecte pendant la partie a le clan tag mort
    if(isRoundStart == false)
    {
        CS_RespawnPlayer(client);
    }
    return Plugin_Handled;
}
 
public Action:roundStart(Handle:timer)
{
    // Faire en sorte qu'on puisse pu spawn après le début de la partie, et d'équilibré automatiquement les équipes d'un ratio 1/4 choisir maman et santa
       
    getAliveTeam(); // On compte le nombre ANGES ET DEMONS spawner
    if(cAlive > 0 && tAlive > 0)
    {
		CPrintToChatAll("{CYAN}[New-Gaming]{honeydew}[{skyblue}Anges {honeydew}& {ancient}Demons{honeydew}] \n{default}Les {red}Démons{default} ont été relachés.");
        new tArray[tAlive];
        new cArray[cAlive];
		new xArray[xAlive];
		
	    new tIncrement = 0;
        new cIncrement = 0;
		new xIncrement = 0;

       
        for (new client = 1; client <= MaxClients; client++)
        {
            if(IsClientInGame(client))
            {
                if(IsPlayerAlive(client) && (GetClientTeam(client) == 2))
                {
                    tArray[tIncrement] = client; // On stock dans un tableau les démons
                    tIncrement++;
                    GivePlayerItem(client, "item_nvgs");  
                    GivePlayerItem(client, "weapon_knife");
                   
                }
                if(IsPlayerAlive(client) && (GetClientTeam(client) == 3))
                {
                    cArray[cIncrement] = client; // On stock dans un tableau les anges
					xArray[xIncrement] = client;
                    SetEntData(client, FindDataMapOffs(randomMere, "m_iMaxHealth"),15, 4, true);
                    SetEntData(client, FindDataMapOffs(randomMere, "m_iHealth"), 15, 4, true);
                    SetClientThrowingKnives(client, 3);
                    GivePlayerItem(client, "weapon_knife");
                    cIncrement++;
					xIncrement++;
                }
            }
        }
       
        randomMere = cArray[GetRandomInt(0, (cIncrement-1))]; // On selectionne une mere et un satan au zazard
		randomSatan = tArray[GetRandomInt(0, (tIncrement-1))];
       
        CS_SetClientClanTag(randomMere, "{Mere}"); // relié avec poisonsmoke
        CS_SetClientClanTag(randomSatan, "{Satan}");
       
        //// ITEM DE LA MERE
       
        GivePlayerItem(randomMere, "weapon_flashbang");
        GivePlayerItem(randomMere, "weapon_hegrenade");
        Client_SetWeaponPlayerAmmo(randomMere, "weapon_flashbang", 2);
        Client_SetWeaponPlayerAmmo(randomMere, "weapon_hegrenade", 2);
        GivePlayerItem(randomMere, "weapon_deagle");
        Client_SetWeaponPlayerAmmo(randomMere, "weapon_deagle", 0);
        Client_SetWeaponClipAmmo(randomMere, "weapon_deagle", 5);
        SetClientThrowingKnives(randomMere, 5);
		
       
        new Float:speeeed = GetEntPropFloat(randomMere, Prop_Data, "m_flLaggedMovementValue");
        new Float:nowspeeed = speeeed + 0.2;
        SetEntPropFloat(randomMere, Prop_Data, "m_flLaggedMovementValue", nowspeeed);  // La mere va plus vite
        SetEntData(randomMere, FindDataMapOffs(randomMere, "m_iMaxHealth"),20, 4, true);
        SetEntData(randomMere, FindDataMapOffs(randomMere, "m_iHealth"), 20, 4, true);
		SetEntityHealth(randomMere, 19);
        SetEntityHealth(randomMere, 20);
		
	
 
        trailMere = CreateEntityByName("env_spritetrail");
        decl String:parentName[64], Float:vPosClient[3];
        GetClientName(randomMere, parentName, sizeof( parentName ));
        Format(parentName, sizeof(parentName), "%i:%s", randomMere, parentName);
        DispatchKeyValue(randomMere, "targetname", parentName);
        DispatchKeyValue(trailMere, "parentname", "A trailMere");
        DispatchKeyValue(trailMere, "lifetime", "5");
        DispatchKeyValue(trailMere, "startwidth", "10");
        DispatchKeyValue(trailMere, "endwidth", "1");
        DispatchKeyValue(trailMere, "spritename", "materials/sprites/store/trails/8bitmushroom.vmt");
        DispatchKeyValue(trailMere, "renderamt", "200");
        DispatchKeyValue(trailMere, "rendercolor", "0 0 255");
        DispatchKeyValue(trailMere, "rendermode", "1");
        DispatchSpawn(trailMere);
        GetClientAbsOrigin(randomMere, vPosClient);
        TeleportEntity(trailMere, vPosClient, NULL_VECTOR, NULL_VECTOR);
        SetVariantString(parentName);
        AcceptEntityInput(trailMere, "SetParent");
        SetVariantString("grenade0");
        AcceptEntityInput(trailMere, "SetParentAttachmentMaintainOffset");
        SetEntityModel(randomMere, "models/player/natalya/zelda/zelda.mdl"); // on leur met le skin mere
		new CT_Team_Count1 = GetTeamClientCount(CS_TEAM_CT);
		if(CT_Team_Count1 >= 10)
		{
	
		randomPere = xArray[GetRandomInt(1, (xIncrement-1))];
		if(randomPere == randomMere)
		    {
			randomPere = xArray[GetRandomInt(1, (xIncrement-1))];
			}
		CS_SetClientClanTag(randomPere, "{Pere}");
		GivePlayerItem(randomPere, "weapon_flashbang");
        Client_SetWeaponPlayerAmmo(randomPere, "weapon_flashbang", 2);
        GivePlayerItem(randomPere, "weapon_deagle");
        Client_SetWeaponPlayerAmmo(randomPere, "weapon_deagle", 0);
        Client_SetWeaponClipAmmo(randomPere, "weapon_deagle", 3);
        SetClientThrowingKnives(randomPere, 5);
		SetEntPropFloat(randomPere, Prop_Data, "m_flLaggedMovementValue", nowspeeed);
		SetEntData(randomPere, FindDataMapOffs(randomPere, "m_iMaxHealth"),25, 4, true);
        SetEntData(randomPere, FindDataMapOffs(randomPere, "m_iHealth"), 25, 4, true);
		SetEntityHealth(randomPere, 24);
        SetEntityHealth(randomPere, 25);
        SetEntityModel(randomPere, "models/mapeadores/kaem/bahamut/bahamut.mdl");
		}
        //// ITEM DE SATAN
        GivePlayerItem(randomSatan, "weapon_flashbang");
        GivePlayerItem(randomSatan, "weapon_smokegrenade");
        GivePlayerItem(randomSatan, "weapon_deagle");
        Client_SetWeaponPlayerAmmo(randomSatan, "weapon_flashbang", 2);
        Client_SetWeaponPlayerAmmo(randomSatan, "weapon_smokegrenade", 3);
        Client_SetWeaponPlayerAmmo(randomSatan, "weapon_deagle", 0);
        Client_SetWeaponClipAmmo(randomSatan, "weapon_deagle", 5);
        SetEntityModel(randomSatan, "models/mapeadores/kaem/diablo3/diablo3.mdl"); // on lui met le satan
       
        TE_SetupBeamFollow(randomSatan, g_HaloSprite, 0, 5.0, 10.0, 10.0, 5.0, {255,0,0,255});
       
       
       
       
       
       
        //////////////////////////////////////////////////////////////////
       
       
        //////////////// MUSIC DE BACKGROUND //////////////////////////////
       
        /////////////////////////////////////////////////////////////////
       
       
        for (new clientt = 1; clientt <= MaxClients; clientt++)
        {
            if(IsClientInGame(clientt))
            {
                if(IsPlayerAlive(clientt))
                {
                    if(GetClientTeam(clientt) == 2)
                    {
                        SetEntityMoveType(clientt, MOVETYPE_WALK); // On defreeze les Demons
                        new Float:nowspeed = speeed + 0.5;
                        SetEntPropFloat(clientt, Prop_Data, "m_flLaggedMovementValue", nowspeed); // on donne la vitesse
                    }
                }
                ClientCommand(clientt, "r_screenoverlay overlays/ange_demon/demon_release_fr"); // On affiche l'overlay
            }
        }
       
        if(PrecacheSound("avd/random_grow.wav", false)) // on Precache le grognement
        {
            EmitSoundToAll("avd/random_grow.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN); // Tout le monde entend le son
        }
       
        CreateTimer(3.0, killOverlay);
        CloseHandle(roundTimer);
        isRoundStart = true;
    }
    return Plugin_Handled;
}
 
 
 
public getAliveTeam() // Compte le nombre de vivant en fonction des equipes
{
    tAlive = 0;
    cAlive = 0;
	xAlive = 0;
    aAlive = 0;
    for (new client = 1; client <= MaxClients; client++)
    {
        if(IsClientInGame(client))
        {
            if(IsPlayerAlive(client) && (GetClientTeam(client) == 2))
            {
                tAlive = tAlive+1;
            }
            if(IsPlayerAlive(client) && (GetClientTeam(client) == 3))
            {
                cAlive = cAlive+1;
				xAlive = xAlive+1;
                new String:tmpTag2[50];
                CS_GetClientClanTag(client, tmpTag2, sizeof(tmpTag2));
                if(StrEqual(tmpTag2, "{Mort}") == false && StrEqual(tmpTag2, "{Mort | Mere") == false)
                {
                    aAlive = aAlive+1;
                }
                if(StrEqual(tmpTag2, "{Mort | Mere"))
                {
                    new Float:eyePos[3];
                    GetClientAbsOrigin(client, eyePos);
                    TE_SetupBeamRingPoint(eyePos, 1.0, 700.0, g_BeamSprite, g_HaloSprite, 0, 10, 0.6, 10.0, 0.5, blueColor, 10, 0);
                    TE_SendToAll();
                }
            }
        }
    }
}
 
public Action:killOverlay(Handle:timer)
{
    for (new client = 1; client <= MaxClients; client++)
    {
        if(IsClientInGame(client))
        {
            ClientCommand(client, "r_screenoverlay 0"); // On retire l'overlay
        }
    }
   
    if(PrecacheSound("avd/avd_v2.mp3", false)) // on Precache la musique d'ambiance qui se met quand l'overlay est fini
    {
	    EmitSoundToAll("avd/avd_v2.mp3", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 0.2); // Tout le monde entend la musique // Tout le monde entend la musique
    }
   
    CloseHandle(overlayTimer);
    return Plugin_Handled;
}
 
 
public Action:theUpdate(Handle:timer) // On affiche un menu à droite avec Anges Vs Démons
{
    new String:fullsentence[240];
	getAliveTeam();
	if(isRoundStart == false && cAlive >= 1 && tAlive == 0 || isRoundStart == false && cAlive == 0 && tAlive >= 1)
    {
		Format(fullsentence, sizeof(fullsentence), "Anges [VS] Démons: Il manque un joueur dans une des deux equipes.");
    }	 
	
    if(isRoundStart == false && cAlive > 0 && tAlive > 0) // Si le round n'a pas commencé on affiche le temps avant début du round
    {
        Format(fullsentence, sizeof(fullsentence), "Anges [VS] Démons\n________________________\nDémons lachés dans %i secondes\n¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\n", roundTime-GetTime());
		for (new clientt = 1; clientt <= MaxClients; clientt++)
		{
			if(IsClientInGame(clientt))
			{
				if(IsPlayerAlive(clientt))
				{
					if(GetClientTeam(clientt) == 2)
					{
						SetEntityMoveType(clientt, MOVETYPE_NONE); 
					} 
				} 
			} 
		}
	}
    else
    {
        if(realRoundTime-GetTime() <= 0)
        {
			for (new client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client))
				{
					if(IsPlayerAlive(client))
					{
						if(GetClientTeam(client) == 2)
						{
							ForcePlayerSuicide(client);
						}
					}
				}
			}
				CS_TerminateRound(7.0, CSRoundEnd_TerroristsNotEscaped, false);
				
		}
			getAliveTeam();
			if(cAlive > 0 && tAlive > 0)
			{
				decl String:strMere[32];
				GetClientName(randomMere, strMere, sizeof(strMere));
				decl String:strSatan[32];
				GetClientName(randomSatan, strSatan, sizeof(strSatan));
				if(randomPere >= 1)
				{ 
					decl String:strPere[32];
					GetClientName(randomPere, strPere, sizeof(strPere));		 			
					Format(fullsentence, sizeof(fullsentence), "Anges [VS] Démons\n_____________\n¬ Anges vivants: %i/%i\n¬ Mère: %s (%i)\n¬ Père: %s (%i)\n¬ Satan: %s\n¯¯¯¯¯¯¯¯¯¯¯¯¯¯\n", aAlive, GetTeamClientCount(3), strMere, GetClientHealth(randomMere), strPere, GetClientHealth(randomPere), strSatan);
				}
				else if(randomPere == 0)
				{
					Format(fullsentence, sizeof(fullsentence), "Anges [VS] Démons\n_____________\n¬ Anges vivants: %i/%i\n¬ Mère: %s (%i)\n¬ Père: Aucun \n¬ Satan: %s\n¯¯¯¯¯¯¯¯¯¯¯¯¯¯\n", aAlive, GetTeamClientCount(3), strMere, GetClientHealth(randomMere), strSatan);
			    }   
		    }
	}
    
    Client_PrintKeyHintTextToAll(fullsentence);
	if(PhraseTimer-GetTime() == 170)
        {
			CPrintToChatAll("{CYAN}[New-Gaming]{honeydew}[{skyblue}Anges {honeydew}& {ancient}Demons{honeydew}]{default} \n{green}La camp du {RED}{Satan}{green} est interdite{default}.");
		}
    if(PhraseTimer-GetTime() == 155)
        {
			CPrintToChatAll("{CYAN}[New-Gaming]{honeydew}[{skyblue}Anges {honeydew}& {ancient}Demons{honeydew}]{default} \n{green}Rejoignez notre TeamSpeak{default}: {yellow}ts3.new-gaming.eu{default}");
		}
    if(PhraseTimer-GetTime() == 140)
        {
			CPrintToChatAll("{CYAN}[New-Gaming]{honeydew}[{skyblue}Anges {honeydew}& {ancient}Demons{honeydew}]{default} \n{green}La camp du {RED}{Satan}{green} est interdite{default}.");
		}
    if(PhraseTimer-GetTime() == 110)
        {
			CPrintToChatAll("{CYAN}[New-Gaming]{honeydew}[{skyblue}Anges {honeydew}& {ancient}Demons{honeydew}]{default} \n{green}Rejoignez notre TeamSpeak{default}: {yellow}ts3.new-gaming.eu{default}");
		}
    if(PhraseTimer-GetTime() == 90)
        {
			CPrintToChatAll("{CYAN}[New-Gaming]{honeydew}[{skyblue}Anges {honeydew}& {ancient}Demons{honeydew}]{default} \n{green}La camp du {RED}{Satan}{green} est interdite{default}.");
		}
    if(PhraseTimer-GetTime() == 60)
        {
			CPrintToChatAll("{CYAN}[New-Gaming]{honeydew}[{skyblue}Anges {honeydew}& {ancient}Demons{honeydew}]{default} \n{green}Merci de ne pas rester dans des endroits inaccessible aux {RED}{Démons}{default}.");
		}
    if(PhraseTimer-GetTime() == 30)
        {
			CPrintToChatAll("{CYAN}[New-Gaming]{honeydew}[{skyblue}Anges {honeydew}& {ancient}Demons{honeydew}]{default} {green}http://new-gaming.eu/sourceban{default}");
		}		
    return Plugin_Handled;
}
 
public Action:EventReset(Handle:event,const String:name[],bool:dontBroadcast) // reset les variables
{
    isRoundStart = false;
    randomSatan = 0;
    randomMere = 0;
	randomPere = 0;
    CloseHandle(updateTimer);
    CloseHandle(overlayTimer);
    CloseHandle(roundTimer);
    for (new client = 1; client <= MaxClients; client++)
    {
        cantCut[client] = false;
    }
    KillTimer(updateTimer);
    KillTimer(overlayTimer);
    KillTimer(roundTimer);
    AcceptEntityInput(trailSatan, "Kill");
    AcceptEntityInput(trailMere, "Kill");
    KillAllBeacons();
    return Plugin_Handled;
	
}
 stock bool:IsAlive(client)
{
    if(GetClientHealth(client) == 15 || GetClientHealth(client) == 20 || GetClientHealth(client) == 25)
        return true;
		else
    return false;
}