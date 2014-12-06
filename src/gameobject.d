import std.conv;
import std.stdio;
import std.math;
import std.string;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.opengl3.gl;

import game;
import resourcemanager;

class GameObject {
	int id;

	int width = 0;
	int height = 0;

	int lastWidth = 0;
	int lastHeight = 0;

	float x = 0;
	float y = 0;

	float offsetY = 0;
	float offsetX = 0;

	float offsetResetRate = 0.75;

	float z = 0;

	float red = 1.0f;
	float green = 1.0f;
	float blue = 1.0f;

	float angle = 0.0;
	float scale = 1.0f;

	string textureID;
	string name;

	bool clickable;

	SDL_Point pivot = {0, 0};
	Texture2D texture;

	this(string name, string textureID){
		if(textureID){
			this.textureID = textureID;
		}
		texture = ResourceManager.textures[this.textureID];

		this.name = text(name, "_", Game.gameObjectCount);
		this.id = Game.gameObjectCount;

		width = Game.TILE_SIZE;
		height = Game.TILE_SIZE;
		lastWidth = width;
		lastHeight = height;

		pivot.x = texture.width/2;
		pivot.y = texture.height/2;

		translate(pivot.x, pivot.y);

		Game.gameobjects[this.name] = this;
		Game.gameObjectCount++;
		clickable = true;
	}

	void preUpdate(){}

	void update(){}

	void postUpdate(){}

	void render(){
		glEnable(GL_TEXTURE_2D);
		glLoadIdentity();
		glTranslatef(-(Game.camera.x + Game.camera.offsetX), -(Game.camera.y + Game.camera.offsetY), 0.0f);
		glTranslatef(x+offsetX, y+offsetY, 0.0f);
		glRotatef(angle, 0, 0, 1);

		pivot.x += (width-lastWidth)/2;
		pivot.y += (height-lastHeight)/2;

		glBindTexture(GL_TEXTURE_2D, texture.tex);

		glColor3f(red, green, blue);

		glBegin(GL_QUADS);
			glTexCoord2i(0, 1);
			glVertex3f(-pivot.x*scale, pivot.y*scale, 0.0f);
			glTexCoord2i(1, 1);
			glVertex3f(pivot.x*scale, pivot.y*scale, 0.0f);
			glTexCoord2i(1, 0);
			glVertex3f(pivot.x*scale, -pivot.y*scale, 0.0f);
			glTexCoord2i(0, 0);
			glVertex3f(-pivot.x*scale, -pivot.y*scale, 0.0f);
		glEnd();

		lastWidth = width;
		lastHeight = height;
		offsetX *= offsetResetRate;
		offsetY *= offsetResetRate;
	}
	
	void translate(float x, float y){
		this.x += x;
		this.y += y;
	}

	void translateTiles(float x, float y){
		translate(x*texture.width, y*texture.height);
	}

	void onMouseDown(SDL_Event e){}

	void onMouseUp(SDL_Event e){}
}