class pam_access::hiera inherits pam_access {
    $u_bl=hiera_array( "users_blacklist", [] )
    $u_wl=hiera_array( "users_whitelist", [] )
    $g_bl=hiera_array( "groups_blacklist", [] )
    $g_wl=hiera_array( "groups_whitelist", [] )

    # Could actually be done by using the 4 hiera variables
    # directly, and adding them to the template in the order
    # "blacklist, whitelist". pam_access will use the first match. 
    $g__wl = union( [ $hostname ] , $g_wl )
    
    # Puppet 4 only :-( 
    # $users = $u_wl - $u_bl
    $users=array_difference( $u_wl, $u_bl )
    $group=array_difference( $g__wl, $g_bl )

    File["/etc/security/access.conf"] {
	content => template("${mod}/etc/security/access.conf.erb"),
    }
}
