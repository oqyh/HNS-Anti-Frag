#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
#include <cstrike>
#include <multicolors>

ConVar h_enable_plugin;
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

Handle g_bTimer[MAXPLAYERS + 1] =  { null, ... };

bool h_benable_plugin = false;
bool g_btransparent = false;
bool g_bnotify = false;
bool g_bnotify2 = false;

float h_fknife_damage;
float h_bcooldown;

int g_bctransparent;
int g_bcbodyR;
int g_bcbodyG;
int g_bcbodyB;

public Plugin myinfo =
{
	name = "[HNS] Anti-Frag",
	author = "Gold KingZ ",
	description = "Modify Knife Damage + Cooldown From Stabbing T's",
	version = "1.0.0",
	url = "https://github.com/oqyh"
}

public void OnPluginStart()
{
	LoadTranslations( "HNS-Anti-Frag.phrases" );
	
	h_enable_plugin = CreateConVar("hns_f_enable_plugin", "1", "Enable Anti-Frag Plugin || 1= Yes || 0= No", _, true, 0.0, true, 1.0);
	h_knife_damage = CreateConVar("hns_f_knife_damage", "59.0", "How Much Knife Damage To T's || [Default 59 = 50 HP] ");
	h_cooldown = CreateConVar("hns_f_knife_cooldown", "5.0", "(in sec) Cooldown Between Knife Stabs");
	g_transparent = CreateConVar("hns_f_enable_transparent", "0", "Enable Transparent After Damage || 1= Yes || 0= No", _, true, 0.0, true, 1.0);
	g_ctransparent = CreateConVar("hns_f_transparent", "120", "How Much Transparent After Hit || 0= Invisible || 120= Transparent || 255=None");
	g_cbodyR = CreateConVar("hns_f_color_r", "255", "Body Red Code Color Pick Here https://www.rapidtables.com/web/color/RGB_Color.html");
	g_cbodyG = CreateConVar("hns_f_color_g", "0", "Body Green Code Color  Pick Here https://www.rapidtables.com/web/color/RGB_Color.html");
	g_cbodyB = CreateConVar("hns_f_color_b", "0", "Body Blue Code Color  Pick Here https://www.rapidtables.com/web/color/RGB_Color.html");
	g_notify = CreateConVar("hns_f_enable_notify_ct", "1", "Enable Notification Message Chat After Damage For Attacker (CT) || 1= Yes || 0= No", _, true, 0.0, true, 1.0);
	g_notify2 = CreateConVar("hns_f_enable_notify_t", "0", "Enable Notification Message Chat After Damage For Victim (T) || 1= Yes || 0= No", _, true, 0.0, true, 1.0);
	
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
	
	for (int i = 1; i < MaxClients; ++i)
	{
		if (IsClientInGame(i))
		{
			SDKHook(i, SDKHook_OnTakeDamage, OneHitDamage);
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
	g_bnotify = GetConVarBool(g_notify);
	g_bnotify2 = GetConVarBool(g_notify2);
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
		g_bnotify = g_notify.BoolValue;
	}
	
	if(convar == g_notify2)
	{
		g_bnotify2 = g_notify2.BoolValue;
	}
	return 0;
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OneHitDamage);
}

public Action OneHitDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (!attacker || attacker > MaxClients || !IsClientInGame(attacker) || !h_benable_plugin)
    {
        return Plugin_Continue;
    }

	if(g_bTimer[victim] != null)
	return Plugin_Handled;
	
	char weapon[64];
	GetClientWeapon(attacker, weapon, sizeof(weapon));
	if(StrContains(weapon, "weapon_knife", false) != -1 && GetClientTeam(attacker) == CS_TEAM_CT && GetClientTeam(victim) == CS_TEAM_T)
	{

		damage = h_fknife_damage;

		float cooldown = h_bcooldown;
		
		if(g_bnotify)
		{
			CPrintToChat(attacker, " %t %t", "Tag", "CooldownCT", cooldown);
			
		}
		
		if(g_bnotify2)
		{
			CPrintToChat(victim, " %t %t", "Tag", "CooldownT", cooldown);
		}
		
		g_bTimer[victim] = CreateTimer(cooldown, Time_Disable, victim);

		if(g_btransparent){
		SetEntityRenderMode(victim, RENDER_TRANSALPHA);
		SetEntityRenderColor(victim, g_bcbodyR, g_bcbodyG, g_bcbodyB, g_bctransparent);
		}else if(!g_btransparent){
		SetEntityRenderMode(victim, RENDER_TRANSALPHA);
		SetEntityRenderColor(victim, g_bcbodyR, g_bcbodyG, g_bcbodyB, 255);
		}
		
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

public Action Time_Disable(Handle timer, any client)
{
	if(IsValidClient(client))
	{
	g_bTimer[client] = null;
	SetEntityRenderMode(client, RENDER_NORMAL);
	SetEntityRenderColor(client, 255, 255, 255, 255);
	}
	return Plugin_Stop;
}

static bool IsValidClient( int client ) 
{
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) 
        return false; 
     
    return true; 
} 