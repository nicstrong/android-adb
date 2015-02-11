# Author:: Nic Strong  (mailto:nic.strong@gmail.com)
# Copyright:: Copyright (c) 2011 Nic Strong
# License::   MIT (See LICENSE)

require 'Open3'
require 'Platform'

module AndroidAdb

  class Adb
    attr_accessor :adb_path, :show_stderr, :dry_run, :last_command

    # Contructs an Adb object for issuing commands to the connected device or emulator.
    #
    # If the adb path is not specified in the +opts+ hash it is determined in the following order:
    # 1. Try and use the unix which command to locate the adb binary.
    # 2. Use the ANDROID_HOME environment variable.
    # 3. Default to adb (no path specified).
    #
    # @param [Hash] opts The options to create the Adb object with.
    # @option opts [Boolean] :show_stderr Used for diagnosing issues, it will dump the stderr of the *adb* command being processed.
    # @option opts [Boolean] :dry_run Does not execute the *adb* command but will output the command that would be run.
    # @option opts [Boolean] :adb_path Manually set the path to the adb binary.
    def initialize(opts = {})
      @show_stderr = opts[:show_stderr] || false
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

    # Installs a package from the APK file <tt>package</tt> onto the device/emulator.
    # @param [String] package The APK package file
    # @param [Hash] opts The options used to install the package.
    # @option opts [Boolean] :forwardlock Forward lock the package being installed.
    # @option opts [Boolean] :reinstall Reinstall the package, keeping existing data.
    # @option opts [Boolean] :sdcard Install the package to the SD card instead of internal storage.
    # @param [Hash] adb_opts Options for the adb command (@see #run_adb)
    def install(package, opts = {}, adb_opts = {})
      opt_arg = ""
      opt_arg += " -l" if opts[:forwardlock]
      opt_arg += " -r" if opts[:reinstall]
      opt_arg += " -s" if opts[:sdcard]
      run_adb("install#{opt_arg} #{package}", adb_opts)
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
      adb_arg += " -s #{adb_opts[:serial]}" if !adb_opts[:serial].nil? && !adb_opts[:serial].empty?
      adb_arg += " -e #{adb_opts[:emulator]}" if adb_opts[:emulator]
      adb_arg += " -d #{adb_opts[:device]}" if adb_opts[:emulator]
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
      if @dry_run
        puts "[#{path}]"
        return
      end
      Open3::popen3(path) do |pin, pout, perr|
        if (@show_stderr)
          perr.each do |line|
            puts "{e}" + line
          end
        end
        yield pout
      end
    end

    def self.find_adb
      if (Platform::OS != :win32)
        begin
          which_adb = `which adb`.strip
          return which_adb if !which_adb.nil? && !which_adb.empty?
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


