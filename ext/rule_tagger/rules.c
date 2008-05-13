#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "useful.h"
#include "rules.h"
#include "lex.h"
#include "darray.h"
#include "registry.h"
#include "memory.h"

#define MAXTAGLEN 256  /* max char length of pos tags */
#define MAXWORDLEN 256 /* max char length of words */
#define MAXAFFIXLEN 5  /* max length of affixes being considered */

void change_the_tag(theentry,thetag,theposition)
  char **theentry, *thetag;
  int theposition;
{
  free(theentry[theposition]);
  theentry[theposition] = strdup(thetag);
}

void change_the_tag_darray(tag_array,theposition,thetag)
  Darray tag_array;
  int theposition;
  char *thetag;
{
  free(Darray_get(tag_array, theposition));
  Darray_set(tag_array, theposition, strdup(thetag));
}

void rule_destroy(trans_rule *r) {
  free(r->old);
  free(r->new);
  free(r->when);
  free(r->arg1);
  free(r->arg2);
  free(r);
}

trans_rule *parse_lexical_rule (const char *rule_text) {
  trans_rule *rule = (trans_rule*) malloc(sizeof(trans_rule));
  char **split_ptr = perl_split(rule_text);

  /* The general rule-pattern is:
   * [old] arg1 when [arg2] new
   * 'old' is only present when 'when' starts with 'f'.
   * 'arg2' is only present for a few 'when' types.
   */


  int offset = 0;

  /* Rule types starting with 'f' have an extra 'old' arg at the beginning */
  if (*split_ptr[2] == 'f') {
    rule->old = strdup(split_ptr[0]);
    offset = 1;
  } else {
    rule->old = NULL;
  }

  rule->arg1 = strdup(split_ptr[0 + offset]);
  rule->when = strdup(split_ptr[1 + offset]);

  /* A few rules have a string-length argument too */
  if (strstr(rule->when, "hassuf")    ||
      strstr(rule->when, "haspref")   ||
      strstr(rule->when, "addpref")   ||
      strstr(rule->when, "addsuf")    ||
      strstr(rule->when, "deletesuf") ||
      strstr(rule->when, "deletepref")  ) {
    rule->arg2 = strdup(split_ptr[2 + offset]);
    offset++;
  } else {
    rule->arg2 = NULL;
  }

  rule->new = strdup(split_ptr[2 + offset]);

  return rule;
}

trans_rule *parse_contextual_rule (const char *rule_text) {
  trans_rule *rule = (trans_rule*) malloc(sizeof(trans_rule));
  char **split_ptr = perl_split(rule_text);
  
  rule->old  = strdup(split_ptr[0]);
  rule->new  = strdup(split_ptr[1]);
  rule->when = strdup(split_ptr[2]);
  rule->arg1 = strdup(split_ptr[3]);

  /* The following rule-types take an additional argument */
  if (strcmp(rule->when, "SURROUNDTAG")  == 0 ||
      strcmp(rule->when, "PREVBIGRAM")   == 0 ||
      strcmp(rule->when, "NEXTBIGRAM")   == 0 ||
      strcmp(rule->when, "LBIGRAM")      == 0 ||
      strcmp(rule->when, "WDPREVTAG")    == 0 ||
      strcmp(rule->when, "RBIGRAM")      == 0 ||
      strcmp(rule->when, "WDNEXTTAG")    == 0 ||
      strcmp(rule->when, "WDAND2BFR")    == 0 ||
      strcmp(rule->when, "WDAND2TAGBFR") == 0 ||
      strcmp(rule->when, "WDAND2AFT")    == 0 ||
      strcmp(rule->when, "WDAND2TAGAFT") == 0 )

    rule->arg2 = strdup(split_ptr[4]);
  else
    rule->arg2 = NULL;

  return rule;
}


