<xsl:stylesheet
        version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:b="http://xslc.org/XBEM/Block"
        xmlns:e="http://xslc.org/XBEM/Element"
        xmlns:m="http://xslc.org/XBEM/Modifier"
        exclude-result-prefixes="b e m">

    <xsl:output method="html" />


    <xsl:template match="b:b-page">
        <xsl:text disable-output-escaping="yes"><![CDATA[<!doctype html>
<!--
  Hello, stranger.
  I am the code you're looking at.
  Don't do no harm and I might work niftily for ya.
    -->
]]></xsl:text>

        <html>
            <head>
                <!--<meta charset="utf-8" />-->
                <title><xsl:value-of select="e:title/title" /></title>
                <link rel="stylesheet" href="_/_.css" />
            </head>
            <body class="b-page">
                <xsl:if test="timezone/text() != ''">
                    <xsl:attribute name="data-tz"><xsl:value-of select="timezone" /></xsl:attribute>
                </xsl:if>
                <header>
                    <h1 class="b-page__title">
                        <xsl:value-of select="e:title/first" />
                        <xsl:text> </xsl:text>
                        <strong><xsl:value-of select="e:title/last" /></strong>
                    </h1>

                    <ul class="b-page__menu">
                        <xsl:for-each select="e:menu/e:menu-item">
                            <li class="b-page__menu-item">
                                <xsl:if test="@m:log-off">
                                    <xsl:attribute name="class">b-page__menu-item b-page__menu-item_log-off</xsl:attribute>
                                </xsl:if>
                                <a href="{@href}">
                                    <xsl:value-of select="text()" />
                                </a>
                            </li>
                        </xsl:for-each>
                    </ul>

                    <xsl:if test="e:avatar">
                        <div class="b-page__avatar" style="background: url({e:avatar});"></div>
                    </xsl:if>
                </header>

                <div id="b-page__cover" class="b-page__cover">
                    <div>
                        <img width="100%" height="300" src="{e:cover}" />
                    </div>
                </div>

                <section class="b-page__content">
                    <xsl:apply-templates select="e:content/*" />
                </section>

                <footer class="b-page__footer">
                    <a href="/about">Diet My Feed</a>
                </footer>

                <script src="/_/libs.js"></script>
                <script src="/_/_.js"></script>
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
