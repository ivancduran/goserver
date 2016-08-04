# Golang and nginx in production (CentOs 7+) 

----------

*This project is thinking of golang put on production servers*


 - Golang on 8080 port as a service
 - Nginx as reverse proxy in 80 and 443 ports and cache

Steps
-----
----------

Put this folder on your project with the directory name "service" and then:

Execute generator with project PATH, this command will generate configuration files
```bash

./create.sh "/Users/name/golang/src/github.com/ivancduran/newserv"

```

Install lsof (check ports for golang app default:8080)
```bash

yum install lsof

```

Move "goserver" to /etc/init.d/
and make exec

```bash

mv ./output/goserver /etc/init.d/goserver
chmod +x /etc/init.d/goserver

```

Move "goserver.service" to /etc/systemd/system/
And activate: systemctl enable goserver.service

```bash

mv ./output/goserver.service /etc/systemd/system/goserver.service
systemctl enable goserver.service

```

Make cache directory on your project

```bash

mkdir cache

```

Start server

```bash

service goserver start

```

**Note**: this project was create thinking and tested on the iris framework and centos 7, but if you have your own application you can configure the output files "goserver" and "nginx.conf" as you want.
