require 'spec_helper'

describe 'maxscale' do
  context 'supported operating systems' do
    [
      { osfamily: 'Debian', operatingsystem: 'Ubuntu', lsbdistid: 'Ubuntu', lsbdistcodename: 'trusty', lsbdistrelease: '14.04', puppetversion: Puppet.version },
      { osfamily: 'RedHat', operatingsystem: 'CentOS', operatingsystemmajrelease: '6', puppetversion: Puppet.version }
    ].each do |family|
      describe "maxscale class without required parameters on #{family[:osfamily]}" do
        let(:params) { {} }
        let(:facts) { family }

        it { is_expected.not_to compile.with_all_deps }
        it { expect { is_expected.to contain_package('maxscale') }.to raise_error(Puppet::Error, %r{You need to provide a valid token. See https://github.com/tubemogul/puppet-maxscale#before-you-begin for more details.}) }
      end

      describe "maxscale class with only required parameters on #{family[:osfamily]}" do
        let(:params) do
          {
            token: 'abc123-456xyz'
          }
        end
        let(:facts) { family }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to create_class('maxscale') }
        it { is_expected.to contain_class('maxscale::params') }
        it { is_expected.to contain_class('maxscale::install').that_comes_before('Class[maxscale::config]') }
        it { is_expected.to contain_class('maxscale::config') }

        it do
          case family[:osfamily]
          when 'Debian'
            is_expected.to contain_apt__source('maxscale').\
              with_location('http://downloads.mariadb.com/enterprise/abc123-456xyz/mariadb-maxscale/latest/ubuntu').\
              with_release('trusty').\
              with_repos('main').\
              that_notifies('Class[apt::update]')
          when 'RedHat'
            is_expected.to contain_yumrepo('maxscale').\
              with_baseurl('http://downloads.mariadb.com/enterprise/abc123-456xyz/mariadb-maxscale/latest/centos/6/x86_64')
          end
        end

        case family[:osfamily]
        when 'Debian'
          it { is_expected.to contain_package('maxscale').with_ensure('present').that_requires('Class[apt::update]') }
        when 'RedHat'
          it { is_expected.to contain_package('maxscale').with_ensure('present').that_requires('Yumrepo[maxscale]') }
        end

        it do
          is_expected.to contain_file('/root/.maxadmin').\
            with_ensure('present').\
            with_owner('root').\
            with_group('root').\
            with_mode('0600').\
            with_content(%r{^user=admin$}).\
            with_content(%r{^passwd=mariadb$})
        end

        it { is_expected.to contain_Maxscale__Instance('default') }
        it do
          is_expected.to contain_file('/etc/maxscale.cnf').\
            with_ensure('present').\
            with_require('[Class[Maxscale::Install]{:name=>"Maxscale::Install"}, File[/etc]{:path=>"/etc"}]').\
            with_content(%r{^\[maxscale\]$}).\
            with_content(%r{^threads=2$}).\
            with_content(%r{^\[Binlog_Service\]$}).\
            with_content(%r{^type=service$})
        end
        it do
          is_expected.to contain_file('/etc/init.d/maxscale').\
            with_ensure('present').\
            with_require('File[/etc/maxscale.cnf]')
        end
        it do
          is_expected.to contain_service('maxscale').\
            with_ensure('running').\
            with_hasrestart(true).\
            with_hasstatus(true).\
            that_subscribes_to('File[/etc/maxscale.cnf]').\
            that_subscribes_to('File[/etc/init.d/maxscale]')
        end
      end
      describe "do not install repository on #{family[:osfamily]}" do
        let(:params) do
          {
            install_repository: false
          }
        end
        let(:facts) { family }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('maxscale') }
        it { is_expected.to contain_class('maxscale::params') }
        it { is_expected.to contain_class('maxscale::install').that_comes_before('Class[maxscale::config]') }
        it { is_expected.to contain_class('maxscale::config') }

        case family[:osfamily]
        when 'Debian'
          it { is_expected.not_to contain_apt__source('maxscale') }
        when 'RedHat'
          it { is_expected.not_to contain_yumrepo('maxscale') }
        end

        it { is_expected.to contain_package('maxscale').with_ensure('present') }
      end

      describe "multi-instances maxscale on #{family[:osfamily]}" do
        let(:params) do
          {
            token: 'abc123-456xyz',
            services_conf: {
              'default'                    => {},
              'foo'                        => {
                'ensure'                   => 'stopped',
                'logdir'                   => '/var/log/maxscale_foo',
                'cachedir'                 => '/var/cache/maxscale_foo',
                'datadir'                  => '/var/data/maxscale_foo',
                'piddir'                   => '/var/run/maxscale_foo',
                'errmsgsys_path'           => '/var/lib/maxscale_foo',
                'svcuser'                  => 'nobody',
                'svcgroup'                 => 'nogroup',
                'configfile'               => '/etc/maxscale/maxscale_foo.cnf',
                'master_ini'               => {
                  'directory'              => '/var/cache/maxscale_foo/binlog',
                  'content'                => {
                    'binlog_configuration' => {
                      'master_host'        => '10.0.0.125',
                      'master_port'        => 3306,
                      'master_user'        => 'maxscale',
                      'master_password'    => 'PLEASE_CHANGE_ME!3!',
                      'filestem'           => 'mysql-bin'
                    }
                  }
                }
              }
            }
          }
        end
        let(:facts) { family }

        # The details of the test of Maxscale::Instance define are in
        # spec/defines/instance_spec.rb
        it { is_expected.to contain_Maxscale__Instance('default') }
        it { is_expected.to contain_Maxscale__Instance('foo') }
      end

      # This will change based on the os family
      describe "maxscale repo install with custom url repository on #{family[:osfamily]}" do
        case family[:osfamily]
        when 'Debian'
          let(:params) do
            {
              repo_custom_url: 'https://my.company.repo/ubuntu'
            }
          end
        when 'RedHat'
          let(:params) do
            {
              repo_custom_url: 'https://my.company.repo/centos'
            }
          end
        end
        let(:facts) { family }

        it do
          case family[:osfamily]
          when 'Debian'
            is_expected.to contain_apt__source('maxscale').\
              with_location('https://my.company.repo/ubuntu').\
              with_release('trusty').\
              with_repos('main')
          when 'RedHat'
            is_expected.to contain_yumrepo('maxscale').\
              with_baseurl('https://my.company.repo/centos')
          end
        end
        it { is_expected.to contain_package('maxscale').with_ensure('present') }
      end
    end
  end

  context 'unsupported operating system' do
    describe 'maxscale class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          osfamily: 'Solaris',
          operatingsystem: 'Nexenta'
        }
      end

      it { expect { is_expected.to contain_package('maxscale') }.to raise_error(Puppet::Error, %r{Nexenta not supported}) }
    end
  end
end
