# Class: pam_access
#
# This module manages pam_access on Redhat
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#   include pam_access
#      or
#   include pam_access::example
#
# [Remember: No empty lines between comments and class definition]
#
# Sample Usage: 
#
# [Remember: No empty lines between comments and class definition]
class pam_access (
    $homedir_umask = '0022'
){
   # place groups or users in the below arrays.
   # ex: $group = [sudo, foo, bar]
   $group = [ "sudo" ]
   $users = []
   $other={}
   file { "/etc/security/access.conf":
         ensure  => "present",
         owner   => "root",
         group   => "root",
         mode    => "644",
         backup  => "true",
         content => template("pam_access/etc/security/access.conf.erb"),
   }

    case $::operatingsystem { 
        'RedHat', 'CentOS': { 
            $pam_acc_enable="authconfig --enablelocauthorize --enablepamaccess --enablemkhomedir --update" 
            exec { "authconfig-access":
              command => $pam_acc_enable, 
              unless  => "grep '^account.*required.*pam_access.so' \
        	  /etc/pam.d/system-auth 2>/dev/null",
              path    => "/usr/bin:/usr/sbin:/bin",
              require => File["/etc/security/access.conf"],
            }
        }
        'debian': { 
            # pam files: login + sshd
            $pam_acc_enable = "sed -i -e 's/^# *\(.*pam_access.*\)/\1/' /etc/pam.d/sshd /etc/pam.d/login"
            $pam_acc_enable_unless = "grep '^[^#].*pam_access' login >/dev/null && grep '^[^#].*pam_access' sshd  >/dev/null"

            # pam files: common-session
            $homedir_line = "session	optional	pam_mkhomedir.so umask=${homedir_umask}"
            $enable_mkhomedir = "sed -i -e '/.*pam_mkhomedir.*/d' /etc/pam.d/common-session \
                && echo '$homedir_line' >> /etc/pam.d/common-session"
            $enable_mkhomedir_unless = "grep '^$homedir_line$' /etc/pam.d/common-session >/tmp/null"

            # pam files: common-session
            $enable_umask = "echo 'session	optional	pam_umask.so'  >> /etc/pam.d/common-session"
            $enable_umask_unless = "grep '^[^#].*pam_umask' /etc/pam.d/common-session >/dev/null"

            exec { "authconfig-access":
                command => $pam_acc_enable,
                unless  => $pam_acc_enable_unless,
                path    => "/usr/bin:/usr/sbin:/bin",
                require => File["/etc/security/access.conf"],
            }

            exec { "enable_mkhomedir":
                command  => $enable_mkhomedir,
                unless   => $enable_mkhomedir_unless,
                path     => "/usr/bin:/usr/sbin:/bin",
            }

            exec { "enable_umask":
                command => $enable_umask,
                unless  => $enable_umask_unless,
                path    => "/usr/bin:/usr/sbin:/bin",
            }
        } # debian
    } # case 
} # class

