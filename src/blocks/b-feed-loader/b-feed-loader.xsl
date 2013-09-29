<xsl:stylesheet
        version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:b="http://xslc.org/XBEM/Block"
        xmlns:e="http://xslc.org/XBEM/Element"
        xmlns:m="http://xslc.org/XBEM/Modifier"
        exclude-result-prefixes="b e m">

    <xsl:template match="b:b-feed-loader">
        <div class="js b-feed-loader">
            <div class="b-feed-loader__new">
                You have new.
            </div>
            <div class="b-feed-loader__feed"></div>
            <div class="b-feed-loader__more">
                <span class="more-feed">More feed</span>
                <span class="no-more-feed">No more feed</span>
                <xsl:call-template name="b:b-spinner" />
            </div>
        </div>
    </xsl:template>

</xsl:stylesheet>
