// C++ std lib includes
#include <iostream>
#include <chrono>
#include <cstring>

// System includes
#include <linux/limits.h>
#include <unistd.h>
#include <pwd.h>
#include <sys/types.h>
#include <sys/ioctl.h>

#define COLOR(code) "\033[" code "m"
#define RESET_COLOR "\033[0m"
#define RED "1;31"
#define GREEN "1;32"
#define BLUE "0;34"
#define MAGENTA "1;35"
#define ROOT_PATH_MAX_LEN (PATH_MAX / 2)
#define HOME_PATH_MAX_LEN (PATH_MAX / 2 )


const char* path_until_user_dir(const char* path, bool app_slash=true) {
    static char prepath[ROOT_PATH_MAX_LEN];
    size_t child_dir_count = 0;
    size_t path_len = strlen(path);
    size_t i;
    for (i=0;  i < path_len;  ++i) {
        if (path[i] == '/') {
            ++child_dir_count;
        }
        if (child_dir_count == 3) {
            break;
        }
        prepath[i] = path[i];
    }
    prepath[i] = '\0';

    if (app_slash) {
        size_t len = strlen(prepath);
        prepath[len] = '/';
        prepath[len + 1] = '\0';
    }
    return prepath;
}

const char* path_after_user_dir(const char* path) {
    static char postpath[HOME_PATH_MAX_LEN];
    size_t parent_dir_count = 0;
    size_t path_len = strlen(path);
    size_t j = 0;
    for (size_t i=0;  i < path_len;  ++i) {
        if (path[i] == '/') {
            ++parent_dir_count;
            if (parent_dir_count > 3) {
                postpath[j++] = path[i];
            }
            continue;
        }
        if (parent_dir_count > 2) {
            postpath[j++] = path[i];
        }
    }
    postpath[j] = '\0';
    return postpath;
}


int get_terminal_width() {
    winsize w;
    ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
    return w.ws_col;
}

int main()
{
	const char* cwd = get_current_dir_name();

	std::cout
	<< COLOR(GREEN) << path_until_user_dir(cwd, true)
	<< COLOR(MAGENTA) << path_after_user_dir(cwd)
	<< RESET_COLOR
	;

	free((void*)cwd);
	return EXIT_SUCCESS;
}
