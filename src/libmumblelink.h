/* libmumblelink.h -- mumble link interface

  Copyright (C) 2008 Ludwig Nussel <ludwig.nussel@suse.de>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.

*/

#ifndef LIBMUMBLELINK
#define LIBMUMBLELINK

#include <string>
#include <inttypes.h>

namespace mumble {
	typedef struct
	{
		uint32_t uiVersion;
		uint32_t uiTick;
		float   fPosition[3];
		float   fFront[3];
		float   fTop[3];
		wchar_t name[256];
	// this was added to the original file, we use uiVersion=2 for context and identity
		float    fCameraPosition[3];
		float    fCameraFront[3];
		float    fCameraTop[3];
		wchar_t  identity[256];
		uint32_t context_len;
		unsigned char context[256];
		wchar_t description[2048];
	} LinkedMem;

	int link();
	bool islinked(void);
	void update_coordinates(float x, float y, float fx, float fy); // modified for EE
	void update_infos(const std::string identity, const std::string context);  // new for EE
	void reset(void);
	void unlink(void);
}
#endif
