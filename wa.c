#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>
#include <sys/types.h>

int main() {
	int status;
	char kt[10];
	char **ml = malloc(2*sizeof(void*));
	ml[0] = kt;
	strcpy(kt, "curl");
	char temp_url[100] = "https://api.github.com/orgs/apache/repos?sort=updated&per_page=20&page=";
	for (int i = 1; i <= 114; ++i) {
		int pid = fork();
		if (pid != 0) {
			wait(&status);
		} else {
			chdir("apache_complete");
			char filename[20] = "page";
			char buf[5];
			sprintf(buf, "%d", i);
			strcat(filename, buf);
			strcat(filename, ".txt");
			freopen(filename, "w", stdout);
			strcat(temp_url, buf);
			ml[1] = temp_url;
			execvp("curl", ml);
		}
	}
	return 0;
}
