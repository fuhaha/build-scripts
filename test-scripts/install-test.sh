#!/bin/bash

# $1 - image 
# $2 - (optional) URL to repo configuration package (without .deb or .rpm)

set -x

image=$1
url_repo=$2

if [ "$url_repo" == "" ] ; then
	url_repo="http://downloads.mariadb.com/software/mariadb-maxscale/configure-maxscale-repo-0.1.2"
fi

orig_image=$image
echo "image: $image"
image_type=`cat /home/ec2-user/kvm/images/image_type | grep "$orig_image".img | sed "s/$orig_image.img//" | sed "s/ //g"`
echo "image type is $image_type"

if [ "$do_not_reset_vm2" != "yes" ] ; then
        /home/ec2-user/kvm/start_build_VM.sh $image
fi


if [ "$image_type" != "RPM" ] && [ "$image_type" != "DEB" ] ; then
        echo "unknown image type: should be RPM or DEB"
        exit 1
else
        if [ "$image_type" == "RPM" ] ; then
		ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$IP "rpm -U $url_repo.rpm"
#                ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$IP "echo -e \"portaluser\ntesting\" | /usr/local/mariadb-maxscale-setup/configure-maxscale-repo"

		ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$IP "zypper --version"
		if [ $? != 0 ] ; then
			ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$IP "yum install -y maxscale"
		else
			ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$IP "zypper -n install maxscale"
		fi
	else
#         	ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$IP "apt-get update; apt-get -y --force-yes install apt-transport-https"
		ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$IP "wget $url_repo.deb ; dpkg -i configure-maxscale-repo-0.1.*.deb"
#                ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$IP "echo -e \"portaluser\ntesting\" | /usr/local/mariadb-maxscale-setup/configure-maxscale-repo"
                ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$IP "apt-get update; apt-get -y --force-yes install maxscale"
	fi
fi
