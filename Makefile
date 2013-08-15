help:
	@echo "TODO: Write some help here."

clean:
	rm -rf .deps
	rm -rf .build

apt-get-deps:
	apt-get install git subversion g++ make libxml2-dev libxslt-dev ruby cmake curl libpcre3 libpcre3-dev libssl-dev

download-custom-deps:
	mkdir .deps
	git clone https://github.com/hoho/xrlt.git .deps/xrlt
	git clone https://github.com/v8/v8.git .deps/v8
	$(MAKE) -C .deps/v8 dependencies
	git clone https://github.com/lloyd/yajl.git .deps/yajl
	curl -o .deps/nginx-1.4.2.tar.gz http://nginx.org/download/nginx-1.4.2.tar.gz
	cd .deps && tar -xzvf nginx-1.4.2.tar.gz

custom-deps:
	mkdir .build
	$(MAKE) -C .deps/v8 native -j8 OUTDIR=../../.build/v8 library=shared
	cp .build/v8/native/obj.target/tools/gyp/libv8.so /usr/local/lib
	cp .deps/v8/include/v8* /usr/local/include
	cd .deps/yajl && ./configure
	$(MAKE) -C .deps/yajl install
	$(MAKE) -C .deps/xrlt/libxrlt
	$(MAKE) -C .deps/xrlt/libxrlt install

build:
	cd .deps/nginx-1.4.2 && ./configure --prefix=/usr/local/www/dietmyfeed/nginx \
	                                    --conf-path=/etc/dietmyfeed/nginx.conf \
	                                    --sbin-path=/usr/local/www/dietmyfeed/nginx/bin/nginx \
	                                    --http-log-path=/var/log/dietmyfeed/access.log \
	                                    --error-log-path=/var/log/dietmyfeed/error.log \
	                                    --pid-path=/var/run/dietmyfeed.pid \
	                                    --add-module=../xrlt/nginx/ngx_http_xrlt \
	                                    --with-http_ssl_module \
	                                    --with-cc-opt="-I/usr/include/libxml2 -I../xrlt/libxrlt" \
	                                    --with-ld-opt="-L/usr/local/lib -lxml2 -lyajl -lxrlt" \
	                                    && make

install:
	$(MAKE) -C .deps/nginx-1.4.2 install