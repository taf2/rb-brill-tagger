require 'mkmf'

dir_config("tagger")
have_library("c", "main")

create_makefile("tagger")
