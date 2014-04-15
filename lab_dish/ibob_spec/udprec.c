/* History:
 *
 * Version 1.0: Original udprec code. (asiemion)
 * Version 1.1: Added command line options to select filename, number of iterations,and number of packets per iterations. (gfoster)
 * Version 1.1-ugastro: modified version for undergraduate astronomy radio lab dish at Leuschner
 */

#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <string.h>
#include <time.h>

#define BUFLEN 1500
#define SPECTRA 78125
#define NPACK SPECTRA/32 // 2500000 packets
#define PORT 6969

#define VERSION "udprec 1.1-ugastro - 07.25.08"

int main(int argc, char **argv)
{
  struct sockaddr_in si_me, si_other;
  int s, i, slen=sizeof(si_other), x;
  char buf[BUFLEN];

  printf("%s, use -h for help\n",VERSION);
  /*parse command line options*/
  int c;
  char *prefix = "poco_data";
  int iterations = 1;
  int npackets = NPACK;
  //file name header - default poco_data (char *)
  //iterations - default 1 (int)
  //npack - default 1000000
  for (c=1; c<argc; c++)
  {
	if(strcmp(argv[c], "-h") == 0)
	{
		printf("Usage: %s [options]\n", argv[0]);
		printf("\t -p [prefix] : write log files with prefix, default is spec_data\n");
		printf("\t -i [iterations] : number of files to produce, default is 1\n");
		printf("\t -n [spectra] : number of spectra per iteration, default is 78125\n");
		exit(0);
	} else if(strcmp(argv[c], "-p") == 0) {
		prefix = argv[c+1];
		c++;
	} else if(strcmp(argv[c], "-i") == 0) {
		iterations = atoi(argv[c+1]);
		c++;
	} else if(strcmp(argv[c], "-n") == 0) {
		npackets = atoi(argv[c+1]) * 32;
		c++;
	}
  }
  //printf("%s, %i, %i\n", prefix, iterations, npackets);

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

  int iter = 0;
  char *filename;
  for(iter=0; iter<iterations; iter++) {

  sprintf(filename, "%s%i.log",prefix,iter);
  printf("Beginning to write to file %s\n",filename); 

  FILE *fp;
  time_t tim;
  struct tm *mytime;
  if ((fp = fopen(filename, "w")) == NULL) {
	printf("\nerror couldn't open file\n");
  }

  for (i=0; i<npackets; i++) {

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

  }

  close(s);
  return 0;
}

