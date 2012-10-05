#include "avocado-global.h"

#include "SdlWindow.h"

void scale_1(SDL_Surface *visible, SDL_Surface *working) {
	SDL_LockSurface(working);
	SDL_LockSurface(visible);

	// Take addresses of the first pixel of the source and destination.
	unsigned int *src = (unsigned int *)working->pixels, *dst = (unsigned int *)visible->pixels;

	// For each pixel from the source image, make it a
	//  2 x 2 block in the destination.
	for (int y = 0; y < 240; ++y) {
		for (int x = 0; x < 320; ++x) {
			*dst++ = *src++;
		}
	}

	SDL_UnlockSurface(visible);
	SDL_UnlockSurface(working);
}

void scale_2(SDL_Surface *visible, SDL_Surface *working) {
	SDL_LockSurface(working);
	SDL_LockSurface(visible);

	// Take addresses of the first pixel of the source and destination.
	unsigned int *src = (unsigned int *)working->pixels, *dst = (unsigned int *)visible->pixels;

	// For each pixel from the source image, make it a
	// 2 x 2 block in the destination.
	for (int y = 0; y < 240; ++y) {
		for (int x = 0; x < 320; ++x) {
			dst[0] = dst[1] = dst[640] = dst[641] = *src++;
			dst += 2;
		}
		dst += 640;
	}

	SDL_UnlockSurface(visible);
	SDL_UnlockSurface(working);
}

void scale_2_5(SDL_Surface *visible, SDL_Surface *working) {
	SDL_LockSurface(working);
	SDL_LockSurface(visible);

	// Take addresses of the first pixel of the source and destination.
	unsigned int *src = (unsigned int *)working->pixels, *dst = (unsigned int *)visible->pixels;
	int flip_x = 0;
	int flip_y = 0;

	// For each pixel from the source image, make it a
	// 2.5 x 2.5 block in the destination.
	for (int y = 0; y < 240; ++y) {
		for (int x = 0; x < 320; ++x) {
			int p = *src++;
			dst[0] = dst[1] = dst[800] = dst[801] = p;
			if (flip_y) {
				dst[1600] = dst[1601] = p;
			}
			if (flip_x) {
				dst[2] = dst[802] = p;
				if (flip_y) {
					dst[1602] = p;
				}
			}
			dst += 2 + flip_x;
			flip_x = flip_x xor 1;
		}
		dst += 800 + (flip_y ? 800 : 0);
		flip_y = flip_y xor 1;
	}

	SDL_UnlockSurface(visible);
	SDL_UnlockSurface(working);
}

void scale_3(SDL_Surface *visible, SDL_Surface *working) {
	SDL_LockSurface(working);
	SDL_LockSurface(visible);

	// Take addresses of the first pixel of the source and destination.
	unsigned int *src = (unsigned int *)working->pixels, *dst = (unsigned int *)visible->pixels;

	// For each pixel from the source image, make it a
	// 2 x 2 block in the destination.
	for (int y = 0; y < 240; ++y) {
		for (int x = 0; x < 320; ++x) {
			dst[0] = dst[1] = dst[2] = dst[960] = dst[961] = dst[962] = dst[1920] = dst[1921] = dst[1922] = *src++;
			dst += 3;
		}
		dst += 1920;
	}

	SDL_UnlockSurface(visible);
	SDL_UnlockSurface(working);
}

void scale_4(SDL_Surface *visible, SDL_Surface *working) {
	SDL_LockSurface(working);
	SDL_LockSurface(visible);

	// Take addresses of the first pixel of the source and destination.
	unsigned int *src = (unsigned int *)working->pixels, *dst = (unsigned int *)visible->pixels;

	// For each pixel from the source image, make it a
	// 2 x 2 block in the destination.
	for (int y = 0; y < 240; ++y) {
		for (int x = 0; x < 320; ++x) {
			dst[0] = dst[1] = dst[2] = dst[3] =
			dst[1280] = dst[1281] = dst[1282] = dst[1283] =
			dst[2560] = dst[2561] = dst[2562] = dst[2563] =
			dst[3840] = dst[3841] = dst[3842] = dst[3843] =
			*src++;
			dst += 3;
		}
		dst += 3840;
	}

	SDL_UnlockSurface(visible);
	SDL_UnlockSurface(working);
}

namespace avo {

AbstractFactory<SdlWindow> *SdlWindow::factory = new AbstractFactory<SdlWindow>();

SdlWindow::SdlWindow()
	: image(new SdlImage())
{
}

SdlWindow::~SdlWindow() {

	// SDL will free the surface automatically.
	image->surface = NULL;

	delete image;
}

void SdlWindow::render(Image *working) {

	SDL_Surface *imageSurface = image->surface;
	SDL_Surface *workingSurface = Image::superCast<SdlImage>(working)->surface;

	// Scale the offscreen buffer to the visible buffer.
	// @todo The scale factor needs to be dynamically set. Also, if the
	// source is the same as the destination, we need to skip
	// this call altogether, for speed.
	switch (image->width()) {

		case 320:
			scale_1(imageSurface, workingSurface);
			break;

		case 640:
			scale_2(imageSurface, workingSurface);
			break;

		case 800:
			scale_2_5(imageSurface, workingSurface);
			break;

		case 960:
			scale_3(imageSurface, workingSurface);
			break;

		default:

			throw std::runtime_error(
				"Unsupported graphics resolution encountered."
			);
	}

	SDL_Flip(imageSurface);
}

void SdlWindow::set(int width, int height, WindowFlags f) {
	Window::set(width, height, f);

	// We have to restore the video mode at least once, since we set dummy
	// during SPII initialization (to allow images to be created before we
	// get to this call).
	if (SDL_getenv(const_cast<char *>("AVOCADO_SDL_VIDEORESTORE"))) {
		SDL_QuitSubSystem(SDL_INIT_VIDEO);

		// Get the current driver, if any.
		const char *currentDriver = SDL_getenv(const_cast<char *>("AVOCADO_SDL_VIDEODRIVER"));
		if (currentDriver && "" != std::string(currentDriver)) {
			std::string driver = "SDL_VIDEODRIVER=";
			driver += currentDriver;

			// (Safely) copy the new driver into a C string for SDL_putenv().
			char *driverArray = new char[256];
			strncpy(driverArray, driver.c_str(), 255);
			driverArray[255] = 0;
			SDL_putenv(driverArray);
		}

		// Otherwise, let SDL decide which driver to use.
		else {
#ifdef __MINGW32__
			SDL_putenv(const_cast<char *>("SDL_VIDEODRIVER="));
#else
			unsetenv("SDL_VIDEODRIVER");
#endif
		}

		SDL_InitSubSystem(SDL_INIT_VIDEO);

		// We only want to restore the video driver once.
#ifdef __MINGW32__
		SDL_putenv(const_cast<char *>("AVOCADO_SDL_VIDEODRIVER="));
#else
		unsetenv("AVOCADO_SDL_VIDEODRIVER");
#endif

	}

	// Translate Window flags to SDL flags.
	int sdlFlags = 0;
	if (f & Flags_Fullscreen) sdlFlags |= SDL_FULLSCREEN;

	// Access the image internals to directly set the screen buffer.
	image->surface = SDL_SetVideoMode(width, height, 32, sdlFlags);
}

void SdlWindow::setMouseVisibility(bool visible) {
	SDL_ShowCursor(visible ? SDL_ENABLE : SDL_DISABLE);
}

void SdlWindow::setWindowTitle(const std::string &window, const std::string &iconified) {

	SDL_WM_SetCaption(
		window.c_str(),
		(iconified == "" ? window : iconified).c_str()
	);
}

}

