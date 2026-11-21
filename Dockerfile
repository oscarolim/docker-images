# PHP-FPM image for Piwigo, rebuilt weekly by .github/workflows/build-php-image.yml
ARG PHP_VERSION=8.3
FROM php:${PHP_VERSION}-fpm-bookworm

# Apply Debian security fixes even when the upstream tag is no longer rebuilt
# (PHP 8.1 is end-of-life, so php:8.1-* images are frozen upstream)
RUN apt-get update \
 && apt-get upgrade -y --no-install-recommends \
 && rm -rf /var/lib/apt/lists/*

# Helper that compiles PHP extensions and pulls in their system libraries
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN install-php-extensions mysqli pdo_mysql gd imagick exif intl zip opcache

# Photo uploads need larger limits than PHP's defaults
RUN { \
      echo 'upload_max_filesize = 100M'; \
      echo 'post_max_size = 100M'; \
      echo 'memory_limit = 512M'; \
      echo 'max_execution_time = 300'; \
    } > /usr/local/etc/php/conf.d/piwigo.ini

# Fail the build (so nothing is pushed) if any required extension is missing
RUN php -r 'foreach (["mysqli","pdo_mysql","gd","imagick","exif","intl","zip","Zend OPcache"] as $e) { if (!extension_loaded($e)) { fwrite(STDERR, "missing extension: $e\n"); exit(1); } } echo "all extensions loaded\n";'
