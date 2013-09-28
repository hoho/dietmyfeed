<xrl:requestsheet xmlns:xrl="http://xrlt.net/Transform">

    <xrl:function name="parse-session-cookie" type="javascript">
        <xrl:param name="cookie"><xrl:cookie name="dietmyfeed" main="yes" /></xrl:param>
        <![CDATA[

        var ret;

        if (cookie) {
            try {
                ret = JSON.parse(decodeURIComponent(cookie));
            } catch(e) {}
        }

        if (!ret || !ret.id) {
            ret = {};
        }

        return ret;

        ]]>
    </xrl:function>

    <xrl:variable name="session-cookie">
        <xrl:apply name="parse-session-cookie" />
    </xrl:variable>

</xrl:requestsheet>
