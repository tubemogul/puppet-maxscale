# == Class maxscale::params
#
# This class is meant to be called from maxscale
# It sets variables according to platform
# Those are the default values. If you want to change a parameter, do it in the
# call of the maxscale class directly.
#
class maxscale::params {

  $install_repository   = true
  $repository_version   = 'latest'
  $package_name         = 'maxscale'
  $maxadmin_config_root = '/root'
  $instance_user        = 'admin'
  $instance_password    = 'mariadb' # Don't forget to change that! :)

  case $::osfamily {
    'Debian': {
      $repo_os          = downcase($::operatingsystem)
      $repo_release     = $::lsbdistcodename
      $repo_repository  = 'main'
      $repo_fingerprint = '13CFDE6DD9EE9784F41AF0F670E4618A8167EE24'
      $repo_keyserver   = 'hkp://keyserver.ubuntu.com:80'
    }
    'RedHat': {
      $repo_repository  = ''
      $repo_fingerprint = ''
      $repo_keyserver   = ''
      $repo_release     = ''
      if $::operatingsystem == 'RedHat' {
        $_os            = 'rhel'
      } else {
        $_os            = downcase($::operatingsystem)
      }
      $repo_os          = "${_os}/${::operatingsystemmajrelease}/x86_64"
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  $services_conf = {
    'default'        => {
      ensure         => 'running',
      logdir         => '/var/log/maxscale',
      cachedir       => '/var/cache/maxscale',
      datadir        => '/var/cache/maxscale',
      piddir         => '/var/run/maxscale',
      svcuser        => 'maxscale',
      svcgroup       => 'maxscale',
      errmsgsys_path => '/var/lib/maxscale',
      configfile     => '/etc/maxscale.cnf',
      'config'       => {
        'maxscale'   => {
          'threads'  => 2
        },
        'Binlog_Service'   => {
          'type'           => 'service',
          'router'         => 'binlogrouter',
          'router_options' => 'mariadb10-compatibility=1,server-id=10,binlogdir=/var/cache/maxscale/binlog',
          'user'           => 'maxscale',
          'passwd'         => 'PLEASE_CHANGE_ME!1!',
          'version_string' => '10.1.12-MariaDB-1~trusty',
        },
        'Binlog_Listener'   => {
          'type'            => 'listener',
          'service'         => 'Binlog_Service',
          'protocol'        => 'MySQLClient',
          'port'            => 3310,
        },
        'Debug_Interface'   => {
          'type'            => 'service',
          'router'          => 'debugcli',
        },
        'CLI'      => {
          'type'   => 'service',
          'router' => 'cli',
        },
        'Debug_Listener'   => {
          'type'           => 'listener',
          'service'        => 'Debug_Interface',
          'protocol'       => 'telnetd',
          'address'        => '127.0.0.1',
          'port'           => 4442,
        },
        'CLI_Listener'   => {
          'type'         => 'listener',
          'service'      => 'CLI',
          'protocol'     => 'maxscaled',
          'port'         => 6603,
        },
      },
      master_ini                 => {
        directory                => '/var/cache/maxscale/binlog',
        content                  => {
          'binlog_configuration' => {
            'master_host'        => '127.0.0.1',
            'master_port'        => 3306,
            'master_user'        => 'maxscale',
            'master_password'    => 'PLEASE_CHANGE_ME!2!',
            'filestem'           => 'mysql-bin',
          },
        },
      },
    },
  }
}
