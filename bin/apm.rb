##!/usr/bin/env ruby -wKU

require 'rubygems'
require 'log4r'
include Log4r

require File.expand_path('../lib/android-adb/Adb', File.dirname(__FILE__))
require File.expand_path('../lib/android-adb/Package', File.dirname(__FILE__))
include AndroidAdb

require "wx"

class AndroidPackageManagerApp < Wx::App
  def on_init
    ApmFrame.new
  end
end

class ApmFrame < Wx::Frame
  def initialize
    super(nil, :title => "Android Package Manager", :pos => [150, 25], :size => [300, 300])
    @log = Logger.new 'packageman'
    @log.outputters = FileOutputter.new 'file', :filename => 'packageman.log', :trunc => true
    @log.level = Log4r::DEBUG

    panel = Wx::Panel.new(self)

    @packages = get_packages_hash

    packages = Wx::ListBox.new(
        panel,
        :pos => [20, 5],              
        :size => Wx::DEFAULT_SIZE,     
        :choices => @packages.keys, 
        :style => Wx::LB_SINGLE
      )

      #evt_radiobox(radios.get_id()) {|cmd_event| on_change_radio(cmd_event)}
      show
  end

  def on_change_radio(cmd_event)
    selected_drink = cmd_event.string  #Selected radio's label

    #Instead of calling cmd_event.get_string() or cmd_event.set_string(), you can  
    #now call an accessor method with the same name as the property you are trying
    #to get or set. See: wxRuby Overview on the doc page wxruby_intro.html

    @text_widget.label = selected_drink
  end

  def get_packages_hash
    @log.debug("Initialised")
    if (Platform::OS == :win32)
      adb = Adb.new({:adb_path => 'C:/Andriod/android-sdk-windows/platform-tools/adb.exe', :log => @log})
    else
      adb = Adb.new({:adb_path => '/Library/android-sdk-mac_x86/platform-tools/adb'})
    end
    @log.debug("Created adb #{adb}")
    pck = adb.get_packages
    @log.debug("Found #{pck.length} packages")
    @log.debug("Read packages: #{pck}")
    packages = Hash[pck.map {|x| [x.name, x]}]
    @log.debug("Packages:  #{packages}")
    return packages
  end
end

AndroidPackageManagerApp.new.main_loop

