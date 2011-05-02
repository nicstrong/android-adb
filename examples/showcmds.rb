#!/usr/bin/env ruby -wKU

require File.expand_path('../lib/android-adb/Adb', File.dirname(__FILE__))

adb = AndroidAdb::Adb.new({:dry_run => true})
puts "Packages:"
adb.get_packages
adb.get_packages({:serial => "1234"})

puts "Devices:"
adb.get_devices

puts "Uninstall:"
adb.install("com.example.package")
adb.install("com.example.package", {:forwardlock => true}, {:serial => "abcd"})
adb.install("com.example.package", {:reinstall => true})
adb.install("com.example.package", {:sdcard => true})
adb.install("com.example.package", {:forwardlock => true, :reinstall => true, :sdcard => true})
