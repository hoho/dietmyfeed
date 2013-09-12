Diet My Feed
============

Diet My Feed is a simplified reader for your Facebook feed.

It is being made as a prove of concept application for [XRLT](http://xrlt.net)
technology.



## Feel It

Diet My Feed is available at [https://dietmyfeed.com](https://dietmyfeed.com)



## Set Up Your Own Copy

These steps are for Ubuntu 12.04:

  * `git clone git://github.com/hoho/dietmyfeed.git`.
  * `sudo make apt-get-deps`.
  * `make download-custom-deps`.
  * `sudo make custom-deps`.
  * `sudo make install`.
  * set your own values for `xrlt_param fb-id`, `xrlt_param fb-secret`, `xrlt_param index-url` and `xrlt_param auth-url` in `/etc/dietmyfeed/nginx.conf`.
  * `sudo /etc/init.d/dietmyfeed start`



## Author

**Marat Abdullin** — [https://github.com/hoho](https://github.com/hoho)



## Licence

Diet My Feed is released under the [CC BY-NC-SA 3.0](http://creativecommons.org/licenses/by-nc-sa/3.0/) licence.
