#include "b43.h"
#include "main.h"
#include "b43_wifo.h"

#define NUM_RECORDS 216

/* DebugFS-related variables */
tracker_msg *pmsg;
struct dentry* trackerDir = NULL;
struct debugfs_blob_wrapper blob;

void wifo_iteration(struct b43_wldev *dev) {
	unsigned int counter, list_pointer, db_counter;
	unsigned int temp1, temp2;

	list_pointer = b43_shm_read16(dev, B43_SHM_SHARED, LIST_POINTER);
	db_counter = 0;

	list_pointer = LIST_END;
	for(counter = LIST_START; counter <= list_pointer; counter += 6) {
		temp1 = (unsigned int)b43_shm_read16(dev, B43_SHM_SHARED, counter);
		temp2 = (unsigned int)b43_shm_read16(dev, B43_SHM_SHARED, counter + 2);
		pmsg[db_counter].time = temp1 + temp2 * 65536;
		pmsg[db_counter].ifs_state = b43_shm_read16(dev, B43_SHM_SHARED, counter + 4);
		db_counter++;
	}
}

void wifo_debugfs_start() {
	int size;

	trackerDir = debugfs_create_dir("tracker", NULL);
	printk("Tracker DENTRY: %p", trackerDir);

	size = sizeof(tracker_msg) * NUM_RECORDS;
	pmsg = kmalloc(size, GFP_KERNEL);

	if(pmsg != NULL) {
		memset(pmsg, 0, size);

		if(trackerDir != NULL) {
			blob.data = pmsg;
			blob.size = size;

			if(debugfs_create_blob("tmsg", 0444, trackerDir, &blob) == NULL) {
				printk("NULL dentry returned for tmesg");
			}
		}
	}
}

void wifo_debugfs_stop() {
	if(trackerDir != NULL)
		debugfs_remove_recursive(trackerDir);

	kfree(pmsg);
}
