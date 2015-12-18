#!/usr/bin/env bash
#
# Shell based Vagrant provisioner
#

#PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Base path for files
declare VAGRANT=/vagrant
declare BASEPATH=${VAGRANT}/shell

# Tool to download via http/https
declare HTTPGET="curl"
declare HTTPGET_OPTS="-O -s"

declare FOUND_LSB_RELEASE

declare DISTRO
declare RELEASE

declare PKG_MGR
declare PKG_MGR_OPTS
declare PKG_INSTALL_CMD

declare PUPPETLABS_PKG_URL
declare PUPPETLABS_PKG

function cleanup() {
	[ -f ${PUPPETLABS_PKG} ] && rm -f ${PUPPETLABS_PKG}
}
trap cleanup EXIT

# Does lsb_release exist?
$(which lsb_release > /dev/null 2>&1)
FOUND_LSB_RELEASE=$?

if [ "${FOUND_LSB_RELEASE}" -ne '0' ]; then
	[ -f /etc/redhat-release ] && yum -q -y install redhat-lsb-core
	$(which lsb_release > /dev/null 2>&1)
	FOUND_LSB_RELEASE=$?
fi

if [ "${FOUND_LSB_RELEASE}" -eq '0' ]
then
	DISTRO=$(lsb_release -s -i)
else
	DISTRO="ERROR"
fi

case "${DISTRO}" in
	"Debian")
		RELEASE=$(lsb_release -s -c)
		PKG_MGR="apt-get"
		PKG_MGR_OPTS="-qq -y -o=Dpkg::Use-Pty=0"
		PUPPETLABS_PKG_URL="https://apt.puppetlabs.com"
		PUPPETLABS_PKG="puppetlabs-release-pc1-${RELEASE}.deb"
		PKG_INSTALL_CMD="dpkg -i ${PUPPETLABS_PKG} && ${PKG_MGR} ${PKG_MGR_OPTS} update"
	;;
	"CentOS")
		RELEASE=$(lsb_release -s -r | cut -d. -f1)
		PKG_MGR="yum"
		PKG_MGR_OPTS="-q -y"
		PUPPETLABS_PKG_URL="https://yum.puppetlabs.com"
		PUPPETLABS_PKG="puppetlabs-release-pc1-el-${RELEASE}.noarch.rpm"
		PKG_INSTALL_CMD="rpm -U --quiet ${PUPPETLABS_PKG}"
	;;
	*)
		echo "Unknown distribution: ${DISTRO}"
		exit 1
	;;
esac

# Install Puppet Labs repo
echo "Downloading ${PUPPETLABS_PKG}..."
${HTTPGET} ${HTTPGET_OPTS} ${PUPPETLABS_PKG_URL}/${PUPPETLABS_PKG}
RESULT=$?
if [ $RESULT -eq 0 ]
then
	echo "Installing ${PUPPETLABS_PKG}..."
	eval "${PKG_INSTALL_CMD}"
fi

# Install basic packages
# Limit to stuff required to bootstrap puppet-agent, everything else can be installed via Puppet
PKG_LISTS="common ${DISTRO}"
for LIST in ${PKG_LISTS}
do
	echo "Processing packages from ${LIST}..."
	if [ -f "${BASEPATH}/packages.${LIST}" ]
	then
		for PKG in $(cat ${BASEPATH}/packages.${LIST})
		do
			echo "Installing ${PKG}..."
			${PKG_MGR} ${PKG_MGR_OPTS} install ${PKG}
		done
	fi
done

exit 0