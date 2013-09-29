$.BEM.decl('b-feed-loader')
    .onMod('js', function(mod, val) {
        if (!val) { return; }

        var self = this;

        self.updates = [];

        self.more = self.$.find('%b-feed-loader(more)');
        self.more.bemMod('type', 'first');

        self.more.on('click', function() {
            if ($(this).not('{loading}').is('{type=first}, {type=next}')) {
                self.bemCall('load', false);
            }
        });

        self.bemCall('load', false);
    })

    .onCall('load', function(update) {
        var self = this;

        if (!update) {
            self.more
                .bemMod('loading', true)
                .bemMod('error', false);
        }

        $.ajax({
            url: '/~/feed' + (update && self.since ? '?since=' + self.since : (self.until ? '?until=' + self.until : '')),
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
                    }
                } else {
                    if (data.feed) {
                        self.more.bemMod('type', 'next');
                        self.$.find('%b-feed-loader(feed)').append(data.feed);
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
                if (!update) {
                    self.more.bemMod('loading', false);
                }
            }
        });
    });
