# == Class: fedora_commons
#
# Parameters for the fedora_commons Class
#
class fedora_commons::params {

  # http://downloads.sourceforge.net/project/fedora-commons/fedora/3.8.0/fcrepo-installer-3.8.0.jar?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Ffedora-commons%2Ffiles%2Flatest%2Fdownload&ts=1421164747&use_mirror=superb-dca3
  $download_url = 'http://downloads.sourceforge.net/project/fedora-commons/fedora/3.8.0/fcrepo-installer-3.8.0.jar?r=&ts=1421164613&use_mirror=hivelocity'
  $version = '3.8.0'

  $user_name = 'fedoraAdmin'
  $user_pass = 'secret'
  $host = 'localhost'
  $servlet_context = 'fedora'
  $auth_api_a = false
  $ssl = true
  $ssl_api_a = false
  $ssl_api_m = true
  $fedora_servlet_engine = 'existingTomcat'

  # Define $CATALINA_HOME
  $fedora_servlet_home = '/usr/share/tomcat'
  $fedora_servlet_http_port = 8080
  $fedora_servlet_shutdown_port = 8005
  $fedora_servlet_https_port = 8443
  
  $fedora_servlet_keystore_path = 'included'
  $fedora_servlet_keystore_pass = 'changeit'
  $fedora_servlet_keystore_type = 'JKS'

  $database_type = 'postgresql'
  $database_jdbc_driver_path = 'included'
  $database_user = 'fedora'
  $database_pass = 'secret'
  $database_host = 'localhost'
  $database = 'fedora3'
  $database_jdbc_url = "jdbc:${database_type}://${database_host}/${database}"
  $database_jdbc_class = 'org.postgresql.Driver'

  $upstream_http_auth = false
  $fesl_authz = false
  $xacml_enforced = true
  $low_level_storage = 'akubra-fs'
  $resource_index = true
  $messaging = true
  $messaging_provider = 'default'
  $local_services = true
  
  $home = '/usr/local/fedora'
  $fedora_users = "${home}/server/config/fedora-users.xml"

  $servlet_engine = 'tomcat'
  $servlet_webapps_dir_path = '/var/lib/tomcat/webapps'
  $servlet_context_dir_path = '/etc/tomcat/Catalina/localhost'
  $servlet_host = 'localhost'
  $servlet_port = '8080'
  $servlet_user = 'tomcat'
  $servlet_group = 'tomcat'
  
}
