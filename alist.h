/****************************************************************************\
| CCHR - A CHR-in-C to C compiler                                            |
| alist.h - header for working with dynamical array lists                    |
| written by Pieter Wuille                                                   |
\****************************************************************************/ 

#ifndef _alist_h_
#define _alist_h_ 1

/* declare var to be a 'alist' of type 'type' */
#define alist_declare(type,var) struct { int _n,_a; type *_d; } var

/* initialize an alist */
#define alist_init(var) do {(var)._n=0; (var)._a=0; (var)._d=NULL; } while(0);

/* get an element from alist 'var' on 0-based position 'pos' (no boundary check) */
#define alist_get(var,pos) ((var)._d[(pos)])

/* get an assignable pointer to the 'pos'th element of alist 'var' (no boundary check) */
#define alist_ptr(var,pos) ((var)._d+(pos))

/* ensure alist 'var' can contain at least 'size' elements */
#define alist_ensure(var,size) do { \
  if ((var)._a < (size)) { \
    (var)._a=(((size)*5)/4)+3; \
    (var)._d=realloc((var)._d,sizeof(*((var)._d))*(var)._a); \
  } \
} while(0);

/* add a new element at the end of alist 'var' and put a pointer to it in 'var' */
#define alist_new(var,ptr) do { \
  (var)._n++; \
  alist_ensure(var,(var)._n); \
  (ptr)=(var)._d+(var)._n-1; \
} while(0);

/* add an existing element 'val' to the end of alist 'var' */ 
#define alist_add(var,val) do { \
  alist_ensure(var,((var)._n+1)); \
  (var)._d[(var)._n]=val; \
  (var)._n++; \
} while(0);

/* remove the last element from the array and put it in 'val' */
#define alist_pop(var,val) do { \
  (var)._n--; \
  (val) = (var)._d[((var)._n)]; \
} while(0);

/* get the number of elements in alist 'var' */
#define alist_len(var) ((var)._n)

/* free the data occupied by alist 'var' WARNING: free the memory of the elements before calling this */
#define alist_free(var) do { free((var)._d); (var)._d=NULL; (var)._n=0; (var)._a=0; } while(0);

/* add all elements in alist 'var2' at the end of alist 'var1' */
#define alist_addall(var1,var2) do { \
  alist_ensure((var1),((var1)._n+(var2)._n)); \
  int _j=0; \
  while (_j<(var2)._n) { \
    (var1)._d[(var1)._n++]=(var2)._d[_j++]; \
  } \
} while(0);

#endif
