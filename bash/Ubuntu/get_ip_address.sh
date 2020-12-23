#!/bin/bash

private_ip=$(ip addr show enp0s31f6 | awk '/inet /{print $2}' )
private_ip=${private_ip::-3}
public_ip=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com)
public_ip=${public_ip:1:-1}
echo "Private IP: ${private_ip}"
echo "Public IP: ${public_ip}"

