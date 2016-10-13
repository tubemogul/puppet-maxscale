# == Class maxscale::install
#
class maxscale::install {

  if $maxscale::install_repository == true {
    if $maxscale::repo_custom_url == undef or $maxscale::repo_custom_url == '' {
      $repo_location = "http://downloads.mariadb.com/enterprise/${maxscale::token}/mariadb-maxscale/${maxscale::repo_version}/${maxscale::repo_os}"
    } else {
      $repo_location = $maxscale::repo_custom_url
    }
    case $::osfamily {
      'Debian': {

        apt::source { 'maxscale':
          location => $repo_location,
          release  => $maxscale::repo_release,
          repos    => $maxscale::repo_repository,
          key      => {
            'id'     => $maxscale::repo_fingerprint,
            'server' => $maxscale::repo_keyserver,
          },
          include  => {
            'deb' => true,
            'src' => false,
          },
        }

        Apt::Source['maxscale'] ~>
        Class['apt::update'] ->
        Package[$maxscale::package_name]
      }
      'RedHat': {
        file { '/etc/pki/rpm-gpg/MariaDB-MaxScale-GPG-KEY':
          ensure => present,
          owner  => root,
          group  => root,
          mode   => '0644',
          source => 'puppet:///modules/maxscale/MariaDB-MaxScale-GPG-KEY',
        } ->
        yumrepo { 'maxscale':
          enabled  => '1',
          descr    => "MariaDB-MaxScale",
          baseurl  => $repo_location,
          gpgcheck => '1',
          gpgkey   => 'file:///etc/pki/rpm-gpg/MariaDB-MaxScale-GPG-KEY',
        }
        Yumrepo['maxscale'] ->
        Package[$maxscale::package_name]
      }
      default: {
        fail("${::operatingsystem} not supported")
      }
    }
  }

  ensure_packages($maxscale::package_name, {
    ensure  => present })

}
