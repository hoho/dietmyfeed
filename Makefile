help:
	@echo "TODO: Write some help here."

clean:
	rm -rf .deps
	rm -rf .build

apt-get-deps:
	apt-get install git subversion g++ make libxml2-dev libxslt-dev ruby cmake

download-custom-deps:
	mkdir .deps
	git clone https://github.com/hoho/xrlt.git .deps/xrlt
	git clone https://github.com/v8/v8.git .deps/v8
	$(MAKE) -C .deps/v8 dependencies
	git clone https://github.com/lloyd/yajl.git .deps/yajl

build-custom-deps:
	mkdir .build
	$(MAKE) -C .deps/v8 native -j8 OUTDIR=../../.build/v8 library=shared
	cd .deps/yajl && ./configure
	$(MAKE) -C .deps/yajl


install-custom-deps:
	cp .build/v8/native/obj.target/tools/gyp/libv8.so /usr/local/lib
	cp .deps/v8/include/v8* /usr/local/include
	$(MAKE) -C .deps/yajl install


install:
	mkdir -p /usr/local/www/dietmyfeed
