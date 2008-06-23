require 'test/unit'
$:.unshift File.join(File.dirname(__FILE__),'..','ext','rule_tagger')
$:.unshift File.join(File.dirname(__FILE__),'..','ext','word_tagger')
$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'rbtagger'
