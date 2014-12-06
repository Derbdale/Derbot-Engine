import std.conv;
import std.datetime;
import std.file;
import std.math;
import std.random;
import std.stdio;
import std.array;
import std.string;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.mixer;
import derelict.opengl3.gl;

import inputhandler;
import game;
import tile;
import gameobject;
import resourcemanager;
import fontrenderer;
import menu;

int frames = 0;
float secondCounter = 0;
bool displayFPS = true;

void main(){
	DerelictSDL2.load();
	DerelictSDL2Image.load();
	DerelictSDL2Mixer.load();
	DerelictGL.load();

	Game.Init("LD31 - Entire Game On One Screen", 640, 480);
	Game.InitGL();
	SDL_GL_SwapWindow(Game.window);
	ResourceManager.LoadResources();
	FontData.init();

	SDL_ShowCursor(SDL_DISABLE);

	new MainMenu();

	while(Game.running){
		auto startTime = SDL_GetTicks();
		if(!SDL_GetKeyboardFocus()){
			if(Game.menus.length == 0){
				new PauseMenu();
			}
		}

		if(Game.menus.length > 0){
			Game.paused = true;
		}else{
			Game.paused = false;
		}

		Game.camera.offsetX = Game.camera.offsetY = 0;
		Game.HandleEvents();
		handleInput();
		Game.Clear();

		GameObject[][float] gameobjects;
		foreach(GameObject g; Game.gameobjects){
			gameobjects[g.z] ~= g;
		}

		foreach(float z; gameobjects.keys.sort){
			foreach(GameObject g; gameobjects[z]){
				if(!Game.paused){
					g.preUpdate();
					g.update();
					g.postUpdate();
				}
				if(((g.x-g.pivot.x > Game.camera.x && g.x-g.pivot.x < Game.camera.x+Game.SCREEN_WIDTH) || (g.x+g.width-g.pivot.x > Game.camera.x && g.x+g.width-g.pivot.x < Game.camera.x+Game.SCREEN_WIDTH)) && ((g.y-g.pivot.y > Game.camera.y && g.y-g.pivot.y < Game.camera.y+Game.SCREEN_HEIGHT) || (g.y+g.height-g.pivot.y > Game.camera.y && g.y+g.height-g.pivot.y < Game.camera.y+Game.SCREEN_HEIGHT))){
					g.render();
				}
			}
		}

		if(Game.menus.length > 0){
			Game.menus.back.render();
		}

		if(displayFPS == true){
			FontRenderer.renderText(Game.SCREEN_WIDTH-5-FontRenderer.measureText("FPS: " ~ text(Game.fps), Game.uiFont), FontData.h[Game.uiFont]['A'], "FPS: " ~ text(Game.fps), Game.uiFont, [1.0f, 0.0f, 1.0f]);
		}

		Game.RenderMouse();
		Game.Present();

		InputHandler.justPressed = InputHandler.falseArray;

		if(!Game.paused){
			Game.ticks++;
		}
		auto elapsedMS = SDL_GetTicks() - startTime;
		if(1000/Game.targetFPS > elapsedMS){
			SDL_Delay(1000/Game.targetFPS-elapsedMS);
		}
		frames++;
		if(floor(SDL_GetTicks()/1000.0f) > secondCounter){
			Game.fps = frames;
			frames = 0;
			secondCounter++;
		}
	}
	Game.Quit();
}



void handleInput(){
	if((InputHandler.keys[SDL_SCANCODE_SPACE])){
		Game.camera.shake(5);
	}
	if((InputHandler.keys[SDL_SCANCODE_LEFT])){
		Game.uiFont = "SmallFont";
	}
	if((InputHandler.keys[SDL_SCANCODE_RIGHT])){
		Game.uiFont = "DefaultFont";
	}
	if((InputHandler.keys[SDL_SCANCODE_W])){
		Game.camera.y -= Game.camera.moveSpeed;
	}
	if((InputHandler.keys[SDL_SCANCODE_S])){
		Game.camera.y += Game.camera.moveSpeed;
	}
	if((InputHandler.keys[SDL_SCANCODE_A])){
		Game.camera.x -= Game.camera.moveSpeed;
	}
	if((InputHandler.keys[SDL_SCANCODE_D])){
		Game.camera.x += Game.camera.moveSpeed;
	}
	if((InputHandler.justPressed[SDL_SCANCODE_ESCAPE])){
		if(Game.menus.length == 0){
			new PauseMenu();
		}
	}
}