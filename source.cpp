/*This source code copyrighted by Lazy Foo' Productions (2004-2015)
and may not be redistributed without written permission.*/

//Using SDL, standard IO, and strings
#include <SDL2/SDL.h>
#include <stdio.h>
#include <string>
#include <iostream>
#include <complex>
#include <cmath>

using namespace std;
//Screen dimension constants
const int SCREEN_WIDTH = 1080;
const int SCREEN_HEIGHT = 720;

Uint32 rmask = 0x0000ff;
Uint32 gmask = 0x00ff00;
Uint32 bmask = 0xff0000;
int depth = 24;
int pitch = 3*SCREEN_WIDTH;

int iterationsLimit = 256;

//Starts up SDL and creates window
bool init();
 
//Frees media and shuts down SDL
void close();

extern "C" void asmfunc(double , double , double , int * , int , int , int , int *, double, double );


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
		bool quit = false, update = true;
		double zoom = 1.0, mouseposx = SCREEN_WIDTH/2, mouseposy=SCREEN_HEIGHT/2;
		SDL_Event event;
				
		SDL_Renderer * renderer = SDL_CreateRenderer(gWindow, -1, 0);
		Uint8 * pixels = new Uint8[3 * SCREEN_WIDTH * SCREEN_HEIGHT];
		SDL_Surface * surf = NULL;
		SDL_Texture * texture = NULL;
		//memset(pixels, 0, SCREEN_WIDTH * SCREEN_HEIGHT * 3 * sizeof(Uint8)); 
		double x_offset = 0, y_offset = 0;
		
		Uint8 * palette = new Uint8[(iterationsLimit+1)*3];
		for(int i=0; i <= iterationsLimit; i++)
		{
			//palette[3*i+0] = (255*i/iterationsLimit)%256;
			//palette[3*i+1] = i*i / (iterationsLimit*iterationsLimit) * 255 %256;
			palette[3*i+0] = i < 2 * iterationsLimit / 3 ? i * 255 * 3 / (2 * iterationsLimit) : 255;
			palette[3*i+1] = i < iterationsLimit / 3 ? 0 : (i - iterationsLimit / 3) * 255 * 3 / (2 * iterationsLimit);
			palette[3*i+2] = 0;
		}
		
		while( !quit )
		{
			//Handle events on queue
			while( SDL_PollEvent( &event ) != 0 )
			{
				//User requests quit
				if( event.type == SDL_QUIT )
				{
					quit = true;
				}
				if( event.type == SDL_MOUSEBUTTONDOWN )
				{
					mouseposx = event.button.x;
					mouseposy = event.button.y;
					x_offset += (mouseposx - SCREEN_WIDTH/2)*zoom;
					y_offset += (mouseposy - SCREEN_HEIGHT/2)*zoom;
					
					cout << "x_mouse: " << mouseposx - SCREEN_WIDTH/2 << " y_mouse: " << mouseposy - SCREEN_HEIGHT/2 << endl;
			
					cout << "x_off: " << x_offset << " y_off: " << y_offset << endl;
				
					if( event.button.button == SDL_BUTTON_LEFT )
						zoom /= 1.2;
					else 
						zoom *= 1.2;
				
					update = true;
					//SDL_FlushEvents(SDL_QUIT, SDL_LASTEVENT);
				}
					
			}
			if(!update)
			{
				SDL_RenderPresent(renderer);
				continue;
			}
			cout << "Calc start" << endl;
			

			
			cout << "x_off: " << x_offset << " y_off: " << y_offset << endl;
			complex<double> z;
			complex<double> c(-0.835 -0.232i);
		
			int n;
			
			cout << (int*)pixels << " <- pizels | palette -> " << &palette << endl;
			int x = 0, y = 0;
			cout <<  1.0 * (x + x_offset/zoom - (SCREEN_WIDTH - SCREEN_HEIGHT ) /2) / SCREEN_HEIGHT * 4.0 * zoom - 2.0 * zoom << endl;
			cout << -1.0 * (y + y_offset/zoom)/ SCREEN_HEIGHT * 4.0 * zoom + 2.0 * zoom << endl;
			//asmfunc(c.real(), c.imag(), zoom, (int*)pixels, SCREE, 55, 66, palette, x_offset/zoom, y_offset/zoom);
			asmfunc(c.real(), c.imag(), zoom, (int*)pixels, SCREEN_WIDTH, SCREEN_HEIGHT, iterationsLimit, (int*)palette, x_offset/zoom, y_offset/zoom);
			
			/*
			 * for(int y = 0; y < SCREEN_HEIGHT; y++)
			{
				for(int x = 0; x < SCREEN_WIDTH; x++)
				{
					double coordx = 1.0 * (x + x_offset/zoom - (SCREEN_WIDTH - SCREEN_HEIGHT ) /2) / SCREEN_HEIGHT * 4.0 * zoom - 2.0 * zoom;
					
					
					double coordy = -1.0 * (y + y_offset/zoom)/ SCREEN_HEIGHT * 4.0 * zoom + 2.0 * zoom;
					z = {coordx,coordy};
					
					for(n = 0; n < iterationsLimit; n++)
					{
						z = pow(z, 2) + c;
						if(n == 0 && x == 540 && y == 360)
							cout << n << " <- n | z-> " << z.real() << " " << z.imag() << endl;
				
						if(abs(z) > 2)
							break;
					}
					
					//Uint8 red = n*255/iterationsLimit % 256;
					//Uint8 green = 0;
					//Uint8 blue = 255 * (n >= iterationsLimit);
					//pixels[(y*SCREEN_WIDTH + x)*3] = red;
					//pixels[(y*SCREEN_WIDTH + x)*3+1] = green;
					//pixels[(y*SCREEN_WIDTH + x)*3+2] = blue;
					
					pixels[(y*SCREEN_WIDTH + x)*3] = palette[3*n+0];
					pixels[(y*SCREEN_WIDTH + x)*3+1] = palette[3*n+1];
					pixels[(y*SCREEN_WIDTH + x)*3+2] = palette[3*n+2];
					if(x == 540 && y == 360)
						cout << n << " <- n | rgb -> " << (int*)pixels[(y*SCREEN_WIDTH + x)*3] << " " << (int*)pixels[(y*SCREEN_WIDTH + x)*3] << " " << (int*)pixels[(y*SCREEN_WIDTH + x)*3] << " " << endl;
				}
			}
			*/
			
			//SDL_UpdateTexture(texture, NULL, pixels,  SCREEN_WIDTH * 3 * sizeof(Uint8));
			//TO DO: update surface -> update texture
			cout << "Calc end" << endl;
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
			
            SDL_SetRenderDrawColor(renderer, 255, 255, 255, SDL_ALPHA_OPAQUE);
            SDL_RenderDrawLine(renderer, 0, SCREEN_HEIGHT/2, SCREEN_WIDTH, SCREEN_HEIGHT/2);
            SDL_RenderDrawLine(renderer, SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2, SCREEN_HEIGHT);
			SDL_RenderPresent(renderer);
			update = false;
			
		}
		SDL_FreeSurface(surf);
		delete[] pixels;
		SDL_DestroyTexture(texture);
		SDL_DestroyRenderer(renderer);	
	}
	close();

	return 0;
}
	
