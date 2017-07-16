<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://sistory.si/schema/sistory/v3/entity"
    xmlns:entity="http://sistory.si/schema/sistory/v3/entity"
    xmlns:sistory="http://www.sistory.si/schemas/sistory/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs sistory entity"
    version="2.0">
    
    <!-- Naredi avtomatično izhodiščne elemente, ki bodo v entity namespace -->
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="sistory:root">
        <root xmlns="http://sistory.si/schema/sistory/v3/entity">
            <!-- lahko poberem podatke za samo aktivne publikacije -->
            <xsl:for-each select="sistory:publication[number(sistory:STATUS)=1]">
                <xsl:variable name="id" select="sistory:ID"/>
                <xsl:variable name="sistoryHTMLsl" select="concat('http://sistory.si/11686/',$id,'?language=sl')"/>
                <xsl:variable name="sistoryHTMLen" select="concat('http://sistory.si/11686/',$id,'?language=en')"/>
                <xsl:variable name="string-sl-var1">
                    <xsl:value-of select="unparsed-text($sistoryHTMLsl,'UTF-8')"/>
                </xsl:variable>
                <xsl:variable name="string-en-var1">
                    <xsl:value-of select="unparsed-text($sistoryHTMLen,'UTF-8')"/>
                </xsl:variable>
                
                <frontend>
                    <id>
                        <xsl:value-of select="$id"/>
                    </id>
                    <files>
                        <xsl:analyze-string select="$string-sl-var1" regex="(&lt;div\sid=&quot;okvircek&quot;&gt;)(.*?)(&lt;/aside&gt;)" flags="s">
                            <xsl:matching-substring>
                                <xsl:value-of select="." disable-output-escaping="yes"/>
                                <xsl:text disable-output-escaping="yes"><![CDATA[</div>]]></xsl:text>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:analyze-string select="." regex="&amp;download">
                                    <xsl:matching-substring>
                                        <xsl:text disable-output-escaping="yes"><![CDATA[&download]]></xsl:text>
                                    </xsl:matching-substring>
                                </xsl:analyze-string>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </files>
                    <description_sl>
                        <xsl:analyze-string select="$string-sl-var1" regex="(&lt;section\sid=&quot;opis&quot;&gt;)(.*?)(&lt;/section&gt;)" flags="s">
                            <xsl:matching-substring>
                                <xsl:value-of select="." disable-output-escaping="yes"/>
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </description_sl>
                    <description_en>
                        <xsl:analyze-string select="$string-en-var1" regex="(&lt;section\sid=&quot;opis&quot;&gt;)(.*?)(&lt;/section&gt;)" flags="s">
                            <xsl:matching-substring>
                                <xsl:value-of select="." disable-output-escaping="yes"/>
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </description_en>
                </frontend>
            </xsl:for-each>
        </root>
    </xsl:template>
    
</xsl:stylesheet>