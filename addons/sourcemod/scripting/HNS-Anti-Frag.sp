#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
#include <cstrike>
#include <multicolors>

#define PLUGIN_VERSION	"1.0.1"

ConVar h_enable_plugin;
ConVar h_e_cooldown_all;
ConVar h_knife_damage;
ConVar g_transparent;
ConVar g_ctransparent;
ConVar g_cbodyR;
ConVar g_cbodyG;
ConVar g_cbodyB;
ConVar g_notify;
ConVar g_notify2;
ConVar h_cooldown;
ConVar gcv_force = null;

Handle g_bTimer[MAXPLAYERS + 1];
Handle g_bTimer2[MAXPLAYERS + 1];

bool RoundEnd;
bool h_benable_plugin = false;
bool g_btransparent = false;
bool g_bLateLoaded = false;
float h_fknife_damage;
float h_bcooldown;

int GetHealth[MAXPLAYERS + 1];

int g_bctransparent;
int g_bcbodyR;
int g_bcbodyG;
int g_bcbodyB;
int g_bnotify = 0;
int g_bnotify2 = 0;
int h_be_cooldown_all = 0;

public Plugin myinfo =
{
	name = "[HNS] Anti Frag",
	author = "Gold KingZ ",
	description = "Modify Knife Damage + Cooldown From Stabbing T's",
	version = PLUGIN_VERSION,
	url = "https://github.com/oqyh"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int length)
{
	g_bLateLoaded = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	LoadTranslations( "HNS-Anti-Frag.phrases" );
	
	CreateConVar("hns_f_version", PLUGIN_VERSION, "[HNS] Anti Frag Plugin Version", FCVAR_NOTIFY|FCVAR_DONTRECORD);

	h_enable_plugin = CreateConVar("hns_f_enable_plugin", "1", "Enable Anti-Frag Plugin\n1= Yes\n0= No", _, true, 0.0, true, 1.0);
	h_knife_damage = CreateConVar("hns_f_knife_damage", "50.0", "How Much Knife Damage To T's\nDefault: 50 HP");
	h_cooldown = CreateConVar("hns_f_knife_cooldown", "5.0", "(in sec) Cooldown Between Knife Stabs");
	h_e_cooldown_all = CreateConVar("hns_f_ct_cooldown", "1", "How Would You Like Cooldown Will Be For Attacker (CT)\n2= Give Attacker (CT) Cooldown From Stabbing To All T's\n1= Give Victim (T) Who Got Stabbed God Mode(Cooldown From Getting Stabbed) \n0= No (Disable Cooldown)", _, true, 0.0, true, 2.0);
	g_transparent = CreateConVar("hns_f_enable_transparent", "0", "Enable Transparent After Damage\n1= Yes\n0= No", _, true, 0.0, true, 1.0);
	g_ctransparent = CreateConVar("hns_f_transparent", "120", "How Much Transparent After Hit\n0= Invisible\n120= Transparent\n255=None");
	g_cbodyR = CreateConVar("hns_f_color_r", "255", "Body Red Code Color Pick Here https://www.rapidtables.com/web/color/RGB_Color.html");
	g_cbodyG = CreateConVar("hns_f_color_g", "0", "Body Green Code Color  Pick Here https://www.rapidtables.com/web/color/RGB_Color.html");
	g_cbodyB = CreateConVar("hns_f_color_b", "0", "Body Blue Code Color  Pick Here https://www.rapidtables.com/web/color/RGB_Color.html");
	g_notify = CreateConVar("hns_f_notify", "1", "Enable Notification Message Chat After Damage For\n3= Both Attacker (CT) And Victim (T)\n2= Victim (T)\n1= Attacker (CT)\n0= No Disable Notify Message", _, true, 0.0, true, 3.0);
	g_notify2 = CreateConVar("hns_f_notify_annoc", "0", "Do You Like The Notification Message To Be Announced To All Players About Who Got Stabbed+Killed\n2= Yes With Hp Left\n1= Yes\n0= No Disable Announcer", _, true, 0.0, true, 2.0);	
	gcv_force = FindConVar("sv_disable_immunity_alpha");
	gcv_force.AddChangeHook(Onchanged);
	
	HookConVarChange(h_enable_plugin, OnSettingsChanged);
	HookConVarChange(h_knife_damage, OnSettingsChanged);
	HookConVarChange(h_cooldown, OnSettingsChanged);
	HookConVarChange(g_transparent, OnSettingsChanged);
	HookConVarChange(g_ctransparent, OnSettingsChanged);
	HookConVarChange(g_cbodyR, OnSettingsChanged);
	HookConVarChange(g_cbodyG, OnSettingsChanged);
	HookConVarChange(g_cbodyB, OnSettingsChanged);
	HookConVarChange(g_notify, OnSettingsChanged);
	HookConVarChange(g_notify2, OnSettingsChanged);
	HookConVarChange(h_e_cooldown_all, OnSettingsChanged);
	
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_death", Event_player_death);
	
	if (g_bLateLoaded) 
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i)) 
			{
				OnClientPutInServer(i);
			}
		}
	}
	
	AutoExecConfig(true, "HNS-Anti-Frag");
}

