control 'docker-hardening' do
  impact 1.0
  title 'Verify Docker hardening'
  desc 'Ensure that Docker is properly configured for security and performance'

  # Ensure that the Docker daemon is running and is listening on a Unix socket
  describe service('docker') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

  describe port('unix:///var/run/docker.sock') do
    it { should be_listening }
  end

  # Ensure that the Docker daemon is properly configured
  describe file('/etc/docker/daemon.json') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('content') { should include '{"live-restore": true}' }
  end

  # Ensure that the Docker engine is using an appropriate storage driver
  describe command('docker info --format "{{ .Driver }}"') do
    its('stdout') { should match /overlay2/ }
  end

  # Ensure that the Docker engine is not using the aufs storage driver
  describe command('docker info --format "{{ .Driver }}"') do
    its('stdout') { should_not match /aufs/ }
  end

  # Ensure that the Docker daemon is not running as root
  describe command('docker info --format "{{ .ID }}"') do
    its('stdout') { should_not match /^0+$/ }
  end

  # Ensure that the Docker engine is using TLS for communication with the Docker daemon
  describe command('docker info --format "{{ .TLS }}"') do
    its('stdout') { should match /true/ }
  end

  # Ensure that the Docker engine is not running in debug mode
  describe command('docker info --format "{{ .Debug }}"') do
    its('stdout') { should match /false/ }
  end
end
