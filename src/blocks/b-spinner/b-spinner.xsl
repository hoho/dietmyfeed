<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:b="http://xslc.org/XBEM/Block"
                exclude-result-prefixes="b">

    <xsl:template match="b:b-spinner" name="b:b-spinner">
        <div class="b-spinner">
            <div class="b"></div>
            <div class="i"></div>
        </div>
    </xsl:template>

</xsl:stylesheet>
