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

  // return the number of matched tags
  // fill results with matching tags in the text body
  // keep the number of tags returned within the threshold of max. reducing tags by least frequent
  int execute( std::vector<std::string> &reduced_tags, const char *text, unsigned short max = 10 )const;
  int execute( std::vector<std::string> &reduced_tags, const std::vector<std::string> &words, unsigned short max = 10 )const;

  // return the number of matched tags
  // result is updated with a mapping of matched tags with their individual term frequency count
  int execute_with_frequency( const char *text, std::map<std::string,int> &matched_tags, int &max_count )const;
  int execute_with_frequency( const std::vector<std::string> &words, std::map<std::string,int> &matched_tags, int &max_count )const;
private:
  short nwords;
  struct stemmer *stemmer;
  std::map<std::string,std::string> tags;
  std::vector<std::string> words;

  std::string stemWord( const std::string &word )const;
};

#endif
