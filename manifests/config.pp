# == Class maxscale::config
#
class maxscale::config {

  file { "${maxscale::maxadmin_config_root}/.maxadmin":
    ensure  => present,
    content => template('maxscale/maxadmin.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
  }
}
