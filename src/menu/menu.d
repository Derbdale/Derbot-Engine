import std.stdio;
import std.algorithm;
import std.conv;
import std.file;
import std.math;
import std.random;
import std.array;

import derelict.sdl2.sdl;
import derelict.opengl3.gl;
import game;
import tile;
import fontrenderer;

class Menu {
	Option[] options;
	this(){
		int count = 0;
		foreach(Option o; options){
			o.h = FontData.h["DefaultFont"]['A'];
			o.y = floor(Game.SCREEN_HEIGHT/2 - o.h/2 - (o.h+o.padding)*(options.length-1)/2 + (o.h+o.padding)*count);
			count++;
		}

		Game.menus ~= this;
	}

	void render(){
		glLoadIdentity();
		glDisable(GL_TEXTURE_2D);
		glColor4f(0.2f, 0.2f, 0.2f, 0.9f);

		glBegin(GL_QUADS);
			//Top-left vertex (corner)
			glVertex3f(0, Game.SCREEN_HEIGHT, 0.0f);
			//Top-right vertex (corner)
			glVertex3f(Game.SCREEN_WIDTH, Game.SCREEN_HEIGHT, 0.0f);
			//Bottom-right vertex (corner)
			glVertex3f(Game.SCREEN_WIDTH, 0, 0.0f);
			//Bottom-left vertex (corner)
			glVertex3f(0, 0, 0.0f);
		glEnd();

		foreach(Option o; options){
			o.update();
			o.render();
		}
	}

	void MenuClick(SDL_Event e){
		if(e.button.button == SDL_BUTTON_LEFT){
			foreach(Option o; options){
				if(o.highlighted){
					o.run();
				}
			}
		}
	}
}

class MainMenu : Menu {
	this(){
		options ~= new Option("Start Game", &startGame);
		options ~= new Option("Quit", &quit);
		super();
	}

	void startGame(){
		//Game.menus.popBack();
	}

	void quit(){
		Game.running = false;
	}
}

class PauseMenu : Menu {
	this(){
		options ~= new Option("Return to Game", &returnToGame);
		options ~= new Option("Quit", &quit);
		super();
	}

	void returnToGame(){
		Game.menus.popBack();
	}

	void quit(){
		Game.running = false;
	}
}

class Option {
	bool highlighted = false;
	bool locked;
	float[] colour = [1.0f, 1.0f, 1.0f];
	string text;
	float x = 0;
	float y = 50;
	float w = 0;
	float h = 0;
	float padding = 15;
	void delegate() run;

	this(string text, void delegate() action, bool locked = false){
		this.w = FontRenderer.measureText(text, "DefaultFont");
		this.x = floor(Game.SCREEN_WIDTH/2-w/2);
		this.text = text;
		this.locked = locked;
		run = action;
	}

	void render(){
		FontRenderer.renderText(x, y, text, "DefaultFont", colour);
	}

	void update(){
		if(!locked){
			highlighted = x-floor(padding/2) <= Game.camera.mouseX && x+w+floor(padding/2) >= Game.camera.mouseX && y-floor(padding/2) <= Game.camera.mouseY && y+h+floor(padding/2) >= Game.camera.mouseY;
			if(highlighted){
				colour = [0.6f, 0.45f, 0.6f];
			}else{
				colour = [1.0f, 1.0f, 1.0f];
			}
		}else{
			colour = [0.5f, 0.25f, 0.25f];
		}
	}
}