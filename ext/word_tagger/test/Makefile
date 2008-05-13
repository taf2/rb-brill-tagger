CFLAGS=-g -Wall #-fprofile-arcs -ftest-coverage

all: porter_stemmer.o tagger.o test.o
	g++ $(CFLAGS) -o testit $^
	time ./testit doc.txt
#	gcov -b tagger.cc
#	valgrind --leak-check=full ./testit
test.o: test.cc tagger.h
	g++ $(CFLAGS) test.cc -c
tagger.o: tagger.cc tagger.h porter_stemmer.h
	g++ $(CFLAGS) tagger.cc -c
porter_stemmer.o: porter_stemmer.c porter_stemmer.h
	gcc $(CFLAGS) porter_stemmer.c -c

setup:
	ln -s ../tagger.h
	ln -s ../tagger.cc
	ln -s ../porter_stemmer.h
	ln -s ../porter_stemmer.c

clean:
	rm -f tagger.o test.o testit