public void Onchanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if(g_btransparent == true)
	{
		if(StrEqual (newValue, "0")){
		gcv_force.BoolValue = true;
		}
	}
}

public void OnConfigsExecuted()
{
	h_benable_plugin = GetConVarBool(h_enable_plugin);
	h_fknife_damage = GetConVarFloat(h_knife_damage);
	h_bcooldown = GetConVarFloat(h_cooldown);
	g_btransparent = GetConVarBool(g_transparent);
	g_bctransparent = GetConVarInt(g_ctransparent);
	g_bcbodyR = GetConVarInt(g_cbodyR);
	g_bcbodyG = GetConVarInt(g_cbodyG);
	g_bcbodyB = GetConVarInt(g_cbodyB);
	g_bnotify = GetConVarInt(g_notify);
	g_bnotify2 = GetConVarInt(g_notify2);
	h_be_cooldown_all = GetConVarInt(h_e_cooldown_all);
}

public int OnSettingsChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == h_enable_plugin)
	{
		h_benable_plugin = h_enable_plugin.BoolValue;
	}
	
	if(convar == h_knife_damage)
	{
		h_fknife_damage = h_knife_damage.FloatValue;
	}
	
	if(convar == h_cooldown)
	{
		h_bcooldown = h_cooldown.FloatValue;
	}
	
	if(convar == g_transparent)
	{
		ServerCommand("sv_disable_immunity_alpha 1");
		g_btransparent = g_transparent.BoolValue;
	}
	
	if(convar == g_ctransparent)
	{
		g_bctransparent = g_ctransparent.IntValue;
	}
	
	if(convar == g_cbodyR)
	{
		g_bcbodyR = g_cbodyR.IntValue;
	}
	
	if(convar == g_cbodyG)
	{
		g_bcbodyG = g_cbodyG.IntValue;
	}
	
	if(convar == g_cbodyB)
	{
		g_bcbodyB = g_cbodyB.IntValue;
	}
	
	if(convar == g_notify)
	{
		g_bnotify = g_notify.IntValue;
	}
	
	if(convar == g_notify2)
	{
		g_bnotify2 = g_notify2.IntValue;
	}
	
	if(convar == h_e_cooldown_all)
	{
		h_be_cooldown_all = h_e_cooldown_all.IntValue;
	}
	
	return 0;
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OneHitDamage);
}

public void OnClientDisconnect(int client)
{
	SetEntityRenderMode(client, RENDER_NORMAL);
	SetEntityRenderColor(client, 255, 255, 255, 255);
	
	if (g_bTimer[client] != INVALID_HANDLE)
	{
		delete g_bTimer[client];
	}
	
	if (g_bTimer2[client] != INVALID_HANDLE)
	{
		delete g_bTimer2[client];
	}
}
public Action Event_player_death(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(IsValidClient(client))
	{
		SetEntityRenderMode(client, RENDER_NORMAL);
		SetEntityRenderColor(client, 255, 255, 255, 255);
		
		if (g_bTimer[client] != INVALID_HANDLE)
		{
			delete g_bTimer[client];
		}
		
		if (g_bTimer2[client] != INVALID_HANDLE)
		{
			delete g_bTimer2[client];
		}
	}
	return Plugin_Continue;
}
public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{	
	RoundEnd = true;

	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i))
		{
			SetEntityRenderMode(i, RENDER_NORMAL);
			SetEntityRenderColor(i, 255, 255, 255, 255);
			
			if (g_bTimer[i] != INVALID_HANDLE)
			{
				delete g_bTimer[i];
			}
			
			if (g_bTimer2[i] != INVALID_HANDLE)
			{
				delete g_bTimer2[i];
			}
			
		}
	}
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	RoundEnd = false;
}

