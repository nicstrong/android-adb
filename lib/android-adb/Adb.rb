# Author:: Nic Strong  (mailto:nic.strong@gmail.com)
# Copyright:: Copyright (c) 2011 Nic Strong
# License::   MIT (See LICENSE)

require 'open3'
require 'platform'

module AndroidAdb

  class Adb
    # Path to adb command.
    attr_accessor :adb_path
    # Log4r logger to send diagnostic information too.
    attr_accessor :log
    # If true, does not execute the *adb* command. Will still log the command and set last_command.
    attr_accessor :dry_run
    # The last adb shell command executed
    attr_accessor :last_command

    # Contructs an Adb object for issuing commands to the connected device or emulator.
    #
    # If the adb path is not specified in the +opts+ hash it is determined in the following order:
    # 1. Try and use the unix which command to locate the adb binary.
    # 2. Use the ANDROID_HOME environment variable.
    # 3. Default to adb (no path specified).
    #
    # @param [Hash] opts The options to create the Adb object with.
    # @option opts [Logger] :log A log4r logger that debug information can be sent too.
    # @option opts [Boolean] :dry_run Does not execute the *adb* command but will log the command and set last_command.
    # @option opts [Boolean] :adb_path Manually set the path to the adb binary.
    def initialize(opts = {})
      @log = opts[:log] || nil
      @dry_run = opts[:dry_run] || false
      @adb_path = opts[:adb_path] || Adb.find_adb
    end

    # Returns a list of all connected devices. The collection is returned as a hash
    # containing the device name <tt>:name</tt> and the serial <tt>:serial</tt>.
    # @return [Array<Device>] THe list of connected devices/emulators.
    def get_devices
      devices = []
      run_adb("devices") do |pout|
        pout.each do |line|
          line = line.strip
          if (!line.empty? && line !~ /^List of devices/)
            parts = line.split
            device = AndroidAdb::Device.new(parts[0], parts[1])
            devices << device
          end
        end
      end
      return devices
    end

    # Returns a list of all installed packages on the device.
    # @param [Hash] adb_opts Options for the adb command (@see #run_adb)
    # @return [Hash] THe list of installed packages. The hash returned contains the apk file name <tt>:apk</tt> and the name of the package <tt>:name</tt>.
    def get_packages(adb_opts = {})
      packages = []
      run_adb_shell("pm list packages -f", adb_opts) do |pout|
        pout.each do |line|
          @log.debug("{stdout} #{line}") unless @log.nil?
          parts = line.split(":")
          if (parts.length > 1)
            info = parts[1].strip.split("=")
            package = AndroidAdb::Package.new(info[1], info[0]);
            packages << package;
          end
        end
      end
      return packages
    end
    
		def monkey(count, opts = {}, adb_opts = {})
      opt_arg = ""
      opt_arg += " -p #{opts[:package]}" if opts[:package]
      opt_arg += " -c #{opts[:category]}" if opts[:category]
      opt_arg += " --pct-touch #{opts[:pct_touch]}" if opts[:pct_touch]
      opt_arg += " --pct-motion #{opts[:pct_motion]}" if opts[:pct_motion]
      opt_arg += " --pct-trackball #{opts[:pct_trackball]}" if opts[:pct_trackball]
      opt_arg += " --pct-nav #{opts[:pct_nav]}" if opts[:pct_nav]
      opt_arg += " --pct-majornav #{opts[:pct_majornav]}" if opts[:pct_majornav]
      opt_arg += " --pct-appswitch #{opts[:pct_appswitch]}" if opts[:pct_appswitch]
      opt_arg += " --pct-anyevent #{opts[:pct_anyevent]}" if opts[:pct_anyevent]
      opt_arg += " -s #{opts[:seed]}" if opts[:seed]
      opt_arg += " -v -v" if opts[:verbose]
      opt_arg += " --throttle #{opts[:throttle]}" if opts[:throttle]
      opt_arg += " #{count}" unless count.nil?
      
			run_adb_shell("monkey#{opt_arg}", adb_opts) do |pout|
				pout.each do |line|
					@log.debug("{stdout} #{line}") unless @log.nil?
				end
			end
    end

    # Installs a package from the APK file <tt>package</tt> onto the device/emulator.
    # @param [String] package The APK package file
    # @param [Hash] opts The options used to install the package.
    # @option opts [Boolean] :forwardlock Forward lock the package being installed.
    # @option opts [Boolean] :reinstall Reinstall the package, keeping existing data.
    # @option opts [Boolean] :sdcard Install the package to the SD card instead of internal storage.
    # @param [Hash] adb_opts Options for the adb command (@see #run_adb)
    def install(package_path, opts = {}, adb_opts = {})
      opt_arg = opts.nil? ? "" : "-"
      opt_arg += "l" if opts[:forwardlock]
      opt_arg += "r" if opts[:reinstall]
      opt_arg += "t" if opts[:testpackage]
      opt_arg += "s" if opts[:sdcard]
      opt_arg += "d" if opts[:versiondown]
      opt_arg += "g" if opts[:grantperms]

      run_adb("install #{opt_arg} #{package_path}", adb_opts) {|stdout| stdout.each_line {|line| print line}}
    end

    def uninstall(package_name, opts = {}, adb_opts = {})
      opts = opts[:keepdata] ? "-k" : ""
      command = "uninstall #{opts} #{package_name}"

      run_adb(command, adb_opts) {|stdout| stdout.each_line {|line| print line}}
    end

    # Run the adb command with the give <tt>args</tt>.
    # @param [String] args Arguments to the adb command.
    # @param [Hash] adb_opts Options for the adb command.
    # @option adb_opts [String] :serial directs command to the USB device or emulator with the given serial number.
    # @option adb_opts [Boolean] :emulator Directs command to the only running emulator. Returns an error if more than one emulator is running.
    # @option adb_opts [Boolean] :device Directs command to the only connected USB device. Returns an error if more than one USB device connected.
    # @yield [stdout] The standard output of the adb command.
    def run_adb(args, adb_opts = {}, &block) # :yields: stdout
      adb_arg = ""
      adb_arg += " -s #{adb_opts[:serial]}" unless adb_opts[:serial].nil? || adb_opts[:serial].empty?
      adb_arg += " -e" if adb_opts[:emulator]
      adb_arg += " -d" if adb_opts[:device]
      path = "#{@adb_path}#{adb_arg} #{args}"
      last_command = path
      run(path, &block)
    end

    # Run the device shell command given by <tt>args</tt>.
    # @param [String] args Arguments to the adb shell command.
    # @param [Hash] adb_opts Options for the adb command (@see run_adb).
    # @yield [stdout] The standard output of the adb command.
    def run_adb_shell(args, adb_args = {}, &block) # :yields: stdout
      args = "shell #{args}"
      run_adb(args, adb_args, &block)
    end

    private
    def run(path, &block)
      @last_command = path 
      if @dry_run
        @log.debug("Adb Command: #{path}") unless @log.nil? || !@log.debug
        return
      end
      Open3::popen3(path) do |pin, pout, perr|
        if (!@log.nil? && @log.debug?)
          perr.each do |line|
            @log.debug("{stderr} #{line}")
          end
        end
        yield pout
      end
    end

    def self.find_adb
      if (Platform::OS != :win32)
        begin
          which_adb = `which adb`.strip
          return which_adb unless which_adb.nil? || which_adb.empty?
        rescue
        end
      end
      android_home = ENV['ANDROID_HOME']
      if !android_home.nil? && !android_home.empty?
        adb_cmd = File.join(android_home, "platform-tools", "adb")
        if (Platform::OS == :win32)
          adb_cmd += ".exe"
        end
        return adb_cmd
      end
      return "adb"
    end
  end # class
end # module