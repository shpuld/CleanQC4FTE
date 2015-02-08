//
//	Menu stuff
//


void() menu_single =
{
	in_menu = MENU_SINGLE;
	time_in_menu = 0;
};

void() menu_multi =
{
	in_menu = MENU_MULTI;
	time_in_menu = 0;
};

void() menu_settings =
{
	in_menu = MENU_SETTINGS;
	time_in_menu = 0;
};

void() menu_about =
{
	in_menu = MENU_ABOUT;
	time_in_menu = 0;
};

void() menu_quit =
{
	localcmd("quit\n");
};

void() menu_back =
{
	in_menu = MENU_MAIN;
	time_in_menu = 0;
};

void() menu_loadtest =
{
	print("loading test\n");
	localcmd("map test_lms\n");
};

void() menu_join =
{
	setcursormode(TRUE,"menu/cursor");
	in_menu = MENU_JOIN;
};

void() game_join =
{
	localcmd("cmd joingame\n");
	in_menu = MENU_NONE;
	setcursormode(FALSE);
};

void() game_spec =
{
	localcmd("cmd specgame\n");
	in_menu = MENU_NONE;
	setcursormode(FALSE);
};

//struct for all buttons, note pos and scale are going to be multiplied with width/height in draw step, so keep them between 0 and 1
var struct
{
	vector pos;
	vector scale;
	string text;
	float active; //used for mouseover hilight (positive values) and alpha (negative values)
	void() action; //function that is called when the button is pressed
	float group; //a bit field, button will be usable/visible when these bits are active
} buttons[] =
{
	{[0.025, 0.500, 0], [0.25, 0.05, 0], "Singleplayer", -1, menu_single, MENU_MAIN},
	{[0.025, 0.575, 0], [0.25, 0.05, 0], "Multiplayer", -1, menu_multi, MENU_MAIN},
	{[0.025, 0.650, 0], [0.25, 0.05, 0], "Settings", -1, menu_settings, MENU_MAIN},
	{[0.025, 0.725, 0], [0.25, 0.05, 0], "About", -1, menu_about, MENU_MAIN},
	{[0.025, 0.925, 0], [0.25, 0.05, 0], "Quit", -1, menu_quit, MENU_MAIN},
	{[0.025, 0.925, 0], [0.25, 0.05, 0], "Back", -1, menu_back, MENU_SINGLE + MENU_MULTI + MENU_SETTINGS + MENU_ABOUT},
	{[0.025, 0.500, 0], [0.25, 0.05, 0], "Load test", -1, menu_loadtest, MENU_SINGLE},
	{[0.475, 0.500, 0], [0.25, 0.05, 0], "Join", -1, game_join, MENU_JOIN},
	{[0.475, 0.575, 0], [0.25, 0.05, 0], "Spectate", -1, game_spec, MENU_JOIN}
};

//REMEMBER TO UPDATE THIS CONST IF YOU ADD BUTTONS
const float BUTTONS_COUNT = 9;


//this function handles drawing the buttons and checking if they should be active/hilighted
void(float index) Update_Button = 
{
	if(in_menu != in_menu & buttons[index].group)
		buttons[index].active = -1;
		
	if(buttons[index].active == -1)
	{
		if(in_menu == in_menu & buttons[index].group)
			buttons[index].active = 1;
		else
			return;
	}
	
	local vector pos = buttons[index].pos;
	pos_x *= g_width;
	pos_y *= g_height;
	local vector scale = buttons[index].scale;
	scale_x *= g_width;
	scale_y *= g_height;
	
	local float alphafactor;
	
	if(buttons[index].active > 0)
		alphafactor = 1;
	else
		alphafactor = buttons[index].active + 1; //-1 invis, 0 normal
	
	if(cursor_pos_x > pos_x && cursor_pos_x < pos_x + scale_x && cursor_pos_y > pos_y && cursor_pos_y < pos_y + scale_y )
		buttons[index].active = 1;
	
	drawfill(pos, scale, [0.2,0.2,0.2] + [0.15,0.15,0.15]*buttons[index].active, 0.3 * alphafactor);
	drawline(1, pos, [pos_x + scale_x, pos_y, 0], [0.6, 0.6, 0.6], 0.5, 1); //top outline
	drawline(1, pos, [pos_x, pos_y + scale_y, 0], [0.6, 0.6, 0.6], 0.5, 1); //left outline
	drawline(1, [pos_x, pos_y + scale_y, 0], [pos_x + scale_x, pos_y + scale_y, 0], [0.6, 0.6, 0.6], 0.5, 1); //bottom outline
	drawline(1, [pos_x + scale_x, pos_y, 0], [pos_x + scale_x, pos_y + scale_y, 0], [0.6, 0.6, 0.6], 0.5, 1); //right outline
	drawstring(pos + [scale_x*0.05, scale_y*0.25, 0], buttons[index].text, [scale_y*0.5, scale_y*0.5, 1], [0.8,0.8,0.8], 1 * alphafactor, 1);
	
	if(buttons[index].active > 0)
	{
		buttons[index].active -= frametime * 5;
		if(buttons[index].active < 0)
			buttons[index].active = 0;
	}
};


void(float index) Button_Click = 
{
	//don't click if not active
	if(buttons[index].active == -1)
		return;
		
	local vector pos = buttons[index].pos;
	pos_x *= g_width;
	pos_y *= g_height;
	local vector scale = buttons[index].scale;
	scale_x *= g_width;
	scale_y *= g_height;
	
	if(cursor_pos_x > pos_x && cursor_pos_x < pos_x + scale_x && cursor_pos_y > pos_y && cursor_pos_y < pos_y + scale_y )
	{
		buttons[index].action(); //do whatever this button is supposed to do
	}
};


void() Menu_Click =
{
	float i;
	for(i = 0; i < BUTTONS_COUNT; i++)
	{
		Button_Click(i);
	}
};



void() Draw_Menu =
{

	//Background picture with a nice scrolling effect, scrolling happens in the shader in scripts/menu.shader
	if(serverkey("constate") == "disconnected")
	{
		if(g_width <= g_height * 1.77778)
			drawpic([0,0,0], "menu/bg", [g_height * 1.77778, g_height, 1], [1, 1, 1], 1);
		else
			drawpic([0,0,0], "menu/bg", [g_width, g_height, 1], [1, 1, 1], 1);
	}

		
	//Gradient on the background
	drawpic([0,0,0], "menu/gradient_l2r", [0.75*g_width, g_height, 1], [1, 1, 1], 1);
	

	//Title with a simple but nice animation
	local string title = "";
	switch(in_menu)
	{
		case MENU_MAIN:
			title = "Game: Video";
			break;
		case MENU_SINGLE:
			title = "Singleplayer";
			break;
		case MENU_MULTI:
			title = "Multiplayer";
			break;
		case MENU_SETTINGS:
			title = "Settings";
			break;
		case MENU_ABOUT:
			title = "About";
			break;
		default:
			title = "FTEQW Example";
	}

	local float chars_to_keep;
	time_in_menu += frametime;
	
	if(time_in_menu < 0.5)
	{
		chars_to_keep = time_in_menu * 2;
		chars_to_keep = rint(chars_to_keep * strlen(title));
	}
	else
		chars_to_keep = strlen(title);
	
	drawstring([0.025*g_width, 0.05*g_height, 0], substring(title, 0, chars_to_keep), [g_height * 0.05, g_height * 0.05, 1], [0.8, 0.8, 0.8], 1, 1);
	
	
	//Update buttons
	local float i;

	for(i = 0; i < BUTTONS_COUNT; i++)
	{
		Update_Button(i);
	}
};