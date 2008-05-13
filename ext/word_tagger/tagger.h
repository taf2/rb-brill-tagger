#ifndef NWORD_TAGGER_H
#define NWORD_TAGGER_H
#include <set>
#include <map>
#include <string>
#include <vector>

struct NWordTagger {
  NWordTagger();
  ~NWordTagger();

  void loadTags( const std::set<std::string> &tags );

  short getNWords()const{ return nwords; }
  void setNWords( short words ){ nwords = words; }

  std::vector<std::string> execute( const char *text, short max = 10 )const;
private:
  short nwords;
  struct stemmer *stemmer;
  std::map<std::string,std::string> tags;
  std::vector<std::string> words;

  std::string stemWord( const std::string &word )const;
};

#endif
