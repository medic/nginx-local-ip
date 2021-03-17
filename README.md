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
there is no need to rebuild it if you change the Nginx configurations,
unless you want to change the certificates or the Dockerfile script.

### Running with Medic-OS

The default ports used here will conflict with the ports that medic-os uses to run. To get around that you can specify the env-file for medic-os. This will start the container using 444 and 8080 for https and http, making your instance available at `https://192-168-0-3.my.local-ip.co:444/`

Command to run:

    APP_URL=https://192.168.0.3 docker-compose --env-file=medic-os.env up


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


Copyright
---------

Copyright 2021 Medic Mobile, Inc. <hello@medic.org>.

The certificates files under the `cert/` folder are property of
**local-ip.co**.


License
-------

The software is provided under AGPL-3.0. Contributions to this project
are accepted under the same license.
