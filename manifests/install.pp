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

  file { "/tmp/install.properties":

    content => template('fedora_commons/install.properties.erb')
  }

  exec { 'fedora_commons_install':

    command => "/usr/bin/env java -jar /tmp/fcrepo-installer-3.8.0.jar /tmp/install.properties",
    unless => "/usr/bin/env stat ${fedora_commons::home}/install/fedora.war",
    require => [ Exec['fedora_commons_set_env', 'fedora_commons_download' ], File["/tmp/install.properties"], Postgresql::Server::Db[$fedora_commons::database] ]
  }

  # @todo Resolve
  # An exception by Tomcat is logged if /var/lib/tomcat/webapps/fedora is not created (after deploying fedora.war)
  # Further, ensure that the directories are owned by the system servlet user and group
  file { [ "${fedora_commons::servlet_webapps_dir_path}/${fedora_commons::servlet_context}", $fedora_commons::home ]:

    ensure => 'directory',
    recurse => true,
    owner => $fedora_commons::servlet_user,
    group => $fedora_commons::servlet_group
  }

  # The following *must* be inserted into the Tomcat server.xml Document if a keystore is being used!
  #
  # <Connector minSpareThreads="25" maxSpareThreads="75" acceptCount="100" scheme="https" secure="true" SSLEnabled="true" port="8443" enableLookups="true" keystoreFile="conf/keystore" URIEncoding="UTF-8"/>

  exec { 'fedora_commons_deploy':

    command => "/usr/bin/env cp ${fedora_commons::home}/install/fedora.war ${fedora_commons::servlet_webapps_dir_path}",
    unless => "/usr/bin/env stat ${fedora_commons::servlet_webapps_dir_path}/fedora.war",
    require => [ File["${fedora_commons::servlet_webapps_dir_path}/${fedora_commons::servlet_context}", $fedora_commons::home], Exec['fedora_commons_install'] ]
  }
  
}
