#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <strings.h>
#include "tracker.h"

tracker_msg prec[NUM_RECORDS];

int main(int argc, char* argv[]) {
	int server_socket, client_socket, i, cutix;
	unsigned int latest_time = 0;

	server_socket = create_server(1363);

	if(server_socket < 0)
		return 1;

	client_socket = connect_client(server_socket);

	if(client_socket < 0)
		return 1;

	read_debugfs();

	while(1) {
		if(read_debugfs()) {
			cutix = 1;

			while(cutix < NUM_RECORDS) {
				if(prec[cutix].time < prec[cutix - 1].time)
					break;

				cutix++;
			}

			for(i = cutix; i < NUM_RECORDS; i++) {
				tracker_msg *rec = prec + i;

				if(rec->time > latest_time) {
					size_t n, sz = sizeof(tracker_msg);
					n = write(client_socket, rec, sz);
					if(n != sz) break;
					latest_time = rec->time;
				}
			}

			for(i = 0; i < cutix; i++) {
				tracker_msg *rec = prec + i;

				if(rec->time > latest_time) {
					size_t n, sz = sizeof(tracker_msg);
					n = write(client_socket, rec, sz);
					if(n != sz) break;
					latest_time = rec->time;
				}
			}
		}

		sleep(0.2);
	}

	return 0;
}

size_t read_debugfs() {
	size_t ret;
	FILE *fpin = fopen("/sys/kernel/debug/tracker/tmsg", "r");
	ret = fread(prec, sizeof(tracker_msg), NUM_RECORDS, fpin);
	fclose(fpin);
	return ret;
}

int create_server(int portno) {
	int sockfd = socket(AF_INET, SOCK_STREAM, 0);
	struct sockaddr_in serv_addr;

	if (sockfd < 0) {
		perror("ERROR opening socket");
		return -1;
	}

	bzero((char *)&serv_addr, sizeof(serv_addr));
	serv_addr.sin_family = AF_INET;
	serv_addr.sin_addr.s_addr = INADDR_ANY;
	serv_addr.sin_port = htons(portno);

	if (bind(sockfd, (struct sockaddr *) &serv_addr, sizeof(serv_addr)) < 0) {
		perror("ERROR on binding");
		return -1;
	}

	return sockfd;
}

int connect_client(int sockfd) {
	int listenfd = 0, connfd = 0, newsockfd, clilen;
	struct sockaddr_in cli_addr;

	listen(sockfd, 5);
	clilen = sizeof(cli_addr);

	/* Accept actual connection from the client */
	newsockfd = accept(sockfd, (struct sockaddr *)&cli_addr, &clilen);

	if (newsockfd < 0) {
		perror("ERROR on accept");
		return -1;
	}

	return newsockfd;
}
