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

    command => "/usr/bin/env bash -c \"export FEDORA_HOME=${fedora_common::home}\" "
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
  postgresql::server::role { $fedora_common::database_user:
    
    password_hash => postgresql_password($fedora_common::database_user, $fedora_common::database_pass),
    require => Class['postgresql::server']
  }
    
  postgresql::server::db { $fedora_common::database:
    
    user     => $fedora_common::database_user,
    password => postgresql_password($fedora_common::database_user, $fedora_common::database_pass),
    require => Postgresql::Server::Role[$fedora_common::database_user]
  }

  exec { 'fedora_commons_download':

    command => "/usr/bin/env wget ${fedoragsearch::download_url} -O /tmp/fcrepo-installer-3.8.0.jar",
    unless => '/usr/bin/env stat /tmp/fcrepo-installer-3.8.0.jar'
  }

  file { "${fedora_commons}/install/install.properties":

    content => template('fedora_commons/install.properties.erb'),
    require => Exec['fedora_commons_set_env', 'fedora_commons_download', 'fedora_commons_create_database']
  }

  exec { 'fedora_commons_install':

    command => "/usr/bin/env java ${fedoragsearch::download_url} -O /tmp/fcrepo-installer-3.8.0.jar ${fedora_commons}/install/install.properties",
    unless => "/usr/bin/env stat ${fedoragsearch::home}",
    require => File["${fedora_commons}/install/install.properties"]
  }

  exec { 'fedoragsearch_deploy':

    command => "/usr/bin/env cp ${fedora_commons}/install/fedora.war ${servlet_webapps_dir_path}",
    unless => "/usr/bin/env stat ${servlet_webapps_dir_path}/fedora.war",
    require => Exec['fedora_commons_install']
  }
  
}
