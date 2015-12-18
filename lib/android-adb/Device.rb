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
    def initialize(serial, name)
      @name = name
      @serial = serial
    end
  end # class
end # module


