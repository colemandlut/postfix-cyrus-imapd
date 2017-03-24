FROM centos:centos6

MAINTAINER coleman <coleman_dlut@hotmail.com>

#************************************************************
#*  Updateし、postfix、cyrus-imapd、cyrus-sasl-md5、cyrus-saslをインストールする                       *
#************************************************************
RUN yum -y update && yum -y install postfix cyrus-imapd cyrus-sasl-md5 cyrus-sasl && yum clean all

VOLUME  ["/Maildir"]

EXPOSE 25

CMD ["/bin/bash"]

