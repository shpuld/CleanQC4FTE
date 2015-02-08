

void() Player_Interpolate = 
{
	if(self.entnum == player_localentnum)
	{
		UpdateLocalMovement(self);
	}
}

void(float isnew) Player_Refresh =
{
	self.predraw = Player_Interpolate;
}