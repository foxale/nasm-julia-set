/*This source code copyrighted by Lazy Foo' Productions (2004-2015)
and may not be redistributed without written permission.*/

//Using SDL, standard IO, and strings
#include <SDL2/SDL.h>
#include <stdio.h>
#include <string>
#include <iostream>


//Screen dimension constants
const int SCREEN_WIDTH = 640;
const int SCREEN_HEIGHT = 320;

Uint32 rmask = 0x00ff0000;
Uint32 gmask = 0x0000ff00;
Uint32 bmask = 0x000000ff;
int depth = 24;
int pitch = 3*SCREEN_WIDTH;

//Starts up SDL and creates window
bool init();

//Frees media and shuts down SDL
void close();


SDL_Window* gWindow = NULL;


bool init()
{
	//Initialization flag
	bool success = true;

	//Initialize SDL
	if( SDL_Init( SDL_INIT_VIDEO ) < 0 )
	{
		printf( "SDL could not initialize! SDL Error: %s\n", SDL_GetError() );
		success = false;
	}
	else
	{
		//Create window
		gWindow = SDL_CreateWindow( "SDL Tutorial", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_SHOWN );
		if( gWindow == NULL )
		{
			printf( "Window could not be created! SDL Error: %s\n", SDL_GetError() );
			success = false;
		}
	}

	return success;
}


void close()
{

	SDL_DestroyWindow( gWindow );
	gWindow = NULL;

	SDL_Quit();
}


int main( int argc, char* args[] )
{
	//Start up SDL and create window
	if( !init() )
	{
		printf( "Failed to initialize!\n" );
	}
	else
	{
			//Main loop flag
			bool quit = false;

			//Event handler
			SDL_Event e;

			//While application is running
			
			SDL_Renderer * renderer = SDL_CreateRenderer(gWindow, -1, 0);
			//SDL_Texture * texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGB888, SDL_TEXTUREACCESS_STATIC, SCREEN_WIDTH, SCREEN_HEIGHT);
			Uint8 * pixels = new Uint8[3 * SCREEN_WIDTH * SCREEN_HEIGHT];
			
			//memset(pixels, 0, SCREEN_WIDTH * SCREEN_HEIGHT * 3 * sizeof(Uint8)); 
			SDL_Surface * surf = NULL;
			SDL_Texture * texture = NULL;
			
			
			
			int i = 0;	
			while( !quit )
			{
				//Handle events on queue
				while( SDL_PollEvent( &e ) != 0 )
				{
					//User requests quit
					if( e.type == SDL_QUIT )
					{
						quit = true;
					}
				}
				
				memset(pixels, i, SCREEN_WIDTH * SCREEN_HEIGHT * sizeof(Uint8) * 3); 
				//SDL_UpdateTexture(texture, NULL, pixels,  SCREEN_WIDTH * 3 * sizeof(Uint8));
				//TO DO: update surface -> update texture
				
				SDL_Surface *surf = SDL_CreateRGBSurfaceFrom((void*)pixels, SCREEN_WIDTH, SCREEN_HEIGHT, depth, pitch, rmask, gmask, bmask, 0);			
				if (surf == NULL)
				{
					fprintf(stderr, "CreateRGBSurface failed: %s\n", SDL_GetError());
					SDL_Log("SDL_CreateRGBSurface() failed: %s", SDL_GetError());
					exit(1);
				}
				
				texture = SDL_CreateTextureFromSurface(renderer, surf);
				
				SDL_RenderClear(renderer);
				SDL_RenderCopy(renderer, texture, NULL, NULL);
				SDL_RenderPresent(renderer);
				
				i=++i%256;
				SDL_Delay(10);
			}
			SDL_FreeSurface(surf);
			delete[] pixels;
			SDL_DestroyTexture(texture);
			SDL_DestroyRenderer(renderer);	
	}
	close();

	return 0;
}
