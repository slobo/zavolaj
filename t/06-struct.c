#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef WIN32
#define DLLEXPORT __declspec(dllexport)
#else
#define DLLEXPORT extern
#endif

typedef struct {
    long intval;
    double numval;
    long *arr;
} MyStruct;

DLLEXPORT MyStruct *ReturnAStruct()
{
    MyStruct *obj = (MyStruct *) malloc(sizeof(MyStruct));
    obj->intval = 17;
    obj->numval = 4.2;
    obj->arr = (long *) malloc(3*sizeof(long));
    obj->arr[0] = 2;
    obj->arr[1] = 3;
    obj->arr[2] = 5;

    return obj;
}

DLLEXPORT void TakeAStruct(MyStruct *obj)
{
    if(obj->intval != 42) printf("not ");
    printf("ok - C-side int value\n");
    if(obj->numval != -3.7) printf("not ");
    printf("ok - C-side num value\n");
    if(!obj->arr || obj->arr[0] != 1) printf("not ");
    printf("ok - C-side array value, element 1\n");
    if(!obj->arr || obj->arr[1] != 2) printf("not ");
    printf("ok - C-side array value, element 2\n");
}
