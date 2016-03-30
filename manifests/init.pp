# == Class: maxscale
#
class maxscale (
  $install_repository = $maxscale::params::install_repository,
  # Required if repo_custom_url is not set. Used to construct to download url. For more information, see "Before you begin" section in the README.markdown
  $token = undef,
  # Required if no token is specified. Use that if you want to download the package from a custom repository
  $repo_custom_url = undef,
  $repo_version = $maxscale::params::repository_version,
  $repo_release = $maxscale::params::repo_release,
  $repo_repository = $maxscale::params::repo_repository,
  $repo_fingerprint = $maxscale::params::repo_fingerprint,
  $repo_keyserver = $maxscale::params::repo_keyserver,
  $package_name = $maxscale::params::package_name,
  $maxadmin_config_root = $maxscale::params::maxadmin_config_root,
  $instance_user = $maxscale::params::instance_user,
  $instance_password = $maxscale::params::instance_password,
  $services_conf = $maxscale::params::services_conf,
) inherits maxscale::params {

  validate_bool($install_repository)
  validate_string($token)
  validate_string($repo_custom_url)
  validate_string($repo_version)
  validate_string($repo_release)
  validate_string($repo_repository)
  validate_string($repo_fingerprint)
  validate_string($repo_keyserver)
  validate_string($package_name)
  validate_string($maxadmin_config_root)
  validate_string($instance_user)
  validate_string($instance_password)
  validate_hash($services_conf)

  if $install_repository == true {
    if $repo_custom_url == undef or $repo_custom_url == '' {
      validate_re($token, '^[0-9a-zA-Z\-]+$', 'You need to provide a valid token. See https://github.com/tubemogul/puppet-maxscale#before-you-begin for more details.')
    }
  }

  class { 'maxscale::install': } ->
  class { 'maxscale::config': }
  create_resources(maxscale::instance, $services_conf)
}
