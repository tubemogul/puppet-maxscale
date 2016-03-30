require 'spec_helper'

describe 'path_tree' do
  it { should run.with_params('/').and_return([]) }
  it { should run.with_params('/etc').and_return(['/etc']) }
  it { should run.with_params('/etc/maxscale').and_return(['/etc', '/etc/maxscale']) }
  it { should run.with_params('/etc/maxscale/test').and_return(['/etc', '/etc/maxscale', '/etc/maxscale/test']) }
  it { should run.with_params(['/etc/maxscale/test', '/etc/maxscale/cfg']).and_return(['/etc', '/etc/maxscale', '/etc/maxscale/test', '/etc/maxscale/cfg']) }
end
