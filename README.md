
# vra_puppet_plugin_prep - DEPRECATED

Note, this repo has been forked to [github.com/puppetlabs](https://github.com/puppetlabs/puppet-vra_puppet_plugin_prep) and is now being maintained there.

Prepares a Puppet Enterprise master for vRA Puppet Plugin integration.

#### Table of Contents

1. [Description](#description)
2. [Beginning with vra_puppet_plugin_prep](#beginning-with-vra_puppet_plugin_prep)
3. [Usage](#usage)
4. [Reference](#reference)
6. [Contributors](#contributors)

## Description

When setting up the vRA Puppet Plugin there are some setup steps that need to be performed on the Puppet Enterprise Master. This module automates many of these, ie it ensures that:

- a system user exists for the plugin to ssh in with
- an api user exists for the plugin to utilise
- sudo rules are in place for this user so the plugin can run the commands it needs to
- autosign policy is configured (shared secret via challengePassword in the CSR)


## Beginning with vra_puppet_plugin_prep

Default behaviour (including autosign configuration enabled):

```
include vra_puppet_plugin_prep
```

## Usage

```puppet
class { 'vra_puppet_plugin_prep':
  vro_plugin_user   => 'vro-plugin-user',
  vro_password      => 'puppetlabs',
  vro_password_hash => '$1$Fq9vkV1h$4oMRtIjjjAhi6XQVSH6.Y.',
  manage_autosign   => true,
  manage_localuser  => true,
  autosign_secret   => 'S3cr3tP@ssw0rd!',
}
```

## Reference

### Class: vra_puppet_plugin_prep

Parameters:

`vro_plugin_user`
The username the plugin will connect to Puppet with, both via ssh, and api

Default: `vro-plugin-user`

`vro_password`
The password the plugin will authenticate to the Puppet apis with.

Default: `puppetlabs`

`vro_password_hash`
The hash of the password the plugin will authenticate with via ssh to the Puppet Master.

Default: `$1$Fq9vkV1h$4oMRtIjjjAhi6XQVSH6.Y.` ('puppetlabs')

`vro_plugin_user_uid`
UID to create the vro-plugin-user with. Optional.

Default: undef

`vro_plugin_user_gid`
GID to create the vro-plugin-user with. Optional.

Default: undef

`manage_autosign`
Whether to configure autosigning with this module.

Default: True

`manage_localuser`
Whether to configure the local user creation with this module

Default: True

`autosign_secret`
The secret to use for autosign validation. It is placed into the challengePassword within the CSR.

Default: `S3cr3tP@ssw0rd!`

## Contributors

Thank you to Jeremy Adams and other contributors to the [vRO Starter Content](https://github.com/puppetlabs/puppet-vro-starter_content) project, from which much of the code in this repo has been stolen.
