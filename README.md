# k3s setup

Makefile and YAMLs from [the blog post about k3s at home].


NOTE - these YAML files issue Let's Encrypt `staging` certificates that are not valid. When you're sure it all works, change:

```
cert-manager.io/cluster-issuer: letsencrypt-staging
```

to

```
cert-manager.io/cluster-issuer: letsencrypt-prod
```

on all ingress definitions.

To use this Makefile, first make sure you have a VM with a hostname of `k3s-vm` installed, and you can SSH into it as root with no password (put your SSH key on it). This on your `~/.ssh/config` will help:

```
Host k3s
    User root
    Hostname 192.168.1.60
```

If you use a different name for your server, edit `HOST` on the Makefile and the hostname condition in the `nodeAffinity` statements for Bookstack and Portainer.

## Steps

1. Forward the following TCP ports to your server's IP:

- 22/ssh
- 80/http
- 443/https
- 6443/k8s
- 10250/kubelet

2. Point your domain name to your _external_ IP with both `domain` and `*.domain` A records (or AAAA for IPv6)

3. change `user@domain.tld` and `domain.tld` for the proper values for your setup in the YAML files for ingresses and configmaps - CERTIFICATES AND INGRESSES WILL NOT WORK WITH THE VALUES PRESENT NOW

4. test `ssh k3s` and confirm you get a root shell with no password prompt

5. double-check the top of the Makefile for the `HOST_IP` and `HOST` variable values

6. `make k3s_install base bookstack portainer samba` (you might need to run it a few times if you get an error like `error: no matching resources found` - it's fine to repeat this command multiple times)

The default user for Bookstack is `admin@admin.com` and the password is `password`.

Feedback and pull requests welcome!

To-do list:

- unite `bookstack` and `bookstack-mysql` into single service
- find a better way than using `nodeAffinity` for the PV provisioning
- find a better way to specify the mysql port in the configmap for Bookstack other than literally using `10001`


[the blog post about k3s at home]: https://blog.nootch.net/post/kubernetes-at-home-with-k3s/
