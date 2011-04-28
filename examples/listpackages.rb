#!/usr/bin/env ruby -wKU

require 'rubygems'
require "pp"

require File.expand_path('../lib/android-adb', File.dirname(__FILE__))

adb = AndroidAdb::Adb.new()
puts "Packages:"
pp adb.get_packages
