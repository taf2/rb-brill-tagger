require 'mkmf'
$CFLAGS << ' -Wall'

dir_config("word_tagger")
have_library("c", "main")
have_library("stdc++")

create_makefile("word_tagger")
