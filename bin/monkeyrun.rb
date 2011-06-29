require 'rubygems'

require File.expand_path('../lib/android-adb/Adb', File.dirname(__FILE__))
require File.expand_path('../lib/android-adb/Package', File.dirname(__FILE__))
include AndroidAdb

require 'log4r'
include Log4r

TOUCH=30
MOTION=30
TRACKBALL=0
NAV=0
MAJORNAV=20
APPSWITCH=10
ANYEVENT=10

def parseOptions(args)
	options = OpenStruct.new
	options.count = 1
	options.allowedPackage = nil
	options.logFile = nil
	options.touch = TOUCH
	options.motion = MOTION
	options.trackball = TRACKBALL
	options.nav = NAV
	options.majornav = MAJORNAV
	options.appswitch = APPSWITCH
	options.anyevent = ANYEVENT
	options.verbose = false

	opts = OptionParser.new do |opts|
		opts.banner = "Usage: monkeyrun.rb [options]"

		opts.on("-c", "--count COUNT", "Provision already running instance") do |count|
			options.count = count
		end
		opts.on("-p", "--package ALLOWED_PACKAGE", "Only allow the system to visit activities within the specifieced package") do |package|
			options.allowedPackage = package
		end
		opts.on("-l", "--log LOGFILE", "Log file for diagnostics") do |log|
			options.logFile = log
		end
		opts.on("-v", "--verbose", "Verbose output from monkey") do |verbose|
			options.verbose = true
		end

	end
	opts.parse!(args)
	return options
end


def init(opts)
	@log = Logger.new 'monkeyrun'	
	@log.outputters = FileOutputter.new('file', :filename => 'monkeyrun.log', :trunc => true)
	@log.level = DEBUG

	if (Platform::OS == :win32)
	  adb = Adb.new({:adb_path => 'C:/Andriod/android-sdk-windows/platform-tools/adb.exe', :log => @log})
	else
	  adb = Adb.new({:adb_path => '/Library/android-sdk-mac_x86/platform-tools/adb', :log => @log})
	end
	@log.debug("Created adb #{adb}")
end

init
opts = parseOptions(ARGV)

monkey_opts = { :pct_touch => opts.touch, :pct_motion => opts.motion, :pct_trackball => opts.trackball, 
								:pct_nav => opts.nav, :pct_majornav => opts.majornav, :pct_appswitch => opts.appswitch
								:pct_anyevent => opts.anyevent, :verbose => opts.verbose }

adb.monkey(opts.count, monkey_opts)