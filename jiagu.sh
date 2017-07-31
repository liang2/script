#此脚本会重置iptables,/etc/hosts.allow,/etc/hosts.deny


#安装必要软件
yum -y install *epel* *gcc* vim lrzsz htop bash-completion rsync showmount cronolog logrotate rng-tools telnet psmisc lsof ntpdate net-tools wget htop *epel*
#修改SSH默认端口
sed -i '/Port/d' /etc/ssh/sshd_config
sed -i "17a Port 10022" /etc/ssh/sshd_config




myPath="/backup/"

if [ ! -d "$myPath" ]; then

mkdir "$myPath" 

fi 
#修改登录密码策略
cp /etc/login.defs /backup/login.defs
sed -i '/PASS_MAX_DAYS/c PASS_MAX_DAYS 99999' /etc/login.defs
sed -i '/PASS_MIN_DAYS/c PASS_MIN_DAYS	1' /etc/login.defs
sed -i '/PASS_MIN_LEN/c PASS_MIN_LEN	0' /etc/login.defs
sed -i '/PASS_WARN_AGE/c PASS_WARN_AGE	7' /etc/login.defs
#禁用系统默认账户
usermod -L adm
usermod -L lp
usermod -L sync
usermod -L shutdown
usermod -L halt
#usermod -L news
usermod -L uucp
usermod -L operator
usermod -L games
usermod -L gopher
#设置密码复杂度
cp /etc/pam.d/system-auth /backup/system-auth
sed -i '/password    requisite/c password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=' /etc/pam.d/system-auth
#设置账户锁定策略
sed -i '/auth        required      pam_deny.so/c auth        required      pam_deny.so onerr=fail no_magic_root deny=3 even_deny_root_account unlock_time=20 root_unlock_time=20' /etc/pam.d/system-auth
#设置客户端超时时间
cp /etc/profile /backup/profile
sed -i '/TMOUT=600/d' /etc/profile
sed -i '/HISTSIZE=1000/a TMOUT=600' /etc/profile
#检查重要文件的UMASK值
umask 077 /etc/profile /etc/csh.login /etc/csh.cshrc /etc/bashrc /etc/sysconfig/init
#删除banner信息
cp /etc/issue /backup/issue
sed -i 's/^/#/' /etc/issue
#禁用IPv6协议
sed -i "/NETWORKING_IPV6/d" /etc/sysconfig/network
sed -i '$a NETWORKING_IPV6="no"' /etc/sysconfig/network
#限制SSH远程管理IP
echo '' > /etc/hosts.deny
echo '' > /etc/hosts.allow
#sed -i '/sshd/d' /etc/hosts.deny
#sed -i '$a sshd:all' /etc/hosts.deny
sed -i '/sshd/d' /etc/hosts.allow
sed -i '$a sshd:211.103.153.200' /etc/hosts.allow
sed -i '$a sshd:123.125.139.66' /etc/hosts.allow
sed -i '$a sshd:106.39.200.40' /etc/hosts.allow
sed -i '$a sshd:106.39.200.41' /etc/hosts.allow
sed -i '$a sshd:106.39.200.42' /etc/hosts.allow
sed -i '$a sshd:106.39.200.43' /etc/hosts.allow
sed -i '$a sshd:106.39.200.44' /etc/hosts.allow
sed -i '$a sshd:106.39.200.45' /etc/hosts.allow
sed -i '$a sshd:106.39.200.46' /etc/hosts.allow
sed -i '$a sshd:106.39.200.47' /etc/hosts.allow
sed -i '$a sshd:192.168.49.0/255.255.255.0' /etc/hosts.allow
sed -i '$a sshd:10.105.0.0/255.255.255.0' /etc/hosts.allow
sed -i '$a sshd:10.0.0.0/255.0.0.0' /etc/hosts.allow
#禁止root用户直接通过SSH登录
sed -i '/PermitRootLogin/c PermitRootLogin no' /etc/ssh/sshd_config
#禁用nfs服务
chkconfig --level 345 nfs off
chkconfig --level 345 nfslock off
chkconfig --level 345 autofs off

#添加普通账户
useradd jerry
#添加跳板机公钥
mkdir /home/jerry/.ssh
touch /home/jerry/.ssh/authorized_keys
chmod 700 /home/jerry/.ssh
chmod 600 /home/jerry/.ssh/authorized_keys
echo "" >> /home/jerry/.ssh/authorized_keys
sed -i '$a ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCuW7G4jvKKQjedu5i9sokuGevlC4j3FOwcmhhy6r1MNct4aSkvcSBW9bF5U7cppzmjzcIRS9p2PHZCi2Ge6QWYo5xRF4gl3gYt8LtlEZ+QKkFWmC1M+Omqw+riZjY1YXoxlTpBChWxBIUiEL/gROaBAVaRP983j6fnfU9qHULYrsTZ1/Lz/hlwyFD2SmcZTrM+oj9wq2EMFXMG6+o87ghE6leP7/fL4tHkKuL6MvhWAbtECN8tt2A4cUMfDKWNjx8hsS7fN0No7ILh1ECkybAdEzC3vUOXgVtQHc1/yEZQMzbBFW1ncZZ9Xg5qLO55AXN0eM4vQvevHGFEPq9ScMdF tom@zookeeper2' /home/jerry/.ssh/authorized_keys
chown -R jerry:jerry /home/jerry/


#添加ntp自动时间同步定时任务
sed -i '$a 0  3  *  *  *       ntpdate 0.asia.pool.ntp.org  >> /var/log/upClock.log 2>&1' /etc/crontab
ntpdate 0.asia.pool.ntp.org
date
#iptables 初始化
systemctl stop firewalld 
systemctl mask firewalld
yum -y install iptables-services
systemctl enable iptables



systemctl restart iptables 
service iptables save

service sshd restart
service ntpd stop
service rngd restart
service rngd status
