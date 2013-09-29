<xrl:requestsheet
        xmlns:xrl="http://xrlt.net/Transform"
        xmlns:b="http://xslc.org/XBEM/Block"
        xmlns:e="http://xslc.org/XBEM/Element"
        xmlns:m="http://xslc.org/XBEM/Modifier">

    <xrl:transformation name="page" type="xslt-stringify" src="index.xsl" />


    <xrl:import href="../cookie.xrl" />


    <xrl:response>
        <xrl:variable name="login-data">
            <xrl:if test="$session-cookie/fb/text()">
                <!-- We have access token, request user info. -->
                <xrl:include>
                    <xrl:href>/fb/me</xrl:href>
                    <xrl:type>json</xrl:type>

                    <xrl:with-param name="fields">name,first_name,last_name,username,cover,picture,timezone</xrl:with-param>
                    <xrl:with-param name="access_token" select="$session-cookie/fb/text()" />

                    <xrl:success>
                        <xrl:choose>
                            <xrl:when test="/name/text()">
                                <name><xrl:value-of select="/name/text()" /></name>
                                <first-name><xrl:value-of select="/first_name/text()" /></first-name>
                                <last-name><xrl:value-of select="/last_name/text()" /></last-name>
                                <cover><xrl:value-of select="/cover/source/text()" /></cover>
                                <avatar><xrl:value-of select="/picture/data/url/text()" /></avatar>
                                <timezone><xrl:value-of select="/timezone/text()" /></timezone>
                            </xrl:when>
                            <xrl:otherwise>
                                <failure />
                            </xrl:otherwise>
                        </xrl:choose>
                    </xrl:success>

                    <xrl:failure>
                        <failure />
                    </xrl:failure>
                </xrl:include>
            </xrl:if>
        </xrl:variable>

        <xrl:choose>
            <xrl:when test="$login-data/failure">
                <xrl:response-status>502</xrl:response-status>
                <xrl:text>Error: Failed to get login data</xrl:text>
            </xrl:when>

            <xrl:otherwise>
                <xrl:transform name="page">
                    <b:b-page>
                        <xrl:choose>
                            <xrl:when test="$login-data/name">
                                <timezone>
                                    <xrl:value-of select="$login-data/timezone" />
                                </timezone>

                                <e:title b:block="b-page">
                                    <title>Diet My Feed — <xrl:value-of select="$login-data/name" /></title>
                                    <first><xrl:value-of select="$login-data/first-name" /></first>
                                    <last><xrl:value-of select="$login-data/last-name" /></last>
                                </e:title>

                                <e:menu b:block="b-page">
                                    <e:menu-item b:block="b-page" href="/">News</e:menu-item>
                                    <e:menu-item b:block="b-page" href="/about">About</e:menu-item>
                                    <e:menu-item b:block="b-page" href="/off" m:log-off="">Log off</e:menu-item>
                                </e:menu>

                                <e:avatar b:block="b-page">
                                    <xrl:value-of select="$login-data/avatar" />
                                </e:avatar>

                                <e:cover b:block="b-page">
                                    <xrl:value-of select="$login-data/cover" />
                                </e:cover>

                                <e:content b:block="b-page">
                                    <b:b-feed-loader />
                                </e:content>
                            </xrl:when>

                            <xrl:otherwise>
                                <e:title b:block="b-page">
                                    <title>Diet My Feed</title>
                                    <first>Diet</first>
                                    <last>My Feed</last>
                                </e:title>

                                <e:menu b:block="b-page">
                                    <e:menu-item b:block="b-page" href="/">Log on</e:menu-item>
                                    <e:menu-item b:block="b-page" href="/about">About</e:menu-item>
                                </e:menu>

                                <e:cover b:block="b-page">/_/b-page__cover.jpg</e:cover>

                                <e:content b:block="b-page">
                                    <!--<b:b-log-on />-->
                                </e:content>
                            </xrl:otherwise>
                        </xrl:choose>
                    </b:b-page>
                </xrl:transform>
            </xrl:otherwise>
        </xrl:choose>
    </xrl:response>

</xrl:requestsheet>
