module Puppet::Parser::Functions
	newfunction(:path_tree, :type => :rvalue, :doc => <<-'ENDOFDOC'
This function use the descend ruby finction to provide an array of all the
parent paths so that you can avoid using a mkdir -p to create a path where the
parent don't exist.
It can take a simple string as input or directly an array (and it will be
deduplicated).
The root level is not returned to avoid trying to create drives on windows or '/' on unix/linux

Example: create multiple directories and their full path:

  $conf1 = '/etc/app/app1'
  $conf2 = '/etc/app/app2'
  ensure_resource( 'file', path_tree([ $conf1, $conf2 ]), { ensure => directory, })

This example is the equivalent of writing (it becomes handby when you have dynamic paths from a configuration):

  ensure_resource( 'file', [ '/etc', '/etc/app', '/etc/app/app1', '/etc/app/app2' ]), { ensure => directory, })

ENDOFDOC
  ) do |args|
    require 'pathname'
    path = [ args[0] ].flatten
    _ret = []
    path.each do |p|
      Pathname.new(p).descend {|v| _ret << v.to_s unless v.root? }
    end
    return _ret.uniq
	end
end
