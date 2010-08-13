require 'rubygems'
require 'test/unit'

[ %w[ .. lib ], %w[ . ] ].each do |path|
  $LOAD_PATH.unshift(
    File.expand_path(File.join(*path), File.dirname(__FILE__))
  )
end

require 'redns'

class Test::Unit::TestCase
end