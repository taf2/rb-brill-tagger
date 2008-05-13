#ifndef PORTER_STEMMER_H
#define PORTER_STEMMER_H
#ifdef __cplusplus
extern "C" {
#endif

struct stemmer;

extern struct stemmer * porter_stemmer_new(void);
extern void porter_stemmer_free(struct stemmer * z);

extern int porter_stem(struct stemmer * z, const char * b, int k);



#ifdef __cplusplus
}
#endif
#endif
