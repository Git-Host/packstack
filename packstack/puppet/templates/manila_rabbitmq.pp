$kombu_ssl_ca_certs = hiera('CONFIG_AMQP_SSL_CACERT_FILE', undef)
$kombu_ssl_keyfile = hiera('CONFIG_MANILA_SSL_KEY', undef)
$kombu_ssl_certfile = hiera('CONFIG_MANILA_SSL_CERT', undef)

if $kombu_ssl_keyfile {
  $files_to_set_owner = [ $kombu_ssl_keyfile, $kombu_ssl_certfile ]
  file { $files_to_set_owner:
    owner   => 'manila',
    group   => 'manila',
    # manila user on RH/Fedora is provided by python-manila
    require => Package['openstack-manila'],
  }
  File[$files_to_set_owner] ~> Service<||>
}

$db_pw = hiera('CONFIG_MANILA_DB_PW')
$mariadb_host = hiera('CONFIG_MARIADB_HOST_URL')

class { '::manila':
  rabbit_host     => hiera('CONFIG_AMQP_HOST_URL'),
  rabbit_port     => hiera('CONFIG_AMQP_CLIENTS_PORT'),
  rabbit_use_ssl  => hiera('CONFIG_AMQP_SSL_ENABLED'),
  rabbit_userid   => hiera('CONFIG_AMQP_AUTH_USER'),
  rabbit_password => hiera('CONFIG_AMQP_AUTH_PASSWORD'),
  sql_connection  => "mysql://manila:${db_pw}@${mariadb_host}/manila",
  verbose         => true,
  debug           => hiera('CONFIG_DEBUG_MODE'),
}
