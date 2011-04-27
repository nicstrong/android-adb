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

    s.executables = []
    s.extra_rdoc_files = [ 'README,md', 'LICENSE', ]
    #s.test_files = Dir.glob( 'test/*-test.rb' )
    s.has_rdoc = true
end
