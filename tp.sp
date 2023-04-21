#include <sourcemod>
#include <smlib>
#include <morecolors>
 
 

new bool:Vue[MAXPLAYERS+1];
 
public OnPluginStart()
{
RegConsoleCmd("sm_tp", CMD_TP);
}
 
 
public Action:CMD_TP(client, args)
{
if(IsPlayerAlive(client))
{
if (Vue[client])
{
Vue[client] = false;
Client_SetThirdPersonMode(client, false);
CPrintToChat(client, "{CYAN}[Team-Family]{honeydew}[{skyblue}Mario {honeydew}vs {ancient}Bowser{honeydew}] {lime}Vous n'êtes plus en {springgreen}troisième personne {lime}!");
}
else
{
Vue[client] = true;
CPrintToChat(client, "{CYAN}[Team-Family]{honeydew}[{skyblue}Mario {honeydew}vs {ancient}Bowser{honeydew}] {lime}Vous êtes en {springgreen}troisième personne {lime}!");
Client_SetThirdPersonMode(client, true);
}
}
else
CPrintToChat(client, "{CYAN}[Team-Family]{honeydew}[{skyblue}Mario {honeydew}vs {ancient}Bowser{honeydew}] {lime}Vous devez être en {springgreen}vie {lime}!");
}