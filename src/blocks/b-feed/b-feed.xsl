<xsl:stylesheet
        version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:b="http://xslc.org/XBEM/Block"
        xmlns:e="http://xslc.org/XBEM/Element"
        xmlns:m="http://xslc.org/XBEM/Modifier"
        exclude-result-prefixes="b e m">

    <xsl:template match="b:b-feed">
        <ul class="b-feed">
            <xsl:apply-templates select="item" />
        </ul>
    </xsl:template>


    <xsl:template match="b:b-feed/item">
        <li class="b-feed__item">
            <div class="b-feed__head">
                <img src="{from/picture/data/url/text()}" />
                <a href="{from/link/text()}">
                    <xsl:value-of select="from/name/text()" />
                </a>
                <span>
                    <xsl:value-of select="datetime-humanized/text()" />
                </span>
            </div>

            <xsl:if test="message/text() != ''">
                <div class="b-feed__message">
                    <xsl:value-of select="message/text()" />
                </div>
            </xsl:if>

            <xsl:choose>
                <xsl:when test="type/text() = 'photo'">
                    <div class="b-feed__photo">
                        <a href="{link/text()}">
                            <img>
                                <xsl:attribute name="src">
                                    <xsl:choose>
                                        <xsl:when test="substring-before(picture/text(), '_s.') != ''">
                                            <xsl:value-of select="substring-before(picture/text(), '_s.')" />
                                            <xsl:text>_n.</xsl:text>
                                            <xsl:value-of select="substring-after(picture/text(), '_s.')" />
                                        </xsl:when>

                                        <xsl:otherwise>
                                            <xsl:value-of select="picture/text()" />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                            </img>
                        </a>
                    </div>
                </xsl:when>

                <xsl:otherwise>
                    <div class="b-feed__placeholder">Here be dragons</div>
                </xsl:otherwise>
            </xsl:choose>

            <div class="b-feed__actions">

            </div>

            <!--<div style="display: none;">
                <xsl:copy-of select="node()" />
            </div>-->
        </li>
    </xsl:template>

</xsl:stylesheet>
