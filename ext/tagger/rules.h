
#ifndef _RULES_H_
#define _RULES_H_

#include "darray.h"
#include "registry.h"

typedef struct {
  char *old;
  char *new;
  char *when;
  char *arg1;
  char *arg2;
} trans_rule;

trans_rule *parse_lexical_rule (const char *rule_text);

trans_rule *parse_contextual_rule (const char *rule_text);

void rule_destroy(trans_rule *r);

void change_the_tag(char **theentry, char *thetag, int theposition);

void apply_lexical_rule(const trans_rule *r,
			Darray tag_array_key,
			Darray tag_array_val,
			Registry lexicon_hash,
			Registry wordlist_hash,
			Registry bigram_hash,
			int EXTRAWDS
		       );

void apply_contextual_rule(const trans_rule *r,
			   char **word_corpus_array,
			   char **tag_corpus_array,
			   int corpus_size,
			   int RESTRICT_MOVE,
			   Registry WORDS,
			   Registry SEENTAGGING
			  );

#endif  /* _RULES_H_ */
