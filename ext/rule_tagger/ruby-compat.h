#ifndef _RUBY_COMPAT_HEADER_H
#define _RUBY_COMPAT_HEADER_H

#define DEBUG
#ifdef DEBUG
#define TRACE()  fprintf(stderr, "> %s:%d:%s\n", __FILE__, __LINE__, __FUNCTION__)
#else
#define TRACE() 
#endif

/* ruby 1.9 compat */
#ifndef RSTRING_PTR
#define RSTRING_PTR(str) RSTRING(str)->ptr
#endif

#ifndef RSTRING_LEN
#define RSTRING_LEN(str) RSTRING(str)->len
#endif

#ifndef RARRAY_LEN
#define RARRAY_LEN(ar) RARRAY(ar)->len
#endif

#ifndef RARRAY_PTR
#define RARRAY_PTR(ar) RARRAY(ar)->ptr
#endif

#endif
