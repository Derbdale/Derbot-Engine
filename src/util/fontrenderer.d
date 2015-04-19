import std.stdio;
import std.math;
import std.string;
import std.random;

import derelict.sdl2.sdl;
import derelict.opengl3.gl;

import game;
import resourcemanager;

class FontRenderer{
	static Texture2D texture;
	static float red;
	static float green;
	static float blue;

	static int measureText(string text, string font = "DefaultFont"){
		bool first = true;
		int length = 0;
		foreach(char c; text.toUpper){
			if(!first){
				length += FontData.w[font][c]+FontData.k[font][c];
			}else{
				length += FontData.w[font][c];
				first = false;
			}
		}
		return length;
	}

	static void renderText(float x, float y, string text, string font = "DefaultFont", float[] rgb = [1.0f, 1.0f, 1.0f], bool isStatic = true){
		red = rgb[0];
		green = rgb[1];
		blue = rgb[2];
		float size = FontData.size[font];
		texture = ResourceManager.textures[font];
		glEnable(GL_TEXTURE_2D);
		glLoadIdentity();
		if(!isStatic)
			glTranslatef(-(Game.camera.x + Game.camera.offsetX), -(Game.camera.y + Game.camera.offsetY), 0.0f);
		glTranslatef(x, y, 0.0f);

		glBindTexture(GL_TEXTURE_2D, texture.tex);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glColor3f(red, green, blue);

		int position = 0;


		foreach(char c; text.toUpper){
			glBegin(GL_QUADS);
				float topLeftX = ((FontData.characters.indexOf(c) - (floor(cast(float)(FontData.characters.indexOf(c)/10))*10))*FontData.size[font] + FontData.x[font][c])/(FontData.size[font]*10);
				float topLeftY = (floor(cast(float)(FontData.characters.indexOf(c)/10))*FontData.size[font] + FontData.y[font][c])/(FontData.size[font]*10);
				glTexCoord2f(topLeftX, topLeftY);
				glVertex3f(0.0f, 0.0f, 0.0f);
				glTexCoord2f(topLeftX+(FontData.w[font][c]/(FontData.size[font]*10)), topLeftY);
				glVertex3f(FontData.w[font][c]*size/FontData.size[font], 0.0f, 0.0f);
				glTexCoord2f(topLeftX+(FontData.w[font][c]/(FontData.size[font]*10)), topLeftY+(FontData.h[font][c]/(FontData.size[font]*10)));
				glVertex3f(FontData.w[font][c]*size/FontData.size[font], FontData.h[font][c]*size/FontData.size[font], 0.0f);
				glTexCoord2f(topLeftX, topLeftY+(FontData.h[font][c]/(FontData.size[font]*10)));
				glVertex3f(0.0f, FontData.h[font][c]*size/FontData.size[font], 0.0f);
			glEnd();
			if(position != text.length-1)
				glTranslatef(FontData.w[font][c]*size/FontData.size[font] + FontData.k[font][cast(char)(text[position+1].toUpper)]*size/FontData.size[font], 0.0f, 0.0f);
			position++;
		}
	}


}

class FontData{
	static float[string] size;
	static float[char][string] x;
	static float[char][string] y;
	static float[char][string] w;
	static float[char][string] h;
	static float[char][string] k;

	static string characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789:-*$ ";

