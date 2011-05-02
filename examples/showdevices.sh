#!/usr/bin/env ruby -wKU

require 'rubygems'
require "pp"

require File.expand_path('../lib/android-adb/Adb', File.dirname(__FILE__))
require File.expand_path('../lib/android-adb/Device', File.dirname(__FILE__))

adb = AndroidAdb::Adb.new()
puts "Devices:"
pp adb.get_devices