void apply_contextual_rule(const trans_rule *r,
			   char **word_corpus_array,
			   char **tag_corpus_array,
			   int corpus_size,
			   int RESTRICT_MOVE,
			   Registry WORDS,
			   Registry SEENTAGGING
			  ) {

  char            atempstr2[256];

  int count, tempcount1, tempcount2;
  
  corpus_size--; /* Is used below as the index of the last element (dunno why...) */

  /* fprintf(stderr,"R: OLD: %s NEW: %s WHEN: %s (%s).\n", r->old, r->new, r->when, r->arg1); */
  
  for (count = 0; count <= corpus_size; ++count) {
    if (strcmp(tag_corpus_array[count], r->old) == 0) {

      sprintf(atempstr2,"%s %s", word_corpus_array[count], r->new);
      
      if (! RESTRICT_MOVE || 
	  ! Registry_get(WORDS, word_corpus_array[count]) ||
	  Registry_get(SEENTAGGING,atempstr2)) {
	
	if (strcmp(r->when, "SURROUNDTAG") == 0) {
	  if (count < corpus_size && count > 0) {
	    if (strcmp(r->arg1, tag_corpus_array[count - 1]) == 0 &&
		strcmp(r->arg2, tag_corpus_array[count + 1]) == 0)
	      change_the_tag(tag_corpus_array, r->new, count);
	  }
	} else if (strcmp(r->when, "NEXTTAG") == 0) {
	  if (count < corpus_size) {
	    if (strcmp(r->arg1,tag_corpus_array[count + 1]) == 0)
	      change_the_tag(tag_corpus_array, r->new, count);
	  }
	}  
	else if (strcmp(r->when, "CURWD") == 0) {
	  if (strcmp(r->arg1, word_corpus_array[count]) == 0)
	    change_the_tag(tag_corpus_array, r->new, count);
	} 
	else if (strcmp(r->when, "NEXTWD") == 0) {
	  if (count < corpus_size) {
	    if (strcmp(r->arg1, word_corpus_array[count + 1]) == 0)
	      change_the_tag(tag_corpus_array, r->new, count);
	  }
	} 
	else if (strcmp(r->when, "RBIGRAM") == 0) {
	  if (count < corpus_size) {
	    if (strcmp(r->arg1, word_corpus_array[count]) ==
		0 &&
		strcmp(r->arg2, word_corpus_array[count+1]) ==
		0)
	      change_the_tag(tag_corpus_array, r->new, count);
	  }
	} 
	else if (strcmp(r->when, "WDNEXTTAG") == 0) {
	  if (count < corpus_size) {
	    if (strcmp(r->arg1, word_corpus_array[count]) ==
		0 &&
		strcmp(r->arg2, tag_corpus_array[count+1]) ==
		0)
	      change_the_tag(tag_corpus_array, r->new, count);
	  }
	}
	
	else if (strcmp(r->when, "WDAND2AFT") == 0) {
	  if (count < corpus_size-1) {
	    if (strcmp(r->arg1, word_corpus_array[count]) ==
		0 &&
		strcmp(r->arg2, word_corpus_array[count+2]) ==
		0)
	      change_the_tag(tag_corpus_array, r->new, count);
	  }
	}
	else if (strcmp(r->when, "WDAND2TAGAFT") == 0) {
	  if (count < corpus_size-1) {
	    if (strcmp(r->arg1, word_corpus_array[count]) ==
		0 &&
		strcmp(r->arg2, tag_corpus_array[count+2]) ==
		0)
	      change_the_tag(tag_corpus_array, r->new, count);
	  }
	}
	
	else if (strcmp(r->when, "NEXT2TAG") == 0) {
	  if (count < corpus_size - 1) {
	    if (strcmp(r->arg1, tag_corpus_array[count + 2]) == 0)
	      change_the_tag(tag_corpus_array, r->new, count);
	  }
	} else if (strcmp(r->when, "NEXT2WD") == 0) {
	  if (count < corpus_size - 1) {
	    if (strcmp(r->arg1, word_corpus_array[count + 2]) == 0)
	      change_the_tag(tag_corpus_array, r->new, count);
	  }
	} else if (strcmp(r->when, "NEXTBIGRAM") == 0) {
	  if (count < corpus_size - 1) {
	    if
	      (strcmp(r->arg1, tag_corpus_array[count + 1]) == 0 &&
	       strcmp(r->arg2, tag_corpus_array[count + 2]) == 0)
	      change_the_tag(tag_corpus_array, r->new, count);
	  }
	} else if (strcmp(r->when, "NEXT1OR2TAG") == 0) {
	  if (count < corpus_size) {
	    if (count < corpus_size-1) 
	      tempcount1 = count+2;
	    else 
	      tempcount1 = count+1;
	    if
	      (strcmp(r->arg1, tag_corpus_array[count + 1]) == 0 ||
	       strcmp(r->arg1, tag_corpus_array[tempcount1]) == 0)
	      change_the_tag(tag_corpus_array, r->new, count);
	  }
	}  else if (strcmp(r->when, "NEXT1OR2WD") == 0) {
	  if (count < corpus_size) {
	    if (count < corpus_size-1) 
	      tempcount1 = count+2;
	    else 
	      tempcount1 = count+1;
	    if
	      (strcmp(r->arg1, word_corpus_array[count + 1]) == 0 ||
	       strcmp(r->arg1, word_corpus_array[tempcount1]) == 0)
	      change_the_tag(tag_corpus_array, r->new, count);
	  }
	}   else if (strcmp(r->when, "NEXT1OR2OR3TAG") == 0) {
	  if (count < corpus_size) {
	    if (count < corpus_size -1)
	      tempcount1 = count+2;
	    else 
	      tempcount1 = count+1;
	    if (count < corpus_size-2)
	      tempcount2 = count+3;
	    else 
	      tempcount2 =count+1;
	    if
	      (strcmp(r->arg1, tag_corpus_array[count + 1]) == 0 ||
	       strcmp(r->arg1, tag_corpus_array[tempcount1]) == 0 ||
	       strcmp(r->arg1, tag_corpus_array[tempcount2]) == 0)
	      change_the_tag(tag_corpus_array, r->new, count);
	  }
	} else if (strcmp(r->when, "NEXT1OR2OR3WD") == 0) {
	  if (count < corpus_size) {
	    if (count < corpus_size -1)
	      tempcount1 = count+2;
	    else 
	      tempcount1 = count+1;
	    if (count < corpus_size-2)
	      tempcount2 = count+3;
	    else 
	      tempcount2 =count+1;
	    if
	      (strcmp(r->arg1, word_corpus_array[count + 1]) == 0 ||
	       strcmp(r->arg1, word_corpus_array[tempcount1]) == 0 ||
	       strcmp(r->arg1, word_corpus_array[tempcount2]) == 0)
	      change_the_tag(tag_corpus_array, r->new, count);
	  }
	}  else if (strcmp(r->when, "PREVTAG") == 0) {
	  if (count > 0) {
	    if (strcmp(r->arg1, tag_corpus_array[count - 1]) == 0) {
	      change_the_tag(tag_corpus_array, r->new, count);
	    }
	  }
	} else if (strcmp(r->when, "PREVWD") == 0) {
	  if (count > 0) {
	    if (strcmp(r->arg1, word_corpus_array[count - 1]) == 0) {
	      change_the_tag(tag_corpus_array, r->new, count);
	    }
	  }
	} 
	else if (strcmp(r->when, "LBIGRAM") == 0) {
	  if (count > 0) {
	    if (strcmp(r->arg2, word_corpus_array[count]) ==
		0 &&
		strcmp(r->arg1, word_corpus_array[count-1]) ==
		0)
	      change_the_tag(tag_corpus_array, r->new, count);
	  }
	}
	else if (strcmp(r->when, "WDPREVTAG") == 0) {
	  if (count > 0) {
	    if (strcmp(r->arg2, word_corpus_array[count]) ==
		0 &&
		strcmp(r->arg1, tag_corpus_array[count-1]) ==
		0)
	      change_the_tag(tag_corpus_array, r->new, count);
	  }
	}
	else if (strcmp(r->when, "WDAND2BFR") == 0) {
	  if (count > 1) {
	    if (strcmp(r->arg2, word_corpus_array[count]) ==
		0 &&
		strcmp(r->arg1, word_corpus_array[count-2]) ==
		0)
	      change_the_tag(tag_corpus_array, r->new, count);
	  }
	}
	else if (strcmp(r->when, "WDAND2TAGBFR") == 0) {
	  if (count > 1) {
	    if (strcmp(r->arg2, word_corpus_array[count]) ==
		0 &&
		strcmp(r->arg1, tag_corpus_array[count-2]) ==
		0)
	      change_the_tag(tag_corpus_array, r->new, count);
	  }
	}
	
	else if (strcmp(r->when, "PREV2TAG") == 0) {
	  if (count > 1) {
	    if (strcmp(r->arg1, tag_corpus_array[count - 2]) == 0)
	      change_the_tag(tag_corpus_array, r->new, count);
	  }
	} else if (strcmp(r->when, "PREV2WD") == 0) {
	  if (count > 1) {
	    if (strcmp(r->arg1, word_corpus_array[count - 2]) == 0)
	      change_the_tag(tag_corpus_array, r->new, count);
	  }
	} else if (strcmp(r->when, "PREV1OR2TAG") == 0) {
	  if (count > 0) {
	    if (count > 1) 
	      tempcount1 = count-2;
	    else
	      tempcount1 = count-1;
	    if (strcmp(r->arg1, tag_corpus_array[count - 1]) == 0 ||
		strcmp(r->arg1, tag_corpus_array[tempcount1]) == 0)
	      change_the_tag(tag_corpus_array, r->new, count);
	  }
	} else if (strcmp(r->when, "PREV1OR2WD") == 0) {
	  if (count > 0) {
	    if (count > 1) 
	      tempcount1 = count-2;
	    else
	      tempcount1 = count-1;
	    if (strcmp(r->arg1, word_corpus_array[count - 1]) == 0 ||
		strcmp(r->arg1, word_corpus_array[tempcount1]) == 0)
	      change_the_tag(tag_corpus_array, r->new, count);
	  }
	} else if (strcmp(r->when, "PREV1OR2OR3TAG") == 0) {
	  if (count > 0) {
	    if (count>1) 
	      tempcount1 = count-2;
	    else 
	      tempcount1 = count-1;
	    if (count >2) 
	      tempcount2 = count-3;
	    else 
	      tempcount2 = count-1;
	    if (strcmp(r->arg1, tag_corpus_array[count - 1]) == 0 ||
		strcmp(r->arg1, tag_corpus_array[tempcount1]) == 0 ||
		strcmp(r->arg1, tag_corpus_array[tempcount2]) == 0)
	      change_the_tag(tag_corpus_array, r->new, count);
	  }
	} else if (strcmp(r->when, "PREV1OR2OR3WD") == 0) {
	  if (count > 0) {
	    if (count>1) 
	      tempcount1 = count-2;
	    else 
	      tempcount1 = count-1;
	    if (count >2) 
	      tempcount2 = count-3;
	    else 
	      tempcount2 = count-1;
	    if (strcmp(r->arg1, word_corpus_array[count - 1]) == 0 ||
		strcmp(r->arg1, word_corpus_array[tempcount1]) == 0 ||
		strcmp(r->arg1, word_corpus_array[tempcount2]) == 0)
	      change_the_tag(tag_corpus_array, r->new, count);
	  }
	} else if (strcmp(r->when, "PREVBIGRAM") == 0) {
	  if (count > 1) {
	    if (strcmp(r->arg2, tag_corpus_array[count - 1]) == 0 &&
		strcmp(r->arg1, tag_corpus_array[count - 2]) == 0)
	      change_the_tag(tag_corpus_array, r->new, count);
	  }
	}
	else 
	  fprintf(stderr,
		  "ERROR: %s is not an allowable transform type\n",
		  r->when);
      }
    }
  }
}


