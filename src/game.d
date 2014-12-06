import std.array;
import std.conv;
import std.math;
import std.stdio;


import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.mixer;
import derelict.opengl3.gl;

import camera;
import gameobject;
import inputhandler;
import tile;
import menu;

class Game { 
	static SDL_Window *window;
	static SDL_Renderer *renderer;

	static private SDL_Rect bounds;

	static int gameObjectCount = 0;
	static int ticks = 0;

	static int SCREEN_WIDTH;
	static int SCREEN_HEIGHT;
	static int TILE_SIZE = 32;
	static int targetFPS = 60;
	static int[] WORLD_SIZE = [20, 15];

	static float fps = 0;

	static string uiFont = "SmallFont";

	static bool running = false;
	static bool paused = false;
	static bool isDebug = true;

	static SDL_GameController*[int] controllers;

	static GameObject[string] gameobjects;
	static GameObject clickedObj;

	static Tile[string] tileMap;
	static Menu[] menus;

	static Camera camera;

	static this();

	static void Init(const(char*) title = "Game", int width = 640, int height = 480, int x = SDL_WINDOWPOS_CENTERED, int y = SDL_WINDOWPOS_CENTERED, int flags = SDL_WINDOW_SHOWN){

		if (SDL_Init(SDL_INIT_EVERYTHING) == -1){
			LogSDLError("Init");
			return;
		}

		SCREEN_WIDTH = width;
		SCREEN_HEIGHT = height;

		camera = new Camera(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

		bounds.x = x;
		bounds.y = y;
		bounds.w = width;
		bounds.h = height;

		window = SDL_CreateWindow(title, bounds.x, bounds.y, bounds.w, bounds.h, SDL_WINDOW_OPENGL);
		if (window == null){
			LogSDLError("CreateWindow");
			return;
		}

		renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
		if (renderer == null){
			LogSDLError("CreateRenderer");
			return;
		}

		if(Mix_OpenAudio( 44100, MIX_DEFAULT_FORMAT, 2, 2048 ) < 0){
			LogSDLError("Mix_OpenAudio");
			return;
		}

		Mix_Init(MIX_INIT_MP3);

		SDL_GL_CreateContext(Game.window);
		DerelictGL.reload();

		running = true;
	}

	static void InitGL(){
		glEnable( GL_TEXTURE_2D );
		glEnable( GL_BLEND );
	    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
		glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
		glViewport( 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT );
		glClear( GL_COLOR_BUFFER_BIT );
		glMatrixMode( GL_PROJECTION );
		glLoadIdentity();

		glOrtho(0.0f, SCREEN_WIDTH, SCREEN_HEIGHT, 0.0f, -10.0f, 10.0f);

		glMatrixMode( GL_MODELVIEW );
		glLoadIdentity();

		SDL_GL_SetSwapInterval(0);
	}

	static void Clear(){
		glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
		glViewport(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
		glClear(GL_COLOR_BUFFER_BIT);
	}

	static void Present(){
		SDL_GL_SwapWindow(window);
	}

	static void RenderMouse(){
		glDisable(GL_TEXTURE_2D);
		glLoadIdentity();
		if(!Game.paused){
			glColor4f(0.125f, 0.125f, 0.125f, 0.5f);
			glBegin(GL_QUADS);
				glVertex3f(camera.gameMouseX*32+1, camera.gameMouseY*32+1, 0.0f);
				glVertex3f(camera.gameMouseX*32+31, camera.gameMouseY*32+1, 0.0f);
				glVertex3f(camera.gameMouseX*32+31, camera.gameMouseY*32+31, 0.0f);
				glVertex3f(camera.gameMouseX*32+1, camera.gameMouseY*32+31, 0.0f);
			glEnd();
		}
		glColor3f(0.5f, 0.05f, 0.7f);
		glBegin(GL_QUADS);
			glColor3f(0.65f, 0.2f, 0.875f);
			glVertex3f(camera.mouseX, camera.mouseY-1, 0.0f);
			glColor3f(0.5f, 0.05f, 0.7f);
			glVertex3f(camera.mouseX+12, camera.mouseY+12, 0.0f);
			glColor3f(0.4f, 0.02f, 0.6f);
			glVertex3f(camera.mouseX+6, camera.mouseY+12, 0.0f);
			glColor3f(0.25f, 0.01f, 0.425f);
			glVertex3f(camera.mouseX, camera.mouseY+18, 0.0f);
		glEnd();
		glColor3f(0.1f, 0.1f, 0.1f);
		glBegin(GL_LINE_LOOP);
			glVertex3f(camera.mouseX, camera.mouseY, 0.0f);
			glVertex3f(camera.mouseX+12, camera.mouseY+12, 0.0f);
			glVertex3f(camera.mouseX+6, camera.mouseY+12, 0.0f);
			glVertex3f(camera.mouseX, camera.mouseY+18, 0.0f);
		glEnd();
	}

	static void Quit(){
		SDL_GL_DeleteContext(window);
		SDL_DestroyRenderer(renderer);
		SDL_DestroyWindow(window);
		SDL_Quit();
	}

	static void LogSDLError(string msg){
		writeln("SDL_" ~ msg ~ " Error: " ~ *SDL_GetError());
	}

	//Destroy a gameobject.
	static void DestroyGameObject(GameObject gameobject){
		if(gameobjects.get(gameobject.name, null)){
			gameobjects.remove(gameobject.name);
		}
		gameobject = null;
		destroy(gameobject);
	}
	
	static void HandleEvents(){
		SDL_GetMouseState(&camera.realMouseX, &camera.realMouseY);
		camera.realMouseX += camera.x;
		camera.realMouseY += camera.y;
		camera.mouseX = camera.realMouseX;
		camera.mouseY = camera.realMouseY;
		camera.gameMouseX = cast(int)(floor(camera.mouseX)/32);
		camera.gameMouseY = cast(int)(floor(camera.mouseY)/32);

		SDL_Event e;
		while (SDL_PollEvent(&e)){
			if (e.type == SDL_QUIT){
				running = false;
			}
			if(e.type == SDL_KEYDOWN){
				InputHandler.mod = e.key.keysym.mod;
				if(!InputHandler.keys[e.key.keysym.scancode])
					InputHandler.justPressed[e.key.keysym.scancode] = true;
				InputHandler.keys[e.key.keysym.scancode] = true;
			}
			if(e.type == SDL_KEYUP){
				InputHandler.mod = e.key.keysym.mod;
				InputHandler.keys[e.key.keysym.scancode] = false;
			}
			if(e.type == SDL_MOUSEBUTTONDOWN){
				if(paused){
					if(menus.length > 0){
						menus.back.MenuClick(e);
					}
				}else{
					GameMouseDown(e);
				}
				
			}
			if(e.type == SDL_MOUSEBUTTONUP){
				if(paused){

				}else{
					GameMouseUp(e);
				}
			}
			if(e.type == SDL_CONTROLLERDEVICEADDED){
				SDL_GameController* ctrl = SDL_GameControllerOpen(e.cdevice.which);
				controllers[SDL_JoystickInstanceID(SDL_GameControllerGetJoystick(ctrl))] = ctrl;
			}
			if(e.type == SDL_CONTROLLERDEVICEREMOVED){
				SDL_GameControllerClose(controllers[e.cdevice.which]);
				controllers.remove(e.cdevice.which);
			}
			if(e.type == SDL_CONTROLLERAXISMOTION){
				InputHandler.axis[e.caxis.which][e.caxis.axis] = e.caxis.value;
			}
			if(e.type == SDL_CONTROLLERBUTTONDOWN){
				InputHandler.button[e.cbutton.which][e.cbutton.button] = true;
			}
			if(e.type == SDL_CONTROLLERBUTTONUP){
				InputHandler.button[e.cbutton.which][e.cbutton.button] = false;
			}
		}
	}

	static void GameMouseDown(SDL_Event e){
		GameObject clicked = null;
		foreach(GameObject g; gameobjects){
			if(g.clickable){
				if(!clicked){
					if(g.x-g.pivot.x <= camera.mouseX && g.x-g.pivot.x+g.width > camera.mouseX && g.y-g.pivot.y <= camera.mouseY && g.y-g.pivot.y+g.height > camera.mouseY){
						clicked = g;
					}
				}else{
					if(clicked.z <= g.z && g.clickable){
						if(g.x-g.pivot.x <= camera.mouseX && g.x-g.pivot.x+g.width > camera.mouseX && g.y-g.pivot.y <= camera.mouseY && g.y-g.pivot.y+g.height > camera.mouseY){
							clicked = g;
						}
					}
				}
			}
		}
		if(clicked){
			clickedObj = clicked;
			clicked.onMouseDown(e);
		}
	}

	static void GameMouseUp(SDL_Event e){
		GameObject clicked = null;
		foreach(GameObject g; gameobjects){
			if(g.clickable){
				if(!clicked){
					if(g.x-g.pivot.x <= camera.mouseX && g.x-g.pivot.x+g.width >= camera.mouseX && g.y-g.pivot.y <= camera.mouseY && g.y-g.pivot.y+g.height >= camera.mouseY){
						clicked = g;
					}
				}else{
					if(clicked.z <= g.z && g.clickable){
						if(g.x-g.pivot.x <= camera.mouseX && g.x-g.pivot.x+g.width >= camera.mouseX && g.y-g.pivot.y <= camera.mouseY && g.y-g.pivot.y+g.height >= camera.mouseY){
							clicked = g;
						}
					}
				}
			}
		}
		if(clickedObj){
			clickedObj.onMouseUp(e);
		}else if(clicked){
			clicked.onMouseUp(e);
		}
	}
}