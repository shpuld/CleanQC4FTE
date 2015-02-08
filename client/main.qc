
void() ToggleMenu =
{
	if(serverkey("constate") != "disconnected")
	{
		if(in_menu == MENU_NONE)
		{
			in_menu = MENU_MAIN;
			time_in_menu = 0;
			local float i;
			for(i = 0; i < BUTTONS_COUNT; i++)
			{
				buttons[i].active = 1;
			}
			setcursormode(TRUE,"menu/cursor");
		}
		else
		{
			in_menu = MENU_NONE;
			setcursormode(FALSE);
		}
	}
	else
	{
		in_menu = MENU_MAIN;
		time_in_menu = 0;
		setcursormode(TRUE,"menu/cursor");
	}
}

noref void(float apiver, string enginename, float enginever) CSQC_Init =
{
	registercommand("togglemenu");
	registercommand("startwalk");
	registercommand("stopwalk");
	registercommand("promptjoin");
	print("CSQC Started\n");
	dummy = spawn();
	if(serverkey("constate") == "disconnected")
		ToggleMenu();
	//bgpos = 0;
};

noref void() CSQC_WorldLoaded =
{
	precache_model("models/weapons/mg/mg.iqm");
	precache_model("models/weapons/pistol/pistol.iqm");
	precache_model("models/weapons/mg/mzl.iqm");
	precache_model("models/blood.iqm");
	
	//if(!player)
	//	player = edict_num(player_localentnum);
	if(!vmodel)
		vmodel = spawn();
	if(!mzlflash)
		mzlflash = spawn();
		
	vmodel.renderflags = RF_VIEWMODEL;
	vmodel.origin = '24 -12 -18';
	vmodel_targetpos = vmodel_currentpos = vmodel.origin;
	vmodel_velocity = '0 0 0';
	vmodel_muzzleoffset = '48 -1 2';
	setmodel(vmodel,"");
	mzlflash.renderflags = vmodel.renderflags;
	mzlflash.origin = vmodel.origin + vmodel_muzzleoffset;
	setmodel(mzlflash,"models/weapons/mg/mzl.iqm");
};

void() Update_Vmodel =
{
	local vector offset;
	local vector dir;
	
	offset_x = 0.6 * sin(time * 1.2);
	offset_y = 0.4 * cos(time * 1.5);
	offset_z = 0.7 * sin(1.1*time + 0.5);
	
	dir = vmodel_targetpos - vmodel_currentpos;
	if(vlen(dir) < (0.15 * 128 * frametime))
		vmodel_currentpos = vmodel_targetpos;
	else
		vmodel_currentpos += (dir * 0.15 * 128) * frametime;
	
	if(vlen(vmodel.angles) < (0.1 * 128 * frametime))
		vmodel.angles = '0 0 0';
	else
		vmodel.angles += (-vmodel.angles * 0.2 * 128) * frametime;
		
	vmodel_currentpos += (vmodel_velocity * 128) * frametime;
	vmodel_velocity *= 1 - frametime * 30;
	
	vmodel.angles += (vmodel_avelocity * 128) * frametime;
	vmodel_avelocity *= 1 - frametime * 30;
	
	vmodel.origin = vmodel_currentpos + offset;
	if(weapon == 1)
	{
		if(mzlflash.scale < 1)
			mzlflash.scale += (10 * random()) * frametime;
	}
	else if(weapon == 2)
	{
		if(mzlflash.scale < 1.5)
			mzlflash.scale += (20 * random()) * frametime;
	}
	mzlflash.origin = vmodel.origin + vmodel_muzzleoffset;
	mzlflash.alpha -= (0.15 * 100) * frametime;
	if(mzlflash.alpha < 0.1)
		mzlflash.alpha = 0.01;
}

noref void(float isnew) CSQC_Ent_Update =
{
	if(isnew)
		print(strcat(etos(self),"\n"));
}	

