#!/bin/bash
set -uexo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y expect

# Run installer.
chmod +x /opt/hcloud/wireguard_setup.sh
expect <<"EXPECT"
#!/usr/bin/expect -f
#
# This Expect script was generated by autoexpect on Mon Aug  8 22:36:46 2022
# Expect and autoexpect were both written by Don Libes, NIST.
#
# Note that autoexpect does not guarantee a working script.  It
# necessarily has to guess about certain things.  Two reasons a script
# might fail are:
#
# 1) timing - A surprising number of programs (rn, ksh, zsh, telnet,
# etc.) and devices discard or ignore keystrokes that arrive "too
# quickly" after prompts.  If you find your new script hanging up at
# one spot, try adding a short sleep just before the previous send.
# Setting "force_conservative" to 1 (see below) makes Expect do this
# automatically - pausing briefly before sending each character.  This
# pacifies every program I know of.  The -c flag makes the script do
# this in the first place.  The -C flag allows you to define a
# character to toggle this mode off and on.

set force_conservative 0  ;# set to 1 to force conservative mode even if
			  ;# script wasn't run conservatively originally
if {$force_conservative} {
	set send_slow {1 .1}
	proc send {ignore arg} {
		sleep .1
		exp_send -s -- $arg
	}
}

#
# 2) differing output - Some programs produce different output each time
# they run.  The "date" command is an obvious example.  Another is
# ftp, if it produces throughput statistics at the end of a file
# transfer.  If this causes a problem, delete these patterns or replace
# them with wildcards.  An alternative is to use the -p flag (for
# "prompt") which makes Expect only look for the last line of output
# (i.e., the prompt).  The -P flag allows you to define a character to
# toggle this mode off and on.
#
# Read the man page for more info.
#
# -Don


set timeout -1
spawn /opt/hcloud/wireguard_setup.sh
match_max 100000
expect -exact " _________________________________________________________________________\r
|                                                                         |\r
|   Welcome to the WireGuard One-Click-App configuration.                 |\r
|                                                                         |\r
|   In this process WireGuard and the management UI will be set up        |\r
|   accordingly. You only need to set your desired domain which will      |\r
|   be used to configure the reverse proxy and to obtain Let's Encrypt    |\r
|   certificates.                                                         |\r
|                                                                         |\r
|   ATTENTION: Please make sure your domain exists and points to the      |\r
|              IPv4/IPv6 address of your server!                          |\r
|                                                                         |\r
|   Please enter the domain in following pattern: wireguard.example.com   |\r
|_________________________________________________________________________|\r
\r
Please enter your details to set up your new WireGuard instance.\r
Your domain: "
send -- "example.com\r"
expect -exact "example.com\r
Please enter the password that should be used to protect the management UI:\r
Password: "
send -- "admin\r"
expect -exact "\r
Password (again): "
send -- "wrong\r"
expect -exact "\r
Please try again.\r
Password: "
send -- "admin\r"
expect -exact "\r
Password (again): "
send -- "admin\r"
expect -exact "\r
Please enter an Email address for Let's Encrypt notifications:\r
Your Email address: "
send -- "mail@example.com\r"
expect -exact "\r
\r
Is everything correct? \[Y/n\] "
send -- "\r"
expect eof
EXPECT

# Check if the wg0 interface exists.
ip link show wg0

# Check that forwarding is enabled.
[ `cat /proc/sys/net/ipv4/ip_forward` == "1" ]
[ `cat /proc/sys/net/ipv6/conf/all/forwarding` == "1" ]

# Check that the firewall ruleset is loaded.
[ `nft list ruleset | wc -l` -ge 5 ]

# Test if the server is reachable.
# We have to connect locally without TLS, because caddy won't be able to acquire a valid cert.
curl -sL http://localhost:5000 | grep "WireGuard UI"
