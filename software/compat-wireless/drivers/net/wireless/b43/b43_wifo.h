#ifndef __B43_POLICING_H__
#define __B43_POLICING_H__

/* Driver-specific constants */
#define WIFO_INTERVAL		1

/* For 0.025 second interval
#define WIFO_DELAY		25 // msecs
#define WIFO_TRANS		/40
#define WIFO_60SEC		2400
#define WIFO_30SEC		1200
#define WIFO_15SEC		600
*/

/* For 0.1 second interval */
#define WIFO_DELAY		100 // msecs
#define WIFO_TRANS		/10
#define WIFO_60SEC		600
#define WIFO_30SEC		300
#define WIFO_15SEC		150

struct b43_wldev;

typedef struct {
	unsigned int time;
	unsigned int ifs_state;
} tracker_msg;

void wifo_iteration(struct b43_wldev *dev);
void wifo_debugfs_start(void);
void wifo_debugfs_stop(void);

/* Shared memory map */
#define	LIST_POINTER		0xAF0
#define LIST_START		0xAF2
#define	LIST_END		0xFF8

#endif
