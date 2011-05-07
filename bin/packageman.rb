#!/usr/bin/env ruby -wKU

Shoes.setup do
  gem 'log4r'
  gem 'Platform'
end

require File.expand_path('../lib/android-adb/Adb', File.dirname(__FILE__))
require File.expand_path('../lib/android-adb/Package', File.dirname(__FILE__))

require 'log4r'
include Log4r

Shoes.app :title => "ADB Package Manager", :width => 300, :height => 200 do
  Shoes.show_log

  def init
    @log = Logger.new 'packageman'
    @log.outputters = FileOutputter.new 'file', :filename => 'packageman.log', :trunc => true
    @log.level = DEBUG

  end

  stack :margin => 10 do
    init
    @log.debug("Initialised")
    if (Platform::OS == :win32)
      adb = AndroidAdb::Adb.new({:adb_path => 'C:/Andriod/android-sdk-windows/platform-tools/adb.exe', :log => @log})
    else
      adb = AndroidAdb::Adb.new({:adb_path => '/Library/android-sdk-mac_x86/platform-tools/adb'})
    end
    @log.debug("Created adb #{adb}")
    pck = adb.get_packages
    @log.debug("Found #{pck.length} packages")
    @log.debug("Read packages: #{pck}")
    packages = Hash[pck.map {|x| [x.name, x]}]
    @log.debug("Packages:  #{packages}")
    para "Select package:"
    list_box :items => packages.keys  do |list|
      @package = list.text
    end
    button("Uninstall") { alert("Selected #{@package}") }
  end
end

