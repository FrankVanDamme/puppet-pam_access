# Haal users en groepen uit hiera om pam_access config file
# /etc/security/access.conf te maken
class pam_access::hiera inherits pam_access {
    $u_bl=hiera_array( "users_blacklist", [] )
    $u_wl=hiera_array( "users_whitelist", [] )

    $g_bl=hiera_array( "groups_blacklist", [] )
    $g_wl=hiera_array( "groups_whitelist", [] )

    # Could actually be done by using the 4 hiera variables
    # directly, and adding them to the template in the order
    # "blacklist, whitelist". pam_access will use the first match. 
    $g__wl = union( [ $facts[networking][hostname] ] , $g_wl )

    $users = $u_wl - $u_bl
    $group = $g__wl - $g_bl

    $other=hiera_hash( "pam_access", {} )

    File["/etc/security/access.conf"] {
        content => template("${module_name}/etc/security/access.conf.erb"),
    }
}
