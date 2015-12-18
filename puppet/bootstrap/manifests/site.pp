# Install r10k
exec { 'r10k-install':
  command => '/opt/puppetlabs/puppet/bin/gem install r10k',
  creates => '/opt/puppetlabs/puppet/bin/r10k',
}

# Run r10k to grab the modules specified in the Puppetfile
exec { 'r10k':
  command => '/opt/puppetlabs/puppet/bin/r10k puppetfile install',
  cwd     => '/vagrant/puppet/bootstrap',
  require => Exec['r10k-install'],
}