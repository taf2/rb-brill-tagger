require 'mkmf'

dir_config('rule_tagger')
have_header('stdlib.h')
have_header('string.h')
have_library('c', 'main')

if !have_func('snprintf', 'stdio.h')
  raise "You must have snprintf available to compile this library"
end

CFLAGS='-Wall'

create_makefile('rule_tagger')
