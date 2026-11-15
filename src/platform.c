#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "platform.h"

void platform_sleep(int t)
{
#ifdef WINDOWS
	Sleep(t/1000);
#else
	usleep(t);
#endif
}

#ifdef WINDOWS
#define PATHSEP '\\'
#else
#define PATHSEP '/'
#endif

// Makes the folder and any missing parents. Errors show up at chdir.
static void make_path(char *path)
{
	for(char *p=path+1; *p; p++)
	{
		if(*p=='/' || *p=='\\')
		{
			char c=*p;
			*p='\0';
			MKDIR(path,0755);
			*p=c;
		}
	}
	MKDIR(path,0755);
}

// Saves, settings, high scores and the -v log are opened by relative
// paths, so the game keeps them in the folder it starts from. This moves
// into a per-player state folder first, so they stay put wherever the
// game is started from: $XDG_STATE_HOME/diabaig, else
// ~/.local/state/diabaig (on Windows %LOCALAPPDATA%\diabaig). If no
// such folder can be made, the game stays where it was started.
int platform_statedir(void)
{
	char path[1024];
	const char *base=getenv("XDG_STATE_HOME");

	if(base && *base) snprintf(path,sizeof(path),"%s%cdiabaig",base,PATHSEP);
#ifdef WINDOWS
	else if((base=getenv("LOCALAPPDATA")) && *base)
		snprintf(path,sizeof(path),"%s\\diabaig",base);
#else
	else if((base=getenv("HOME")) && *base)
		snprintf(path,sizeof(path),"%s/.local/state/diabaig",base);
#endif
	else return -1;

	make_path(path);
	return chdir(path);
}

// Turns a relative path given on the command line into an absolute one,
// for use after platform_statedir() has changed folder.
void platform_abspath(char *path, size_t size)
{
	char cwd[1024], *tmp;

	if(!path[0] || path[0]=='/' || path[0]=='\\' || (path[0] && path[1]==':')) return;
	if(!getcwd(cwd,sizeof(cwd))) return;
	if(!(tmp=malloc(size))) return;
	snprintf(tmp,size,"%s%c%s",cwd,PATHSEP,path);
	strncpy(path,tmp,size-1);
	path[size-1]='\0';
	free(tmp);
}
