# vra_puppet_plugin_prep
#
# @summary Prepares a PE master for vRA Puppet Plugin integration.
#
# @example
#   include vra_puppet_plugin_prep
#
# @example
#   class { 'vra_puppet_plugin_prep':
#     vro_plugin_user    => 'vro-plugin-user',
#     vro_password       => 'puppetlabs',
#     vro_password_hash  => '$1$Fq9vkV1h$4oMRtIjjjAhi6XQVSH6.Y.',
#     manage_autosign    => true,
#     autosign_secret    => 'S3cr3tP@ssw0rd!',
#   }
class vra_puppet_plugin_prep (
  String            $vro_plugin_user     = 'vro-plugin-user',
  String            $vro_password        = 'puppetlabs',
  String            $vro_password_hash   = '$1$Fq9vkV1h$4oMRtIjjjAhi6XQVSH6.Y.', #puppetlabs
  Boolean           $manage_autosign     = true,
  Optional[Boolean] $vro_plugin_user_uid = undef,
  Optional[Boolean] $vro_plugin_user_gid = undef,
  String            $autosign_secret     = 'S3cr3tP@ssw0rd!',
  String            $vro_email           = 'vro-plugin-user@example',
  String            $vro_display_name    = 'vRO Puppet Plugin',
) {

  $vro_role_name = 'VRO Plugin User'
  $permissions   = [
    { 'action'      => 'view_data',
      'instance'    => '*',
      'object_type' => 'nodes',
    },
  ]

  rbac_role { $vro_role_name:
    ensure      => present,
    name        => $vro_role_name,
    description => $vro_role_name,
    permissions => $permissions,
  }

  rbac_user { $vro_plugin_user:
    ensure       => 'present',
    name         => $vro_plugin_user,
    display_name => $vro_display_name,
    password     => $vro_password,
    roles        => [ $vro_role_name ],
    email        => $vro_email,
    require      => Rbac_role[$vro_role_name],
  }

  if $vro_plugin_user_gid {
    group { $vro_plugin_user:
      ensure => present,
      gid    => $vro_plugin_user_gid,
    }
  }

  $uid_attr = $vro_plugin_user_uid ? {
    /Integer/ => { uid => $vro_plugin_user_uid, },
    default   => {},
  }

  $gid_attr = $vro_plugin_user_gid ? {
    /Integer/ => { gid => $vro_plugin_user_gid, },
    default   => {},
  }

  $user_base_attrs = {
    ensure     => present,
    shell      => '/bin/bash',
    password   => $vro_password_hash,
    groups     => ['pe-puppet'],
    managehome => true,
  }

  $user_attrs = $user_base_attrs + $uid_attr + $gid_attr

  user { $vro_plugin_user:
    * => $user_attrs,
  }

  file { '/etc/sudoers.d/vro-plugin-user':
    ensure  => file,
    mode    => '0440',
    owner   => 'root',
    group   => 'root',
    content => epp('vra_puppet_plugin_prep/vro_sudoer_file.epp'),
  }

  sshd_config { 'PasswordAuthentication':
    ensure => present,
    value  => 'yes',
  }

  sshd_config { 'ChallengeResponseAuthentication':
    ensure => present,
    value  => 'no',
  }

  if $manage_autosign {
    file { '/etc/puppetlabs/puppet/autosign.rb' :
      ensure  => file,
      owner   => 'pe-puppet',
      group   => 'pe-puppet',
      mode    => '0700',
      content => epp('vra_puppet_plugin_prep/autosign.rb.epp', { 'autosign_secret' => $autosign_secret }),
      notify  => Service['pe-puppetserver'],
    }

    ini_setting { 'autosign script setting':
      ensure  => present,
      path    => '/etc/puppetlabs/puppet/puppet.conf',
      section => 'master',
      setting => 'autosign',
      value   => '/etc/puppetlabs/puppet/autosign.rb',
      notify  => Service['pe-puppetserver'],
    }
  }
}
