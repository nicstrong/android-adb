# Author::    Nic Strong  (mailto:nic.strong@gmail.com)
# Copyright:: Copyright (c) 2011 Nic Strong
# License::   MIT (See LICENSE)

require 'rubygems'
require 'POpen4'

module AndroidAdb

  class Adb
    attr_accessor :adb_path, :show_stderr, :dry_run

    # Contructs an Adb object for issuing commands to the connected device or emulator.
    # You may set options that control the behaviour of the class in the +opts+ Hash.
    # Available options are:
    #
    # [<b><tt>:show_stderr</tt></b>] Used for diagnosing issues, it will dump the stderr of the *adb* command being processed.
    # [<b><tt>:dry_run</tt></b>] Does not execute the *adb* command but will output the command that would be run.
    # [<b><tt>:adb_path</tt></b>] Manually set the path to the adb binary.
    #
    # If the adb path is not specified in the +opts+ hash it is determined in the following order:
    # 1. Try and use the unix which command to locate the adb binary.
    # 2. Use the ANDROID_HOME environment variable.
    # 3. Default to adb (no path specified).
    def initialize(opts = {})
      @show_stderr = opts[:show_stderr] || false
      @dry_run = opts[:dry_run] || false
      @adb_path = opts[:adb_path] || Adb.find_adb
    end

    # Returns a list of all connected devices. The collection is returned as a hash
    # containing the device name <tt>:name</tt> and the device serial <tt>:serial</tt>
    def get_devices
      devices = []
      run_adb("devices") do |pout|
        pout.each do |line|
          line = line.strip
          if (!line.empty? && line !~ /^List of devices/)
            parts = line.split
            devices << {:name   => parts[0],
                        :serial => parts[1]}
          end
        end
      end
      return devices
    end

    # Returns a list of all installed packages on the device. The hash returned
    # contains the apk file name <tt>:apk</tt> and the name of the package <tt>:name</tt>
    def get_packages
      packages = []
      run_adb_shell("pm list packages -f") do |pout|
        pout.each do |line|
          parts = line.split(":")
          if (parts.length > 1)
            info = parts[1].strip.split("=")
            packages <<  {:apk => info[0], :name => info[1]}
          end
        end
      end
      return packages
    end

    # Installs a package from the APK file +package+ onto the device/emulator.
    # The following options maybe passed to the adb command with the +opts+ hash.
    # [<b><tt>:forwardlock</tt></b>] Forward lock the package being installed.
    # [<b><tt>:reinstall</tt></b>] Reinstall the package, keeping existing data.
    # [<b><tt>:sdcard</tt></b>] Install the package to the SD card instead of internal storage.
    def install(package, opts = {})
      opt_arg = ""
      opt_arg += " -l" if opts[:forwardlock]
      opt_arg += " -r" if opts[:reinstall]
      opt_arg += " -s" if opts[:sdcard]
      run_adb("uninstall#{opt_arg} #{package}")
    end

    # Run the adb command with the give +args+.
    def run_adb(args, &block) # :yields: stdout
      path = "#{@adb_path} #{args}"
      run(path, &block)
    end

    # Run the device shell command given by +args+.
    def run_adb_shell(args, &block) # :yields: stdout
      path = "#{@adb_path} shell #{args}"
      run(path, &block)
    end

    private
    def run(path, &block)
      if @dry_run
        puts "[#{path}]"
        return
      end
      POpen4::popen4(path) do |pout, perr, pin|
        if (@show_stderr)
          perr.each do |line|
            puts "{e}" + line
          end
        end
        yield pout
      end
    end

    def self.find_adb
      begin
        which_adb = `which adb`.strip
        return which_adb if !which_adb.nil? && !which_adb.empty?
      rescue
      end
      android_home = ENV['ANDROID_HOME']
      return File.join(android_homes, "platform-tool/adb") if !android_home.nil? && !android_home.empty
      return "adb"
    end
  end # class
end # module


