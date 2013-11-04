<xsl:stylesheet
        version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:b="http://xslc.org/XBEM/Block"
        xmlns:e="http://xslc.org/XBEM/Element"
        xmlns:m="http://xslc.org/XBEM/Modifier"
        exclude-result-prefixes="b e m">

    <xsl:key name="user-by-id" match="/b:b-feed/user" use="uid/text()" />


    <xsl:template match="b:b-feed">
        <ul class="b-feed">
            <xsl:apply-templates select="item[type != '347']" />
        </ul>
    </xsl:template>


    <xsl:template match="b:b-feed/item">
        <li class="b-feed__item">
            <div class="b-feed__head">
                <xsl:variable name="user" select="key('user-by-id', actor_id/text())" />
                <img src="{$user/pic_square/text()}" />
                <a href="{$user/profile_url/text()}">
                    <xsl:value-of select="$user/name/text()" />
                </a>
                <xsl:if test="substring(description/text(), 1, string-length($user/name/text())) = $user/name/text()">
                    <xsl:value-of select="substring(description/text(), string-length($user/name/text()) + 1)" disable-output-escaping="yes" />
                </xsl:if>
                <span>
                    <xsl:value-of select="created_time/text()" />
                </span>
            </div>

            <xsl:if test="message/text() != ''">
                <div class="b-feed__message">
                    <xsl:value-of select="message/text()" disable-output-escaping="yes" />
                </div>
            </xsl:if>

            <xsl:apply-templates select="attachment[media/type]" />

            <div class="b-feed__actions">

            </div>

            <!--<div style="display: none;">
                <xsl:copy-of select="node()" />
            </div>-->
        </li>
    </xsl:template>


    <xsl:template match="attachment">
        <xsl:choose>
            <xsl:when test="media/type/text() = 'photo'">
                <div class="b-feed__photo">
                    <a href="{media/href/text()}">
                        <img src="{media/src/text()}" />
                    </a>
                </div>
            </xsl:when>
            <xsl:when test="media/type/text() = 'link'">
                <table class="b-feed__link">
                    <tr>
                        <td class="b-feed__link-img">
                            <img src="{media/src/text()}" />
                        </td>
                        <td>
                            <a href="{href/text()}"><xsl:value-of select="name/text()" /></a>
                            <p><xsl:value-of select="description/text()" /></p>
                        </td>
                    </tr>
                </table>
            </xsl:when>
            <xsl:otherwise>
                <div class="b-feed__placeholder">Here be dragons: <xsl:value-of select="media/type/text()" /></div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
