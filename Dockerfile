FROM centos:7

ARG UID=1000
ARG USER=mnagata
ARG PASSWD=hoge

# system update
RUN yum -y update && yum clean all && \
  yum -y install sudo && \
  useradd -m  --uid ${UID} ${USER} && \
  echo ${USER}:${PASSWD} | chpasswd && \
  echo "$USER ALL=(ALL) ALL" >> /etc/sudoers

# set locale
RUN yum reinstall -y glibc-common && yum clean all && \
  localedef -f UTF-8 -i ja_JP ja_JP.UTF-8
ENV LANG="ja_JP.UTF-8" \
  LANGUAGE="ja_JP:ja" \
  LC_ALL="ja_JP.UTF-8"
RUN unlink /etc/localtime && \
  ln -s /usr/share/zoneinfo/Japan /etc/localtime

# editor install
RUN curl -sL https://rpm.nodesource.com/setup_11.x | bash - && \
  yum install -y vim git wget java-1.8.0-openjdk-devel python-devel nodejs rpm-build gcc-c++ && yum clean all

ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk/jre/ \
  _JAVA_OPTIONS="-Xmx2048m -XX:MaxMetaspaceSize=512m -DJava.awt.headless=true"

# maven install
WORKDIR /opt/maven
ADD https://archive.apache.org/dist/maven/maven-3/3.6.1/binaries/apache-maven-3.6.1-bin.tar.gz /opt/maven/
RUN cat /opt/maven/apache-maven-3.6.1-bin.tar.gz | tar zxv && ln -s /opt/maven/apache-maven-3.6.1 /opt/maven/default && rm apache-maven-3.6.1-bin.tar.gz

ENV PATH $PATH:/opt/maven/default/bin

USER ${USER}
WORKDIR /home/mnagata
RUN echo 'export PS1="[\u@\H:\w]\$ "' >> .bashrc

