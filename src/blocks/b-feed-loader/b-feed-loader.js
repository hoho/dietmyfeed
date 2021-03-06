$.BEM.decl('b-feed-loader')
    .onMod('js', function(mod, val) {
        if (!val) { return; }

        var self = this;

        self.tz = $(document.body).data('tz');

        self.updates = [];

        self.more = self.$.find('%b-feed-loader(more)');
        self.more.bemMod('type', 'first');
        self.more.on('click', function() {
            if ($(this).not('{loading}').is('{type=first}, {type=next}')) {
                self.bemCall('load', false);
            }
        });

        self.feed = self.$.find('%b-feed-loader(feed)');

        self.$.find('%b-feed-loader(new)').on('click', function() {
            if (self.updates.length) {
                self.feed.prepend(self.updates.join(''));
                self.updates = [];
                self.bemMod('new', false);
            }
        });

        self.bemCall('load', false);
        self.bemCall('update');
    })

    .onCall('update', function() {
        var self = this;

        window.setTimeout(function() {
            self.bemCall(self.since ? 'load' : 'update', true);
        }, 30000);
    })

    .onCall('load', function(update) {
        var self = this;

        if (!update) {
            self.more
                .bemMod('loading', true)
                .bemMod('error', false);
        }

        $.ajax({
            url: '/~/feed?tz=' + self.tz + (update && self.since ? '&since=' + self.since : (self.until ? '&until=' + self.until : '')),
            type: 'POST',
            dataType: 'json',
            success: function(data) {
                if (data.since && (!self.since || self.since < data.since)) {
                    self.since = data.since;
                }

                if (data.until && (!self.until || self.until > data.until)) {
                    self.until = data.until;
                }

                if (update) {
                    if (data.feed) {
                        self.updates.unshift(data.feed);
                        self.bemMod('new', true);
                    }
                } else {
                    if (data.feed) {
                        self.more.bemMod('type', 'next');
                        self.feed.append(data.feed);
                    } else {
                        self.more.bemMod('type', 'no-more');
                    }
                }
            },
            error: function() {
                if (!update) {
                    self.more.bemMod('error', true);
                }
            },
            complete: function() {
                if (update) {
                    self.bemCall('update');
                } else {
                    self.more.bemMod('loading', false);
                }
            }
        });
    });
