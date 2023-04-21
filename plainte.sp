#include <sdktools>
#include "colors.inc"
#define SOUND_PLAINTE "nico/notifplainte.wav"
new g_plainte[MAXPLAYERS + 1];


public Plugin:myinfo = {
   name         = "Système de plainte",
   author         = "Steven",
   description = "Permet aux utilisateurs de se plaindre",
   version     = "1.0",
   url = "http://nsnf-clan.net"
};


public OnPluginStart()
{
   RegConsoleCmd("plainte", Cmd_plainte, "Permet aux utilisateurs de se plaindre");
}


public OnMapStart()
{
	AddFileToDownloadsTable("sound/nico/notifplainte.wav");
	PrecacheSound(SOUND_PLAINTE, true);
}


public Action:Cmd_plainte(client, args)
{
   if (args < 1)
   {
       ReplyToCommand(client, "[SM] Utilisation: /plainte <message COMPLET>");
       return Plugin_Handled;
   }
   new timestamp;
   timestamp = GetTime();

   if ((timestamp - g_plainte[client]) < 60) //Modifier le "60" par le délai souhaité pour limiter les abus ^^
   {
       ReplyToCommand(client, "[SM] Vous devez attendre %i secondes avant de refaire une plainte",( 60 - (timestamp - g_plainte[client])) );//Limiter le 60 ici aussi
       return Plugin_Handled;
   }

   g_plainte[client] = GetTime();
   new String:message[128];
   new String:user[64];

   GetCmdArgString(message, sizeof(message));
   GetClientName(client,user, sizeof(user));


   for(new i=1; i <= GetMaxClients(); i++)
   {
       if ( (IsClientInGame(i)) && GetUserFlagBits(i) & ADMFLAG_SLAY)
       {
           CPrintToChat(i,"{green} *** [PLAINTE] de {red}%s{green} :{default} %s",user,message)
           EmitSoundToClient(i, SOUND_PLAINTE);
       }
   }
   CPrintToChat(client,"{blue} *** Votre plainte a bien été envoyée, merci d'être patient...")
   return Plugin_Continue;
}