Android ADB
===========

A ruby gem to bind to the various adb commands (Requires the Android SDK to be installed and tools directory to be in the path).

### Installation from GitHub sources

    git clone git://github.com/nicstrong/android-adb.git
    cd android-adb
    bundle install
    rake install

### Running on Ruby 1.9 under Win32

The POpen4 gem uses win32/open3 on then win32 platform. This gem does not work with Ruby 1.9.

To work around this use matschaffer port from github. To install:

    git clone git://github.com/matschaffer/win32-open3-19.git
    cd win32-open3-19
    gem build win32-open3-19.gemspec
    gem intall win32-open3-19-0.0.1.gem
