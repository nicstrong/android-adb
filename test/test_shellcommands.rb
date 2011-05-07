require 'rubygems'

require "test/unit"

require File.expand_path('../lib/android-adb/Adb', File.dirname(__FILE__))
 
require 'log4r'
include Log4r

class TestAdbCommands < Test::Unit::TestCase
  def test_get_devices
    adb = get_adb
    adb.get_devices
    assert_match(/adb devices$/, adb.last_command)
  end
  
  def test_get_packages
    adb = get_adb
    adb.get_packages
    assert_match(/adb shell pm list packages -f$/, adb.last_command)
  end
  
  def test_get_packages_with_serial
    adb = get_adb

    adb.get_packages({:serial => "1234"})
    assert_match(/adb -s 1234 shell pm list packages -f$/, adb.last_command)
  end
  
  def test_get_packages_with_emulator
    adb = get_adb
    adb.get_packages({:emulator => true})
    assert_match(/adb -e shell pm list packages -f$/, adb.last_command)
  end
  
  def test_get_packages_with_device
    adb = get_adb
    adb.get_packages({:device => true})
    assert_match(/adb -d shell pm list packages -f$/, adb.last_command)
  end
  
  def test_install
    adb = get_adb
    adb.install("test.apk")
    assert_match(/adb install test.apk$/, adb.last_command)
  end
  
  def test_install_with_opts
     adb = get_adb
     adb.install("test.apk", {:forwardlock => true, :reinstall => true, :sdcard => true})
     assert_match(/adb install -l -r -s test.apk$/, adb.last_command)
  end
 
  def test_install_with_serial
    adb = get_adb
    adb.install("test.apk", {}, {:serial => "1234"})
    assert_match(/adb -s 1234 install test.apk$/, adb.last_command)
  end

  def test_install_with_emulator 
    adb = get_adb
    adb.install("test.apk", {}, {:emulator => true})
    assert_match(/adb -e install test.apk$/, adb.last_command) 
  end

 def test_install_with_device
   adb = get_adb 
   adb.install("test.apk", {}, {:device => true})
   assert_match(/adb -d install test.apk$/, adb.last_command) 
 end

 def get_adb
    # @log = Logger.new 'tests'
    # @log.outputters = Outputter.stdout
    # @log.level = Log4r::DEBUG
    return AndroidAdb::Adb.new({:dry_run => true, :log => @log})
  end
end
