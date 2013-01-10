
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <err.h>


#define	ORIG_PATH_OFFSET	0xa7ee0
#define	ORIG_PATH		",\n901 San Antoni"

#define	PATH_PTR_OFFSET		0x3f32e
#define	PATH_PTR_ORIG		0x80fbf84
#define	PATH_PTR_NEW		0x8107ee1

#define	MAX_PATH_STR_LEN	200


int
main(int argc, char **argv)
{
	char buf[MAX_PATH_STR_LEN + 5];
	int fd;
	int replen;
	uint32_t ptr;

	if (argc < 2) {
		printf("usage: %s <path_to_dmake> <new_path>\n", argv[0]);
		exit(1);
	}

	printf("loading dmake: %s\n", argv[1]);

	if ((fd = open(argv[1], O_RDWR)) == -1)
		err(1, "open");

	if (pread(fd, &buf, sizeof (buf), ORIG_PATH_OFFSET) == -1)
		err(1, "pread");

	if (memcmp(buf, ORIG_PATH, strlen(ORIG_PATH)) == 0)
		printf("original path text detected!\n");
	else
		printf("previous replacement path: %s\n", buf);

	/*
	 * Read the pointer to the path string from dmake.
	 */
	if (pread(fd, &ptr, sizeof (ptr), PATH_PTR_OFFSET) != 4)
		err(1, "pread ptr");
	printf("current pointer: %x\n", ptr);
	if (ptr != PATH_PTR_ORIG && ptr != PATH_PTR_NEW) {
		/*
		 * We do not recognise this pointer address, so this is
		 * probably not a dmake we can work with.
		 */
		errx(1, "unrecognised pointer, may not be dmake, aborting!");
	}

	if (argc < 3)
		goto out;

	if ((replen = strlen(argv[2])) >= MAX_PATH_STR_LEN)
		errx(1, "replacement path too long!");

	printf("replacing share path with: %s\n", argv[2]);

	/*
	 * Terminate after the existing Copyright string at the end of the
	 * line, then write our replacement path.  NUL terminate.
	 */
	buf[0] = '\0';
	memcpy(&buf[1], argv[2], replen);
	buf[replen + 1] = '\0';

	if (pwrite(fd, buf, replen + 2, ORIG_PATH_OFFSET) != replen + 2)
		err(1, "pwrite");

	/*
	 * Update the pointer if we need to.
	 */
	if (ptr != PATH_PTR_NEW) {
		ptr = PATH_PTR_NEW;
		printf("new pointer: %x\n", ptr);
		if (pwrite(fd, &ptr, sizeof (ptr), PATH_PTR_OFFSET) !=
		    sizeof (ptr)) {
			err(1, "write pointer");
		}
	}

out:
	(void) close(fd);
	exit(0);
}
