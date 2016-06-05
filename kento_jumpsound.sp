#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdktools_sound>
#include <sdkhooks>

#include <emitsoundany>

new Handle:JUMPALL = INVALID_HANDLE;

new Handle:JUMPT = INVALID_HANDLE;
new Handle:JUMPCT = INVALID_HANDLE;

#define TR 2
#define CT 3

public Plugin:myinfo =
{
	name = "[CS:GO] Jump Sound",
	author = "Kento",
//	Kento Is Handsome???
	version = "1.1",
	description = "Play A Sound When Player Jump",
	url = ""
};

enum JUMPTCharacteristics
{
	String:Sound[512],
	Float:Size
};
new JUMPTFILE[JUMPTCharacteristics];

enum JUMPCTCharacteristics
{
	String:Sound[512],
	Float:Size
};
new JUMPCTFILE[JUMPTCharacteristics];

public OnPluginStart()
{
	HookEvent("player_jump", OnPlayerJump);
	
	JUMPALL = CreateConVar("sm_jumpsound_all", "0", "Play Sound To All Player Or Not");
		
	JUMPT = CreateConVar("sm_jumpsound_t", "ccc.mp3", "T Jump Sound");
	JUMPCT = CreateConVar("sm_jumpsound_ct", "ccc.mp3", "CT Jump Sound");
	
	HookConVarChange(JUMPT, ConvarChange_JUMP);
	HookConVarChange(JUMPCT, ConvarChange_JUMP);
	
	AutoExecConfig(true, "kento_jumpsound");
}

public OnMapStart()
{
	GetConVarString(JUMPT, JUMPTFILE[Sound], 512);
	GetConVarString(JUMPCT, JUMPCTFILE[Sound], 512);
	
	new String:FullJUMPTFILE[PLATFORM_MAX_PATH];
	Format(FullJUMPTFILE,sizeof(FullJUMPTFILE),"sound/%s",JUMPTFILE[Sound]);
	AddFileToDownloadsTable(JUMPTFILE[Sound]);
	
	new String:FullJUMPCTFILE[PLATFORM_MAX_PATH];
	Format(FullJUMPCTFILE,sizeof(FullJUMPCTFILE),"sound/%s",JUMPCTFILE[Sound]);
	AddFileToDownloadsTable(JUMPCTFILE[Sound]);
	
	PrecacheSoundAny(JUMPTFILE[Sound]);
	PrecacheSoundAny(JUMPCTFILE[Sound]);
	
	PrecacheSound2(JUMPTFILE[Sound]);
	PrecacheSound2(JUMPCTFILE[Sound]);
}

public ConvarChange_JUMP(Handle:cvar, const String:oldVal[], const String:newVal[]) 
{
	GetConVarString(JUMPT, JUMPTFILE[Sound], 512);
	GetConVarString(JUMPCT, JUMPCTFILE[Sound], 512);
	
	if(!StrEqual(JUMPTFILE[Sound], "")) 
		PrecacheSoundAny(JUMPTFILE[Sound], false);
	
	else if(!StrEqual(JUMPCTFILE[Sound], "")) 
		PrecacheSoundAny(JUMPCTFILE[Sound], false);
}

public OnConfigsExecuted()
{
	GetConVarString(JUMPT, JUMPTFILE[Sound], 512);
	GetConVarString(JUMPCT, JUMPCTFILE[Sound], 512);
	
	if(!StrEqual(JUMPTFILE[Sound], "")) 
		PrecacheSoundAny(JUMPTFILE[Sound], false);
	
	else if(!StrEqual(JUMPCTFILE[Sound], "")) 
		PrecacheSoundAny(JUMPCTFILE[Sound], false);
}

public Action OnPlayerJump(Handle:event, const String:name[], bool:dontBroadcast)
{
	new Client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (GetClientTeam(Client) == TR)
	{
		if (GetConVarInt(JUMPALL) == 1)
		{
			EmitSoundToAllAny(JUMPTFILE[Sound]); 		
			return Plugin_Handled;
		}
		
		else if (GetConVarInt(JUMPALL) == 0)
		{
			EmitSoundToClientAny(Client, JUMPTFILE[Sound]); 		
			return Plugin_Handled;
		}
	}
	else if (GetClientTeam(Client) == CT)
	{
		if (GetConVarInt(JUMPALL) == 1)
		{
			EmitSoundToAllAny(JUMPCTFILE[Sound]);
			return Plugin_Handled;
		}
		
		else if (GetConVarInt(JUMPALL) == 0)
		{
			EmitSoundToClientAny(Client, JUMPCTFILE[Sound]); 		
			return Plugin_Handled;
		}
	}
	return Plugin_Handled;
}

//https://wiki.alliedmods.net/CSGO_Quirks#Workarounds
stock PrecacheSound2( const String:szPath[] ){
	new String:Path[256];
	Format(Path,sizeof(Path),"*/%s",szPath);
	AddToStringTable(FindStringTable("soundprecache"), Path);
}