float(float isnew) add_outline =
{
	if(num_for_edict(self) == player_localentnum)
		return 1;
	addentity(self);
	copyentity(self, dummy);
	dummy.forceshader = shaderforname("outline");
	dummy.fatness = 0.25;
	addentity(dummy);
	return 1;
}

noref void(float width, float height, float menushown) CSQC_UpdateView =
{
	clearscene();
	g_width = width;
	g_height = height;

	setviewprop(VF_DRAWENGINESBAR, 0);	
	setviewprop(VF_DRAWCROSSHAIR, 0);
	//setviewprop(VF_ORIGIN, self.origin);
	//setviewprop(VF_ANGLES, input_angles);
			
	addentities(MASK_ENGINE);
	dynamiclight_add('-30 0 80', 200, '1 0.6 0.6');

	if(vmodel)
	{
		Update_Vmodel();
		addentity(vmodel);
		if(mzlflash.alpha > 0.09)
		{
			makevectors(view_angles);
			local vector offset = vmodel.origin + vmodel_muzzleoffset;
			local vector muzzlepos;
			muzzlepos = getviewprop(VF_ORIGIN);
			muzzlepos += v_forward * offset_x;
			muzzlepos -= v_right * offset_y;
			muzzlepos += v_up * (offset_z + 6);

			dynamiclight_add(muzzlepos, 128 * mzlflash.alpha, '1.2 0.7 0.2' * mzlflash.alpha);
			addentity(mzlflash);
		}
	}
	
	deltalisten("models/mg_ammo.iqm", add_outline, 0);
	deltalisten("models/weapons/mg/mg.iqm", add_outline, 0);
	deltalisten("models/weapons/pistol/pistol.iqm", add_outline, 0);
	//deltalisten("models/humanoid_simplerig.iqm", add_outline, 0);
	
	
	local entity asd, outlines;
	outlines = spawn();
	local float outlineshader;
	outlineshader = shaderforname("outline");
	asd = nextent(world);

	while(asd != world)
	{
		copyentity(asd, outlines);
		outlines.forceshader = outlineshader;
		outlines.fatness = 0.25;
		addentity(outlines);
		asd = nextent(asd);
	}
	renderscene();
	remove(outlines);
	
	if(in_menu)
	{
		Draw_Menu();
	}
	else
	{
		local float health, ammo;
		health = getstatf(STAT_HEALTH);
		if(weapon == 1)
			ammo = getstatf(51);
		else if(weapon == 2)
			ammo = getstatf(50);
		else
			ammo = -1;
		drawstring([0.01*width, 0.94*height, 0], strcat("+",ftos(health)), [0.03*width, 0.03*width, 0], [1, 1, 1], 1, 1);
		if(ammo != -1)
			drawstring([0.75*width, 0.94*height, 0], strcat("AMMO:",ftos(ammo)), [0.03*width, 0.03*width, 0], [1, 1, 1], 1, 1);
	}
	if(serverkey("constate") != "active" && serverkey("disconnected"))
	{
		drawfill('0 0 0',  [width, height, 0], '0.2 0.4 0.7', 1);
		drawstring([width/2 - 60, height/2, 0], "Loading...", [16,16,0],[1,1,1],1,1);
	}
};

noref float(string cmd) CSQC_ConsoleCommand =
{
	//self = theplayer;
	//if (!self)
	//	return FALSE;

	tokenize(cmd);
	switch(argv(0))
	{
		case "togglemenu":
			ToggleMenu();
			return TRUE;
			break;
		case "map":
			return FALSE;
			break;
		case "startwalk":
			walk = TRUE;
			return FALSE;
		case "stopwalk":
			walk = FALSE;
			return FALSE;
		case "promptjoin":
			menu_join();
			return TRUE;
		default:
			return FALSE;
	}
	return FALSE;
};

