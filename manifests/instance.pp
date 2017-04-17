# == Define: maxscale::instance
#
define maxscale::instance (
  $ensure           = 'running',
  $config           = {},
  $logdir           = '/var/log/maxscale',
  $cachedir         = '/var/cache/maxscale',
  $datadir          = '/var/cache/maxscale',
  $piddir           = '/var/run/maxscale',
  $svcuser          = 'maxscale',
  $svcgroup         = 'maxscale',
  $errmsgsys_path   = '/var/lib/maxscale',
  $configfile       = '/etc/maxscale.cnf',
  $master_ini       = { directory => '/var/cache/maxscale/binlog', content => {}, },
  $service_provider = 'init',
){
  # The default instance is just named maxscale. The other ones have a prefix
  # with the name of the instance.
  $service_name = $name ? {
    'default' => 'maxscale',
    default   => "maxscale_${name}",
  }
  $confdir = dirname($configfile)

  ensure_resource( 'file', [
    $logdir, $cachedir, $datadir, $piddir, $errmsgsys_path,
    $master_ini['directory'],
  ], {
    ensure => directory,
    owner  => $svcuser,
    group  => $svcgroup,
    require => [ Class['maxscale::install'], ],
  })

  # The config file could be /etc so we do not want the service user to be the
  # owner. Plus Maxscale don't need to write in it, just need the rights on the
  # config file.
  # Skip management of $confdir if is /etc as not to conflict with other modules.
  if ($confdir != '/etc') {
    ensure_resource( 'file', $confdir, {
      ensure => directory,
      before => File[$configfile],
    })
  }

  file { $configfile:
    ensure  => present,
    content => template('maxscale/maxscale.cnf.erb'),
    owner   => $svcuser,
    group   => $svcgroup,
    mode    => '0644',
    require => Class['maxscale::install'],
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

  $service_template = $service_provider ? {
    'init'    => "maxscale/maxscale.initd.${::osfamily}.erb",
    'systemd' => 'maxscale/maxscale.systemd.erb',
    default   => fail('service provider not supported by the module'),
  }
  $service_file = $service_provider ? {
    'init'    => "/etc/init.d/${service_name}",
    'systemd' => "/lib/systemd/system/${service_name}.service",
    default   => fail('service provider not supported by the module'),
  }

  file { $service_file:
    ensure  => present,
    content => template($service_template),
    mode    => '0755',
    require => File[$configfile],
    notify  => Service[$service_name],
  }

  service { $service_name:
    ensure     => $ensure,
    provider   => $service_provider,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => [ File[$configfile], File[$service_file], ],
  }

  if $service_provider == 'systemd' {
    exec { 'refresh_systemd':
      command     => '/bin/systemctl daemon-reload',
      refreshonly => true,
      subscribe   => [ Service[$service_name], ],
    }
  }

}
