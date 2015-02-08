
void(float to) SwitchWeapon =
{
	if(self.weapon == to)
		return;
	if(time < self.ready && self.readystate != SWITCHING)
		return;
	if(!(self.items & to))
	{
		sprint(self, PRINT_HIGH, "No weapon.\n");
		return;
	}
		
	self.ready = time + 0.150;
	self.readystate = SWITCHING;
	
	sound(self, CHAN_BODY, "sounds/player/land.wav", 1, 1.75);
	
	self.weapon = to;
	
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EVENT_WEAPONCHANGE);
	WriteByte(MSG_MULTICAST, to);
	msg_entity = self;
	multicast('0 0 0', MULTICAST_ONE);
	
}

void() FirePistol =
{
	if(self.ammo_pistol <= 0)
	{
		return;
	}
	//local float damage;
	local vector vorg, dir;
	makevectors(self.v_angle);
	dir = v_forward + (v_right * (random() - 0.5)*0.005) + (v_up * (random() - 0.5)*0.005); 
	vorg = self.origin + '0 0 22';
	traceline(vorg, vorg + dir * 16000, FALSE, self);
	msg_entity = self;
	
	//write some stuff for CSQC that is handled in CSQC_Parse_Event
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EVENT_PISTOLFIRE);
	WriteEntity(MSG_MULTICAST, self);
	WriteCoord(MSG_MULTICAST, trace_endpos_x);
	WriteCoord(MSG_MULTICAST, trace_endpos_y);
	WriteCoord(MSG_MULTICAST, trace_endpos_z);
	WriteCoord(MSG_MULTICAST, trace_plane_normal_x);
	WriteCoord(MSG_MULTICAST, trace_plane_normal_y);
	WriteCoord(MSG_MULTICAST, trace_plane_normal_z);
	WriteEntity(MSG_MULTICAST, trace_ent);
	multicast(trace_endpos, MULTICAST_PHS);
	
	sound(self, CHAN_WEAPON, "sounds/weapons/mg.wav", 1, 0.4, 100 + (random() - 0.5) * 5);
	self.ready = time + 0.15;
	self.readystate = FIRING_SEMI;
	self.ammo_pistol -= 1;
}

void() FireMG =
{
	if(self.ammo_mg <= 0)
	{
		return;
	}
	//local float damage;
	local vector vorg, dir;
	makevectors(self.v_angle);
	dir = v_forward + (v_right * (random() - 0.5)*0.025) + (v_up * (random() - 0.5)*0.025); 
	vorg = self.origin + '0 0 22';
	traceline(vorg, vorg + dir * 16000, FALSE, self);
	msg_entity = self;
	
	//write some stuff for CSQC that is handled in CSQC_Parse_Event
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EVENT_MGFIRE);
	WriteEntity(MSG_MULTICAST, self);
	WriteCoord(MSG_MULTICAST, trace_endpos_x);
	WriteCoord(MSG_MULTICAST, trace_endpos_y);
	WriteCoord(MSG_MULTICAST, trace_endpos_z);
	WriteCoord(MSG_MULTICAST, trace_plane_normal_x);
	WriteCoord(MSG_MULTICAST, trace_plane_normal_y);
	WriteCoord(MSG_MULTICAST, trace_plane_normal_z);
	WriteEntity(MSG_MULTICAST, trace_ent);
	multicast(trace_endpos, MULTICAST_PHS);
	
	sound(self, CHAN_WEAPON, "sounds/weapons/mg.wav", 1, 0.4, 100 + (random() - 0.5) * 5);
	self.ready = time + 0.075;
	self.readystate = FIRING;
	self.ammo_mg -= 1;
}

void() FireWeapon =
{
	if(time > self.ready)
	{
		if(self.readystate == FIRING_SEMI)
			return;
		else
			self.readystate = READY;
			
		switch(self.weapon)
		{
			case(IT_MG):
				FireMG();
				break;
			case(IT_PISTOL):
				FirePistol();
				break;
		}
	}
}