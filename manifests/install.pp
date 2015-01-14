# == Class: fedora_commons::install
#
# Class for managing the installation process of Fedora Generic Search
#
class fedora_commons::install inherits fedora_commons {

  package { 'ant':

    ensure => 'installed'
  }

  # Set the environmental variables FEDORA_HOME

  exec { 'fedora_commons_set_env':

    command => "/usr/bin/env bash -c \"export FEDORA_HOME=${fedora_commons::home} CATALINA_HOME=${fedora_commons::fedora_servlet_home}\""
  }

  class { 'postgresql::globals':

    manage_package_repo => true,
  }
    
  class { 'postgresql::server':

    listen_addresses => '*',

    # ip_mask_deny_postgres_user => '0.0.0.0/32',
    # ip_mask_allow_all_users    => '0.0.0.0/0',
    # ipv4acls                   => ['hostssl all 192.168.0.0/24 cert'],
    postgres_password          => 'secret',
    require => Class['postgresql::globals']
  }

  
  # Create the database for the repository
  # Use either MySQL or PostgreSQL
  postgresql::server::role { $fedora_commons::database_user:
    
    password_hash => postgresql_password($fedora_commons::database_user, $fedora_commons::database_pass),
    require => Class['postgresql::server']
  }
    
  postgresql::server::db { $fedora_commons::database:
    
    user     => $fedora_commons::database_user,
    password => postgresql_password($fedora_commons::database_user, $fedora_commons::database_pass),
    require => Postgresql::Server::Role[$fedora_commons::database_user]
  }

  exec { 'fedora_commons_download':

    command => "/usr/bin/env wget \"${fedora_commons::download_url}\" -O /tmp/fcrepo-installer-3.8.0.jar",
    unless => '/usr/bin/env stat /tmp/fcrepo-installer-3.8.0.jar',
    timeout => 0
  }

  file { [ $fedora_commons::home, "${fedora_commons::home}/install" ]:

    ensure => 'directory'
  }

  file { "${fedora_commons::home}/install/install.properties":

    content => template('fedora_commons/install.properties.erb'),
    require => File["${fedora_commons::home}/install"]
  }

  exec { 'fedora_commons_install':

    command => "/usr/bin/env java ${fedora_commons::download_url} -O /tmp/fcrepo-installer-3.8.0.jar ${fedora_commons::home}/install/install.properties",
    unless => "/usr/bin/env stat ${fedora_commons::home}/install/fedora.war",
    require => [ Exec['fedora_commons_set_env', 'fedora_commons_download' ], File["${fedora_commons::home}/install/install.properties"], Postgresql::Server::Db[$fedora_commons::database] ]
  }

  exec { 'fedora_commons_deploy':

    command => "/usr/bin/env cp ${fedora_commons::home}/install/fedora.war ${servlet_webapps_dir_path}",
    unless => "/usr/bin/env stat ${servlet_webapps_dir_path}/fedora.war",
    require => Exec['fedora_commons_install']
  }
  
}