noref float(float evtype, float scanx, float chary, float devid) CSQC_InputEvent =
{
	switch(evtype)
	{
	case IE_KEYDOWN:
		if(in_menu != MENU_NONE)
		{
			if(scanx == K_MOUSE1)
			{
				print(strcat(ftos(num_for_edict(world)), ", ", ftos(num_for_edict(self)), "\n"));
				Menu_Click();
				return TRUE;
			}
		}
		return FALSE;
	case IE_KEYUP:
		return FALSE;
	case IE_MOUSEDELTA:
		return FALSE;
	case IE_MOUSEABS:
		//if(devid != 0 && devid != 1)
		//	return FALSE;
		cursor_pos_x = scanx;
		cursor_pos_y = chary;
		return FALSE;
	}
	return FALSE;
};

noref void() CSQC_Input_Frame =
{

	if(walk)
	{
		input_movevalues *= 0.5;
	}
	runstandardplayerphysics(self);
}

float() tracerthink =
{
	//makevectors(self.angles);
	local vector cross1 = normalize(crossproduct( getviewprop(VF_ORIGIN) - self.targetpos, self.targetpos - self.origin));
	local vector cross2 = normalize(crossproduct( getviewprop(VF_ORIGIN) - self.origin, self.targetpos - self.origin));
	R_BeginPolygon("tracers/mg");
	
	R_PolygonVertex(self.origin + cross2, '0 1 0', '1 1 1', self.alpha - 0.6);
	R_PolygonVertex(self.origin - cross2, '0 0 0', '1 1 1', self.alpha - 0.6);
	R_PolygonVertex(self.targetpos - cross1, '1 0 0', '1 1 1', self.alpha);

	R_PolygonVertex(self.targetpos + cross1, '1 1 0', '1 1 1', self.alpha);
	R_PolygonVertex(self.origin + cross2, '0 1 0', '1 1 1', self.alpha - 0.6);
	R_PolygonVertex(self.targetpos - cross1, '1 0 0', '1 1 1', self.alpha);

	/*R_PolygonVertex(self.origin + v_right, '0 1 0', '1 1 1', self.alpha - 0.4);
	R_PolygonVertex(self.origin - v_right, '0 0 0', '1 1 1', self.alpha - 0.4);
	R_PolygonVertex(self.targetpos - v_right, '1 0 0', '1 1 1', self.alpha);

	R_PolygonVertex(self.targetpos + v_right, '1 1 0', '1 1 1', self.alpha);
	R_PolygonVertex(self.origin + v_right, '0 1 0', '1 1 1', self.alpha - 0.4);
	R_PolygonVertex(self.targetpos - v_right, '1 0 0', '1 1 1', self.alpha);*/


	R_EndPolygon();

	self.alpha -= (frametime * self.rate);
	if(self.alpha <= 0)
		remove(self);

	return 0;
}

float() alphafade =
{
	
	self.alpha -= (frametime * 3);
	self.scale += (frametime * 9);
	if(self.alpha <= 0.05)
		remove(self);
	
	local vector cross1 = 10 * self.scale * normalize(crossproduct( getviewprop(VF_ORIGIN) - self.origin + self.targetpos * self.scale, self.targetpos * self.scale));
	local vector cross2 = 10 * self.scale * normalize(crossproduct( getviewprop(VF_ORIGIN) - self.origin, self.targetpos * self.scale));
	R_BeginPolygon("bloodsplat2");
	
	R_PolygonVertex(self.origin + cross2, '0 1 0', '1 1 1', self.alpha);
	R_PolygonVertex(self.origin - cross2, '0 0 0', '1 1 1', self.alpha);
	R_PolygonVertex(self.origin + (self.targetpos*self.scale*18) - cross1, '1 0 0', '1 1 1', self.alpha);

	R_PolygonVertex(self.origin + (self.targetpos*self.scale*18) + cross1, '1 1 0', '1 1 1', self.alpha);
	R_PolygonVertex(self.origin + cross2, '0 1 0', '1 1 1', self.alpha);
	R_PolygonVertex(self.origin + (self.targetpos*self.scale*18) - cross1, '1 0 0', '1 1 1', self.alpha);
	
	R_EndPolygon();
	
	return 0;
}

