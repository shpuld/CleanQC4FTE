//
//	Items.qc - all the definitions for item spawn functions as well as other functions related to them
//
void() fade_in =
{
	self.alpha += 0.1;
	if(self.alpha >= 1)
	{
		self.alpha = 1;
		return;
	}
	self.nextthink = time + 0.05;
	self.think = fade_in;
	
}

void() item_respawn =
{
	sound(self, 0, "sounds/items/respawn.wav", 0.6, 1.5); //0.4 for a bit lower volume
	self.picked = FALSE;
	self.alpha += 0.1;
	self.nextthink = time + 0.05;
	self.think = fade_in;
	pointparticles(self.parts, self.origin, '0 0 1', 20);
}

void() ammo_touch =
{
	if(other.classname == "player" && self.picked == FALSE)
	{
		if(self.classname == "item_ammo_mg")
		{
			other.ammo_mg += 50;
			if(other.ammo_mg > MAXAMMO_MG)
				other.ammo_mg = MAXAMMO_MG;
		}
		sound(other, 0, "sounds/items/health.wav", 1, 1);
		self.picked = TRUE;
		self.nextthink = time + 5;
		self.think = item_respawn;
		self.alpha = 0.05;
		pointparticles(particleeffectnum("items.pickup"), self.origin, '0 0 1', 20);
	}
}

void() weapon_touch =
{
	if(other.classname == "player" && self.picked == FALSE)
	{
		if(self.classname == "item_mg" && !(other.items & IT_MG))
		{
			other.ammo_mg += 50;
			other.items = other.items + IT_MG;

			if(other.ammo_mg > MAXAMMO_MG)
				other.ammo_mg = MAXAMMO_MG;
			
			sound(other, 0, "sounds/items/health.wav", 1, 1);
			self.picked = TRUE;
			self.nextthink = time + 10;
			self.think = item_respawn;
			self.alpha = 0.05;
			pointparticles(particleeffectnum("items.pickup"), self.origin, '0 0 1', 20);			
		}		
	}
}

void() item_ammo_mg =
{
	self.solid = SOLID_TRIGGER;
	setmodel(self, "models/mg_ammo.iqm");
	setsize(self, '-16 -16 -16', '16 16 32');
	self.classname = "item_ammo_mg";
	self.modelflags = MF_ROTATE;
	self.touch = ammo_touch;
	self.parts = particleeffectnum("items.respawn");
}

void() item_mg = 
{
	self.solid = SOLID_TRIGGER;
	setmodel(self, "models/weapons/mg/mg.iqm");
	setsize(self, '-16 -16 -16', '16 16 32');
	self.classname = "item_mg";
	self.modelflags = MF_ROTATE;
	self.touch = weapon_touch;
	self.parts = particleeffectnum("items.respawn");
}