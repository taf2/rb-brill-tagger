require 'mkmf'

dir_config("tagger")
have_library("c", "main")
have_library("stdc++")

create_makefile("rtagger")
