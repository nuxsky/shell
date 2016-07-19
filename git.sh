#!/bin/sh
# v1.0.0

if [ ! $1 ]; then exit; fi
if [ ! $2 ]; then gitname=ecstore; else gitname=$2; fi
gituser=$1-dev
gitemail=$1@shopex.cn
gitpass=shopex.cn
giturl=https://$gituser:$gitpass@git.shopex.cn/shopex01/$1-$gitname.git

git config --global user.name "$gituser"
git config --global user.email "$gitemail"
cd /data/www/$gitname
git init
touch README.md
chown www.www -R ./
git add .
git commit -m 'first commit'
git remote add origin $giturl
git push -u origin master
git branch dev
git checkout dev
git push origin dev

if [ -f /data/sh/update.sh ]; then
  mkdir -p /data/sh
  touch /data/sh/update.log
  echo -e "#!/bin/bash\nDATE=\$(date +%F-%T)\necho \$DATE" > /data/sh/update.sh
  chown www.www -R /data/sh
fi
if [ gitname = 'bbc' ]; then $pvs='54'; fi
echo -e "cd /data/www/$gitname\n/usr/bin/git pull origin dev\n/usr/local/php$pvs/bin/php /data/www/$gitname/app/base/cmd update" >> /data/sh/update.sh

crontab -uwww -l | grep update.sh
if [ $? -eq 1 ]; then
  crontab -uwww -l > /tmp/cronfile
  echo '*/2 * * * * sh /data/sh/update.sh >> /data/sh/update.log  2>&1' >> /tmp/cronfile
  crontab -uwww /tmp/cronfile
  rm -f /tmp/cronfile
fi