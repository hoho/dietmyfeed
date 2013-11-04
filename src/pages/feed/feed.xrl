<xrl:requestsheet
        xmlns:xrl="http://xrlt.net/Transform"
        xmlns:b="http://xslc.org/XBEM/Block">

    <xrl:import href="../cookie.xrl" />

    <xrl:transformation name="json-stringify" type="json-stringify" />
    <xrl:transformation name="feed-html" type="xslt-stringify" src="feed.xsl" />
    <xrl:transformation name="fuck" type="xml-stringify" />

    <xrl:function name="check-times-and-tz" type="javascript">
        <xrl:param name="since" />
        <xrl:param name="until" />
        <xrl:param name="tz" />

        <![CDATA[

        var maxTime = (new Date()).getTime() / 1000 + 86400,
            ret = {};

        tz = parseInt(tz, 10);
        if (tz >= -12 && tz <= 14) {
            ret.tz = tz * 60;
        }

        since = parseInt(since, 10);

        // Checking that our time is between 2007 and now + one day.

        if (since > 1167609600 && since < maxTime) {
            ret.since = since;
        } else {
            until = parseInt(until, 10);

            if (until > 1167609600 && until < maxTime) {
                ret.until = until;
            }
        }

        return ret;

        ]]>
    </xrl:function>


    <xrl:querystring name="GET" type="querystring">
        <xrl:success>
            <xrl:apply name="check-times-and-tz">
                <xrl:with-param name="since" select="since/text()" />
                <xrl:with-param name="until" select="until/text()" />
                <xrl:with-param name="tz" select="tz/text()" />
            </xrl:apply>
        </xrl:success>
    </xrl:querystring>


    <xrl:function name="adjust-feed" type="javascript">
        <xrl:param name="data" />
        <xrl:param name="tz" select="$GET/tz/text()" />
        <![CDATA[

        tz = parseInt(tz) || 0;

        var textFields = {message: true, description: true},
            minTime,
            maxTime,
            months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
            tmp;

        function datetimeToStr(date) {
            // XXX: This is ugly. Do something with it.
            date.setMinutes(date.getMinutes() + date.getTimezoneOffset() + tz);
            date = [
                date.getHours(),
                ':',
                date.getMinutes(),
                ', ',
                months[date.getMonth()],
                ' ',
                date.getDate(),
                ' ',
                date.getFullYear()
            ];

            if (date[0] < 10) { date[0] = '0' + date[0]; }
            if (date[2] < 10) { date[2] = '0' + date[2]; }

            return date.join('');
        }

        function clone(obj) {

            if (obj === null || typeof obj !== 'object') {
                return obj;
            }

            if (obj instanceof Array) {
                var copy = [];
                for (var i = 0, len = obj.length; i < len; i++) {
                    copy[i] = clone(obj[i]);
                }
                return copy;
            }

            if (obj instanceof Object) {
                var copy = {};
                for (var name in obj) {
                    if (name === 'created_time') {
                        copy[name] = datetimeToStr(new Date(parseInt(obj[name], 10) * 1000));
                    } else if (name === 'updated_time') {
                        tmp = obj[name];

                        if (tmp && (!minTime || tmp < minTime)) {
                            minTime = tmp;
                        }

                        if (tmp && (!maxTime || tmp > maxTime)) {
                            maxTime = tmp;
                        }

                        copy[name] = tmp;
                    } else if (name in textFields) {
                        copy[name] = (obj[name] || '')
                            .replace(/&/g, '&amp;')
                            .replace(/</g, '&lt;')
                            .replace(/>/g, '&gt;')
                            .replace(/"/g, '&quot;')
                            .replace(/(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig, '<a href="$1" target="_blank">$1</a>');
                    } else if (name === 'src') {
                        copy[name] = (obj[name] || '').replace(/(s\.jpg)$/, 'n.jpg');
                    } else {
                        copy[name] = clone(obj[name]);
                    }
                }

                return copy;
            }
        }

        var ret = {
            item: clone(data[0].fql_result_set),
            page: data[1].fql_result_set,
            user: data[2].fql_result_set
        };

        if (minTime && maxTime) {
            ret.since = maxTime;
            ret.until = minTime;
        }

        return ret;

        ]]>
    </xrl:function>


    <xrl:response>
        <xrl:response-header name="Content-Type">application/json</xrl:response-header>

        <xrl:choose>
            <xrl:when test="$session-cookie/fb/text()">
                <xrl:include>
                    <xrl:href>/fb/fql</xrl:href>
                    <xrl:type>json</xrl:type>
                    <xrl:method>GET</xrl:method>

                    <xrl:with-param name="q">
                        <xrl:transform name="json-stringify">
                            <feed>SELECT post_id, type, actor_id, created_time, updated_time, action_links, target_id, message, description, attachment, like_info, comment_info FROM stream WHERE filter_key IN (SELECT filter_key FROM stream_filter WHERE uid = me() AND type = 'newsfeed') AND is_hidden = 0 <xrl:choose>
                                <xrl:when test="$GET/since"> AND created_time &gt; <xrl:value-of select="$GET/since/text()" /></xrl:when>
                                <xrl:when test="$GET/until"> AND created_time &lt; <xrl:value-of select="$GET/until/text()" /></xrl:when>
                            </xrl:choose> ORDER BY updated_time DESC LIMIT 50</feed>
                            <pages>SELECT page_id, name, pic_square, page_url FROM page WHERE page_id IN (SELECT actor_id FROM #feed)</pages>
                            <users>SELECT uid, name, pic_square, profile_url FROM user WHERE uid IN (SELECT actor_id FROM #feed)</users>
                        </xrl:transform>
                    </xrl:with-param>

                    <xrl:with-param name="method">GET</xrl:with-param>
                    <xrl:with-param name="format">json</xrl:with-param>

                    <xrl:with-param name="access_token" select="$session-cookie/fb/text()" />

                    <xrl:success>
                        <!-- Response is a JSON like {"feed": "News feed HTML code"} -->

                        <xrl:transform name="json-stringify">
                            <xrl:choose>
                                <xrl:when test="/data/fql_result_set/*">
                                    <xrl:variable name="feed">
                                        <xrl:apply name="adjust-feed">
                                            <xrl:with-param name="data" select="/" />
                                        </xrl:apply>
                                    </xrl:variable>

                                    <feed>
                                        <xrl:transform name="feed-html">
                                            <b:b-feed>
                                                <xrl:copy-of select="$feed" />
                                            </b:b-feed>
                                        </xrl:transform>
                                    </feed>
                                    <since><xrl:value-of select="$feed/since" /></since>
                                    <until><xrl:value-of select="$feed/until" /></until>
                                </xrl:when>
                                <xrl:otherwise>
                                    <feed />
                                </xrl:otherwise>
                            </xrl:choose>
                        </xrl:transform>
                    </xrl:success>
                    <xrl:failure>
                        <xrl:response-status>502</xrl:response-status>
                        <xrl:text>Error: Failed to load feed (</xrl:text>
                        <xrl:status />
                        <xrl:text>)</xrl:text>
                    </xrl:failure>
                </xrl:include>
            </xrl:when>

            <xrl:otherwise>
                <xrl:response-status>403</xrl:response-status>
                <xrl:text>Error: Forbidden</xrl:text>
            </xrl:otherwise>
        </xrl:choose>
    </xrl:response>

</xrl:requestsheet>
