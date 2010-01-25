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

#ifndef RARRAY_LEN
#define RARRAY_LEN(ar) RARRAY(ar)->len
#endif

#ifndef RARRAY_PTR
#define RARRAY_PTR(ar) RARRAY(ar)->ptr
#endif


static VALUE rb_Tagger;
static VALUE rb_NWordTagger;

VALUE Tagger_execute( VALUE self, VALUE text )
{
  NWordTagger *tagger;
  Data_Get_Struct( self, NWordTagger, tagger );
  std::vector<std::string> tags;
  tagger->execute( tags, RSTRING_PTR(text) );
  VALUE results = rb_ary_new2(tags.size());
  for( size_t i = 0; i < tags.size(); ++i ) {
    rb_ary_push( results, rb_str_new( tags[i].c_str(), tags[i].length() ) );
  }
  return results;
}
/*
 * call-seq:
 *    tagger.freq(['word1','word2','word3',...,n])  => {'word1' => 5, 'word2' => 10, ... }
 *
 * run the tagger against a body of text either as an array or as a string.  extract words of interest
 * given the predefined set of tags.
 */
VALUE Tagger_execute_freq( VALUE self, VALUE text )
{
  NWordTagger *tagger;
  Data_Get_Struct( self, NWordTagger, tagger );
  int max_count = 0;
  std::map<std::string,int> tags;
  if( TYPE(text) == T_STRING) {
    tagger->execute_with_frequency( RSTRING_PTR(text), tags, max_count );
  }
  else if( TYPE(text) == T_ARRAY ) {
    // convert ruby array to std vector
    std::vector<std::string> words;
    unsigned int len = RARRAY_LEN(text);
    words.reserve(len);
    for( unsigned int i = 0; i < len; ++i ) {
      words.push_back(std::string(RSTRING_PTR(rb_ary_entry(text,i))));
    }
    tagger->execute_with_frequency( words, tags, max_count );
  }
  else {
    rb_raise(rb_eRuntimeError, "Must provide either a string or array as input");
  }
  VALUE results = rb_hash_new();
  for( std::map<std::string,int>::const_iterator it = tags.begin(); it != tags.end(); ++it ) {
    rb_hash_aset( results, rb_str_new(it->first.c_str(), it->first.length()), rb_int_new(it->second) );
  }
  return results;
}
VALUE Tagger_set_words( VALUE self, VALUE words )
{
  NWordTagger *tagger;
  Data_Get_Struct( self, NWordTagger, tagger );
  tagger->setNWords( NUM2INT(words) );
  return Qnil;
}
VALUE Tagger_load_tags( VALUE self, VALUE tagarr )
{
  NWordTagger *tagger;
  Data_Get_Struct( self, NWordTagger, tagger );
  std::set<std::string> tags;
  int len = RARRAY_LEN(tagarr);
  for( int i = 0; i < len; ++i ){
    std::string tag = RSTRING_PTR( rb_ary_entry( tagarr, i ) );
    tags.insert(tag);
  }
  tagger->loadTags(tags);
  return Qnil;
}

static void Tagger_free( NWordTagger *tagger )
{
  delete tagger;
}

VALUE Tagger_alloc(VALUE klass)
{
  VALUE object;
  NWordTagger *tagger = new NWordTagger();
  object = Data_Wrap_Struct( klass, NULL, Tagger_free, tagger );

  return object;
}

extern "C" void Init_word_tagger()
{
  rb_Tagger = rb_define_module( "Tagger" );
  rb_NWordTagger = rb_define_class_under( rb_Tagger, "WordTagger", rb_cObject );

  rb_define_alloc_func( rb_NWordTagger, Tagger_alloc );

  rb_define_method( rb_NWordTagger, "load_tags", (VALUE (*)(...))Tagger_load_tags, 1 );
  rb_define_method( rb_NWordTagger, "execute", (VALUE (*)(...))Tagger_execute, 1 );
  rb_define_method( rb_NWordTagger, "freq", (VALUE (*)(...))Tagger_execute_freq, 1 );
  rb_define_method( rb_NWordTagger, "set_words", (VALUE (*)(...))Tagger_set_words, 1 );
}