	static void init(){
		string s;
		char l;
		s = "DefaultFont";
		size[s] = 16;
		l = ' '; x[s][l] = 0; y[s][l] = 0; w[s][l] = 0; h[s][l] = 0; k[s][l] = 6;
		l = 'A'; x[s][l] = 3; y[s][l] = 2; w[s][l] = 9; h[s][l] = 12; k[s][l] = 2;
		l = 'B'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 7; h[s][l] = 12; k[s][l] = 2;
		l = 'C'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 8; h[s][l] = 12; k[s][l] = 2;
		l = 'D'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 8; h[s][l] = 12; k[s][l] = 2;
		l = 'E'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 7; h[s][l] = 12; k[s][l] = 2;
		l = 'F'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 7; h[s][l] = 12; k[s][l] = 2;
		l = 'G'; x[s][l] = 3; y[s][l] = 2; w[s][l] = 9; h[s][l] = 12; k[s][l] = 2;
		l = 'H'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 7; h[s][l] = 12; k[s][l] = 2;
		l = 'I'; x[s][l] = 5; y[s][l] = 2; w[s][l] = 5; h[s][l] = 12; k[s][l] = 2;
		l = 'J'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 7; h[s][l] = 12; k[s][l] = 2;
		l = 'K'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 7; h[s][l] = 12; k[s][l] = 2;
		l = 'L'; x[s][l] = 5; y[s][l] = 2; w[s][l] = 6; h[s][l] = 12; k[s][l] = 2;
		l = 'M'; x[s][l] = 3; y[s][l] = 2; w[s][l] = 9; h[s][l] = 12; k[s][l] = 2;
		l = 'N'; x[s][l] = 3; y[s][l] = 2; w[s][l] = 9; h[s][l] = 12; k[s][l] = 2;
		l = 'O'; x[s][l] = 3; y[s][l] = 2; w[s][l] = 10; h[s][l] = 12; k[s][l] = 2;
		l = 'P'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 8; h[s][l] = 12; k[s][l] = 2;
		l = 'Q'; x[s][l] = 3; y[s][l] = 2; w[s][l] = 10; h[s][l] = 12; k[s][l] = 2;
		l = 'R'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 7; h[s][l] = 12; k[s][l] = 2;
		l = 'S'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 8; h[s][l] = 12; k[s][l] = 2;
		l = 'T'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 7; h[s][l] = 12; k[s][l] = 2;
		l = 'U'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 8; h[s][l] = 12; k[s][l] = 2;
		l = 'V'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 7; h[s][l] = 12; k[s][l] = 2;
		l = 'W'; x[s][l] = 3; y[s][l] = 2; w[s][l] = 9; h[s][l] = 12; k[s][l] = 2;
		l = 'X'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 7; h[s][l] = 12; k[s][l] = 2;
		l = 'Y'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 7; h[s][l] = 12; k[s][l] = 2;
		l = 'Z'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 8; h[s][l] = 12; k[s][l] = 2;
		l = '0'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 8; h[s][l] = 12; k[s][l] = 2;
		l = '1'; x[s][l] = 6; y[s][l] = 2; w[s][l] = 4; h[s][l] = 12; k[s][l] = 2;
		l = '2'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 8; h[s][l] = 12; k[s][l] = 2;
		l = '3'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 8; h[s][l] = 12; k[s][l] = 2;
		l = '4'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 8; h[s][l] = 12; k[s][l] = 2;
		l = '5'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 8; h[s][l] = 12; k[s][l] = 2;
		l = '6'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 8; h[s][l] = 12; k[s][l] = 2;
		l = '7'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 8; h[s][l] = 12; k[s][l] = 2;
		l = '8'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 8; h[s][l] = 12; k[s][l] = 2;
		l = '9'; x[s][l] = 4; y[s][l] = 2; w[s][l] = 8; h[s][l] = 12; k[s][l] = 2;
		l = ':'; x[s][l] = 7; y[s][l] = 2; w[s][l] = 4; h[s][l] = 12; k[s][l] = 2;
		l = '-'; x[s][l] = 5; y[s][l] = 2; w[s][l] = 6; h[s][l] = 12; k[s][l] = 2;
		l = '*'; x[s][l] = 2; y[s][l] = 2; w[s][l] = 11; h[s][l] = 12; k[s][l] = 2;
		l = '$'; x[s][l] = 2; y[s][l] = 2; w[s][l] = 12; h[s][l] = 12; k[s][l] = 3;
		s = "SmallFont";
		size[s] = 10;
		l = ' '; x[s][l] = 0; y[s][l] = 0; w[s][l] = 0; h[s][l] = 0; k[s][l] = 4;
		l = 'A'; x[s][l] = 1; y[s][l] = 1; w[s][l] = 7; h[s][l] = 8; k[s][l] = 1;
		l = 'B'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 5; h[s][l] = 8; k[s][l] = 1;
		l = 'C'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 6; h[s][l] = 8; k[s][l] = 1;
		l = 'D'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 6; h[s][l] = 8; k[s][l] = 1;
		l = 'E'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 5; h[s][l] = 8; k[s][l] = 1;
		l = 'F'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 5; h[s][l] = 8; k[s][l] = 1;
		l = 'G'; x[s][l] = 1; y[s][l] = 1; w[s][l] = 7; h[s][l] = 8; k[s][l] = 1;
		l = 'H'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 6; h[s][l] = 8; k[s][l] = 1;
		l = 'I'; x[s][l] = 3; y[s][l] = 1; w[s][l] = 3; h[s][l] = 8; k[s][l] = 1;
		l = 'J'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 5; h[s][l] = 8; k[s][l] = 1;
		l = 'K'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 5; h[s][l] = 8; k[s][l] = 1;
		l = 'L'; x[s][l] = 3; y[s][l] = 1; w[s][l] = 4; h[s][l] = 8; k[s][l] = 1;
		l = 'M'; x[s][l] = 1; y[s][l] = 1; w[s][l] = 7; h[s][l] = 8; k[s][l] = 1;
		l = 'N'; x[s][l] = 1; y[s][l] = 1; w[s][l] = 7; h[s][l] = 8; k[s][l] = 1;
		l = 'O'; x[s][l] = 1; y[s][l] = 1; w[s][l] = 8; h[s][l] = 8; k[s][l] = 1;
		l = 'P'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 6; h[s][l] = 8; k[s][l] = 1;
		l = 'Q'; x[s][l] = 1; y[s][l] = 1; w[s][l] = 8; h[s][l] = 8; k[s][l] = 1;
		l = 'R'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 5; h[s][l] = 8; k[s][l] = 1;
		l = 'S'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 6; h[s][l] = 8; k[s][l] = 1;
		l = 'T'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 5; h[s][l] = 8; k[s][l] = 1;
		l = 'U'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 6; h[s][l] = 8; k[s][l] = 1;
		l = 'V'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 5; h[s][l] = 8; k[s][l] = 1;
		l = 'W'; x[s][l] = 1; y[s][l] = 1; w[s][l] = 7; h[s][l] = 8; k[s][l] = 1;
		l = 'X'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 5; h[s][l] = 8; k[s][l] = 1;
		l = 'Y'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 5; h[s][l] = 8; k[s][l] = 1;
		l = 'Z'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 6; h[s][l] = 8; k[s][l] = 1;
		l = '0'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 6; h[s][l] = 8; k[s][l] = 1;
		l = '1'; x[s][l] = 3; y[s][l] = 1; w[s][l] = 3; h[s][l] = 8; k[s][l] = 1;
		l = '2'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 6; h[s][l] = 8; k[s][l] = 1;
		l = '3'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 6; h[s][l] = 8; k[s][l] = 1;
		l = '4'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 6; h[s][l] = 8; k[s][l] = 1;
		l = '5'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 6; h[s][l] = 8; k[s][l] = 1;
		l = '6'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 6; h[s][l] = 8; k[s][l] = 1;
		l = '7'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 6; h[s][l] = 8; k[s][l] = 1;
		l = '8'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 6; h[s][l] = 8; k[s][l] = 1;
		l = '9'; x[s][l] = 2; y[s][l] = 1; w[s][l] = 6; h[s][l] = 8; k[s][l] = 1;
		l = ':'; x[s][l] = 3; y[s][l] = 1; w[s][l] = 6; h[s][l] = 8; k[s][l] = 1;
		l = '-'; x[s][l] = 3; y[s][l] = 1; w[s][l] = 4; h[s][l] = 8; k[s][l] = 1;
		l = '*'; x[s][l] = 1; y[s][l] = 1; w[s][l] = 7; h[s][l] = 8; k[s][l] = 2;
		l = '$'; x[s][l] = 1; y[s][l] = 1; w[s][l] = 9; h[s][l] = 8; k[s][l] = 2;
	}
}