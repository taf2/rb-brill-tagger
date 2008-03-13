/** 
 * Copyright (c) 2008 Todd A. Fisher
 * see LICENSE
 */
#include "ruby.h"
#include "tagger.h"

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

static VALUE rb_Tagger;
static VALUE rb_BrillTagger;

static
VALUE BrillTagger_alloc(VALUE klass)
{
  VALUE object;
  return object;
}

void Init_tagger()
{
  rb_Tagger = rb_define_module( "Tagger" );
  rb_BrillTagger = rb_define_class_under( rb_Tagger, "BrillTagger", rb_cObject );
  
  rb_define_alloc_func( rb_BrillTagger, BrillTagger_alloc );
}
