<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://sistory.si/schema/sistory/v2/menu"
    xmlns:sistory="http://sistory.si/schema/sistory/v2/menu"
    xmlns:METS="http://www.loc.gov/METS/"
    xmlns:xlink="http://www.w3.org/TR/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/" 
    xmlns:dcmitype="http://purl.org/dc/dcmitype/"
    xmlns:premis="http://www.loc.gov/standards/premis/v1"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:entity="http://sistory.si/schema/sistory/v3/entity"
    exclude-result-prefixes="xs sistory"
    version="2.0">
    
    <!-- pretvorba podatkov iz ../SIstory/menu/nav.xml v mets.xml za collection -->
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <!-- Če želim, da v mets.xml vključim lokacijo sheme, mora biti parameter schemaLocation true -->
    <xsl:param name="schemaLocation">true</xsl:param>
    
    <!-- določi si, kje naj ustvari folderje z mets datetekami -->
    <xsl:param name="outputDir">/Users/administrator/Documents/moje/Sheme/sistory-mets/si4/collection/</xsl:param>
    
    <xsl:template match="/">
        <xsl:for-each select="//sistory:collection">
            <xsl:result-document href="{concat($outputDir,'menu',@id,'/mets.xml')}">
                <METS:mets xmlns:METS="http://www.loc.gov/METS/"
                    xmlns:xlink="http://www.w3.org/TR/xlink"
                    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                    xmlns:dc="http://purl.org/dc/elements/1.1/"
                    xmlns:dcterms="http://purl.org/dc/terms/" 
                    xmlns:dcmitype="http://purl.org/dc/dcmitype/"
                    xmlns:premis="http://www.loc.gov/premis/v3"
                    xmlns:mods="http://www.loc.gov/mods/v3"
                    ID="collection."
                    TYPE="collection" 
                    OBJID="http://hdl.handle.net/11686/menu{@id}">
                    <xsl:if test="$schemaLocation = 'true'">
                        <xsl:attribute name="xsi:schemaLocation">http://www.loc.gov/METS/ http://www.loc.gov/mets/mets.xsd http://purl.org/dc/terms/ http://dublincore.org/schemas/xmls/qdc/dcterms.xsd http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/mods.xsd http://www.loc.gov/premis/v3 https://www.loc.gov/standards/premis/premis.xsd</xsl:attribute>
                    </xsl:if>
                    <xsl:variable name="currentDateTime" select="substring-before(xs:string(current-dateTime()),'.')"/>
                    <METS:metsHdr CREATEDATE="{xs:dateTime($currentDateTime)}" LASTMODDATE="{xs:dateTime($currentDateTime)}" RECORDSTATUS="Active">
                        <xsl:attribute name="RECORDSTATUS">
                            <xsl:choose>
                                <xsl:when test="@active">Inactive</xsl:when>
                                <xsl:otherwise>Active</xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <METS:agent ROLE="DISSEMINATOR" TYPE="ORGANIZATION">
                            <METS:name>SIstory</METS:name>
                            <METS:note>http://sistory.si/</METS:note>
                        </METS:agent>
                        <!-- dam samo svoje podatke -->
                        <METS:agent ROLE="CREATOR" ID="user.11" TYPE="INDIVIDUAL">
                            <METS:name>Pančur, Andrej</METS:name>
                        </METS:agent>
                    </METS:metsHdr>
                    <METS:dmdSec ID="default.dc">
                        <METS:mdWrap MDTYPE="DC" MIMETYPE="text/xml">
                            <METS:xmlData>
                                <xsl:if test="sistory:title[@lang='slv']">
                                    <dcterms:title xml:lang="slv">
                                        <xsl:value-of select="sistory:title[@lang='slv']"/>
                                    </dcterms:title>
                                </xsl:if>
                                <xsl:if test="sistory:title[@lang='eng']">
                                    <dcterms:title xml:lang="eng">
                                        <xsl:value-of select="sistory:title[@lang='eng']"/>
                                    </dcterms:title>
                                </xsl:if>
                                <xsl:for-each select="sistory:dublincore/*[not(self::dcterms:title)]">
                                    <xsl:copy-of select="." copy-namespaces="no"/>
                                </xsl:for-each>
                            </METS:xmlData>
                        </METS:mdWrap>
                    </METS:dmdSec>
                    <METS:amdSec ID="default.amd">
                        <!-- v premis:object je najprej zapisan identifikator te entitete tako v relacijski bazi kot handle različica -->
                        <METS:techMD ID="default.premis">
                            <METS:mdWrap MDTYPE="PREMIS:OBJECT" MIMETYPE="text/xml">
                                <METS:xmlData>
                                    <premis:objectIdentifier>
                                        <premis:objectIdentifierType>si4</premis:objectIdentifierType>
                                        <premis:objectIdentifierValue></premis:objectIdentifierValue>
                                    </premis:objectIdentifier>
                                    <premis:objectIdentifier>
                                        <premis:objectIdentifierType>Local name</premis:objectIdentifierType>
                                        <premis:objectIdentifierValue>
                                            <xsl:value-of select="concat('menu',@id)"/>
                                        </premis:objectIdentifierValue>
                                    </premis:objectIdentifier>
                                    <premis:objectIdentifier>
                                        <premis:objectIdentifierType>hdl</premis:objectIdentifierType>
                                        <premis:objectIdentifierValue>
                                            <xsl:value-of select="concat('http://hdl.handle.net/11686/menu',@id)"/>
                                        </premis:objectIdentifierValue>
                                    </premis:objectIdentifier>
                                    <premis:objectCategory>Collection</premis:objectCategory>
                                </METS:xmlData>
                            </METS:mdWrap>
                        </METS:techMD>
                        <xsl:if test="sistory:menu">
                            <METS:techMD ID="default.si4">
                                <METS:mdWrap MDTYPE="OTHER" OTHERMDTYPE="COLLECTION" MIMETYPE="text/xml">
                                    <METS:xmlData xmlns:collection="http://sistory.si/schema/si4/collection">
                                        <xsl:if test="$schemaLocation = 'true'">
                                            <xsl:attribute name="xsi:schemaLocation">https://raw.githubusercontent.com/SIstory/si4-mets/master/schema/collection.1.0.xsd</xsl:attribute>
                                        </xsl:if>
                                        <xsl:for-each select="sistory:menu/*">
                                            <xsl:copy-of select="." copy-namespaces="no"/>
                                        </xsl:for-each>
                                    </METS:xmlData>
                                </METS:mdWrap>
                            </METS:techMD>
                        </xsl:if>
                    </METS:amdSec>
                    <METS:structMap ID="default.structure" xmlns:xlink="http://www.w3.org/1999/xlink">
                        <xsl:attribute name="TYPE">
                            <xsl:choose>
                                <xsl:when test="parent::sistory:repository">primary</xsl:when>
                                <xsl:otherwise>dependent</xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:choose>
                            <!-- primary collection -->
                            <xsl:when test="parent::sistory:repository">
                                <METS:div TYPE="collection" DMDID="default.dc" ADMID="default.amd">
                                    <xsl:for-each select="sistory:collection">
                                        <METS:div TYPE="collection">
                                            <METS:mptr LOCTYPE="HANDLE" xlink:href="http://hdl.handle.net/11686/menu{@id}"/>
                                        </METS:div>
                                    </xsl:for-each>
                                </METS:div>
                            </xsl:when>
                            <!-- dependent collection -->
                            <xsl:otherwise>
                                <METS:div TYPE="collection">
                                    <METS:mptr LOCTYPE="HANDLE" xlink:href="http://hdl.handle.net/11686/menu{parent::sistory:collection/@id}"/>
                                    <METS:div TYPE="collection" DMDID="default.dc" ADMID="default.amd">
                                        <METS:mptr LOCTYPE="HANDLE" xlink:href="http://hdl.handle.net/11686/menu{@id}"/>
                                        <xsl:for-each select="sistory:collection">
                                            <METS:div TYPE="collection">
                                                <METS:mptr LOCTYPE="HANDLE" xlink:href="http://hdl.handle.net/11686/menu{@id}"/>
                                            </METS:div>
                                        </xsl:for-each>
                                    </METS:div>
                                </METS:div>
                            </xsl:otherwise>
                        </xsl:choose>
                    </METS:structMap>
                    <METS:behaviorSec ID="default.behavior" xmlns:xlink="http://www.w3.org/1999/xlink">
                        <METS:behavior BTYPE="collection">
                            <METS:mechanism LOCTYPE="URL" xlink:href="http://sistory.si/resources/assets/xsd/default/mets.xsd"/>
                        </METS:behavior>
                    </METS:behaviorSec>
                </METS:mets>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>