#!/usr/bin/env ruby -wKU

require 'rubygems'
require "android-adb"
require "pp"

adb = AndroidAdb::Adb.new()
puts "Packages:"
pp adb.get_packages
