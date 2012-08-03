#include <stdlib.h>

typedef struct {
    long *ptr;
} Structy;

static Structy *saved = NULL;

long _deref(long *ptr) {
    return *ptr;
}

long *make_ptr() {
    long *ptr = (long *) malloc(sizeof(long));
    *ptr = 32;
    return ptr;
}

void struct_twiddle(Structy *s) {
    s->ptr = (long *) malloc(sizeof(long));
    *(s->ptr) = 9;
}

void array_twiddle(long **arr) {
    arr[0] = (long *) malloc(sizeof(long));
    arr[1] = (long *) malloc(sizeof(long));
    arr[2] = (long *) malloc(sizeof(long));

    *arr[0] = 1;
    *arr[1] = 2;
    *arr[2] = 3;
}

void dummy(void **arr) {
    /* dummy */
}

void save_ref(Structy *s) {
    saved = s;
}

void atadistance(void) {
    saved->ptr = (long *) malloc(sizeof(long));
    *(saved->ptr) = 42;
}
