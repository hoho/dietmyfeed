<xsl:stylesheet
        version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:b="http://xslc.org/XBEM/Block"
        exclude-result-prefixes="b">

    <xsl:output method="html" />

    <xsl:template match="/">
        <xsl:apply-templates select="b:b-feed" />
    </xsl:template>

</xsl:stylesheet>
