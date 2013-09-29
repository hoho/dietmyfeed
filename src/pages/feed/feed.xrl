<xrl:requestsheet
        xmlns:xrl="http://xrlt.net/Transform"
        xmlns:b="http://xslc.org/XBEM/Block"
        xmlns:m="http://xslc.org/XBEM/Modifier">

    <xrl:import href="../cookie.xrl" />

    <xrl:transformation name="json-stringify" type="json-stringify" />
    <xrl:transformation name="feed-html" type="xslt-stringify" src="feed.xsl" />

    <xrl:function name="check-times" type="javascript">
        <xrl:param name="before" />
        <xrl:param name="after" />

        <![CDATA[

        var maxTime = (new Date()).getTime() / 1000 + 86400;

        before = parseInt(before, 10);

        // Checking that our time is between 2007 and now + one day.

        if (before > 1167609600 && before < maxTime) {
            return {before: before};
        }

        after = parseInt(after, 10);

        if (after > 1167609600 && after < maxTime) {
            return {after: after};
        }

        ]]>
    </xrl:function>

    <xrl:querystring name="GET" type="querystring">
        <xrl:success select="until | since" />
    </xrl:querystring>

    <xrl:function name="humanize-datetime" type="javascript">
        <xrl:param name="value" />
        <![CDATA[

        return new Date(value);

        ]]>
    </xrl:function>

    <xrl:response>
        <xrl:response-header name="Content-Type">application/json</xrl:response-header>

        <xrl:choose>
            <xrl:when test="$session-cookie/fb/text()">
                <xrl:include>
                    <xrl:href>/fb/me/home</xrl:href>
                    <xrl:type>json</xrl:type>
                    <xrl:method>GET</xrl:method>

                    <xrl:with-param name="fields">
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
                    </xrl:with-param>

                    <!--<xrl:with-param name="q">
                        <xrl:transform name="json-stringify">
                            <feed>SELECT post_id, type, actor_id, created_time, action_links, target_id, message, attachment, likes.count, comments FROM stream WHERE filter_key = 'others' <xrl:choose>
                                <xrl:when test="$GET/before"> AND created_time &lt; <xrl:value-of select="$GET/before/text()" /></xrl:when>
                                <xrl:when test="$GET/after"> AND created_time &gt; <xrl:value-of select="$GET/after/text()" /></xrl:when>
                            </xrl:choose> ORDER BY created_time DESC</feed>
                            <users>SELECT uid, name, pic_square, profile_url FROM user WHERE uid IN (SELECT comments.comment_list.fromid FROM #feed) OR uid IN (SELECT actor_id FROM #feed)</users>
                            <pages>SELECT page_id, name, pic_square, page_url FROM page WHERE page_id IN (SELECT comments.comment_list.fromid FROM #feed) OR page_id IN (SELECT actor_id FROM #feed)</pages>
                        </xrl:transform>
                    </xrl:with-param>-->

                    <xrl:with-param test="$GET/since" name="since"><xrl:value-of select="$GET/since/text()" /></xrl:with-param>
                    <xrl:with-param test="$GET/since" name="__previous">1</xrl:with-param>

                    <xrl:with-param test="$GET/until" name="until"><xrl:value-of select="$GET/until/text()" /></xrl:with-param>

                    <xrl:with-param name="limit">25</xrl:with-param>
                    <xrl:with-param name="method">GET</xrl:with-param>
                    <xrl:with-param name="format">json</xrl:with-param>

                    <xrl:with-param name="access_token" select="$session-cookie/fb/text()" />

                    <xrl:success>
                        <!-- Response is a JSON like {"feed": "News feed HTML code"} -->

                        <xrl:transform name="json-stringify">
                            <xrl:choose>
                                <xrl:when test="/data/*">
                                    <feed>
                                        <xrl:transform name="feed-html">
                                            <b:b-feed>
                                                <xrl:for-each select="/data">
                                                    <item>
                                                        <xrl:copy-of select="*" />
                                                        <datetime-humanized>
                                                            <xrl:apply name="humanize-datetime">
                                                                <xrl:with-param name="value" select="created_time/text()" />
                                                            </xrl:apply>
                                                        </datetime-humanized>
                                                    </item>
                                                </xrl:for-each>
                                            </b:b-feed>
                                        </xrl:transform>
                                    </feed>
                                    <since><xrl:value-of select="substring-before(substring-after(/paging/previous/text(), 'since='), '&amp;') + 1" /></since>
                                    <until><xrl:value-of select="substring-after(/paging/next/text(), 'until=')" /></until>
                                </xrl:when>
                                <xrl:otherwise>
                                    <feed>
                                        <xrl:transform name="feed-html">
                                            <b:b-feed m:empty="" />
                                        </xrl:transform>
                                    </feed>
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
