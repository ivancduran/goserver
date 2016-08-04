# Golang and nginx in production (CentOs 7+)

Execute generator with project PATH, This command will generate configuration files
```bash

./create.sh "/Users/name/golang/src/github.com/ivancduran/newserv"

```

Install lsof (check ports for golang app)
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

Note: this project was create thinking and tested on the iris framework, but if you have your own application you can configure the output files "goserver" and "nginx.conf" as you want
