require 'mkmf'

dir_config("rule_tagger")
have_header("stdlib.h")
have_header("string.h")
have_library("c", "main")
CFLAGS='-Wall -g'

create_makefile("rule_tagger")
