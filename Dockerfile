FROM centos:centos6

MAINTAINER coleman <coleman_dlut@hotmail.com>

ENV MAILDOMAIN localhost
ENV SMTPD_TLS_CERT_FILE "/etc/pki/tls/certs/server.crt"
ENV SMTPD_TLS_KEY_FILE "/etc/pki/tls/certs/server.key"
ENV TLS_CERT_FILE "/etc/pki/tls/certs/server.pem"
ENV TLS_KEY_FILE "/etc/pki/tls/certs/server.pem"


#************************************************************
#*  Updateし、postfix、cyrus-imapd、cyrus-sasl-md5、cyrus-saslをインストールする                       *
#************************************************************
RUN yum -y update && yum -y install postfix cyrus-imapd cyrus-sasl-md5 cyrus-sasl && yum clean all


#/etc/imapd.confの変更
RUN sed -i -e 's/admins: cyrus/admins: admin/' /etc/imapd.conf && \
sed -i -e 's/sasl_pwcheck_method: saslauthd/sasl_pwcheck_method: auxprop \
sasl_auxprop_plugin: sasldb/' /etc/imapd.conf && \
sed -i -e 's/tls_cert_file: \/etc\/pki\/cyrus-imapd\/cyrus-imapd.pem/tls_cert_file: \/etc\/pki\/tls\/certs\/server.pem/' /etc/imapd.conf && \
sed -i -e 's/tls_key_file: \/etc\/pki\/cyrus-imapd\/cyrus-imapd.pem/tls_key_file: \/etc\/pki\/tls\/certs\/server.pem/' /etc/imapd.conf && \
sed -i -e '$ a allowanonymouslogin: no' /etc/imapd.conf && \
sed -i -e '$ a allowplaintext: yes' /etc/imapd.conf && \
sed -i -e '$ a autocreateinboxfolders: Sent|Draft|Trash' /etc/imapd.conf && \
sed -i -e '$ a autosubscribeinboxfolders: Sent|Draft|Trash' /etc/imapd.conf && \
sed -i -e '$ a virtdomains: on' /etc/imapd.conf

#/etc/cyrus.confの変更
RUN sed -i -e 's/  pop3\t\tcmd="pop3d" listen="pop3" prefork=3/# pop3\t\tcmd="pop3d" listen="pop3" prefork=3/' /etc/cyrus.conf && \
sed -i -e 's/  pop3s\t\tcmd="pop3d -s" listen="pop3s" prefork=1/# pop3s\t\tcmd="pop3d -s" listen="pop3s" prefork=1/' /etc/cyrus.conf && \
sed -i -e 's/  sieve\t\tcmd="timsieved" listen="sieve" prefork=0/# sieve\t\tcmd="timsieved" listen="sieve" prefork=0/' /etc/cyrus.conf && \
sed -i -e '$ i \ ' /etc/cyrus.conf && \
sed -i -e '$ i \  # create SQUAT indexes for mailboxes' /etc/cyrus.conf && \
sed -i -e '$ i \  squatter      cmd="squatter -r -s user" period=1440' /etc/cyrus.conf

#/etc/postfix/main.cfの変更
RUN sed -i -e 's/#myhostname = virtual.domain.tld/myhostname = freemail.server-on.net/' /etc/postfix/main.cf && \
sed -i -e 's/#mydomain = domain.tld/mydomain = freemail.server-on.net/' /etc/postfix/main.cf && \
sed -i -e 's/inet_interfaces = localhost/inet_interfaces = all/' /etc/postfix/main.cf && \
sed -i -e 's/inet_protocols = all/inet_protocols = ipv4/' /etc/postfix/main.cf && \
sed -i -e 's/^mydestination = $myhostname, localhost.$mydomain, localhost/mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain/' /etc/postfix/main.cf && \
sed -i -e "s/#local_recipient_maps =\$/local_recipient_maps =/" /etc/postfix/main.cf && \
sed -i -e "s/#mailbox_transport = cyrus\$/mailbox_transport = cyrus/" /etc/postfix/main.cf && \
sed -i -e "s/#fallback_transport =\$/fallback_transport = cyrus/" /etc/postfix/main.cf && \
sed -i -e "s/#smtpd_banner = \$myhostname ESMTP \$mail_name\$/smtpd_banner = \$myhostname ESMTP unknown/" /etc/postfix/main.cf && \
sed -i -e '$ a \ ' /etc/postfix/main.cf && \
sed -i -e '$ a smtpd_sasl_auth_enable = yes' /etc/postfix/main.cf && \
sed -i -e '$ a smtpd_sasl_security_options = noanonymous' /etc/postfix/main.cf && \
sed -i -e '$ a smtpd_sasl_local_domain = $myhostname' /etc/postfix/main.cf && \
sed -i -e '$ a broken_sasl_auth_clients=yes' /etc/postfix/main.cf && \
sed -i -e '$ a smtpd_use_tls = yes' /etc/postfix/main.cf && \
sed -i -e '$ a smtpd_tls_cert_file = /etc/pki/tls/certs/server.crt' /etc/postfix/main.cf && \
sed -i -e '$ a smtpd_tls_key_file = /etc/pki/tls/certs/server.key' /etc/postfix/main.cf && \
sed -i -e '$ a smtpd_tls_session_cache_database = btree:/var/lib/postfix/smtpd_scache' /etc/postfix/main.cf && \
sed -i -e '$ a smtpd_recipient_restrictions = permit_mynetworks,permit_sasl_authenticated,reject_unauth_destination' /etc/postfix/main.cf

#/etc/sysconfig/saslauthdの変更
RUN sed -i -e 's/MECH=pam/MECH=rimap/' /etc/sysconfig/saslauthd && \
sed -i -e "s/FLAGS=/FLAGS='-r -O 127.0.0.1'/" /etc/sysconfig/saslauthd


VOLUME  ["/Maildir"]

EXPOSE 25

CMD ["/bin/bash"]

