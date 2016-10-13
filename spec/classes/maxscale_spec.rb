require 'spec_helper'

describe 'maxscale' do

  context 'supported operating systems' do

    ['Debian','RedHat'].each do |osfamily|

      describe "maxscale class without required parameters on #{osfamily}" do
        let(:params) {{
        }}
        case osfamily
        when 'Debian'
          let(:facts) {{
            :osfamily        => osfamily,
            :operatingsystem => 'Ubuntu',
            :lsbdistid       => 'Ubuntu',
            :lsbdistcodename => 'trusty',
            :lsbdistrelease  => '14.04',
            :puppetversion   => Puppet.version,
          }}
        when 'RedHat'
          let(:facts) {{
            :osfamily        => osfamily,
            :operatingsystem => 'CentOS',
            :operatingsystemmajrelease => '6',
            :puppetversion   => Puppet.version,
          }}
        end

        it { should_not compile.with_all_deps }
        it { expect { should contain_package('maxscale') }.to raise_error(Puppet::Error, /You need to provide a valid token. See https:\/\/github.com\/tubemogul\/puppet-maxscale#before-you-begin for more details./) }
      end

      describe "maxscale class with only required parameters on #{osfamily}" do
        let(:params) {{
          :token => 'abc123-456xyz',
        }}
        case osfamily
        when 'Debian'
          let(:facts) {{
            :osfamily        => osfamily,
            :operatingsystem => 'Ubuntu',
            :lsbdistid       => 'Ubuntu',
            :lsbdistcodename => 'trusty',
            :lsbdistrelease  => '14.04',
            :puppetversion   => Puppet.version,
          }}
        when 'RedHat'
          let(:facts) {{
            :osfamily        => osfamily,
            :operatingsystem => 'CentOS',
            :operatingsystemmajrelease => '6',
            :puppetversion   => Puppet.version,
          }}
        end

        it { should compile.with_all_deps }

        it { should create_class('maxscale') }
        it { should contain_class('maxscale::params') }
        it { should contain_class('maxscale::install').that_comes_before('Class[maxscale::config]') }
        it { should contain_class('maxscale::config') }

        it do
          case osfamily
          when 'Debian'
            should contain_apt__source('maxscale')\
              .with_location('http://downloads.mariadb.com/enterprise/abc123-456xyz/mariadb-maxscale/latest/ubuntu')\
              .with_release('trusty')\
              .with_repos('main')\
              .that_notifies('Class[apt::update]')
          when 'RedHat'
            should contain_yumrepo('maxscale')\
              .with_baseurl('http://downloads.mariadb.com/enterprise/abc123-456xyz/mariadb-maxscale/latest/centos/6/x86_64')
          end
        end

        case osfamily
        when 'Debian'
          it { should contain_package('maxscale').with_ensure('present').that_requires('Class[apt::update]') }
        when 'RedHat'
          it { should contain_package('maxscale').with_ensure('present').that_requires('Yumrepo[maxscale]') }
        end

        it do
          should contain_file('/root/.maxadmin')\
            .with_ensure('present')\
            .with_owner('root')\
            .with_group('root')\
            .with_mode('0600')\
            .with_content(/^user=admin$/)\
            .with_content(/^passwd=mariadb$/)
        end

        it { should contain_Maxscale__Instance('default') }
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
          should contain_file('/etc/init.d/maxscale')\
            .with_ensure('present')\
            .with_require('File[/etc/maxscale.cnf]')
        end
        it do
          should contain_service('maxscale')\
            .with_ensure('running')\
            .with_hasrestart(true)\
            .with_hasstatus(true)\
            .that_subscribes_to('File[/etc/maxscale.cnf]')
            .that_subscribes_to('File[/etc/init.d/maxscale]')
        end
      end
      describe "do not install repository on #{osfamily}" do
        let(:params) {{ :install_repository => false, }}
        case osfamily
        when 'Debian'
          let(:facts) {{
            :osfamily        => osfamily,
            :operatingsystem => 'Ubuntu',
            :lsbdistid       => 'Ubuntu',
            :lsbdistcodename => 'trusty',
            :lsbdistrelease  => '14.04',
            :puppetversion   => Puppet.version,
          }}
        when 'RedHat'
          let(:facts) {{
            :osfamily        => osfamily,
            :operatingsystem => 'CentOS',
            :operatingsystemmajrelease => '6',
            :puppetversion   => Puppet.version,
          }}
        end
        it { should compile.with_all_deps }

        it { should create_class('maxscale') }
        it { should contain_class('maxscale::params') }
        it { should contain_class('maxscale::install').that_comes_before('Class[maxscale::config]') }
        it { should contain_class('maxscale::config') }

        case osfamily
        when 'Debian'
          it { should_not contain_apt__source('maxscale') }
        when 'RedHat'
          it { should_not contain_yumrepo('maxscale') }
        end

        it { should contain_package('maxscale').with_ensure('present') }
      end

      describe "multi-instances maxscale on #{osfamily}" do
        let(:params) {{
          :token                         => 'abc123-456xyz',
          :services_conf                 => {
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
										'filestem'           => 'mysql-bin',
									},
                },
              },
            }
          }
        }}
        case osfamily
        when 'Debian'
          let(:facts) {{
            :osfamily        => osfamily,
            :operatingsystem => 'Ubuntu',
            :lsbdistid       => 'Ubuntu',
            :lsbdistcodename => 'trusty',
            :lsbdistrelease  => '14.04',
            :puppetversion   => Puppet.version,
          }}
        when 'RedHat'
          let(:facts) {{
            :osfamily        => osfamily,
            :operatingsystem => 'RedHat',
            :operatingsystemmajrelease => '6',
            :puppetversion   => Puppet.version,
          }}
        end
        # The details of the test of Maxscale::Instance define are in
        # spec/defines/instance_spec.rb
        it { should contain_Maxscale__Instance('default') }
        it { should contain_Maxscale__Instance('foo') }
      end

      # This will change based on the os family
      describe "maxscale repo install with custom url repository on #{osfamily}" do
        case osfamily
        when 'Debian'
          let(:params) {{
            :repo_custom_url => 'https://my.company.repo/ubuntu',
          }}
          let(:facts) {{
            :osfamily        => osfamily,
            :operatingsystem => 'Ubuntu',
            :lsbdistid       => 'Ubuntu',
            :lsbdistcodename => 'trusty',
            :lsbdistrelease  => '14.04',
            :puppetversion   => Puppet.version,
          }}
        when 'RedHat'
          let(:params) {{
            :repo_custom_url => 'https://my.company.repo/centos',
          }}
          let(:facts) {{
            :osfamily        => osfamily,
            :operatingsystem => 'CentOS',
            :operatingsystemmajrelease => '6',
            :puppetversion   => Puppet.version,
          }}
        end

        it do
          case osfamily
	  when 'Debian'
            should contain_apt__source('maxscale')\
              .with_location('https://my.company.repo/ubuntu')\
              .with_release('trusty')\
              .with_repos('main')
          when 'RedHat'
            should contain_yumrepo('maxscale')\
              .with_baseurl('https://my.company.repo/centos')
          end
        end
        it { should contain_package('maxscale').with_ensure('present') }
      end
    end
  end


  context 'unsupported operating system' do
    describe 'maxscale class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { should contain_package('maxscale') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end

end
