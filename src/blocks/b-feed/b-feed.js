$.BEM.decl('b-feed')
    .onCall('replace', function(data) {
        var tmp = $(data.feed);
        tmp
            .bemMod('js', true)
            .filter('{more}')
            .bemCall('init', data.since, data.until);
        this.$.replaceWith(tmp);
    });


$.BEM.decl('b-feed', 'loader')
    .onMod('js', function(mod, val) {
        if (!val) { return; }

        var self = this;

        $.ajax({
            url: '/~/feed',
            type: 'POST',
            dataType: 'json',
            success: function(data) {
                self.bemCall('replace', data);
            }
        });
    });


$.BEM.decl('b-feed', 'more')
    .onCall('init', function(since, until) {
        this.since = since;
        this.until = until;
    });


$.BEM.extend('b-feed', 'more')
    .onMod('js', function($super, mod, val) {
        if (!val) { return; }

        var self = this;

        self.$.on('click', function() {
            self.bemMod('loading', true);

            $.ajax({
                url: '/~/feed?until=' + self.until,
                type: 'POST',
                dataType: 'json',
                success: function(data) {
                    self.$.off('click');
                    self.bemCall('replace', data);
                },
                error: function() {
                    self.bemMod('loading', false);
                }
            });
        });
    });
