//
//	Main.qc - mostly functions that will be called from the engine and are expected to exist
//

//called when starting server/loading the map
void() main =
{
	localcmd("echo Server starting...\n");

}

//called for each frame that QC runs
void() StartFrame =
{
	deathmatch = cvar("deathmatch");
	framecount = framecount + 1;
}

//called when map loaded
void() worldspawn =
{
	precache_model("models/humanoid_simplerig.iqm");
	precache_model("models/mg_ammo.iqm");
	precache_model("models/weapons/mg/mg.iqm");
	precache_model("models/weapons/pistol/pistol.iqm");
	
	precache_sound("sounds/player/footstep1.wav");
	precache_sound("sounds/player/footstep2.wav");
	precache_sound("sounds/player/footstep3.wav");
	precache_sound("sounds/player/footstep4.wav");
	precache_sound("sounds/player/footstep5.wav");
	precache_sound("sounds/player/jump.wav");
	precache_sound("sounds/player/land.wav");
	precache_sound("sounds/items/health.wav");
	precache_sound("sounds/items/respawn.wav");
	precache_sound("sounds/weapons/mg.wav");

	clientstat(50, EV_FLOAT, ammo_mg);
	clientstat(51, EV_FLOAT, ammo_pistol);
}

void() SpectatorConnect =
{
	bprint(PRINT_HIGH, self.netname);
	bprint(PRINT_HIGH, " has joined the spectators.\n");
}

