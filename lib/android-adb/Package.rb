# Author:: Nic Strong  (mailto:nic.strong@gmail.com)
# Copyright:: Copyright (c) 2011 Nic Strong
# License::   MIT (See LICENSE)

module AndroidAdb
  class Package
    attr_accessor :name, :apk

    # Contructs an Package object.
    #
    # @param [String] name The name of the package.
    # @param [String] apk The path of the installed apk file.
    def initialize(name, apk)
      @name = name
      @apk = apk
    end
  end # class
end # module


