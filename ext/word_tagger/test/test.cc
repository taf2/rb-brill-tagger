#include <stdio.h>
#include <ctype.h>
#include <sys/stat.h>
#include <assert.h>
#include "tagger.h"

struct TestBase {
  TestBase();
  void overflow();
  void small();
  void large_file();

  std::set<std::string> tags;
  NWordTagger tagger;
};


TestBase::TestBase()
{
  tags.insert("fitness");
  tags.insert("delightful");
  tags.insert("dreaming");
  tags.insert("dreaming of their world");
  tags.insert("names");
  tags.insert("places");
  tags.insert("diabetes");
  tags.insert("sugars");
  tags.insert("allergy");
  tags.insert("dermatitis");
  
  tagger.setNWords( 4 );

  tagger.loadTags( tags );
}

void TestBase::overflow()
{
  // input passed to the filter should be processed to downcase, and remove all punctionation
  std::string words( "hello fitness fitness fitness party dreaming dreaming of their world how are you all doing today so many times I ve seen or heard a delightful story or tales" );
  std::vector<std::string> matched_tags = tagger.execute( words.c_str(), 2 ); 
  
  printf( "%ld tags\n", (long int)matched_tags.size() );
  for( size_t i = 0; i < matched_tags.size(); ++i ){
    printf( "tagged: %s\n", matched_tags[i].c_str() ); 
  }

  assert( matched_tags.size() == 2 );
  assert( matched_tags[0] == "dreaming" );
  assert( matched_tags[1] == "fitness" );
}

void TestBase::small()
{
  // input passed to the filter should be processed to downcase, and remove all punctionation
  std::string words( "nothing to see here" );
  std::vector<std::string> matched_tags = tagger.execute( words.c_str(), 2 ); 

  assert( matched_tags.size() == 0 );
}

void TestBase::large_file()
{
  // input passed to the filter should be processed to downcase, and remove all punctionation
  std::string words;
  FILE *in = fopen("doc.txt","r");
  struct stat s;
  char *buffer = NULL;
  fstat( fileno(in), &s );
  buffer = (char*)malloc(sizeof(char)*(s.st_size+1));
  memset(buffer,'\0',s.st_size+1);
  fread( buffer, sizeof(char), s.st_size, in );
  words = buffer;
  free(buffer);
  fclose(in);

  std::vector<std::string> matched_tags = tagger.execute( words.c_str(), 10 ); 
  
  printf( "%ld tags\n", (long int)matched_tags.size() );
  for( size_t i = 0; i < matched_tags.size(); ++i ){
    printf( "tagged: %s\n", matched_tags[i].c_str() ); 
  }

  assert( matched_tags.size() == 2 );
  assert( matched_tags[0] == "allergy" );
  assert( matched_tags[1] == "dermatitis" );
}

static void test_run()
{
  TestBase test;

  for( int i = 0; i < 10; ++i ) {
    test.overflow();
    test.small();
    test.large_file();
  }

}

int main()
{
  // running multiple iterations to test for memory leaks
  for( int i = 0; i < 2; ++i ) {
    test_run();
  }
  return 0;
}
