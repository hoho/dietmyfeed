help:
	@echo "TODO: Write some help here."

clean:
	rm -rf .deps
	rm -rf .build
	rm -rf .www

apt-get-deps:
	apt-get install git subversion g++ make libxml2-dev libxslt-dev ruby cmake curl libpcre3 libpcre3-dev libssl-dev python-setuptools

download-custom-deps:
	mkdir .deps
	git clone https://github.com/hoho/xrlt.git .deps/xrlt
	git clone https://github.com/v8/v8.git .deps/v8 && cd .deps/v8 && git checkout 3.22.8
	$(MAKE) -C .deps/v8 dependencies
	git clone https://github.com/lloyd/yajl.git .deps/yajl
	curl -o .deps/nginx-1.4.2.tar.gz http://nginx.org/download/nginx-1.4.2.tar.gz
	cd .deps && tar -xzvf nginx-1.4.2.tar.gz

custom-deps:
	mkdir .build
	$(MAKE) -C .deps/v8 native -j8 OUTDIR=../../.build/v8 library=shared
	cp .build/v8/native/obj.target/tools/gyp/libv8.so /usr/local/lib
	cp .build/v8/native/lib.target/libicui18n.so /usr/local/lib
	cp .build/v8/native/lib.target/libicuuc.so /usr/local/lib
	cp .deps/v8/include/v8* /usr/local/include
	cd .deps/yajl && ./configure
	$(MAKE) -C .deps/yajl install
	$(MAKE) -C .deps/xrlt/libxrlt
	$(MAKE) -C .deps/xrlt/libxrlt install
	cd .deps/nginx-1.4.2 && ./configure --prefix=/usr/local/dietmyfeed/nginx \
	                                    --conf-path=/etc/dietmyfeed/nginx.conf \
	                                    --sbin-path=/usr/local/dietmyfeed/bin/nginx \
	                                    --http-log-path=/var/log/dietmyfeed/access.log \
	                                    --error-log-path=/var/log/dietmyfeed/error.log \
	                                    --pid-path=/var/run/dietmyfeed.pid \
	                                    --lock-path=/var/run/dietmyfeed.lock \
	                                    --http-client-body-temp-path=/var/cache/dietmyfeed/client_temp \
	                                    --http-proxy-temp-path=/var/cache/dietmyfeed/proxy_temp \
	                                    --http-fastcgi-temp-path=/var/cache/dietmyfeed/fastcgi_temp \
	                                    --http-uwsgi-temp-path=/var/cache/dietmyfeed/uwsgi_temp \
	                                    --http-scgi-temp-path=/var/cache/dietmyfeed/scgi_temp \
	                                    --add-module=../xrlt/nginx/ngx_http_xrlt \
	                                    --with-http_ssl_module \
	                                    --with-http_realip_module \
	                                    --with-http_gzip_static_module \
	                                    --with-http_secure_link_module \
	                                    --with-http_stub_status_module \
	                                    --with-cc-opt="-I/usr/include/libxml2 -I../xrlt/libxrlt" \
	                                    --with-ld-opt="-L/usr/local/lib -lxml2 -lyajl -lxrlt" \
	                                    && make
	easy_install xbem

install: buildwww
	$(MAKE) -C .deps/nginx-1.4.2 install
	mkdir -p /var/log/dietmyfeed
	mkdir -p /etc/dietmyfeed
	cp nginx/nginx.conf /etc/dietmyfeed/nginx.conf

buildwww:
	rm -rf .www
	cd src && xbem
	rm -rf /usr/local/dietmyfeed/www
	mkdir -p /usr/local/dietmyfeed/www
	cp -r .www/private /usr/local/dietmyfeed/www/private
	cp -r .www/public /usr/local/dietmyfeed/www/public
	cp src/robots.txt /usr/local/dietmyfeed/www/public

start:
	@echo "Starting nginx..."
	/usr/local/dietmyfeed/bin/nginx -c /etc/dietmyfeed/nginx.conf

stop:
	@echo "Stopping nginx..."
	/usr/local/dietmyfeed/bin/nginx -c /etc/dietmyfeed/nginx.conf -s stop
