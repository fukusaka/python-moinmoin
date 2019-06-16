#!/bin/sh
set -e

SETUP_LOCK=/etc/created_moin_wiki

if [ ! -f $SETUP_LOCK -a x"$SETUP_WIKI" = xyes ]; then

  su moin -s /usr/bin/moin -- \
    --config-dir=/etc/moin/ \
    --wiki-url=http://localhost/ \
    account create \
    --name $WIKI_ADMIN \
    --password=$WIKI_ADMIN_PASS \
    --email=$WIKI_ADMIN_EMAIL

  sed -i \
    -e 's/# superuser.*$/superuser = [u"'$WIKI_ADMIN'"]/g' \
    -e 's/# acl_rights_before.*$/acl_rights_before = u"'"$WIKI_ACL_RIGHTS_BEFORE"'"/g' \
    -e 's/# acl_rights_default.*$/acl_rights_default = u"'"$WIKI_ACL_RIGHTS_DEFAULT"'"/g' \
    /etc/moin/mywiki.py

  touch $SETUP_LOCK
fi

if [ $(id -u moin) != $MOIN_UID ]; then
    usermod -u $MOIN_UID moin
fi

if [ $(id -g moin) != $VMAIL_GID ]; then
    groupmod -g $MOIN_GID moin
fi

unset WIKI_ADMIN WIKI_ADMIN_PASS WIKI_ADMIN_EMAIL WIKI_ACL_RIGHTS_BEFORE WIKI_ACL_RIGHTS_DEFAULT

if [ x"$USE_NGINX" = xyes ]; then
  if [ x"$(rc-update show default | grep nginx)" = x ]; then
    rc-update -q add nginx default
  fi
else
  if [ x"$(rc-update show default | grep nginx)" != x ]; then
    rc-update -q del nginx default
  fi
fi

exec /sbin/init
