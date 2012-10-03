#include "avocado-global.h"

#include "SdlSample.h"

namespace avo {

AbstractFactory<SdlSample> *SdlSample::factory = new AbstractFactory<SdlSample>;

SdlSample::SdlSample()
	: sample(NULL)
{
}

SdlSample::SdlSample(const boost::filesystem::path &uri)
{
	sample = Mix_LoadWAV(uri.c_str());

	if (!sample) {
		throw std::runtime_error(
			"Mix_LoadWAV failed! SDL says, \"" + std::string(SDL_GetError()) + "\"."
		);
	}

	setUri(uri);
}

SdlSample::~SdlSample() {
	if (sample) Mix_FreeChunk(sample);
}

int SdlSample::play(int loops, int channel) {
	return Mix_PlayChannel(channel, sample, loops);
}

}
