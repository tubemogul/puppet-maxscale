# == Define: maxscale::instance
#
define maxscale::instance (
  $ensure         = 'running',
  $config         = {},
  $logdir         = '/var/log/maxscale',
  $cachedir       = '/var/cache/maxscale',
  $datadir        = '/var/cache/maxscale',
  $piddir         = '/var/run/maxscale',
  $svcuser        = 'maxscale',
  $svcgroup       = 'maxscale',
  $errmsgsys_path = '/var/lib/maxscale',
  $configfile     = '/etc/maxscale.cnf',
){
  # The default instance is just named maxscale. The other ones have a prefix
  # with the name of the instance.
  $service_name = $name ? {
    'default' => 'maxscale',
    default   => "maxscale_${name}",
  }
  $confdir = dirname($configfile)

  ensure_resource( 'file', path_tree([
    $confdir, $logdir, $cachedir, $datadir, $piddir, $errmsgsys_path 
    ]), { ensure => directory, })

  file { $configfile:
    ensure  => present,
    content => template('maxscale/maxscale.cnf.erb'),
    owner   => $svcuser,
    group   => $svcgroup,
    require => [ Class['maxscale::install'], File[$confdir], ],
  }

  file { "/etc/init.d/${service_name}":
    ensure  => present,
    content => template('maxscale/maxscale.initd.erb'),
    require => [ File [$configfile], ],
    notify  => [ Service[$service_name], ],
  }

  service { $service_name:
    ensure     => $ensure,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => [ File[$configfile], File["/etc/init.d/${service_name}"], ],
  }

}
