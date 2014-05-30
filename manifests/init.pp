# Classe squid3
# Implementa squid proxy server

class squid3 (
	# Opcoes que serao aplicadas no squid.conf
	# Customizacoes na chamada da classe sobresquevem os vaores default
	$acl = [],
	$http_access = [],
	$icp_access = [],
	$http_port = [ '3128' ],
	$cache_dir = [ 'ufs /var/spool/squid3 5120 16 256' ],
	$visible_hostname = 'localhost',
	$coredump_dir = '/var/spool/squid3',
	$maximum_object_size = '128000 KB',
	$maximum_object_size_in_memory = '100 MB',
	$cache_mgr = 'root',
	$access_log = '/var/log/squid3/access.log',
	$cache_mem = '1500 MB',
	$cache_store_log = 'none',
	$memory_replacement_policy = 'lru',
	$cache_replacement_policy = 'lru',
	$store_dir_select_algorithm = 'least-load',
	$cache = [],
	$hosts = [],
	$config_hash = {},
) {

	# Definicoes
	
	$package = 'squid3'
	$service = 'squid3'
	$user = 'proxy'
	$group = 'proxy'
	$config_file = "/etc/${package}/squid.conf"
	$real_cache_dir = "/var/spool/${package}"
	$hosts_file = "/etc/hosts"
	
	# Pacote
	
	package { $package:
		ensure  => installed,
	}
	
	# Arquivo de configuracao
	
	file { $config_file:
		ensure  => file,
		owner   => root,
		group   => root,
		mode    => '0644',
		content => template("squid3/squid.conf.erb"),
		require => Package[$package],
	}

	# Diretorio de cache
	
	file { $real_cache_dir:
		ensure  => directory,
		owner   => $user,
		group   => $group,
		mode    => '0755',
		require => Package[$package],
	}

	file { $hosts_file:
		ensure  => file,
		owner   => root,
		group   => root,
		mode    => '0644',
		content => template("squid3/hosts.erb"),
		require => Package[$package],
	}
	# Exec que inicia o cache
	
	exec { 'Iniciando o diretorio de cache':
		command => "/usr/sbin/service ${service} stop; /usr/sbin/${service} -z",
		creates => "${real_cache_dir}/00",
		notify  => Service[$service],
		require => [ File[$real_cache_dir], File[$config_file] ],
	}

	# Servico
	
	service { $service:
		ensure    => running,
		enable    => true,
		require   => Package[$package],
		restart   => '/etc/init.d/squid3 reload',
		subscribe => File['/etc/squid3/squid.conf'],
	}

	# Arquivos estaticos
	
	file { '/etc/squid3/malware.txt':
		ensure => file,
		owner => root,
		group => root,
		mode => '0644',
		source => 'puppet:///modules/squid3/malware.txt',
		recurse => true,
		require => Package[$package],
	}
	
	file { '/etc/squid3/malware-re.txt':
		ensure => file,
		owner => root,
		group => root,
		mode => '0644',
		source => 'puppet:///modules/squid3/malware-re.txt',
		recurse => true,
		require => Package[$package],
	}
	
	file { '/etc/squid3/blocklist.txt':
		ensure => file,
		owner => root,
		group => root,
		mode => '0644',
		source => 'puppet:///modules/squid3/blocklist.txt',
		recurse => true,
		require => Package[$package],
	}
	
	file { '/etc/squid3/blocklist-re.txt':
		ensure => file,
		owner => root,
		group => root,
		mode => '0644',
		source => 'puppet:///modules/squid3/blocklist-re.txt',
		recurse => true,
		require => Package[$package],
	}
	
	file { '/etc/squid3/vip-sites.txt':
		ensure => file,
		owner => root,
		group => root,
		mode => '0644',
		source => 'puppet:///modules/squid3/vip-sites.txt',
		recurse => true,
		require => Package[$package],
	}

# Fim
}