<xrl:requestsheet xmlns:xrl="http://xrlt.net/Transform">

    <xrl:param name="fb-id" />
    <xrl:param name="fb-secret" />
    <xrl:param name="auth-url" />
    <xrl:param name="index-url" />


    <xrl:import href="../cookie.xrl" />


    <xrl:querystring name="GET" type="querystring" />


    <xrl:function name="urlencode" type="javascript">
        <xrl:param name="text" />
        <![CDATA[

        return encodeURIComponent(text);

        ]]>
    </xrl:function>


    <xrl:function name="get-auth-random" type="javascript">
        <![CDATA[

        return Math.random().toString(16).substring(2);

        ]]>
    </xrl:function>


    <xrl:function name="new-session-cookie-value" type="javascript">
        <xrl:param name="fb-token" />
        <xrl:param name="auth-random" />
        <xrl:param name="cookie" select="$session-cookie" />
        <![CDATA[

        var ret = {}, id, i, tmp;

        if (!cookie || !cookie.id) {
            id = new Array(4);

            for (i = 0; i < 4; i++) {
                id[i] = Math.random().toString(16).substring(2);
            }

            ret.id = id.join('');
        } else {
            ret.id = cookie.id;
        }

        if (fb_token) { ret.fb = fb_token; }
        if (auth_random) { ret.csrf = auth_random; }

        return encodeURIComponent(JSON.stringify(ret));

        ]]>
    </xrl:function>


    <xrl:function name="new-session-cookie">
        <xrl:param name="fb-token" />
        <xrl:param name="auth-random" />

        <xrl:response-cookie name="dietmyfeed" domain="dietmyfeed.com" path="/" httponly="yes">
            <xrl:apply name="new-session-cookie-value">
                <xrl:with-param name="fb-token" select="$fb-token" />
                <xrl:with-param name="auth-random" select="$auth-random" />
            </xrl:apply>
        </xrl:response-cookie>
    </xrl:function>


    <xrl:response>
        <xrl:choose>
            <xrl:when test="$GET/error/text()">
                <!-- Facebook API redirected us here with an error message. -->
                <xrl:response-status>502</xrl:response-status>
                <xrl:text>Error: </xrl:text>
                <xrl:value-of select="$GET" />
            </xrl:when>

            <xrl:when test="$GET/code/text() and $GET/state[text() != '' and text() = $session-cookie/csrf/text()]">
                <!-- Request access token. -->
                <xrl:include>
                    <xrl:href>/fb/oauth/access_token</xrl:href>
                    <xrl:type>querystring</xrl:type>

                    <xrl:with-param name="client_id" select="$fb-id" />
                    <xrl:with-param name="redirect_uri" select="$auth-url" />
                    <xrl:with-param name="client_secret" select="$fb-secret" />
                    <xrl:with-param name="code" select="$GET/code/text()" />

                    <xrl:success>
                        <xrl:choose>
                            <xrl:when test="/access_token/text()">
                                <!-- Everything is alright, set sessin cookie and redirect to index page. -->
                                <xrl:apply name="new-session-cookie">
                                    <xrl:with-param name="fb-token" select="/access_token/text()" />
                                </xrl:apply>
                                <xrl:redirect select="$index-url" />
                            </xrl:when>
                            <xrl:otherwise>
                                <!-- Failed to request access token. -->
                                <xrl:response-status>502</xrl:response-status>
                                <xrl:text>Error (</xrl:text><xrl:status /><xrl:text>): </xrl:text>
                                <xrl:value-of select="/" />
                            </xrl:otherwise>
                        </xrl:choose>
                    </xrl:success>
                    <xrl:failure>
                        <xrl:response-status>502</xrl:response-status>
                        <xrl:text>Error: Failed to get access token</xrl:text>
                    </xrl:failure>
                </xrl:include>
            </xrl:when>

            <xrl:when test="count($GET/*) = 0">
                <!-- No parameters passed, redirect to Facebook authentication dialog. -->
                <xrl:variable name="new-auth-random"><xrl:apply name="get-auth-random" /></xrl:variable>

                <xrl:apply name="new-session-cookie">
                    <xrl:with-param name="auth-random" select="$new-auth-random" />
                </xrl:apply>

                <xrl:redirect>
                    <xrl:text>https://www.facebook.com/dialog/oauth?client_id=</xrl:text>
                    <xrl:apply name="urlencode"><xrl:with-param name="text" select="$fb-id" /></xrl:apply>
                    <xrl:text>&amp;redirect_uri=</xrl:text>
                    <xrl:apply name="urlencode"><xrl:with-param name="text" select="$auth-url" /></xrl:apply>
                    <xrl:text>&amp;response_type=code&amp;scope=read_stream,read_mailbox,publish_actions&amp;state=</xrl:text>
                    <xrl:value-of select="$new-auth-random" />
                </xrl:redirect>
            </xrl:when>

            <xrl:otherwise>
                <!-- Incorrect request parameters. -->
                <xrl:response-status>400</xrl:response-status>
                <xrl:text>Error: Bad request</xrl:text>
            </xrl:otherwise>
        </xrl:choose>
    </xrl:response>

</xrl:requestsheet>
