local-ip.co HTTPS reverse-proxy
===============================

> 🚀 Public URLs for exposing your local webapp without
>    external proxies in your LAN

Set of Nginx and Docker configurations to launch a Nginx reverse proxy
running in the HTTPS ports (443), using the public SSL certificate for
domains `*.my.local-ip.co`. The SSL certificate is signed by a CA authority
and provided for free by [local-ip.co](http://local-ip.co/), moreover,
they have a free DNS service that provide wildcard DNS for any IP
address, including private IPs:

    $ dig 10-0-0-1.my.local-ip.co +short

    10.0.0.1

So having a public certificate and a public DNS that resolves to your
local IP address, you can launch the HTTPS server to proxy
your local app built with whatever stack, and connect any browser,
app or device that requires to access it with HTTPS like Android
apps, that some times require secure connections.

Eg. if your webapp runs locally in the port 5988, and your
local IP is 192.168.0.3, you normally access to your app
with `http://192.168.0.3:5988` in the same device or any other
device within the same network, but you can access your app with
the URL https://192-168-0-3.my.local-ip.co launching the Docker
configuration in the same machine as follow:

Only the first time:

    $ git clone https://github.com/medic/nginx-local-ip.git

Then:

    $ cd nginx-local-ip/
    $ APP_URL=http://192.168.0.3:5988 docker-compose up

Note that the IP set in the `APP_URL` environment variable is passed
as it is in your computer, but the URL to access the app in the devices
separates each number from the IP address by `-`,
not `.`: https://192-168-0-3.my.local-ip.co .

Also note you cannot use the localhost IP 127.0.0.1, it needs to
be the IP of your wifi connection, ethernet connection, or whatever
connection your computer has with the network is connected. You
can get your IP address in a Unix system with `ifconfig` or `ip addr`.
Your computer may also have other virtual interfaces with IP addresses
assigned, omit them, like the IP of the _docker0_ interface.

The server also opens the port 80 so if you forget to write the URL
with https:// , Nginx redirects the request to the HTTPS version
for you 😉.

**Docker note**: A local image is created the first time executed, and
there is no need to rebuild it if you change the Nginx configuration or the `entrypoint.sh` file. Only changes to the Dockerfile script require a rebuild. If you just edit the Nginx configuration, or want to change the ports mapped, only restart the container is needed. 

If you do need to rebuild the container, append `--build` on to your compose call: ` docker-compose up --build`.

### Public SSL certificate

The certs are downloaded and cached from [local-ip.co](http://local-ip.co/) on first run. On subsequent runs, the `entrypoint.sh` script checks locally whether they are expired and downloads renewed certs from  [local-ip.co](http://local-ip.co/) if needed.

### Running with Medic-OS 

#### Change Ports

The default ports used in `nginx-local-ip` might conflict with the standard web server ports of 
that the `medic-os` docker image uses to run, `80` and `443`. To fix this, specify `nginx-local-ip` 
to use the `medic-os.env` file. Using the included `env-file` the container will avoid `80` and `443` 
and use `8080` and `444` for http and https respectively. Your instance will be available 
at `https://192-168-0-3.my.local-ip.co:444/`

Command to run:

    APP_URL=https://192.168.0.3 docker-compose --env-file=medic-os.env up
    
#### Install Certs
    
To avoid running the `nginx-local-ip` container all together, consider adding the `local-ip` certs directly to your `medic-os` container.  This simplifies your development environemnt by having one less docker image.  First [download the certs](http://local-ip.co#ssl-certificate-for-.my.local-ip.co) then follow [the steps already published in self hosting](https://github.com/medic/cht-infrastructure/tree/master/self-hosting#ssl-certificate-installation) on how to install the certs.

If the IP of your local machin is `192.168.0.3`, you could then access your instance directly at `https://192-168-0-3.my.local-ip.co/` after adding the certs. This way there is no `nginx-local-ip` container as a reverse proxy because `medic-os` hosts the certs internally.

**NOTE** - You will have to manually refresh the `local-ip`  certificates if you use this approach.


Requirements
------------

Only **Docker** and **Docker compose** installed are needed, and despite
this setup helps you to connect your devices with your webapp using
a local connection, without complex reverse proxy connections through
Internet like Ngrok.com, the devices that want to connect with the app
still need access to Internet just to resolve the `*.my.local-ip.co` domain
against the `local-ip.co` public DNS, unless you configure your own DNS server
within your network, which needs to be configured in all the devices your are
going to use the app, in that case, no Internet connection will required,
just a LAN connection.


Troubleshooting
---------

### Port Conflicts

If you run `docker-compose` and you get a `address already in use` error like this:

```
ERROR: for nginx-local-ip_app_1  Cannot start service app: driver failed programming external connectivity on endpoint nginx-local-ip_app_1 (5a31171148dcaa58b4053f793288aaa940f5678043d302c1c1ad87
5cdae3a684): Error starting userland proxy: listen tcp4 0.0.0.0:443: bind: address already in use
```                                                                                          

You may need to change one or both ports.  For example, you could shift them
up to 8xxx like so:

    $ HTTP=8080 HTTPS=8443 APP_URL=http://192.168.1.3:5988 docker-compose up

Also a convenient environment file can be used to store the new values as
suggested in the [Running with Medic-OS](#running-with-medic-os) section:

**my.env file:**

    HTTP=8080
    HTTPS=8443

Run with: `APP_URL=https://192.168.1.3:5988 docker-compose --env-file=my.env up`

You would then access your dev instance with the `8443` port.
Using the sample URL from above, it would go from `https://192-168-0-3.my.local-ip.co`
to this instead `https://192-168-0-3.my.local-ip.co:8443`.


Copyright
---------

Copyright 2021 Medic Mobile, Inc. <hello@medic.org>.

The SSL certificate files are downloaded from Internet at runtime,
and are property of **local-ip.co**.


License
-------

The software is provided under AGPL-3.0. Contributions to this project
are accepted under the same license.
