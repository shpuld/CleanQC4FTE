//
//	Player.qc - Various stuff done for the player, including per-frame functions like PlayerPreThink and PlayerPostThink, also client specific stuff like PutClientInServer etc.
//

void() PlayerJump =
{
	if (!(self.flags & FL_ONGROUND))
		return;

	if ( !(self.flags & FL_JUMPRELEASED) )
		return;
			
	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
	sound(self, CHAN_VOICE, "sounds/player/jump.wav", 1, 1.75);
	self.button2 = 0;
}

void() CheckImpulses =
{
	if(self.impulse == 1)
		SwitchWeapon(IT_PISTOL);
	else if(self.impulse == 2)
		SwitchWeapon(IT_MG);
	
	self.impulse = 0;
}

void() PlayerPreThink =
{
	if(self.isspec != 0)
	{
		if(self.button0 && time > self.ready)
		{
			self.aiment = find(self.aiment, classname, "player");
			if(self.aiment != world)
			{
				sprint(self, PRINT_HIGH, "Now spectating ");
				sprint(self, PRINT_HIGH, self.aiment.netname);
				sprint(self, PRINT_HIGH, "\n");
				
				self.solid = SOLID_NOT;
				self.movetype = MOVETYPE_NONE;
			}
			else
			{
				sprint(self, PRINT_HIGH, "Freefly spectate\n");
				self.movetype = MOVETYPE_FLY;
			}
			self.ready = time + 0.5;
		}
		if(self.aiment != world)
		{
			self.origin = self.aiment.origin;
			self.angles = self.aiment.v_angle;
			self.velocity = self.aiment.velocity;
			self.fixangle = TRUE;
		}
		return;
	}
	
	CheckImpulses();
	
	if(self.button0)
	{
		FireWeapon();
	}
	else
	{
		if(time > self.ready)
		{
			self.readystate = READY;
		}
		else if(self.readystate == FIRING_SEMI)
		{
			self.readystate = FIRING;
		}
	}
	if(self.button2)
	{
		PlayerJump ();
	}
	else
		self.flags = self.flags | FL_JUMPRELEASED;
};

void() PlayerPostThink =
{
	if(self.isspec)
		return;
	
	//landsound
	if((self.oldvelocity_z < -10) && (self.flags & FL_ONGROUND))
	{
		if(self.oldvelocity_z < -270)
			sound(self, CHAN_BODY, "sounds/player/land.wav", 1, 1.75);
		self.lastsound_time = time - 0.15;
	}
	
	//footsteps
	if((vlen(self.velocity) > 315) &&( time - self.lastsound_time > 0.3) && (self.flags & FL_ONGROUND))
	{
		local float movelen = vlen(input_movevalues);
		if(movelen > 300)
		{
			local float ran = random();
			if(ran > 0.8)
				sound(self, CHAN_BODY, "sounds/player/footstep1.wav", 0.6, 2.5);
			else if(ran > 0.6)
				sound(self, CHAN_BODY, "sounds/player/footstep2.wav", 0.6, 2.5);
			else if(ran > 0.4)
				sound(self, CHAN_BODY, "sounds/player/footstep3.wav", 0.6, 2.5);
			else if(ran > 0.2)
				sound(self, CHAN_BODY, "sounds/player/footstep4.wav", 0.6, 2.5);
			else
				sound(self, CHAN_BODY, "sounds/player/footstep5.wav", 0.6, 2.5);
			self.lastsound_time = time;
		}
	}
	
	self.oldvelocity = self.velocity;
};

void() ClientKill =
{
};

//called when a client connects to the server
void() ClientConnect =
{
	bprint(PRINT_HIGH, self.netname); //print player name
	bprint(PRINT_HIGH, " connected.\n");
};

void() PlayerSpawn =
{
	local entity spawnpoint;
	spawnpoint = find(world, classname, "info_player_start");
	
	self.isspec = FALSE;
	self.classname = "player";
	self.solid = SOLID_SLIDEBOX;
	setmodel(self, "models/humanoid_simplerig.iqm");
	self.movetype = MOVETYPE_WALK;
	self.health = 100;
	self.origin = spawnpoint.origin + [0,0,1];
	self.fixangle = TRUE;
	setsize(self, [-16, -16, -24], [16, 16, 32]);
	self.view_ofs = '0 0 22';
	self.ammo_pistol = 50;
	self.items = IT_PISTOL;
	self.ready = 0;
	self.readystate = READY;
	SwitchWeapon(IT_PISTOL);
	stuffcmd(self, "cl_gunx 8;cl_guny 16;cl_gunz 25\n");
};

void() SpectatorSpawn =
{
	local entity spawnpoint;
	spawnpoint = find(world, classname, "info_player_start");
	
	self.isspec = TRUE;
	self.classname = "spectator";
	self.solid = SOLID_NOT;
	setmodel(self, "");
	self.movetype = MOVETYPE_FLY;
	self.origin = spawnpoint.origin + [0,0,1];
	self.fixangle = TRUE;
	setsize(self, [-16, -16, -24], [16, 16, 32]);
	self.view_ofs = '0 0 22';
	self.aiment = world;
};

//called when a client loads a map
void() PutClientInServer =
{
	stuffcmd(self, "promptjoin\n");
	SpectatorSpawn();
};

//called when client disconnects from the server
void() ClientDisconnect =
{
	bprint(PRINT_HIGH, self.netname);
	bprint(PRINT_HIGH, " has left the game.\n");
	remove(self);
};


void() SetNewParms =
{
};

void() SetChangeParms =
{
};

void() info_player_start =
{
	
};

void(string com) SV_ParseClientCommand =
{
	if(com == "joingame")
	{
		if(self.isspec)
		{
			bprint(PRINT_HIGH, self.netname);
			bprint(PRINT_HIGH, " has joined the game.\n");
			PlayerSpawn();
		}
		else
			sprint(self, PRINT_HIGH, "You're already in game!\n");
	}
	else if(com == "specgame")
	{
		if(self.isspec)
			return;
		else
		{
			SpectatorSpawn();
			bprint(PRINT_HIGH, self.netname); //print player name
			bprint(PRINT_HIGH, " has joined the spectators.\n");
		}
	}
};

void() SV_RunClientCommand =
{
	runstandardplayerphysics(self);
}