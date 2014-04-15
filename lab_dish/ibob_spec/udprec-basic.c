#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <string.h>
#include <time.h>

#define BUFLEN 1500
#define NPACK 2500000 
#define PORT 6969


int main()
{
  struct sockaddr_in si_me, si_other;
  int s, i, slen=sizeof(si_other), x;
  char buf[BUFLEN];

  FILE *fp;
  time_t tim;
  struct tm *mytime;
  if ((fp = fopen("blah.log", "w")) == NULL) {
	printf("\nerror couldn't open file\n");
  }

  if ((s=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP))==-1)
  {
  printf("socket not working\n");
  return 0;
  }
  memset((char *) &si_me, sizeof(si_me), 0);
  si_me.sin_family = AF_INET;
  si_me.sin_port = htons(PORT);
  si_me.sin_addr.s_addr = htonl(INADDR_ANY);
  if (bind(s, &si_me, sizeof(si_me))==-1) 
  {
  printf("bind error\n");
  return 0;
  }
  for (i=0; i<NPACK; i++) {
    
    x = recvfrom(s, buf, BUFLEN, 0, &si_other, &slen);
    if (x == -1) 
    {
    printf("recv error\n");
    return 0;
    }
    
//	tim = time(NULL);
//	mytime=localtime(&tim);
//        fwrite(mytime,4,9,fp);
	fwrite(buf, 1, x, fp);
	  

// printf("got: %i\n", x);
 //   printf("Received packet from %s:%d\nData: %s\n Size: %i\n", 
  //         inet_ntoa(si_other.sin_addr), ntohs(si_other.sin_port), buf, x);
 }
 fflush(fp); 
 fclose(fp);
  close(s);
  return 0;
}
