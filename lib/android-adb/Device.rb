# Author:: Nic Strong  (mailto:nic.strong@gmail.com)
# Copyright:: Copyright (c) 2011 Nic Strong
# License::   MIT (See LICENSE)

module AndroidAdb
  class Device
    attr_accessor :name, :serial
    attr_reader :adb

    # Contructs an Device object.
    #
    # @param [String] name The name of the device/emulator.
    # @param [String] serial The serial number of the device/emulator.
    def initialize(name, serial)
      @name = name
      @serial = serial
      @adb = AndroidAdb::Adb.new()
    end

    def usb_install(package, opts = {})
      opt_arg = opts.nil? ? "" : "-"
      opt_arg += "l" if opts[:forwardlock]
      opt_arg += "r" if opts[:reinstall]
      opt_arg += "t" if opts[:testpackage]
      opt_arg += "s" if opts[:sdcard]
      opt_arg += "d" if opts[:versiondown]
      opt_arg += "g" if opts[:grantperms]

      command = "install #{opt_arg} #{package}"
      adb_opts = {:serial => "#{name}"}

      adb.run_adb(command, adb_opts) {|pout| pout}
    end

    def usb_uninstall(package_name, opt = {})
      opt = opt[:keepdata] ? "-k" : ""
      command = "uninstall #{opt} #{package_name}"
      adb_opts = {:serial => name}

      adb.run_adb(command, adb_opts) {|pout| pout}
    end
  end # class
end # module


