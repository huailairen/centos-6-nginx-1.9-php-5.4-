FROM index.alauda.cn/library/centos:6.6
RUN  mkdir /chaofansrc
WORKDIR /chaofansrc
RUN  groupadd -r nginx
RUN  useradd -s /sbin/nologin -g nginx -r nginx
RUN  yum install -y tar vi  wget  gcc gcc-c++ autoconf automake zlib zlib-devel openssl openssl-devel pcre-devel

RUN  wget http://nginx.org/download/nginx-1.10.1.tar.gz
RUN  tar zxf nginx-1.10.1.tar.gz  && cd nginx-1.10.1 && \
./configure \
--prefix=/usr \
--sbin-path=/usr/sbin/nginx \
 --conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--pid-path=/var/run/nginx/nginx.pid \
--user=nginx \
--group=nginx \
--with-http_ssl_module \
--with-http_flv_module \
--with-http_gzip_static_module \
--http-log-path=/var/log/nginx/access.log \
--http-client-body-temp-path=/var/tmp/nginx/client \
--http-proxy-temp-path=/var/tmp/nginx/proxy \
--http-fastcgi-temp-path=/var/tmp/nginx/fcgi \
--with-http_stub_status_module && make && make install 
RUN mkdir -p  /var/tmp/nginx/client

WORKDIR /chaofansrc
RUN  wget http://cn2.php.net/distributions/php-5.4.44.tar.bz2
RUN yum install -y  bzip2
RUN  tar -xjf php-5.4.44.tar.bz2  
WORKDIR /chaofansrc/php-5.4.44 
RUN yum install -y libxml2-devel.x86_64 bzip2-devel.x86_64  bzip2-devel.x86_64 libcurl-devel.x86_64 gd-devel.x86_64
RUN yum install -y  epel-release
RUN yum install -y libmcrypt-devel.x86_64
RUN ./configure --prefix=/usr/local/php --enable-fpm  \
--enable-bcmath  \
--with-bz2  \
--with-curl  \
--with-pcre-dir  \
--enable-exif  \
--enable-ftp  \
--with-gd  \
--enable-gd-native-ttf  \
--enable-gd-jis-conv  \
--with-gettext  \
--enable-mbstring  \
--with-mcrypt  \
--with-mysql  \
--enable-mysqlnd  \
--with-openssl  \
--enable-pcntl  \
--with-pcre-dir=/usr/local/bin/pcre-config  \
--with-pdo-mysql  \
--enable-shmop  \
--enable-soap \
--enable-sockets  \
--enable-sysvsem  \
--enable-wddx \
--with-xmlrpc  \
--enable-zip  \
--with-zlib  

RUN make && make install

RUN cp  /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
RUN cp php.ini-production  /usr/local/php/lib/php.ini

WORKDIR /chaofansrc
RUN wget http://pecl.php.net/get/yar-1.1.1.tgz
RUN tar xvzf yar-1.1.1.tgz

WORKDIR /chaofansrc/yar-1.1.1 

RUN /usr/local/php/bin/phpize  && ./configure  --with-php-config=/usr/local/php//bin/php-config && make && make install

RUN echo -e "\n" >> /usr/local/php/lib/php.ini
RUN echo  extension=yar.so >> /usr/local/php/lib/php.ini
RUN mkdir -p /usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/
RUN cp /chaofansrc/yar-1.1.1/modules/yar.so  /usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/


WORKDIR /chaofansrc
RUN yum install  -y python-setuptools.noarch
RUN wget --no-check-certificate https://github.com/pypa/pip/archive/1.5.5.tar.gz
RUN tar zvxf 1.5.5.tar.gz && cd pip-1.5.5/ && python setup.py install
RUN pip install supervisor supervisor-stdout
RUN pip install --upgrade setuptools
RUN easy_install supervisor

RUN mkdir /var/www
COPY phpinfo.php  /var/www

COPY nginx.conf  /etc/nginx/
COPY supervisord.conf  /etc
#CMD ["supervisord", "-n","-c", "/etc/supervisord.conf"]
