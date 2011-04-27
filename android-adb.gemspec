Gem::Specification.new do |s|
    s.name = 'android-adb'
    s.version = '0.0.2'
    s.summary = 'Ruby bindings for the Android SDK adb command.'
    #s.rubyforge_project = 'android-adb'

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

    s.add_runtime_dependency('popen4', '~> 0.1.1')
end
