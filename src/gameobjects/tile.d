import std.stdio;
import std.conv;
import std.math;
import std.random;
import std.string;

import derelict.sdl2.mixer;
import derelict.sdl2.sdl;

import game;
import gameobject;

class Tile : GameObject{
	string type = "Default";

	bool walkable;

	this(string type = "Default"){
		this.type = type;
		super("Tile", type ~ "_Tile");
	}

	override void onMouseDown(SDL_Event e){
		writeln("I've been clicked: " ~ name);
	}
}