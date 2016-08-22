#!/bin/sh
# v1.0.1
# git脚本：push/pull代码，创建定时任务脚本

gituser=$2-dev
gitemail=$2@shopex.cn
gitpass=shopex.cn
giturl=https://$gituser:$gitpass@git.shopex.cn/shopex01/$2-$3.git
[ -f /usr/bin/git ] && yum remove git -y
[ -d /usr/local/git ] || rpm -ivh http://ftp.wyaopeng.com/package/git-2.7.0-1.el6.x86_64.rpm && . /etc/profile

if [ $1 = 'push' ]; then
	[ -d /data/www/$3 ] && cd /data/www/$3 || exit 1
	git init
	touch README.md
	git config --local user.name "$gituser"
	git config --local user.email "$gitemail"
	chown www.www -R .
	git add .
	git commit -m 'first commit'
	git remote add origin $giturl
	git push -u origin master
	git branch dev
	git checkout dev
	git push origin dev
	[ -d /data/sh ] || mkdir /data/sh && touch /data/sh/update.log
	[ -f /data/sh/update.sh ] || echo -e "#!/bin/bash\nDATE=\$(date +%F-%T)\necho \$DATE" > /data/sh/update.sh && chown www.www -R /data/sh
	echo -e "cd /data/www/$3\n/usr/local/git/bin/git pull origin dev\n/usr/local/php$4/bin/php /data/www/$3/app/base/cmd update" >> /data/sh/update.sh
	[[ $(crontab -uwww -l) =~ 'update.sh' ]] || echo '*/2 * * * * sh /data/sh/update.sh >> /data/sh/update.log  2>&1' >> /var/spool/cron/www
elif [ $1 = 'pull' ]; then
	[ -d /data/www/$3 ] || mkdir /data/www/$3
	cd /data/www/$3
	git init
	git config --local user.name "$gituser"
	git config --local user.email "$gitemail"
	git remote add origin $giturl
	git pull origin dev
	chown www.www -R .
fi	