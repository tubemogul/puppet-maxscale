require 'spec_helper'

describe 'maxscale::instance' do
  context 'definition of the default instance' do
    let (:title) { 'default' }
    let (:params) {
      {
        :ensure    => 'running',
        :config    => {
          'maxscale'  => {
            'threads' => 2
          },
          'Binlog_Service'   => {
            'type'           => 'service',
            'router'         => 'binlogrouter',
            'servers'        => 'master',
            'router_options' => 'mariadb10-compatibility=1,server-id=10',
            'user'           => 'maxscale',
            'passwd'         => 'PLEASE_CHANGE_ME!1!',
            'version_string' => '10.1.12-MariaDB-1~trusty',
          }
        },
      }
    }
    it do
      should contain_file('/etc/init.d/maxscale')\
        .with_ensure('present')\
        .with_require('File[/etc/maxscale.cnf]')\
        .with_notify('Service[maxscale]')\
        .with_content(/^processname=maxscale$/)\
        .with_content(/^servicename=maxscale$/)\
        .with_content(/--config=\/etc\/maxscale.cnf/)\
        .with_content(/--datadir=\/var\/cache\/maxscale/)\
        .with_content(/--logdir=\/var\/log\/maxscale/)\
        .with_content(/--cachedir=\/var\/cache\/maxscale/)\
        .with_content(/--piddir=\/var\/run\/maxscale/)\
        .with_content(/--language=\/var\/lib\/maxscale/)\
        .with_content(/--user=maxscale/)
    end
    it do
      should contain_file('/etc/maxscale.cnf')\
        .with_ensure('present')\
        .with_require('[Class[Maxscale::Install]{:name=>"Maxscale::Install"}, File[/etc]{:path=>"/etc"}]')\
        .with_content(/^\[maxscale\]$/)\
        .with_content(/^threads=2$/)\
        .with_content(/^\[Binlog_Service\]$/)\
        .with_content(/^type=service$/)
    end
    it do
      should contain_service('maxscale')\
        .with_ensure('running')\
        .with_hasrestart(true)\
        .with_hasstatus(true)\
        .that_subscribes_to('File[/etc/maxscale.cnf]')
    end
    it { should_not contain_file('/etc/maxscale').with_ensure('directory') }
    it { should contain_file('/etc').with_ensure('directory') }
    it { should contain_file('/var/cache/maxscale').with_ensure('directory').with_owner('maxscale') }
    it { should contain_file('/var/log/maxscale').with_ensure('directory').with_owner('maxscale') }
    it { should contain_file('/var/run/maxscale').with_ensure('directory').with_owner('maxscale') }
    it { should contain_file('/var/lib/maxscale').with_ensure('directory').with_owner('maxscale') }
  end

  context 'definition of a non-default instance' do
    let (:title) { 'foo' }
    let (:params) {
      {
        :ensure         => 'stopped',
        :logdir         => '/var/log/maxscale_foo',
        :cachedir       => '/var/cache/maxscale_foo',
        :datadir        => '/var/data/maxscale_foo',
        :piddir         => '/var/run/maxscale_foo',
        :errmsgsys_path => '/var/lib/maxscale_foo',
        :svcuser        => 'nobody',
        :svcgroup       => 'nogroup',
        :configfile     => '/etc/maxscale/maxscale_foo.cnf',
        :config         => {
          'maxscale'    => {
            'threads'   => 1
          },
          'Binlog Listener' => {
            'type'          => 'service',
          }
        },
      }
    }

    it { should contain_file('/etc/maxscale').with_ensure('directory') }
    it { should contain_file('/var/cache/maxscale_foo').with_ensure('directory') }
    it { should contain_file('/var/log/maxscale_foo').with_ensure('directory') }
    it { should contain_file('/var/run/maxscale_foo').with_ensure('directory') }
    it { should contain_file('/var/data/maxscale_foo').with_ensure('directory') }
    it { should contain_file('/var/lib/maxscale_foo').with_ensure('directory') }

    it do
      should contain_file('/etc/init.d/maxscale_foo')\
        .with_ensure('present')\
        .with_require('File[/etc/maxscale/maxscale_foo.cnf]')\
        .with_notify('Service[maxscale_foo]')\
        .with_content(/^processname=maxscale_foo$/)\
        .with_content(/^servicename=maxscale_foo$/)\
        .with_content(/--config=\/etc\/maxscale\/maxscale_foo.cnf/)\
        .with_content(/--datadir=\/var\/data\/maxscale_foo/)\
        .with_content(/--logdir=\/var\/log\/maxscale_foo/)\
        .with_content(/--cachedir=\/var\/cache\/maxscale_foo/)\
        .with_content(/--piddir=\/var\/run\/maxscale_foo/)\
        .with_content(/--language=\/var\/lib\/maxscale_foo/)\
        .with_content(/--user=nobody/)
    end
    it do
      should contain_file('/etc/maxscale/maxscale_foo.cnf')\
        .with_ensure('present')\
        .with_require('[Class[Maxscale::Install]{:name=>"Maxscale::Install"}, File[/etc/maxscale]{:path=>"/etc/maxscale"}]')
        .with_content(/^\[maxscale\]$/)\
        .with_content(/^threads=1$/)\
        .with_content(/^\[Binlog Listener\]$/)\
        .with_content(/^type=service$/)
    end
    it do
      should contain_service('maxscale_foo')\
        .with_ensure('stopped')\
        .with_hasrestart(true)\
        .with_hasstatus(true)\
        .that_subscribes_to('File[/etc/maxscale/maxscale_foo.cnf]')
    end
  end
end
