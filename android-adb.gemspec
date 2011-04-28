require File.expand_path('../lib/android-adb/version', __FILE__)

Gem::Specification.new do |s|
    s.name = 'android-adb'
    s.version = AndroidAdb::VERSION.dup
    s.summary = 'Ruby bindings for the Android SDK adb command.'

    s.authors = [ 'nicstrong' ]
    s.email = 'nic dot strong at gmail dot net'
    s.homepage = 'http://github.com/nicstrong/android-adb'

    s.files = Dir[
      'lib/**/*.rb',
      'test/**/*.rb',
      'examples/**/*.rb',
      'LICENCE',
      'LICENSE',
      'README.md',
    ]

    s.add_development_dependency('bundler',  '~> 1.0')
    s.add_development_dependency('rake', '~> 0.8')
    s.add_runtime_dependency('POpen4', '~> 0.1.4')
end
