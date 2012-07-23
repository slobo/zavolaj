#include <stdlib.h>
#include <string.h>

#ifdef WIN32
#define DLLEXPORT __declspec(dllexport)
#else
#define DLLEXPORT extern
#endif

typedef struct {
    char *str;
    long ival;
} Struct;

DLLEXPORT void TakeACallback(void (*cb)(void)) {
    cb();
}

DLLEXPORT void TakeIntCallback(void (*cb)(int)) {
    cb(17);
}

DLLEXPORT void TakeStringCallback(void (*cb)(char *)) {
    /* strdup() so that the dyncall stuff doesn't try to free a stack
     * allocated string. */
    cb(strdup("lorem ipsum"));
}

DLLEXPORT void TakeStructCallback(void (*cb)(Struct *)) {
    Struct *s = (Struct *) malloc(sizeof(Struct));
    s->str = "foobar";
    s->ival = -42;
    cb(s);
}
