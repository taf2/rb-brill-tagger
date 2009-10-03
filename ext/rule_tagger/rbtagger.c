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

static VALUE
BrillTagger_apply_lexical_rules( VALUE self, VALUE tokens, VALUE tags, VALUE wordlist, VALUE extrawds )
{
  TaggerContext *tc;
  int i = 0;
  int token_length = RARRAY_LEN(tokens);
  int tags_length = RARRAY_LEN(tags);
  int rules_length;
  VALUE fetched;
  int EXTRAWDS = NUM2INT( extrawds );
  Data_Get_Struct( self, TaggerContext, tc );

  if( token_length != tags_length ){
    rb_raise(rb_eArgError, "Error: tags and tokens must be of equal length!");
    return Qnil;
  }
      
  Darray text_array = Darray_create();
  Darray tag_array  = Darray_create();

  Darray_hint( text_array, token_length, token_length );
  Darray_hint( tag_array, token_length, token_length );

  for( i = 0; i < token_length; ++i ){
    fetched = rb_ary_entry(tokens,i);
    if( fetched == Qnil ){
      fprintf(stderr, "token missing %d of %d\n", i, token_length );
      rb_raise(rb_eArgError, "Token was missing unexpectedly");
      return Qnil;
    }
    Darray_addh(text_array, (VOIDP)strdup(RSTRING_PTR(fetched)) );
    fetched = rb_ary_entry(tags,i);
    if( fetched == Qnil ){
      fprintf(stderr, "tag missing %d of %d\n", i, token_length );
      rb_raise(rb_eArgError, "Tag was missing unexpectedly");
      return Qnil;
    }
    Darray_addh(tag_array, (VOIDP)strdup(RSTRING_PTR(fetched)) );
  }
  rules_length = Darray_len(tc->rule_array);
  /* Apply the rules */
  for( i = 0; i < rules_length; ++i ) {
    apply_lexical_rule( Darray_get(tc->rule_array, i),
                        text_array, tag_array,
                        tc->lexicon_hash,
                        tc->wordlist_hash,
                        tc->bigram_hash,
                        EXTRAWDS );
  }
  /* Stuff the results back into the ruby arrays */
  for( i = 0; i < token_length; ++i ) {
    char *text_strref = (char*)Darray_get( text_array, i );
    char *tag_strref = (char*)Darray_get( tag_array, i );

    // copy into ruby space
    rb_ary_store( tokens, i, rb_str_new2(text_strref) );
    rb_ary_store( tags, i, rb_str_new2( tag_strref ) );

    free( text_strref );
    free( tag_strref );
  }

  Darray_destroy(text_array);
  Darray_destroy(tag_array);

  return Qnil;
}
static VALUE
BrillTagger_default_tag_finish( VALUE self, VALUE tokens, VALUE tags )
{
  int i;
  VALUE fetched, word;
  char *tempstr;
  int token_length = RARRAY_LEN(tokens);
  int tags_length = RARRAY_LEN(tags);
  TaggerContext *tc;

  Data_Get_Struct( self, TaggerContext, tc );

  if( token_length != tags_length ){
    rb_raise(rb_eArgError, "Error: tags and tokens must be of equal length!");
    return Qnil;
  }

  for( i = 0; i < token_length; ++i ){
    fetched = rb_ary_entry(tokens,i);
    if( fetched == Qnil ){
      rb_raise(rb_eArgError, "Token was missing unexpectedly");
      return Qnil;
    }
    word = fetched;

    if( (tempstr = Registry_get(tc->lexicon_hash, RSTRING_PTR(word))) != NULL ){
      //fetched = rb_ary_entry(tags,i);
      //printf( "'%s'/%s -> %s\n", RSTRING_PTR(word), RSTRING_PTR(fetched), tempstr );
      rb_ary_store( tags, i, rb_str_new2(tempstr) );
    }
  }
  return Qnil;
}

static VALUE
BrillTagger_apply_contextual_rules( VALUE self, VALUE tokens, VALUE tags, VALUE rmove )
{
  int i;
  int token_length = RARRAY_LEN(tokens);
  int tags_length = RARRAY_LEN(tags);
  int rules_length;
  int restrict_move = NUM2INT( rmove );
  char **text_tags, **text_tokens;
  VALUE fetched;
  TaggerContext *tc;
  Data_Get_Struct( self, TaggerContext, tc );

  if( token_length != tags_length ){
    rb_raise(rb_eArgError, "Error: tags and tokens must be of equal length!");
    return Qnil;
  }
  if( restrict_move && Registry_entry_count( tc->lexicon_hash ) == 0 ){
    rb_raise(rb_eArgError, "Must load a leicon before applying contextual rules");
    return Qnil;
  }

  text_tags = (char**)malloc(sizeof(char*) * tags_length );
  text_tokens = (char**)malloc(sizeof(char*) * token_length );

  // load the tokens and tags into the char * arrays
  for( i = 0; i < token_length; ++i ){
    fetched = rb_ary_entry(tokens,i);
    text_tokens[i] = strdup(RSTRING_PTR(fetched));
    fetched = rb_ary_entry(tags,i);
    text_tags[i] = strdup(RSTRING_PTR(fetched));
  }

  rules_length = Darray_len(tc->contextual_rule_array);
  // Apply the rules
  for( i = 0; i < rules_length; ++i ){
    apply_contextual_rule(Darray_get(tc->contextual_rule_array, i),
                          text_tokens, text_tags, token_length,
                          restrict_move, tc->lexicon_hash, tc->lexicon_tag_hash);
  }

  // load the results back into ruby arrays
  for( i = 0; i < token_length; ++i ){
    rb_ary_store( tags, i, rb_str_new2(text_tags[i]) );
    free(text_tags[i]);
    free(text_tokens[i]);
  }

  free( text_tags );
  free( text_tokens );

  return Qnil;
}

void Init_rule_tagger()
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
  rb_define_method( rb_BrillTagger, "apply_lexical_rules", BrillTagger_apply_lexical_rules, 4 );
  rb_define_method( rb_BrillTagger, "default_tag_finish", BrillTagger_default_tag_finish, 2 );
  rb_define_method( rb_BrillTagger, "apply_contextual_rules", BrillTagger_apply_contextual_rules, 3 );
}
