#ifndef __TRACKER_H__
#define __TRACKER_H__

#define NUM_RECORDS 1080

typedef struct {
	unsigned int time;
	unsigned int ifs_state;
} tracker_msg;

size_t read_debugfs();
int create_server(int);
int connect_client(int);

#endif