noref void() CSQC_Parse_Event =
{
	local float first = readbyte();
	if(first == 10 || first == 11)
	{
		local float entnum, traceent;
		local vector pos, norm;
		entnum = readentitynum();

		pos_x = readcoord();
		pos_y = readcoord();
		pos_z = readcoord();
		norm_x = readcoord();
		norm_y = readcoord();
		norm_z = readcoord();
		
		traceent = readentitynum();

		if(entnum == player_localentnum)
		{
			tracercounter += 1;
			if(tracercounter == 3)
			{
				tracercounter = 0;
				makevectors(view_angles);
				local vector offset = vmodel.origin + vmodel_muzzleoffset;
				local vector muzzlepos;
				muzzlepos = getviewprop(VF_ORIGIN);
				muzzlepos += v_forward * offset_x;
				muzzlepos -= v_right * offset_y;
				muzzlepos += v_up * offset_z;

				local entity tracer = spawn();
				tracer.alpha = 1;
				tracer.origin = muzzlepos;
				tracer.targetpos = pos;
				tracer.rate = 1/0.05;
				tracer.angles = view_angles;
				tracer.predraw = tracerthink;
				tracer.drawmask = 1;
			}

			
			mzlflash.alpha = 1;
			if(weapon == 1)
			{
				mzlflash.scale = 0.1 + random() * 0.35;
				vmodel_velocity_x = -2.5;
				vmodel_velocity_y = (random() - 0.5) * 0.6;
				vmodel_velocity_z = (random() - 0.5) * 0.6 + 2;
				
				vmodel_avelocity_x = 8;
				vmodel_avelocity_y = (random() - 0.5) * 0.5;
				vmodel_avelocity_z = (random() - 0.5) * 0.5;
			}
			else if(weapon == 2)
			{
				mzlflash.scale = 0.1 + random() * 0.5;
				vmodel_velocity_x = -2;
				vmodel_velocity_y = (random() - 0.5) * 0.5;
				vmodel_velocity_z = (random() - 0.5) * 0.5;
				
				vmodel_avelocity_x = (random() - 0.5) * 1.5;
				vmodel_avelocity_y = (random() - 0.5) * 1.5;
				vmodel_avelocity_z = (random() - 0.2) * 1.5;
			}
			mzlflash.angles_z = random() * 360;
		}
		
		if(traceent == 0)
		{
			pointparticles(particleeffectnum("weapons.impact"), pos, norm*24, 1);
			pointparticles(particleeffectnum("weapons.impact_decal"), pos, '0 0 0', 1);
		}
		else
		{
			local vector entorg;
			entorg = getentity(traceent, GE_ORIGIN);
			norm = (norm * 0.25) + (normalize(pos - (entorg + '0 0 12')) * 0.75);
			local entity splat = spawn();
			setmodel(splat, "models/blood.iqm");
			setorigin(splat, pos + '0 0 0');
			splat.drawmask = 1;
			splat.alpha = 1;
			splat.scale = 0.05;
			splat.angles = [random()*360, random()*360, random()*360];
			splat.targetpos = norm * 1.5;
			splat.predraw = alphafade;
		}
	}
	else if(first == 9)
	{
		local float to;
		to = readbyte();
		if(to == 1)
		{
			vmodel.origin = '32 -8 -16';
			vmodel.angles = '-60 0 0';
			vmodel_currentpos = vmodel.origin + '0 0 -24';
			vmodel_targetpos = vmodel.origin;
			vmodel_muzzleoffset = '12 0 1';
			setmodel(vmodel,"models/weapons/pistol/pistol.iqm");
			weapon = to;
		}
		else if(to == 2)
		{
			vmodel.origin = '10 -8 -18';
			vmodel.angles = '-70 0 0';
			vmodel_currentpos = vmodel.origin + '0 0 -24';
			vmodel_targetpos = vmodel.origin;
			vmodel_muzzleoffset = '40 0 4';
			setmodel(vmodel,"models/weapons/mg/mg.iqm");
			weapon = to;
		}
	}
} 