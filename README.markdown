#Maxscale puppet module

[![TravisBuild](https://travis-ci.org/tubemogul/puppet-maxscale.svg?branch=master)](https://travis-ci.org/tubemogul/puppet-maxscale)
[![Puppet Forge latest release](https://img.shields.io/puppetforge/v/TubeMogul/maxscale.svg)](https://forge.puppetlabs.com/TubeMogul/maxscale)
[![Puppet Forge downloads](https://img.shields.io/puppetforge/dt/TubeMogul/maxscale.svg)](https://forge.puppetlabs.com/TubeMogul/maxscale)
[![Puppet Forge score](https://img.shields.io/puppetforge/f/TubeMogul/maxscale.svg)](https://forge.puppetlabs.com/TubeMogul/maxscale/scores)

####Table of Contents

0. [Before you begin](#before-you-begin)
1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with maxscale](#setup)
    * [What maxscale affects](#what-maxscale-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with maxscale](#beginning-with-maxscale)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Basic example](#basic-example)
    * [Install without installing a specific repository](#install-without-installing-a-specific-repository)
    * [Using a custom package repository](#using-a-custom-package-repository)
    * [Specify a version](#specify-a-version)
    * [Working with a single instance](#working-with-a-single-instance)
    * [Working in a multi-instances environment](#working-in-a-multi-instances-environment)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
  * [Public classes](#public-classes)
  * [Private classes](#private-classes)
  * [Parameters](#parameters)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)


##Before you begin

**Attention:**

To be able to use this module you will have to get the enterprise
"Download token".

You can find the token on [My Portal](https://www.mariadb.com/my_portal) in
the "Your Subscriptions" section.

**Note:** If you do not have a MariaDB Enterprise subscription/contract,
you can create an account at My Portal, sign the Evaluation Agreement,
and try MariaDB Enterprise as an Evaluation User.



##Overview

This module installs and configures the MySQL/MariaDB's binlogs proxy called
Maxscale.

GitHub page of the Maxscale project: https://github.com/mariadb-corporation/MaxScale



##Module Description

The idea behind Maxscale is to have slaves that don't really care about which
master is behind the replication endpoint. As it's a quite lightway process, we
use several of them on the same instance.

In that spirit, this module allows you to manage several maxscale instances on
the same host very easily.

The module installs the package (from MariaDB's official repositories or from
your own repository if you specify a [`repo_custom_url`](#repo_custom_url)), configures and manages
the one or multiple instances you define in the module's parameters.

**Note:** We use generally maxscale as a replication proxy. You should be able to
use this module to manage other configuration cases but they have not been
tested yet. So if you do and find issues, don't hesitate to file a bug on our
github page: https://www.github.com/tubemogul/puppet-maxscale/issues



##Setup

###What maxscale affects

 * `/etc/init.d/maxscale`: used to manage the maxscale service if you setup the instance 'default'.
 * `/etc/init.d/maxscale_<instance_name>`: used to manage non-default maxscale instances.
 * `/root/.maxadmin`: used to setup the authentication credentials to use with maxadmin. (You can change the directory of the maxadmin file using the [`maxadmin_config_root`](#maxadmin_config_root) parameter.

Files and directories that you specify in your configuration:
 * the maxscale configuration files
 * the maxscale datadir. The parents directories will be created if they don't exist.
 * the maxscale cachedir. The parents directories will be created if they don't exist.
 * the maxscale logdir. The parents directories will be created if they don't exist.
 * the maxscale piddir. The parents directories will be created if they don't exist.
 * the folder where the errmsg.sys is stored (generally `/var/lib/maxscale`).

Specific to the Debian OS family:
 * `/etc/apt/sources.list.d/maxscale.list`: used to install the maxscale package repository (unless [`install_repository`](#install_repository) is set to `false`).

### Setup Requirements

The module requires:

 * [Puppetlabs stdlib](https://github.com/puppetlabs/puppetlabs-stdlib.git)
 * [Puppetlabs apt module](https://github.com/puppetlabs/puppetlabs-apt.git)

###Beginning with maxscale

Before you start, make sure you read and completed the [Before you begin](#before-you-begin) section.

Once this is done, the module can be used out of the box directly, it just requires
puppetlabs's apt module (if you want to install Maxscale APT repository) and stdlib to be in your modulepath.

To install (with all the dependencies - stdlib should come by default with your installation but make sure you run with the latest version to avoid issues):

```
puppet module install puppetlabs/stdlib
puppet module install puppetlabs/apt
puppet module install TubeMogul/aerospike
```



##Usage

Those examples include the puppet-only configuration, and the corresponding
configuration for those who use hiera (I find it more convenient for copy/paste
of a full configuration when you have both - yes, I'm lazy ;-) ).

###Basic example

Let's say that you completed the [Before you begin](#before-you-begin) section
and that you ended up with a token that is `abc12-34def`. You want to test out
maxscale with only 1 instance on your server, use the Maxscale APT repository
and all the default parameters. Then your puppet code will just be:

```
class { 'maxscale':
  token => 'abc12-34def',
}
```

Or just do a simple `class { 'maxscale':}` puppet code block and in hiera:

```
maxscale::token: abc12-34def
```

###Install without installing a specific repository

If you already have all the repositories installed and you don't want this
module to manage the APT repository on your instance (or that you are using this
module on another OS family than Debian), simply set the
[`install_repository`](#install_repository) parameter to `false`.

```
class { 'maxscale':
  install_repository => false,
}
```

Or just do a simple `class { 'maxscale':}` puppet code block and in hiera:

```
maxscale::install_repository: false
```

**Note:** as you don't install the maxscale repository, you don't need the token parameter.

###Using a custom package repository

If you want to us a custom APT package repository, you can use the
[`repo_custom_url`](#repo_custom_url) parameter.

In this case you will want also to set the
[`repo_fingerprint`](#repo_fingerprint) with the
fingerprint of your repository and you might also want to change the
[`repo_keyserver`](#repo_keyserver) parameter to specify your own keyserver.

Optionaly you can use the [`repo_repository`](#repo_repository) and [`repo_release`](#repo_release) to fit your
environment but the default values for those are pretty common values.

```
class { 'maxscale':
  repo_custom_url  => 'http://apt.repo.my.company.com',
  repo_fingerprint => '1234567890ABCDEF1234567890ABCDEF12345678',
  repo_keyserver   => 'hkp://keyserver.my.company.com:8080',
  repo_repository  => 'optionals',
}
```

Or just do a simple `class { 'maxscale':}` puppet code block and in hiera:

```
maxscale::repo_custom_url: http://apt.repo.my.company.com
maxscale::repo_fingerprint: 1234567890ABCDEF1234567890ABCDEF12345678
maxscale::repo_keyserver: hkp://keyserver.my.company.com:8080
maxscale::repo_repository: optionals
```

**Note:** as you don't install the maxscale repository, you don't need the token parameter.

###Specify a version

Let's say that you completed the [Before you begin](#before-you-begin) section
and that you ended up with a token that is `abc12-34def`.

By default this module installs the latest version of the package (it doesn't upgrade automatically when a new version is out, that would be really bad in a production environment if it did! :) )

You want now to have a specific older version to install because you haven't
finished benchmarking the new one. Then you would use the
[`repo_version`](#repo_version) parameter for that purpose.

Here's what you would use (if you use all the default for the rest):

```
class { 'maxscale':
  token        => 'abc12-34def',
  repo_version => '1.2'
}
```

Or just do a simple `class { 'maxscale':}` puppet code block and in hiera:

```
maxscale::token: abc12-34def
maxscale::repo_version: 1.2
```

###Working with a single instance

Let's say that you completed the [Before you begin](#before-you-begin) section
and that you ended up with a token that is `abc12-34def`.

Now let's say that you want to customize some parts of your maxscale
installation.
For example, you want your instance setup to have:
 * cachedir to be `/maxscale/cache`,
 * datadir to be `/maxscale/data`,
 * 4 threads instead of 2
 * the `server-id` set to 55
 * an additional binlog router option `binlogdir` set to `/maxscale/binlog`
 * a different password (of course! :) )
 * a master which is 10.0.0.10

**Note:** It is not mandatory to set the `ensure`, `logdir`, `piddir`, `svcuser`, `svcgroup`,
`errmsgsys_path` and `configfile` parameters as those are their defaults, but I like to set
them just to clarify for the user that is not 100% familiar with the instance, what settings it has.

```
class { 'maxscale':
  token              => 'abc12-34def',
  services_conf      => {
    'default'        => {
      ensure         => 'running',
      logdir         => '/var/log/maxscale',
      cachedir       => '/maxscale/cache',
      datadir        => '/maxscale/data',
      piddir         => '/var/run/maxscale',
      svcuser        => 'maxscale',
      svcgroup       => 'maxscale',
      errmsgsys_path => '/var/lib/maxscale',
      configfile     => '/etc/maxscale.cnf',
      'config'       => {
        'maxscale'   => {
          'threads'  => 4
        },
        'Binlog_Service'   => {
          'type'           => 'service',
          'router'         => 'binlogrouter',
          'servers'        => 'master',
          'router_options' => 'mariadb10-compatibility=1,server-id=55,binlogdir=/maxscale/binlog',
          'user'           => 'maxscale',
          'passwd'         => 'AR3allyRe@llyG0odPwd...',
          'version_string' => '10.1.12-MariaDB-1~trusty',
        },
        'Binlog Listener'   => {
          'type'            => 'listener',
          'service'         => 'Binlog_Service',
          'protocol'        => 'MySQLClient',
          'port'            => 3310,
        },
        'Debug Interface'   => {
          'type'            => 'service',
          'router'          => 'debugcli',
        },
        'CLI'      => {
          'type'   => 'service',
          'router' => 'cli',
        },
        'Debug Listener'   => {
          'type'           => 'listener',
          'service'        => 'Debug Interface',
          'protocol'       => 'telnetd',
          'address'        => '127.0.0.1',
          'port'           => 4442,
        },
        'CLI Listener'   => {
          'type'         => 'listener',
          'service'      => 'CLI',
          'protocol'     => 'maxscaled',
          'port'         => 6603,
        },
        'master'     => {
          'type'     => 'server',
          'address'  => '10.0.0.10',
          'port'     => 3306,
          'protocol' => 'MySQLBackend',
        },
      },
    }
}
```

Or just do a simple `class { 'maxscale':}` puppet code block and in hiera:

```
maxscale::token: abc12-34def
maxscale::services_conf:
  default:
    ensure: running
    logdir: /var/log/maxscale
    cachedir: /maxscale/cache
    datadir: /maxscale/data
    piddir: /var/run/maxscale
    svcuser: maxscale
    svcgroup: maxscale
    errmsgsys_path: /var/lib/maxscale
    configfile: /etc/maxscale.cnf
    config:
      maxscale:
        threads: 4
      Binlog_Service:
        type: service
        router: binlogrouter
        servers: master
        router_options: 'mariadb10-compatibility=1,server-id=55,binlogdir=/maxscale/binlog'
        user: maxscale
        passwd: 'AR3allyRe@llyG0odPwd...'
        version_string: '10.1.12-MariaDB-1~trusty'
      Binlog Listener:
        type: listener
        service: Binlog_Service
        protocol: MySQLClient
        port: 3310
      Debug Interface:
        type: service
        router: debugcli
      CLI:
        type: service
        router: cli
      Debug Listener:
        type: listener
        service: 'Debug Interface'
        protocol: telnetd
        address: 127.0.0.1
        port: 4442
      CLI Listener:
        type: listener
        service: CLI
        protocol: maxscaled
        port: 6603
      master:
        type: server
        address: 10.0.0.10
        port: 3306
        protocol: MySQLBackend
```

###Working in a multi-instances environment

Let's say that you completed the [Before you begin](#before-you-begin) section
and that you ended up with a token that is `abc12-34def`.

Now let's say that you want to replicate 2 data streams from 2 different master.
To do that you will need 2 maxscale instances that you can in our case install
on the same sever. For each instance, we will use the same kind of parameters
as previously.

For the example, let's continue to use the default instance to replicate from a
master named `foo` and let's have anoter one for the master named `bar`.

For example, you want your instance setup to have:
 * logdir to be: `/var/log/maxscale/<master_name>`,
 * cachedir to be `/maxscale/cache/<master_name>`,
 * datadir to be `/maxscale/data/<master_name>`,
 * piddir to be `/var/run/maxscale/<master_name>`,
 * configfile to be `/etc/maxscale/<master_name>.cfg`,
 * the `server-id` set to 55 and 66
 * an additional binlog router option `binlogdir` set to `/maxscale/binlog/<master_name>`
 * a different password (of course! :) )
 * foo master IP is 10.0.0.10 and bar master is 10.0.0.11

```
class { 'maxscale':
  token              => 'abc12-34def',
  services_conf      => {
    'default'        => {
      logdir         => '/var/log/maxscale/foo',
      cachedir       => '/maxscale/cache/foo',
      datadir        => '/maxscale/data/foo',
      piddir         => '/var/run/maxscale/foo',
      configfile     => '/etc/maxscale/foo.cnf',
      'config'       => {
        'maxscale'   => {
          'threads'  => 2
        },
        'Binlog_Service'   => {
          'type'           => 'service',
          'router'         => 'binlogrouter',
          'servers'        => 'master',
          'router_options' => 'mariadb10-compatibility=1,server-id=55,binlogdir=/maxscale/binlog/foo',
          'user'           => 'maxscale',
          'passwd'         => 'AR3allyRe@llyG0odPwd...',
          'version_string' => '10.1.12-MariaDB-1~trusty',
        },
        'Binlog Listener'   => {
          'type'            => 'listener',
          'service'         => 'Binlog_Service',
          'protocol'        => 'MySQLClient',
          'port'            => 3310,
        },
        'Debug Interface'   => {
          'type'            => 'service',
          'router'          => 'debugcli',
        },
        'CLI'      => {
          'type'   => 'service',
          'router' => 'cli',
        },
        'Debug Listener'   => {
          'type'           => 'listener',
          'service'        => 'Debug Interface',
          'protocol'       => 'telnetd',
          'address'        => '127.0.0.1',
          'port'           => 4442,
        },
        'CLI Listener'   => {
          'type'         => 'listener',
          'service'      => 'CLI',
          'protocol'     => 'maxscaled',
          'port'         => 6603,
        },
        'master'     => {
          'type'     => 'server',
          'address'  => '10.0.0.10',
          'port'     => 3306,
          'protocol' => 'MySQLBackend',
        },
      },
    }
    'bar'        => {
      logdir         => '/var/log/maxscale/bar',
      cachedir       => '/maxscale/cache/bar',
      datadir        => '/maxscale/data/bar',
      piddir         => '/var/run/maxscale/bar',
      configfile     => '/etc/maxscale/bar.cnf',
      'config'       => {
        'maxscale'   => {
          'threads'  => 2
        },
        'Binlog_Service'   => {
          'type'           => 'service',
          'router'         => 'binlogrouter',
          'servers'        => 'master',
          'router_options' => 'mariadb10-compatibility=1,server-id=66,binlogdir=/maxscale/binlog/bar',
          'user'           => 'maxscale',
          'passwd'         => 'AR3allyRe@llyG0odPwd...',
          'version_string' => '10.1.12-MariaDB-1~trusty',
        },
        'Binlog Listener'   => {
          'type'            => 'listener',
          'service'         => 'Binlog_Service',
          'protocol'        => 'MySQLClient',
          'port'            => 3310,
        },
        'Debug Interface'   => {
          'type'            => 'service',
          'router'          => 'debugcli',
        },
        'CLI'      => {
          'type'   => 'service',
          'router' => 'cli',
        },
        'Debug Listener'   => {
          'type'           => 'listener',
          'service'        => 'Debug Interface',
          'protocol'       => 'telnetd',
          'address'        => '127.0.0.1',
          'port'           => 4442,
        },
        'CLI Listener'   => {
          'type'         => 'listener',
          'service'      => 'CLI',
          'protocol'     => 'maxscaled',
          'port'         => 6603,
        },
        'master'     => {
          'type'     => 'server',
          'address'  => '10.0.0.11',
          'port'     => 3306,
          'protocol' => 'MySQLBackend',
        },
      },
    }
}
```

Or just do a simple `class { 'maxscale':}` puppet code block and in hiera:

```
maxscale::token: abc12-34def
maxscale::services_conf:
  default:
    logdir: /var/log/maxscale/foo
    cachedir: /maxscale/cache/foo
    datadir: /maxscale/data/foo
    piddir: /var/run/maxscale/foo
    configfile: /etc/maxscale/foo.cnf
    config:
      maxscale:
        threads: 2
      Binlog_Service:
        type: service
        router: binlogrouter
        servers: master
        router_options: 'mariadb10-compatibility=1,server-id=55,binlogdir=/maxscale/binlog/foo'
        user: maxscale
        passwd: 'AR3allyRe@llyG0odPwd...'
        version_string: '10.1.12-MariaDB-1~trusty'
      Binlog Listener:
        type: listener
        service: Binlog_Service
        protocol: MySQLClient
        port: 3310
      Debug Interface:
        type: service
        router: debugcli
      CLI:
        type: service
        router: cli
      Debug Listener:
        type: listener
        service: 'Debug Interface'
        protocol: telnetd
        address: 127.0.0.1
        port: 4442
      CLI Listener:
        type: listener
        service: CLI
        protocol: maxscaled
        port: 6603
      master:
        type: server
        address: 10.0.0.10
        port: 3306
        protocol: MySQLBackend
  bar:
    logdir: /var/log/maxscale/bar
    cachedir: /maxscale/cache/bar
    datadir: /maxscale/data/bar
    piddir: /var/run/maxscale/bar
    configfile: /etc/maxscale/bar.cnf
    config:
      maxscale:
        threads: 2
      Binlog_Service:
        type: service
        router: binlogrouter
        servers: master
        router_options: 'mariadb10-compatibility=1,server-id=66,binlogdir=/maxscale/binlog/bar'
        user: maxscale
        passwd: 'AR3allyRe@llyG0odPwd...'
        version_string: '10.1.12-MariaDB-1~trusty'
      Binlog Listener:
        type: listener
        service: Binlog_Service
        protocol: MySQLClient
        port: 3310
      Debug Interface:
        type: service
        router: debugcli
      CLI:
        type: service
        router: cli
      Debug Listener:
        type: listener
        service: 'Debug Interface'
        protocol: telnetd
        address: 127.0.0.1
        port: 4442
      CLI Listener:
        type: listener
        service: CLI
        protocol: maxscaled
        port: 6603
      master:
        type: server
        address: 10.0.0.11
        port: 3306
        protocol: MySQLBackend
```



##Reference

###Public classes

 * [`maxscale`](#class-maxscale): Installs, configures and manage one or serveral maxscale instances on a single server.

###Private classes

 * `maxscale::install`: Installs the maxscale repository and the maxscale package.
 * `maxscale::config`: Configures the .maxadmin file in /root.
 * `maxscale::install`: Installs the repository (if [`install_repository`](#install_repository) is set to `true`) and the maxscale package.
 * `maxscale::params`: Sets the default values that you can overwrite directly by setting the parameters of the `maxscale` class.

###Parameters

####Class maxscale

##### `install_repository`

This parameter is a boolean that defines if you will install the APT repository
on your server or not.

Default: `true`

##### `token`

Required if [`install_repository`](#install_repository) is set to `true` or [`repo_custom_url`](#repo_custom_url) is not set.
It is used to construct to download url in the repository.

For more information, see the [Before you begin](#before-you-begin) section.

Default: `undef`

##### `repo_custom_url`

Required if no [`token`](#token) is specified. Use this parameter if you want to download the package from a custom repository.

Default: `undef`

##### `repo_version`

This is used to contruct the url of the repository to provide the right version
of the package. Unused when [`install_repository`](#install_repository) is set to `false` or when
[`repo_custom_url`](#repo_custom_url) is set.

Default: `latest`

##### `repo_release`

Usual repository `release` field on a classic APT repository.

Defaults to the `lsbdistcodename` fact.

##### `repo_repository`

Usual repository `repository` field on a classic APT repository.

Default: `main`

##### `repo_fingerprint`

Full fingerprint of the key used to authenticate the APT repository.

For more informations on secure apt repository, see:
https://help.ubuntu.com/community/SecureApt

Default: `13CFDE6DD9EE9784F41AF0F670E4618A8167EE24`

##### `repo_keyserver`

Keyserver to use to retrieve your repository key.

For more informations on secure apt repository, see:
https://help.ubuntu.com/community/SecureApt

Default: `hkp://keyserver.ubuntu.com:80`

##### `package_name`

Name of the package to use to install maxscale.

Default: `maxscale`

##### `maxadmin_config_root`

Path of the root home directory where to install the `.maxadmin` file to use to
authenticate on the maxscale instances using maxadmin.

Default: `/root`

##### `instance_user`

User to put in the `.maxadmin` to use with the maxadmin tool.

Default: `maxscale`

##### `instance_password`

Password to put in the `.maxadmin` to use with the maxadmin tool.

Default: `mariadb`

##### `services_conf`

This is a hash containing:
 - on the 1st level, the keys are the name of the instances. If you use just one,
   you will probably want to just use 'default' there. The values contain the
   configuration parameters corresponding to the instance.
 - Inside the configuration parameters, you have:
   - `ensure`: used to force a service to run or to stop
   - `logdir`: will setup the --logdir parameter on the maxscale service (and will create the directory if doesn't exists)
   - `cachedir`: will setup the --cachedir parameter on the maxscale service (and will create the directory if doesn't exists)
   - `datadir`: will setup the --datadir parameter on the maxscale service (and will create the directory if doesn't exists)
   - `piddir`: will setup the --piddir parameter on the maxscale service (and will create the directory if doesn't exists)
   - `svcuser`: OS user to run the service under
   - `svcgroup`: OS group to use to set on the directories managed by the service
   - `errmsgsys_path`: will setup the --language parameter on the maxscale service (to specify the path of the errmsg.sys file)
   - `configfile`: path of the configuration file to be created and used for your instance
   - `config`: contains a hash which will define the content of the maxscale
     configuration file. Each key represent a section, and each value is a has
     which will render like: `key = value`

Default:
```
{
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
    config         => {
      'maxscale'   => {
        'threads'  => 2
      },
      'Binlog_Service'   => {
        'type'           => 'service',
        'router'         => 'binlogrouter',
        'servers'        => 'master',
        'router_options' => 'mariadb10-compatibility=1,server-id=10',
        'user'           => 'maxscale',
        'passwd'         => 'PLEASE_CHANGE_ME!1!',
        'version_string' => '10.1.12-MariaDB-1~trusty',
      },
      'Binlog Listener'   => {
        'type'            => 'listener',
        'service'         => 'Binlog_Service',
        'protocol'        => 'MySQLClient',
        'port'            => 3310,
      },
      'Debug Interface'   => {
        'type'            => 'service',
        'router'          => 'debugcli',
      },
      'CLI'      => {
        'type'   => 'service',
        'router' => 'cli',
      },
      'Debug Listener'   => {
        'type'           => 'listener',
        'service'        => 'Debug Interface',
        'protocol'       => 'telnetd',
        'address'        => '127.0.0.1',
        'port'           => 4442,
      },
      'CLI Listener'   => {
        'type'         => 'listener',
        'service'      => 'CLI',
        'protocol'     => 'maxscaled',
        'port'         => 6603,
      },
      'master'     => {
        'type'     => 'server',
        'address'  => '127.0.0.1',
        'port'     => 3306,
        'protocol' => 'MySQLBackend',
      },
    },
  }
}
```



##Limitations

This module has been tested against Puppet 3.8 with Ubuntu clients with Maxscale 10.1.

The spec tests work on puppet 3.x and 4.x.

To work on the Debian OS family servers, it requires the apt module from
puppetlabs to be installed.

The implementation for the installation on other operating systems has not been
done yet but should be pretty straightforward to do. Just ask which one you want
and we'll add it or submit a pull request on our github page and we'll integrate
it.



##Development

See the [CONTRIBUTING.md](https://github.com/tubemogul/puppet-maxscale/blob/master/CONTRIBUTING.md) file.