public Action OneHitDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (!h_benable_plugin || !IsValidClient(victim) || !IsValidClient(attacker))
    {
        return Plugin_Continue;
    }
	
	if(g_bTimer[victim] != INVALID_HANDLE || g_bTimer2[attacker] != INVALID_HANDLE)
	return Plugin_Handled;
	
	if(IsValidClient(victim) && IsValidClient(attacker))
	{	
		char weapon[64];
		GetClientWeapon(attacker, weapon, sizeof(weapon));
		if(StrContains(weapon, "weapon_knife", false) != -1 && GetClientTeam(attacker) == CS_TEAM_CT && GetClientTeam(victim) == CS_TEAM_T && RoundEnd == false)
		{
			if(h_fknife_damage <= 5.0)
			{
				damage = h_fknife_damage + 1.0;
				GetHealth[victim] = GetClientHealth(victim) - RoundToFloor(damage) + 1;
			}else if(h_fknife_damage <= 11.0)
			{
				damage = h_fknife_damage + 2.0;
				GetHealth[victim] = GetClientHealth(victim) - RoundToFloor(damage) + 2;
			}else if(h_fknife_damage <= 17.0) 
			{
				damage = h_fknife_damage + 3.0;
				GetHealth[victim] = GetClientHealth(victim) - RoundToFloor(damage) + 3;
			}else if(h_fknife_damage <= 22.0) 
			{
				damage = h_fknife_damage + 4.0;
				GetHealth[victim] = GetClientHealth(victim) - RoundToFloor(damage) + 4;
			}else if(h_fknife_damage <= 27.0) 
			{
				damage = h_fknife_damage + 5.0;
				GetHealth[victim] = GetClientHealth(victim) - RoundToFloor(damage) + 5;
			}else if(h_fknife_damage <= 32.0) 
			{
				damage = h_fknife_damage + 6.0;
				GetHealth[victim] = GetClientHealth(victim) - RoundToFloor(damage) + 6;
			}else if(h_fknife_damage <= 38.0) 
			{
				damage = h_fknife_damage + 7.0;
				GetHealth[victim] = GetClientHealth(victim) - RoundToFloor(damage) + 7;
			}else if(h_fknife_damage <= 44.0) 
			{
				damage = h_fknife_damage + 8.0;
				GetHealth[victim] = GetClientHealth(victim) - RoundToFloor(damage) + 8;
			}else if(h_fknife_damage <= 50.0)
			{
				damage = h_fknife_damage + 9.0;
				GetHealth[victim] = GetClientHealth(victim) - RoundToFloor(damage) + 9;
			}else if(h_fknife_damage <= 56.0)
			{
				damage = h_fknife_damage + 10.0;
				GetHealth[victim] = GetClientHealth(victim) - RoundToFloor(damage) + 10;
			}else if(h_fknife_damage <= 62.0)
			{
				damage = h_fknife_damage + 11.0;
				GetHealth[victim] = GetClientHealth(victim) - RoundToFloor(damage) + 11;
			}else if(h_fknife_damage <= 68.0)
			{
				damage = h_fknife_damage + 12.0;
				GetHealth[victim] = GetClientHealth(victim) - RoundToFloor(damage) + 12;
			}else if(h_fknife_damage <= 73.0)
			{
				damage = h_fknife_damage + 13.0;
				GetHealth[victim] = GetClientHealth(victim) - RoundToFloor(damage) + 13;
			}else if(h_fknife_damage <= 78.0)
			{
				damage = h_fknife_damage + 14.0;
				GetHealth[victim] = GetClientHealth(victim) - RoundToFloor(damage) + 14;
			}else if(h_fknife_damage <= 84.0)
			{
				damage = h_fknife_damage + 15.0;
				GetHealth[victim] = GetClientHealth(victim) - RoundToFloor(damage) + 15;
			}else if(h_fknife_damage <= 90.0)
			{
				damage = h_fknife_damage + 16.0;
				GetHealth[victim] = GetClientHealth(victim) - RoundToFloor(damage) + 16;
			}else if(h_fknife_damage <= 96.0)
			{
				damage = h_fknife_damage + 17.0;
				GetHealth[victim] = GetClientHealth(victim) - RoundToFloor(damage) + 17;
			}else if(h_fknife_damage <= 102.0)
			{
				damage = h_fknife_damage + 18.0;
				GetHealth[victim] = GetClientHealth(victim) - RoundToFloor(damage) + 18;
			}

			float cooldown = h_bcooldown;
			
			if(g_bnotify == 1)
			{
				if(h_be_cooldown_all == 1)
				{
					CPrintToChat(attacker, " %t","CooldownCTNotify", cooldown, victim);
				}else if(h_be_cooldown_all == 2)
				{
					CPrintToChat(attacker, " %t","CooldownCTNotifyTeamT", cooldown);
				}
			}else if(g_bnotify == 2)
			{
				if(h_be_cooldown_all == 1 || h_be_cooldown_all == 2)
				{
					CPrintToChat(victim, " %t", "CooldownTNotify", cooldown);
				}
			}else if(g_bnotify == 3)
			{
				if(h_be_cooldown_all == 1)
				{
					CPrintToChat(victim, " %t", "CooldownTNotify", cooldown);
					CPrintToChat(attacker, " %t","CooldownCTNotify", cooldown, victim);
				}else if(h_be_cooldown_all == 2)
				{
					CPrintToChat(victim, " %t", "CooldownTNotify", cooldown);
					CPrintToChat(attacker, " %t","CooldownCTNotifyTeamT", cooldown);
				}
			}
			
			if(g_bnotify2 == 1)
			{
				if(GetHealth[victim] >= 1)
				{
					CPrintToChatAll(" %t","CooldownCTAnnouncedWithoutHP", attacker, victim);
				}else
				{
					CPrintToChatAll(" %t","CooldownCTAnnouncedWithoutHPDead", attacker, victim);
				}
			}else if(g_bnotify2 == 2)
			{
				if(GetHealth[victim] >= 1)
				{
					CPrintToChatAll(" %t","CooldownCTAnnouncedWithHP", attacker, victim, GetHealth[victim]);
				}else
				{
					CPrintToChatAll(" %t","CooldownCTAnnouncedWithHPDead", attacker, victim);
				}
			}
			
			if(h_be_cooldown_all == 1)
			{
				g_bTimer[victim] = CreateTimer(cooldown, Time_Disable, victim);
			}else if(h_be_cooldown_all == 2)
			{
				g_bTimer2[attacker] = CreateTimer(cooldown, Time_Disable2, attacker);
				g_bTimer[victim] = CreateTimer(cooldown, Time_Disable, victim);
			}
			
			if(g_btransparent && h_be_cooldown_all == 2 || g_btransparent && h_be_cooldown_all == 1){
			SetEntityRenderMode(victim, RENDER_TRANSALPHA);
			SetEntityRenderColor(victim, g_bcbodyR, g_bcbodyG, g_bcbodyB, g_bctransparent);
			}else if(!g_btransparent){
			SetEntityRenderMode(victim, RENDER_TRANSALPHA);
			SetEntityRenderColor(victim, g_bcbodyR, g_bcbodyG, g_bcbodyB, 255);
			}
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}


public Action Time_Disable2(Handle timer, any attacker)
{
	if(IsValidClient(attacker))
	{
		if (g_bTimer2[attacker] != INVALID_HANDLE)
		{
			g_bTimer2[attacker] = INVALID_HANDLE;
			delete g_bTimer2[attacker];
		}
	}
	return Plugin_Continue;
}

public Action Time_Disable(Handle timer, any victim)
{
	if(IsValidClient(victim))
	{
		SetEntityRenderMode(victim, RENDER_NORMAL);
		SetEntityRenderColor(victim, 255, 255, 255, 255);
		if (g_bTimer[victim] != INVALID_HANDLE)
		{
			g_bTimer[victim] = INVALID_HANDLE;
			delete g_bTimer[victim];
		}
	}
	return Plugin_Continue;
}

static bool IsValidClient( int client ) 
{
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client)) 
        return false; 
     
    return true; 
}