#!/usr/bin/env ruby -wKU

require 'rubygems'

require File.expand_path('../lib/android-adb/Adb', File.dirname(__FILE__))
require File.expand_path('../lib/android-adb/Package', File.dirname(__FILE__))
include AndroidAdb

require 'log4r'
include Log4r

@log = Logger.new 'packageman'
@log.outputters = FileOutputter.new 'file', :filename => 'monkeyrun.log', :trunc => true
@log.level = DEBUG

if (Platform::OS == :win32)
  adb = Adb.new({:adb_path => 'C:/Andriod/android-sdk-windows/platform-tools/adb.exe', :log => @log})
else
  adb = Adb.new({:adb_path => '/Library/android-sdk-mac_x86/platform-tools/adb', :log => @log})
end
@log.debug("Created adb #{adb}")

