<xsl:stylesheet
        version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:b="http://xslc.org/XBEM/Block"
        xmlns:e="http://xslc.org/XBEM/Element"
        xmlns:m="http://xslc.org/XBEM/Modifier"
        exclude-result-prefixes="b e m">

    <xsl:template match="b:b-feed[@m:loader]">
        <div class="js b-feed b-feed_loader">
            <xsl:call-template name="b:b-spinner" />
        </div>
    </xsl:template>


    <xsl:template match="b:b-feed">
        <div class="b-feed"></div>
    </xsl:template>

</xsl:stylesheet>