void apply_lexical_rule(const trans_rule *r,
			Darray tag_array_key,
			Darray tag_array_val,
			Registry lexicon_hash,
			Registry wordlist_hash,
			Registry bigram_hash,
			int EXTRAWDS
		       ) {

  int count2, count3, tempcount;
  char *tempstr2;
  char *rule_text;

  char tempstr_space[MAXWORDLEN+MAXAFFIXLEN], bigram_space[MAXWORDLEN*2];

  int check_current_tag = (r->when[0] == 'f');
  char *name = strdup( check_current_tag ? &r->when[1] : r->when );

  for (count2=0;count2<Darray_len(tag_array_key);++count2) {

    if (check_current_tag
	? (strcmp(Darray_get(tag_array_val, count2), r->old) != 0)
	: (strcmp(Darray_get(tag_array_val, count2), r->new) == 0))
      continue;
    
    if (strcmp(name, "char") == 0) {
      if(strpbrk(Darray_get(tag_array_key,count2), r->arg1)) {
        change_the_tag_darray(tag_array_val,count2,r->new);
      }
    }
    else if (strcmp(name, "deletepref") == 0) {
      int arg1_len = atoi(r->arg2);

      rule_text = Darray_get(tag_array_key,count2);
      for (count3=0;count3<arg1_len;++count3) {
	if (rule_text[count3] != r->arg1[count3])
	  break;}
      if (count3 == arg1_len) {
	rule_text += arg1_len;
	if (Registry_get(lexicon_hash,(char *)rule_text) != NULL ||
	    (EXTRAWDS &&
	     Registry_get(wordlist_hash,(char *)rule_text) != NULL)){
	  change_the_tag_darray(tag_array_val,count2,r->new);}
      }
    }
    else if (strcmp(name,"haspref") == 0) {
      int arg1_len = atoi(r->arg2);

      rule_text = Darray_get(tag_array_key,count2);
      for (count3=0;count3<arg1_len;++count3) {
	if (rule_text[count3] != r->arg1[count3])
	  break;}
      if (count3 == arg1_len) {
	change_the_tag_darray(tag_array_val,count2,r->new);}
    }
    else if (strcmp(name,"deletesuf") == 0) {
      int arg1_len = atoi(r->arg2);

      rule_text = Darray_get(tag_array_key,count2);
      tempcount=strlen(rule_text)-arg1_len;
      for (count3=tempcount;
	   count3<strlen(rule_text); ++count3) {
	if (rule_text[count3] != r->arg1[count3-tempcount])
	  break;}
      if (count3 == strlen(rule_text)) {
	tempstr2 = strdup(rule_text);
	tempstr2[tempcount] = '\0';
	if (Registry_get(lexicon_hash,(char *)tempstr2) != NULL ||
	    (EXTRAWDS &&
	     Registry_get(wordlist_hash,(char *)tempstr2) != NULL)) {
	  
	  change_the_tag_darray(tag_array_val,count2,r->new);}
	free(tempstr2);
      }
    }
    else if (strcmp(name,"hassuf") == 0) {
      int arg1_len = atoi(r->arg2);
      
      rule_text = Darray_get(tag_array_key,count2);
      tempcount=strlen(rule_text)-arg1_len;
      for (count3=tempcount;
	   count3<strlen(rule_text); ++count3) {
	if (rule_text[count3] != r->arg1[count3-tempcount])
	  break;}
      if (count3 == strlen(rule_text)) {

	change_the_tag_darray(tag_array_val,count2,r->new);}
    }
    else if (strcmp(name,"addpref") == 0) {
      snprintf(tempstr_space,MAXWORDLEN+MAXAFFIXLEN,"%s%s",
	      (char*)r->arg1,(char*)Darray_get(tag_array_key,count2));
      if (Registry_get(lexicon_hash,(char *)tempstr_space) != NULL
	  ||
	  (EXTRAWDS &&
	   Registry_get(wordlist_hash,(char *)tempstr_space) != NULL)) {

	change_the_tag_darray(tag_array_val,count2,r->new);}
    }
    else if (strcmp(name,"addsuf") == 0) {
      snprintf(tempstr_space,MAXWORDLEN+MAXAFFIXLEN,"%s%s",
	      (char*)Darray_get(tag_array_key,count2),
	      (char*)r->arg1);
      if (Registry_get(lexicon_hash,(char *)tempstr_space) != NULL
	  ||
	  (EXTRAWDS &&
	   Registry_get(wordlist_hash,(char *)tempstr_space) != NULL)){

	change_the_tag_darray(tag_array_val,count2,r->new);}
    }
    else if (strcmp(name,"goodleft") == 0) {
      snprintf(bigram_space,MAXWORDLEN*2,"%s %s",
	      (char*)Darray_get(tag_array_key,count2),(char*)r->arg1);
      if (Registry_get(bigram_hash,(char *)bigram_space) != NULL) {
	
	change_the_tag_darray(tag_array_val,count2,r->new);}
    }
    else if (strcmp(name,"goodright") == 0) {
      snprintf(bigram_space,MAXWORDLEN*2,"%s %s",(char*)r->arg1,(char*)Darray_get(tag_array_key,count2));
      if (Registry_get(bigram_hash,(char *)bigram_space) != NULL) {

	change_the_tag_darray(tag_array_val,count2,r->new);}
    }
  }
}
