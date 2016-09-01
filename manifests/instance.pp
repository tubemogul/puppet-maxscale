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
  $master_ini     = { directory => '/var/cache/maxscale/binlog', content => {}, },
){
  # The default instance is just named maxscale. The other ones have a prefix
  # with the name of the instance.
  $service_name = $name ? {
    'default' => 'maxscale',
    default   => "maxscale_${name}",
  }
  $confdir = dirname($configfile)

  $config_directories = [
    $logdir, $cachedir, $datadir, $piddir, $errmsgsys_path,
    $master_ini['directory']
  ]
  # create config directories after maxscale user exists
  Class['maxscale::install'] -> File[$config_directories]
  ensure_resource( 'file', $config_directories, {
    ensure => directory,
    owner  => $svcuser,
    group  => $svcgroup,
  })

  # The config file could be /etc so we do not want the service user to be the
  # owner. Plus Maxscale don't need to write in it, just need the rights on the
  # config file
  ensure_resource( 'file', $confdir, {
    ensure => directory,
  })

  file { $configfile:
    ensure  => present,
    content => template('maxscale/maxscale.cnf.erb'),
    owner   => $svcuser,
    group   => $svcgroup,
    mode    => '0644',
    require => [ Class['maxscale::install'], File[$confdir], ],
  }

  if $master_ini['content'] != undef and $master_ini['directory'] != undef {
    file { "${master_ini['directory']}/master.ini":
      ensure  => present,
      content => template('maxscale/master.ini.erb'),
      owner   => $svcuser,
      group   => $svcgroup,
      mode    => '0640',
      require => [ Class['maxscale::install'], File[$master_ini['directory']], ],
    }
  }

  file { "/etc/init.d/${service_name}":
    ensure  => present,
    content => template('maxscale/maxscale.initd.erb'),
    mode    => '0755',
    require => File[$configfile],
    notify  => Service[$service_name],
  }

  service { $service_name:
    ensure     => $ensure,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => [ File[$configfile], File["/etc/init.d/${service_name}"], ],
  }

}
