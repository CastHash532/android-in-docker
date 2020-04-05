FROM mingc/android-build-box

# install and configure SSH server
EXPOSE 22
ADD sshd-banner /etc/ssh/
ADD authorized_keys /tmp/
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends openssh-server supervisor locales && \
    mkdir -p /var/run/sshd /var/log/supervisord && \
    locale-gen en en_US en_US.UTF-8 && \
    apt-get remove -y locales && apt-get autoremove -y && \
    FILE_SSHD_CONFIG="/etc/ssh/sshd_config" && \
    echo "\nBanner /etc/ssh/sshd-banner" >> $FILE_SSHD_CONFIG && \
    echo "\nPermitUserEnvironment=yes" >> $FILE_SSHD_CONFIG && \
    ssh-keygen -q -N "" -f /root/.ssh/id_rsa && \
    FILE_SSH_ENV="/root/.ssh/environment" && \
    touch $FILE_SSH_ENV && chmod 600 $FILE_SSH_ENV && \
    printenv | grep "JAVA_HOME\|GRADLE_HOME\|KOTLIN_HOME\|ANDROID_HOME\|LD_LIBRARY_PATH\|PATH" >> $FILE_SSH_ENV && \
    FILE_AUTH_KEYS="/root/.ssh/authorized_keys" && \
    touch $FILE_AUTH_KEYS && chmod 600 $FILE_AUTH_KEYS && \
    for file in /tmp/*.pub; \
    do if [ -f "$file" ]; then echo "\n" >> $FILE_AUTH_KEYS && cat $file >> $FILE_AUTH_KEYS && echo "\n" >> $FILE_AUTH_KEYS; fi; \
    done && \
    (rm /tmp/*.pub 2> /dev/null || true)

ADD supervisord.conf /etc/supervisor/conf.d/
CMD ["/usr/bin/supervisord"]

# install and configure VNC server
ENV USER root
ENV DISPLAY :1
EXPOSE 5901
ADD vncpass.sh /tmp/
ADD watchdog.sh /usr/local/bin/
ADD supervisord_vncserver.conf /etc/supervisor/conf.d/
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends xfce4 xfce4-goodies xfonts-base dbus-x11 tightvncserver expect && \
    chmod +x /tmp/vncpass.sh; sync && \
    /tmp/vncpass.sh && \
    rm /tmp/vncpass.sh && \
    apt-get remove -y expect && apt-get autoremove -y && \
    FILE_SSH_ENV="/root/.ssh/environment" && \
    echo "DISPLAY=:1" >> $FILE_SSH_ENV

