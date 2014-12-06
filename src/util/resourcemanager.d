import std.stdio;
import std.string;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.mixer;
import derelict.opengl3.gl;

class ResourceManager{
	static Texture2D[string] textures;
	static Mix_Music*[string] music;
	static Mix_Chunk*[string] sfx;

	static void LoadMusic(string musicID, string file = null){
		if(!file){
			file = "assets/music/"~musicID~".mp3";
		}
		music[musicID] = Mix_LoadMUS(toStringz(file));
	}

	static void LoadSfx(string sfxID, string file = null){
		if(!file){
			file = "assets/sfx/"~sfxID~".ogg";
		}
		sfx[sfxID] = Mix_LoadWAV(toStringz(file));
	}

	static void LoadTexture(string textureID, string file = null){
		if(!file){
			file = "assets/img/"~textureID~".png";
		}

		GLuint texture;
		SDL_Surface* surface = IMG_Load(toStringz(file));
		GLenum texture_format;
		GLint  nOfColors;

		nOfColors = surface.format.BytesPerPixel;

		if (nOfColors == 4){
			if (surface.format.Rmask == 0x000000ff){
				texture_format = GL_RGBA;
			}
			else{
				texture_format = GL_BGRA;
			}
	    } else if (nOfColors == 3) {
			if (surface.format.Rmask == 0x000000ff){
				texture_format = GL_RGB;
			}
			else{
				texture_format = GL_BGR;
			}
	    } else {
			writeln("warning: the image is not truecolor..  this will probably break\n");
	    }

	    glGenTextures(1, &texture);

	    glBindTexture(GL_TEXTURE_2D, texture);

	    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	    glTexImage2D(GL_TEXTURE_2D, 0, nOfColors, surface.w, surface.h, 0, texture_format, GL_UNSIGNED_BYTE, surface.pixels);

	    textures[textureID] = new Texture2D(texture, surface.w, surface.h);

	    SDL_FreeSurface(surface);
	}

	static void LoadResources(){
	    ResourceManager.LoadTexture("DefaultFont", "assets/fonts/default.png");
	    ResourceManager.LoadTexture("SmallFont", "assets/fonts/small.png");
	    ResourceManager.LoadTexture("Default_Tile");
	}
}

class Texture2D{
	int width, height;
	GLuint tex;

	this(GLuint tex, int width, int height){
		this.tex = tex;
		this.width = width;
		this.height = height;
	}
}