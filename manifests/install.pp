# == Class maxscale::install
#
class maxscale::install {

  if $maxscale::install_repository == true {
    case $::osfamily {
      'Debian': {

        if $maxscale::repo_custom_url == undef or $maxscale::repo_custom_url == '' {
          $lower_lsbdistid  = downcase($::lsbdistid)
          $repo_location = "http://downloads.mariadb.com/enterprise/${maxscale::token}/mariadb-maxscale/${maxscale::repo_version}/${lower_lsbdistid}"
        } else {
          $repo_location = $maxscale::repo_custom_url
        }


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
      default: {
        fail("${::operatingsystem} not supported")
      }
    }
  }

  ensure_packages($maxscale::package_name, {
    ensure  => present })

}
