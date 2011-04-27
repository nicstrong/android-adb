require 'rubygems'
require 'popen4'

module AndroidAdb

  class Adb
    attr_accessor :adb_path, :show_stderr, :dry_run

    def initialize(opts = {})
      @show_stderr = opts[:show_stderr] || false
      @dry_run = opts[:dry_run] || false
      # @adb_path = opts[:adb_path] || 'C:\Andriod\android-sdk-windows\platform-tools\adb.exe'
      @adb_path = opts[:adb_path] || '/Library/android-sdk-mac_x86/platform-tools/adb'
    end # def

    def get_devices
      devices = []
      run_adb("devices") do |pout|
        pout.each do |line|
          line = line.strip
          if (line !~ /^List of devices/ && line != "")
            parts = line.split
            devices << {:name   => parts[0],
                        :serial => parts[1]}
          end
        end
      end
      return devices
    end

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
    end # def

    def uninstall(package, opts = {})
      opt_arg = ""
      opt_arg += " -l" if opts[:forwardlock]
      opt_arg += " -r" if opts[:reinstall]
      opt_arg += " -s" if opts[:sdcard]
      run_adb("uninstall#{opt_arg} #{package}")
    end

    def run_adb(args, &block)
      path = "#{@adb_path} #{args}"
      run(path, &block)
    end # def

    def run_adb_shell(args, &block)
      path = "#{@adb_path} shell \"#{args}\""
      run(path, &block)
    end

    private
    def run(path, &block)
      if @dry_run
        puts "#{path}"
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
    end # def

  end # class
end # module


