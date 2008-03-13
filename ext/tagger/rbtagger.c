/** 
 * Copyright (c) 2008 Todd A. Fisher
 * see LICENSE
 */
#include "ruby.h"
#include "tagger.h"
#include "ruby-compat.h"

static VALUE rb_Tagger;
static VALUE rb_BrillTagger;

static
VALUE BrillTagger_alloc(VALUE klass)
{
  VALUE object;
  TaggerContext *tc = tagger_context_new();
  object = Data_Wrap_Struct( klass, NULL, tagger_context_free, tc );
  return object;
}

static VALUE
BrillTagger_add_to_lexicon( VALUE self, VALUE word, VALUE tag )
{
  TaggerContext *tc;
  Data_Get_Struct( self, TaggerContext, tc );
  tagger_context_add_to_lexicon( tc, RSTRING_PTR(word), RSTRING_PTR(tag) );
  return Qnil;
}
static VALUE
BrillTagger_add_to_lexicon_tags( VALUE self, VALUE bigram )
{
  TaggerContext *tc;
  Data_Get_Struct( self, TaggerContext, tc );
  tagger_context_add_to_lexicon_tags( tc, RSTRING_PTR(bigram) );
  return Qnil;
}
static VALUE
BrillTagger_add_contextual_rule( VALUE self, VALUE rule )
{
  TaggerContext *tc;
  Data_Get_Struct( self, TaggerContext, tc );
  tagger_context_add_contextual_rule( tc, RSTRING_PTR(rule) );
  return Qnil;
}
static VALUE
BrillTagger_add_lexical_rule( VALUE self, VALUE rule )
{
  TaggerContext *tc;
  Data_Get_Struct( self, TaggerContext, tc );
  tagger_context_add_lexical_rule( tc, RSTRING_PTR(rule) );
  return Qnil;
}
static VALUE
BrillTagger_add_word_to_wordlist( VALUE self, VALUE word )
{
  TaggerContext *tc;
  Data_Get_Struct( self, TaggerContext, tc );
  tagger_context_add_word_to_wordlist( tc, RSTRING_PTR(word) );
  return Qnil;
}

static VALUE
BrillTagger_add_goodleft( VALUE self, VALUE word )
{
  TaggerContext *tc;
  Data_Get_Struct( self, TaggerContext, tc );
  tagger_context_add_goodleft( tc, RSTRING_PTR(word) );
  return Qnil;
}

static VALUE
BrillTagger_add_goodright( VALUE self, VALUE word )
{
  TaggerContext *tc;
  Data_Get_Struct( self, TaggerContext, tc );
  tagger_context_add_goodright( tc, RSTRING_PTR(word) );
  return Qnil;
}

void Init_tagger()
{
  rb_Tagger = rb_define_module( "Tagger" );
  rb_BrillTagger = rb_define_class_under( rb_Tagger, "BrillTagger", rb_cObject );
  
  rb_define_alloc_func( rb_BrillTagger, BrillTagger_alloc );

  rb_define_method( rb_BrillTagger, "add_to_lexicon", BrillTagger_add_to_lexicon, 2 );
  rb_define_method( rb_BrillTagger, "add_to_lexicon_tags", BrillTagger_add_to_lexicon_tags, 1 );
  rb_define_method( rb_BrillTagger, "add_lexical_rule", BrillTagger_add_lexical_rule, 1 );
  rb_define_method( rb_BrillTagger, "add_contextual_rule", BrillTagger_add_contextual_rule, 1 );
  rb_define_method( rb_BrillTagger, "add_word_to_wordlist", BrillTagger_add_word_to_wordlist, 1 );
  rb_define_method( rb_BrillTagger, "add_goodleft", BrillTagger_add_goodleft, 1 );
  rb_define_method( rb_BrillTagger, "add_goodright", BrillTagger_add_goodright, 1 );
}
