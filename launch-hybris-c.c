#include <unistd.h>
int main() {
  char *const cmd[] = {
    "/usr/bin/screen",
    "-S",
    "hybris",
    "-dm",
    "/bin/bash",
    "-c",
    "export JAVA_HOME=/usr/lib/jvm/jre-1.8.0;cd /usr/local/hybris-6.3/hybris;cd bin/platform/;. ./setantenv.sh;./hybrisserver.sh debug",
    0
  };
  execve(cmd[0], cmd, 0);
  return 111;
}
