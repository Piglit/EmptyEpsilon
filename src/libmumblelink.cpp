/* libmumblelink.c -- mumble link interface

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

#ifdef WIN32
#include <windows.h>
#else
#include <unistd.h>
#include <sys/mman.h>
//#include <sys/types.h>
//#include <sys/stat.h>
#endif

#include <fcntl.h>

#include <string>
#include <cstring>
#include <cstdlib>
#include <cstdio>
#include "libmumblelink.h"
#include "logging.h"

static mumble::LinkedMem *lm = NULL;

#ifdef WIN32
static HANDLE hMapObject = NULL;
#endif

int mumble::link()
{
	LOG(DEBUG) << "Mumble link";
	if(lm)
		return 0;
	LOG(DEBUG) << "Mumble link connecting...";

#ifdef WIN32
	hMapObject = OpenFileMappingW(FILE_MAP_ALL_ACCESS, FALSE, L"MumbleLink");
	if (hMapObject == NULL)
		return -1;

	lm = (LinkedMem *) MapViewOfFile(hMapObject, FILE_MAP_ALL_ACCESS, 0, 0, sizeof(LinkedMem));
	if (lm == NULL) {
		CloseHandle(hMapObject);
		hMapObject = NULL;
		return -1;
	}
#else
	char file[256];
	int shmfd;

	std::snprintf(file, sizeof (file), "/MumbleLink.%d", getuid());
	shmfd = shm_open(file, O_RDWR, S_IRUSR | S_IWUSR);
	if(shmfd < 0) {
		return -1;
	}

	lm = (LinkedMem *) (mmap(NULL, sizeof(LinkedMem), PROT_READ | PROT_WRITE, MAP_SHARED, shmfd,0));
	if (lm == (void *) (-1)) {
		lm = NULL;
	}
	close(shmfd);
#endif
	std::memset(lm, 0, sizeof(LinkedMem));
	std::mbstowcs(lm->name, "EmptyEpsilon", sizeof(lm->name));
	std::mbstowcs(lm->description, "Positional Audio for EmptyEpsilon", sizeof(lm->description));
	lm->uiVersion = 2;

	LOG(DEBUG) << "Mumble link established";
	return 0;
}

// modified function signature to match EE
void mumble::update_coordinates(float x, float y, float fx, float fy)
{
	if (!lm)
		return;

	LOG(DEBUG) << "Mumble coordinates: " << x << "," << y << "  " << fx << "," << fy;
	lm->fPosition[0] = x;
	lm->fPosition[1] = y;
	lm->fCameraPosition[0] = x;
	lm->fCameraPosition[1] = y;
	lm->fFront[0] = fx;
	lm->fFront[1] = fy;
	lm->fCameraFront[0] = fx;
	lm->fCameraFront[1] = fy;
	lm->uiTick++;
}

// new functions, not in original file

/* identity is usually a playerID.
 * it can contain additional information for server side scripts.
 */
void mumble::update_infos(const std::string identity, const std::string context)
{
	if (!lm)
		return;

	LOG(INFO) << "Mumble identity: " << identity;
	LOG(INFO) << "Mumble context: " << context;
	std::mbstowcs(lm->identity, identity.c_str(), sizeof(lm->identity));
	std::memcpy(lm->context, context.c_str(), sizeof(lm->context));
	lm->context_len = context.length();
	lm->uiTick++;
}

void mumble::reset()
{
	if (!lm)
		return;

	LOG(INFO) << "Mumble reset";
	std::memset(lm->identity, 0, sizeof(lm->identity));
	std::memset(lm->context, 0, sizeof(lm->context));
	lm->context_len = 0;
	mumble::update_coordinates(0.0f,0.0f,0.0f,0.0f);
}

void mumble::unlink()
{
	if(!lm)
		return;
#ifdef WIN32
	UnmapViewOfFile(lm);
	CloseHandle(hMapObject);
	hMapObject = NULL;
#else
	munmap(lm, sizeof(LinkedMem));
#endif
	lm = NULL;
}

bool mumble::islinked(void)
{
	return lm != NULL;
}
