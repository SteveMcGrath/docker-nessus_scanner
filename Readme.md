# Nessus Scanner

Tenable's Nessus Scanner is a vulnerability scanner that looks for known vulnerabilities, malware, configuration issues, etc. both through network inspection of hosts and through authenticated analysis of the host itself.  For more information about Nessus, please consult the following links:

* [Nessus Scanner product page](http://www.tenable.com/products/nessus-vulnerability-scanner)
* [Nessus Scanner latest docs](https://docs.tenable.com/nessus/Content/GettingStarted.htm)

# Build files

The github repository for the build files is located [here](https://github.com/stevemcgrath/docker-nessus_scanner).

# Supported tags

Each image is tagged with the major, minor, and patch releases.  The most current image is always tagged as "latest".  For the current listing of tags, please refer to the [tags tab](https://hub.docker.com/r/stevemcgrath/nessus_scanner/tags/) for a current listing.

# Usage

```
docker volume create nessus_scanner_var
docker run -dt \
    -v nessus_scanner_var:/opt/nessus/var/nessus\
    -e LINKING_KEY={LINKING_KEY}\
    -e SCANNER_NAME={SCANNER_NAME}\
    --name nessus_scanner
    stevemcgrath/nessus_scanner:latest
```

# Environmental Variables

**NOTE**: You must specify either a linking key or a license code.

* **LINKING_KEY** _**(required)**_ - Linking key to use for linking the scanner to Tenable.io
* **LICENSE** _**(required)**_ - Activation code (if not a Tenable.io linked scanner)
* **SECURITYCENTER** _**(required)**_ - If the scanner is to be SecurityCenter linked, then simply set this variable to "Yes" instead of setting a _LICENSE_ or _LINKING_KEY_ variable.
* **SCANNER_NAME** _(optional)_ - Override the default behavior of registering with the hostname
* **MANAGER_HOST** _(optional)_ - Nessus Manager address
* **MANAGER_PORT** _(optional)_ - Nessus Manager service port
* **PROXY_HOST** _(optional)_ - Proxy address
* **PROXY_PORT** _(optional)_ - Proxy service port 
* **PROXY_USER** _(optional)_ - Proxy account username
* **PROXY_PASS** _(optional)_ - Proxy account password
* **PROXY_AGENT** _(optional)_ - Proxy agent string
* **ADMIN_USER** _(optional)_ - Username for admin user creation
* **ADMIN_PASS** _(optional)_ - Password for admin user creation