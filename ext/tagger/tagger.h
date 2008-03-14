#ifndef C_BRILL_TAGGER_H
#define C_BRILL_TAGGER_H

#ifdef __cplusplus
extern "C" {
#endif

#include "lex.h"
#include "darray.h"
#include "registry.h"
#include "memory.h"
#include "useful.h"
#include "rules.h"

typedef struct _TaggerContext{
  Registry lexicon_hash;
  Registry lexicon_tag_hash;
  Registry good_right_hash;
  Registry good_left_hash;
  Registry ntot_hash;
  Registry bigram_hash;
  Registry wordlist_hash;

  Darray rule_array;
  Darray contextual_rule_array;
} TaggerContext;

TaggerContext *tagger_context_new();
TaggerContext *tagger_context_new_with_lexicon_size_hint(int lexicon_size);
void tagger_context_free( TaggerContext *tc );

int tagger_context_add_to_lexicon( TaggerContext *tc, const char *word, const char *tag );
int tagger_context_add_to_lexicon_tags( TaggerContext *tc, const char *bigram );
void tagger_context_add_lexical_rule( TaggerContext *tc, const char *rule );
void tagger_context_add_contextual_rule( TaggerContext *tc, const char *rule );
int tagger_context_add_word_to_wordlist( TaggerContext *tc, const char *word );
int tagger_context_add_goodleft( TaggerContext *tc, const char *word );
int tagger_context_add_goodright( TaggerContext *tc, const char *word );

//void tagger_context_apply_lexical_rules( TaggerContext *tc, const char *word );

#ifdef __cplusplus
}
#endif

#endif
