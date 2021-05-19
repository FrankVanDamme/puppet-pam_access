# pam_access

This module will manage your /etc/security/access.conf file using a template.

There are two classes you can invoke:

  pam_access
  pam_access::hiera

The main class serves the purpose of configuring pam

On Debian, this means modifying these files `in /etc/pam.d`:

* enable the `pam_access` module in `login` and `sshd` files
* enable `pam_mkhomedir` and `pam_umask` module in common-session

On RedHat, use use `authconfig` to achieve the same thing.

## hiera

Add these 4 variables to hiera:
* users_whitelist
* users_blacklist
* groups_whitelist
* groups_blacklist

Users are added to `pam_access.conf` first, just as a list of users_whitelist
with the elements of users_blacklist removed. Then the same for groups. So,
blacklist entries take precedence over whitelist entries.

The default is to deny access! You might want to add at least one user or group to your whitelist.

A possible improvement would be to add users and groups directly, and let pam
figure out wether a user is blacklisted or whitelisted by adding them to the
template in the order "blacklist, whitelist". pam_access will use the first
match. 
