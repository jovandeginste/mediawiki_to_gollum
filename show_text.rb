#!/usr/bin/env ruby

require 'yaml'

file = ARGV.shift

puts YAML.load(File.read(file))[:text]
