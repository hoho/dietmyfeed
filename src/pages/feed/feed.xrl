<xrl:requestsheet
        xmlns:xrl="http://xrlt.net/Transform"
        xmlns:b="http://xslc.org/XBEM/Block">

    <xrl:import href="../cookie.xrl" />

    <xrl:transformation name="json-stringify" type="json-stringify" />
    <xrl:transformation name="feed-html" type="xslt-stringify" src="feed.xsl" />
    <xrl:transformation name="fuck" type="xml-stringify" />

    <xrl:function name="check-times" type="javascript">
        <xrl:param name="since" />
        <xrl:param name="until" />

        <![CDATA[

        var maxTime = (new Date()).getTime() / 1000 + 86400;

        since = parseInt(since, 10);

        // Checking that our time is between 2007 and now + one day.

        if (since > 1167609600 && since < maxTime) {
            return {since: since};
        }

        until = parseInt(until, 10);

        if (until > 1167609600 && until < maxTime) {
            return {until: until};
        }

        ]]>
    </xrl:function>


    <xrl:querystring name="GET" type="querystring">
        <xrl:success>
            <xrl:apply name="check-times">
                <xrl:with-param name="since" select="since/text()" />
                <xrl:with-param name="until" select="until/text()" />
            </xrl:apply>
        </xrl:success>
    </xrl:querystring>


    <xrl:function name="adjust-feed" type="javascript">
        <xrl:param name="data" />
        <![CDATA[

        var textFields = {message: true, description: true};

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
                        copy[name] = new Date(parseInt(obj[name], 10) * 1000);
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

        if (ret.item && ret.item.length) {
            ret.since = ret.item[0].created_time.getTime() / 1000;
            ret.until = ret.item[ret.item.length - 1].created_time.getTime() / 1000;
        }

        return ret;

        ]]>
    </xrl:function>


    <xrl:response>
        <xrl:response-header name="Content-Type">application/json</xrl:response-header>

        <xrl:choose>
            <xrl:when test="$session-cookie/fb/text()">
                <xrl:include>
                    <!-- /me/home?fields=created_time,updated_time,id,type,from.fields(name,link,picture),description,is_hidden,link,story,message,name,picture,via,caption,properties,comments.fields(message,attachment,like_count,from.fields(name,link,picture)),likes -->
                    <xrl:href>/fb/fql</xrl:href>
                    <xrl:type>json</xrl:type>
                    <xrl:method>GET</xrl:method>

                    <!--<xrl:with-param name="fields">
                        <xrl:text>created_time,</xrl:text>
                        <xrl:text>updated_time,</xrl:text>
                        <xrl:text>id,</xrl:text>
                        <xrl:text>type,</xrl:text>
                        <xrl:text>from.fields(name,link,picture),</xrl:text>
                        <xrl:text>description,</xrl:text>
                        <xrl:text>is_hidden,</xrl:text>
                        <xrl:text>link,</xrl:text>
                        <xrl:text>story,</xrl:text>
                        <xrl:text>message,</xrl:text>
                        <xrl:text>name,</xrl:text>
                        <xrl:text>picture,</xrl:text>
                        <xrl:text>via,</xrl:text>
                        <xrl:text>caption,</xrl:text>
                        <xrl:text>properties,</xrl:text>
                        <xrl:text>comments.fields(</xrl:text>
                        <xrl:text>message,</xrl:text>
                        <xrl:text>attachment,</xrl:text>
                        <xrl:text>like_count,</xrl:text>
                        <xrl:text>from.fields(name,link,picture)</xrl:text>
                        <xrl:text>),</xrl:text>
                        <xrl:text>likes</xrl:text>
                    </xrl:with-param>-->

                    <!--
                    <xrl:with-param test="$GET/since" name="since"><xrl:value-of select="$GET/since/text()" /></xrl:with-param>
                    <xrl:with-param test="$GET/since" name="__previous">1</xrl:with-param>

                    <xrl:with-param test="$GET/until" name="until"><xrl:value-of select="$GET/until/text()" /></xrl:with-param>
                    <xrl:with-param name="limit">25</xrl:with-param>
                    -->


                    <xrl:with-param name="q">
                        <xrl:transform name="json-stringify">
                            <feed>SELECT post_id, type, actor_id, created_time, action_links, target_id, message, description, attachment, like_info, comment_info FROM stream WHERE filter_key in (SELECT filter_key FROM stream_filter WHERE uid = me() AND type = 'newsfeed') AND is_hidden = 0 <xrl:choose>
                                <xrl:when test="$GET/since"> AND created_time &gt; <xrl:value-of select="$GET/since/text()" /></xrl:when>
                                <xrl:when test="$GET/until"> AND created_time &lt; <xrl:value-of select="$GET/until/text()" /></xrl:when>
                            </xrl:choose> ORDER BY created_time DESC</feed>
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
