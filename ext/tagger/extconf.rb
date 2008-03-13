require 'mkmf'

dir_config("tagger")
have_library("c", "main")
CFLAGS='-Wall -g'

create_makefile("tagger")
