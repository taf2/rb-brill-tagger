#include "tagger.h"

TaggerContext *tagger_context_new()
{
  return tagger_context_new_with_lexicon_size_hint( 94000 );
}
TaggerContext *tagger_context_new_with_lexicon_size_hint(int lexicon_size)
{
  TaggerContext *tc = (TaggerContext*)malloc(sizeof(TaggerContext));

  tc->lexicon_hash    = Registry_create(Registry_strcmp, Registry_strhash);
  tc->lexicon_tag_hash= Registry_create(Registry_strcmp, Registry_strhash);
  tc->ntot_hash       = Registry_create(Registry_strcmp, Registry_strhash);
  tc->good_right_hash = Registry_create(Registry_strcmp, Registry_strhash);
  tc->good_left_hash  = Registry_create(Registry_strcmp, Registry_strhash);
  tc->bigram_hash     = Registry_create(Registry_strcmp, Registry_strhash);
  tc->wordlist_hash   = Registry_create(Registry_strcmp, Registry_strhash);

  tc->rule_array = Darray_create();
  tc->contextual_rule_array = Darray_create();

  Registry_size_hint(tc->lexicon_hash, lexicon_size);
  Registry_size_hint(tc->lexicon_tag_hash, lexicon_size);

  return tc;
}

/* Used in the free_registry() function below */
static void free_registry_entry(void *key, void *value, void *other)
{
  free(key);
  if( value !=  (void *)1)
    free(value);
}

/* Destroy a Registry whose keys & values have been allocated */
static void free_registry(Registry r) {
  Registry_traverse(r, free_registry_entry, NULL);
  Registry_destroy(r);
}

/* Destroy the memory allocated to one of the rule arrays */
static void free_rule_array(Darray a)
{
  int i;
  int t = Darray_len(a);
  for (i=0; i<t; i++) {
    rule_destroy(Darray_get(a, i));
  }
  Darray_destroy(a);
}

void tagger_context_free( TaggerContext *tc )
{
  free_registry(tc->lexicon_hash);
  free_registry(tc->lexicon_tag_hash);
  free_registry(tc->ntot_hash);
  free_registry(tc->good_right_hash);
  free_registry(tc->good_left_hash);
  free_registry(tc->bigram_hash);
  free_registry(tc->wordlist_hash);

  free_rule_array(tc->rule_array);
  free_rule_array(tc->contextual_rule_array);
}

int tagger_context_add_to_lexicon( TaggerContext *tc, const char *word, const char *tag )
{
  return Registry_add(tc->lexicon_hash, (VOIDP)strdup(word), (VOIDP)strdup(tag));
}

int tagger_context_add_to_lexicon_tags( TaggerContext *tc, const char *bigram )
{
  return Registry_add(tc->lexicon_tag_hash, (VOIDP)strdup(bigram), (VOIDP)1);
}

void tagger_context_add_lexical_rule( TaggerContext *tc, const char *rule )
{
  trans_rule *r = parse_lexical_rule(rule);
  Darray_addh(tc->rule_array, r);
}

void tagger_context_add_contextual_rule( TaggerContext *tc, const char *rule )
{
  trans_rule *r = parse_contextual_rule(rule);
  Darray_addh(tc->contextual_rule_array, r);
}

int tagger_context_add_word_to_wordlist( TaggerContext *tc, const char *word )
{
  return Registry_add(tc->wordlist_hash, (VOIDP)strdup(word), (VOIDP)1);
}

int tagger_context_add_goodleft( TaggerContext *tc, const char *word )
{
  return Registry_add(tc->good_left_hash, (VOIDP)strdup(word), (VOIDP)1);
}

int tagger_context_add_goodright( TaggerContext *tc, const char *word )
{
  return Registry_add(tc->good_right_hash, (VOIDP)strdup(word), (VOIDP)1);
}
