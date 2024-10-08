/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <nvault>
#include <hamsandwich>
#include <fakemeta>

#define PLUGIN "Stats All The Time"
#define VERSION "1.0"
#define AUTHOR "DarkGL"

#define OFFSET_CSDEATHS 444 

new bool:bFirst[33];
new nvault;
new pcvar_typ
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	pcvar_typ = register_cvar("stats_save_typ","1") // 1 - nick 2 - steam id
	
	nvault = nvault_open("StatsAllTheTime")
	
	RegisterHam(Ham_Spawn,"player","spawned",1)
	
	register_event("DeathMsg", "DeathMsg", "a")
	
	register_event("TextMsg","autostartrr","a","2&#Game_C"); 
	
}

public spawned(id){
	if(!is_user_alive(id) || !bFirst[id]){
		return HAM_IGNORED;
	}
	
	wczytaj_i_ustaw(id);
	
	bFirst[id] = false;
	
	return HAM_IGNORED;
}

public wczytaj_i_ustaw(id){
	new key[64],data[128]
	switch(get_pcvar_num(pcvar_typ)){
		case 1:
		{
			get_user_name(id,key,63);
		}
		case 2:
		{
			get_user_authid(id,key,63);
		}
	}
	nvault_get(nvault,key,data,127);
	new fragi[64],dedy[64];
	replace_all(data, 127, "#", " ");
	parse(data,fragi,63,dedy,63);
	
	fm_set_user_frags(id,str_to_num(fragi));
	
	fm_set_user_death(id,str_to_num(dedy))
}

public zapisz(id){
	new key[64],data[128]
	switch(get_pcvar_num(pcvar_typ)){
		case 1:
		{
			get_user_name(id,key,63);
		}
		case 2:
		{
			get_user_authid(id,key,63);
		}
	}
	format(data,charsmax(data),"%i#%i",get_user_frags(id),get_user_deaths(id));
	nvault_set(nvault,key,data)
}

public client_connect(id){
	bFirst[id] = true;
}

public DeathMsg()
{
	new kid = read_data(1)	//zabojca
	
	zapisz(kid);
	
}

public autostartrr(id){
	for(new i = 0;i<33;i++){
		bFirst[i] = true;
	}
}

stock fm_set_user_death ( const id, const i_NewDeaths )
{
    set_pdata_int ( id, OFFSET_CSDEATHS, i_NewDeaths );
    
    static i_MsgScoreInfo; 
    if ( !i_MsgScoreInfo ) i_MsgScoreInfo = get_user_msgid ( "ScoreInfo" );
    
    message_begin ( MSG_ALL, i_MsgScoreInfo );
    write_byte ( id );
    write_short ( get_user_frags ( id ) ); 
    write_short ( i_NewDeaths );
    write_short ( 0 );
    write_short ( get_user_team ( id ) );
    message_end ();
}

stock fm_set_user_frags(index, frags) {
	set_pev(index, pev_frags, float(frags));

	return 1;
}
