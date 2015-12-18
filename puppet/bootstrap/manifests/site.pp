exec { 'r10k-install':
  command => '/opt/puppetlabs/puppet/bin/gem install r10k',
  creates => '/opt/puppetlabs/puppet/bin/r10k',
}

exec { 'r10k':
  command => '/opt/puppetlabs/puppet/bin/r10k deploy environment -p',
  cwd     => '/vagrant/puppet/bootstrap',
  require => Exec['r10k-install'],
}