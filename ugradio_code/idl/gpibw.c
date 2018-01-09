/* History: this file use to be findpulseconf.c
 * 
 * Version 1.0: Original findpulseconf.c code. (asiemion)
 * Version 1.1: added commandline option for the ibob ip address and config filename (gfoster)
 */

#include <stdio.h>     /* Standard input/output definitions */
#include <string.h>    /* String function definitions */
#include <unistd.h>    /* UNIX standard function definitions */
#include <fcntl.h>     /* File control definitions */
#include <errno.h>     /* Error number definitions */
#include <termios.h>   /* POSIX terminal control definitions */
#include <signal.h>    /* Signal functions*/
#include <math.h>

#include <sys/types.h>  /* tcpip stuff */
#include <sys/socket.h> /* "	 "	   */
#include <netinet/in.h> /* "	 "	   */
#include <arpa/inet.h>  /* "	 "	   */
#include <netdb.h>      /* "	 "	   */
#include <stdlib.h>





int main(int argc, char **argv)  {
FILE *fp;
int i, j, k, l;
struct  hostent  *ptrh;  /* pointer to a host table entry       */
struct  protoent *ptrp;  /* pointer to a protocol table entry   */
struct  sockaddr_in sad; /* structure to hold an IP address     */
int     port;            /* protocol port number                */
char    host[50];           /* pointer to host name                */
char escape[2];
port = 1234;             /* use default port number      */
int fd = -1;
char filename[40];
int buffsize=1024;
char *buffer=malloc(buffsize);
/*parse command line options*/
char *config_file;
char *ibob_ip;

if (argc < 3)
{
	printf("Usage: %s CONFIG_FILE IBOB_IP_ADDRESS\n", argv[0]);
	exit(0);
} else {
	config_file = argv[1];
	ibob_ip = argv[2];
}

/* tcpip buffers */
char dumpbuffer[250000];  /* buffer for command output */
float ret_val = 0;
char buf[50000];       /* buffer for data from the server */
int amtreceived = 0; /* counter to keep track of how much data we have received */
int n, m, outputdone;

/* commands */
char ibobcommand[255];
char carriagereturn[] = "\n";  /* carriage return command */
char setacc[] = "regwrite sync_gen/period 120320\n";  /* acclen command */
char startudp[] = "startudp 169 254 128 10 6969 3\n";

char ibobprompt[] = "IBOB % "; 
 
 
//for(i = 38; i<49; i++) {

       memset((char *)&sad,0,sizeof(sad)); /* clear sockaddr structure */
       sad.sin_family = AF_INET;         /* set family to Internet     */
        
        if (port > 0)                   /* test for legal value         */
                sad.sin_port = htons((u_short)port);
        else {                          /* print error message and exit */
                fprintf(stderr,"Bad port number\n");
                exit(1);
        }
        sprintf(host, ibob_ip);

        /* Convert host name to equivalent IP address and copy to sad. */
       
        ptrh = gethostbyname(host);
        if ( ((char *)ptrh) == NULL ) {
                fprintf(stderr,"Invalid host: %s\n", host);
                exit(1);
        }
        memcpy(&sad.sin_addr, ptrh->h_addr, ptrh->h_length);
       
        /* Map TCP transport protocol name to protocol number. */
       
        if ( ((int)(ptrp = getprotobyname("tcp"))) == 0) {
                fprintf(stderr, "Cannot map \"tcp\" to protocol number");
                exit(1);
        }
       
        /* Create a socket. */
       
        fd = socket(AF_INET, SOCK_STREAM, ptrp->p_proto);
        if (fd < 0) {
                fprintf(stderr, "Socket creation failed\n");
                exit(1);
        }
       
        /* Connect the socket to the specified server. */
       
        if (connect(fd, (struct sockaddr *)&sad, sizeof(sad)) < 0) {
                fprintf(stderr,"Connect failed\n");
                exit(1);
        }
       
//           printf("Trying host: %s\n", host);
//           printf("Port open, sending data to iBob\n");
      
       escape[0] = 255; 
       send(fd, escape, 1, 0);   /* send a the telnet client identifier */
       send(fd, carriagereturn, strlen(carriagereturn), 0);   /* send a command to the ibob */
       amtreceived = 0; 			
       memset((char *)&dumpbuffer,0,sizeof(dumpbuffer)); /* clear buffers */
         
                         fd = socket(AF_INET, SOCK_STREAM, ptrp->p_proto);
                         if (fd < 0) {
                                        printf("Trying host: %s\n", host);    fprintf(stderr, "Socket creation failed\n");
                                 exit(1);
                         }              
                               
                         if (connect(fd, (struct sockaddr *)&sad, sizeof(sad)) < 0) {
                             fprintf(stderr,"Connect failed\n");
                             exit(1);
                         }
       
      
                         escape[0] = 255; 
                         send(fd, carriagereturn, strlen(carriagereturn), 0);   /* send a command to the ibob */
                         amtreceived = 0;
                         n=0;
                         memset((char *)&dumpbuffer,0,sizeof(dumpbuffer)); /* clear buffers */          
             
          memcpy(dumpbuffer+amtreceived, buf, n); /* copy the data into our complete buffer */
             amtreceived = amtreceived + n;   /* increment total byte counter */
       
       
       
        sprintf(filename, config_file);
	//sprintf(filename, "config.txt"); 
        fp = fopen(filename, "r");  
//        printf("Opened configuration file %s\n", filename);
//        printf("configuring ibob: %s\n", host);
        
        while (fgets(ibobcommand, 250, fp) != NULL){            
             usleep(10000);       
             send(fd, ibobcommand, strlen(ibobcommand), 0);   /* send a command to the ibob */
             
             amtreceived = 0; 			
             memset((char *)&dumpbuffer,0,sizeof(dumpbuffer)); /* clear buffers */
       
       }
	usleep(1000);
	recv(fd,buffer,buffsize,0);
//	fprintf(fp,"val %s\n",buffer);
        printf(buffer);
//	return(buffer);
       //usleep(500000);
//       printf("Done... \n");

       fclose(fp);
       close(fd);
       
       

//}



}

