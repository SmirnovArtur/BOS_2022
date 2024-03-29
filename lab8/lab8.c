#include <security/pam_appl.h>
#include <security/pam_misc.h>
#include <stdio.h>

static struct pam_conv conv = {
    misc_conv,
    NULL
};

int main(int argc, char *argv[])
{
    pam_handle_t *pamh=NULL;
    int retval;
    const char *user="nobody";

    if(argc == 2) {
	user = argv[1];
    }

    if(argc > 2) {
	fprintf(stderr, "Usage: check_user [username]\n");
	exit(1);
    }

    retval = pam_start("check", user, &conv, &pamh);

    if (retval != PAM_SUCCESS) {
        fprintf(stderr, "Failed to initialize PAM: %s\n", pam_strerror(pamh, retval));
        return 1;
    }

    retval = pam_authenticate(pamh, 0);    /* is user really user? */

    if (retval != PAM_SUCCESS) {
        fprintf(stderr, "Authentication failed: %s\n", pam_strerror(pamh, retval));
        return 1;
    }

    retval = pam_acct_mgmt(pamh, 0);       /* permitted access? */

    /* This is where we have been authorized or not. */

    if (retval == PAM_SUCCESS) {
	fprintf(stdout, "Authenticated\n");
    } else {
	fprintf(stderr, "Not Authenticated: %s\n", pam_strerror(pamh, retval));
    }

    if (pam_end(pamh,retval) != PAM_SUCCESS) {     /* close Linux-PAM */
	pamh = NULL;
	fprintf(stderr, "Failed to release authenticator: %s\n", pam_strerror(pamh, retval));
	exit(1);
    }

    return ( retval == PAM_SUCCESS ? 0:1 );       /* indicate success */
}

