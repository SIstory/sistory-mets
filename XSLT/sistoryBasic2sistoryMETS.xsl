<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.sistory.si/schemas/sistory/"
    xmlns:sistory="http://www.sistory.si/schemas/sistory/"
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
    
    <!-- TODO:
            - v METS:div/@DMDID zapiši povezave na vse opisne metapodatke te entitete
            - v Basic SIstory XML manjka podatek za URL umaknjene publikacije, so pa verjetno vse takšne publikacije v eni mapi
            - ker Tage še ne porabljamo, zato ni potrebe po pretvorbi
            - year ne bi uporabljal v posebnem metapodatkovnem polju (je nujno zapisan v dc:terms:date[@xsi:type='dcterms:W3CDTF']
            - Nisem pretvoril podatkov o vrstnem redu child publikacije (publikacij)
            - Nisem pretvoril dodatnih Knjižničarskih, Arhivskih, Muzejskih in Avdiovizualnih elementih
            
            - Pretvorba za METS:structMap je narejena samo za parent/child/child (trenutno ni še nadaljnih child relacij parent/child/child/child itd.)
            
            - Trenutno je pri umaknjenih publikacijah narejena avtomatično preusmeritev z besedilom:
              "Publikacija je bila premaknjena na drug naslov. Čez 3 sekunde boste preusmerjeni na" URL, ki se ga shrani.
              Idealno bi bilo, da bi imeli dvojne preusmeritve:
                - Če se digitalni objekt umakne iz repozitorija kam drugam, se naredi avtomatično preusmeritev s podobnim besedilom kot sedaj.
                - Če pa obstaja nova verzija digitalnega objekta (npr. dopolnjeni raziskovalni podatki, nova HTML predstavitev ipd.),
                  potem se pojavi popup, ki te vpraša, če se želiš, da te preusmeri k novi verziji.
              To bilo potrebno ustrezno označiti v METS XML.
            
            - Grega mora nujno narediti portal SIstory tako, da pri prikazu poljubnih HTML opisov pri publikacijah,
              ne bo več potrebno vse skupaj pisati v eno vrstico. Je že sedaj, v prihodnje pa bo še več problemov z dinamično pretvorbo.
    -->
    
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <!-- določi si, kje naj ustvari folderje z mets datetekami -->
    <xsl:param name="outputDir">/Users/administrator/Documents/moje/Sheme/sistory-mets/</xsl:param>
    
    
    <xsl:template match="sistory:root">
        <!-- zajamem podatke iz ekstra dokument, v katerega sem shranil podatke iz sistory frontendta, ki niso bili v SIstory XML Basic -->
        <xsl:variable name="menuDocument" select="concat('../pretvorba/menu',sistory:publication[1]/sistory:MENU_ID/@id,'-frontend.xml')"/>
        <xsl:variable name="frontends" select="document($menuDocument)"/>
        <xsl:for-each select="sistory:publication">
            <xsl:variable name="sistoryID" select="sistory:ID"/>
            <xsl:variable name="menuID" select="sistory:MENU_ID/@id"/>
            <xsl:variable name="extraData" select="$frontends/entity:root/entity:frontend[entity:id=$sistoryID]"/>
            <xsl:result-document href="{concat($outputDir,'menu',$menuID,'/',$sistoryID,'/mets.xml')}">
                <METS:mets xmlns:METS="http://www.loc.gov/METS/"
                    xmlns:xlink="http://www.w3.org/TR/xlink"
                    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                    xmlns:dc="http://purl.org/dc/elements/1.1/"
                    xmlns:dcterms="http://purl.org/dc/terms/" 
                    xmlns:dcmitype="http://purl.org/dc/dcmitype/"
                    xmlns:premis="http://www.loc.gov/standards/premis/v1"
                    xmlns:mods="http://www.loc.gov/mods/v3"
                    TYPE="entity"
                    ID="SISTORY.ID.{$sistoryID}" OBJID="http://hdl.handle.net/11686/{$sistoryID}"
                    xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/mets/mets.xsd http://purl.org/dc/terms/ http://dublincore.org/schemas/xmls/qdc/dcterms.xsd http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-0.xsd http://www.loc.gov/standards/premis/v1 http://www.loc.gov/standards/premis/v1/PREMIS-v1-1.xsd">
                    <METS:metsHdr CREATEDATE="{translate(sistory:DATETIME_ADDED,' ','T')}">
                        <xsl:if test="sistory:DATETIME_MODIFIED">
                            <xsl:attribute name="LASTMODDATE">
                                <xsl:value-of select="translate(sistory:DATETIME_MODIFIED,' ','T')"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:attribute name="RECORDSTATUS">
                            <xsl:choose>
                                <xsl:when test="number(sistory:STATUS) = 1">Active</xsl:when>
                                <xsl:otherwise>Inactive</xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <METS:agent ROLE="DISSEMINATOR" TYPE="ORGANIZATION">
                            <METS:name>Zgodovina Slovenije - SIstory</METS:name>
                        </METS:agent>
                        <METS:agent ROLE="CREATOR" ID="user.{sistory:USER_ID_ADDED}" TYPE="INDIVIDUAL">
                            <!-- Naredi seznam uporabnikov administracije in iz njega potegni podatke o uporabniku (Priimek, Ime) -->
                            <METS:name></METS:name>
                        </METS:agent>
                    </METS:metsHdr>
                    <METS:dmdSec ID="PREMIS.{$sistoryID}" GROUPID="{$sistoryID}">
                        <METS:mdWrap MDTYPE="PREMIS:OBJECT" MIMETYPE="text/xml">
                            <METS:xmlData>
                                <premis:object>
                                    <premis:objectIdentifier>
                                        <premis:objectIdentifierType>SIstory Entity ID</premis:objectIdentifierType>
                                        <premis:objectIdentifierValue>
                                            <xsl:value-of select="$sistoryID"/>
                                        </premis:objectIdentifierValue>
                                    </premis:objectIdentifier>
                                    <premis:objectIdentifier>
                                        <premis:objectIdentifierType>hdl</premis:objectIdentifierType>
                                        <premis:objectIdentifierValue>
                                            <xsl:text>http://hdl.handle.net/</xsl:text>
                                            <xsl:value-of select="sistory:URN"/>
                                        </premis:objectIdentifierValue>
                                    </premis:objectIdentifier>
                                    <premis:objectCategory>Entity</premis:objectCategory>
                                </premis:object>
                            </METS:xmlData>
                        </METS:mdWrap>
                    </METS:dmdSec>
                    <METS:dmdSec ID="DC.{$sistoryID}" GROUPID="{$sistoryID}">
                        <METS:mdWrap MDTYPE="DC" MIMETYPE="text/xml">
                            <METS:xmlData>
                                <xsl:apply-templates select="sistory:TITLE[@titleType='Title']"/>
                                <xsl:choose>
                                    <xsl:when test="sistory:TITLE[@titleType='Alternative Title'][@lang='eng'] and sistory:TITLE[@titleType='Sistory:Title'][@lang='eng']">
                                        <!-- Če imata oba ta elementa vpisan naslov v angleščini, potem ta naslov ni originalen metapodatek,
                                             temveč je napisan za predstavitvene potrebe portala SIstory. Zato sistory:Title ne mapiramo,
                                             od dcterms:alternative pa mapiramo samo neangleške naslove. -->
                                        <xsl:apply-templates select="sistory:TITLE[@titleType='Alternative Title']" mode="brez_anglescine"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates select="sistory:TITLE[@titleType='Sistory:Title']"/>
                                        <xsl:apply-templates select="sistory:TITLE[@titleType='Alternative Title']" mode="z_anglescino"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:apply-templates select="sistory:CREATOR"/>
                                <xsl:apply-templates select="sistory:CREATOR2"/>
                                <xsl:apply-templates select="sistory:DESCRIPTION[@descriptionType='Description']"/>
                                <xsl:apply-templates select="sistory:DESCRIPTION[@descriptionType='Abstracts']"/>
                                <xsl:apply-templates select="sistory:DESCRIPTION[@descriptionType='TableOfContents']"/>
                                <xsl:apply-templates select="sistory:SUBJECT[not(@subjectAttr)]"/>
                                <xsl:apply-templates select="sistory:SUBJECT[@subjectAttr='UDK']"/>
                                <xsl:apply-templates select="sistory:SUBJECT[@subjectAttr='ARRS']"/>
                                <xsl:apply-templates select="sistory:PUBLISHER"/>
                                <xsl:apply-templates select="sistory:CONTRIBUTOR"/>
                                <xsl:apply-templates select="sistory:DATE[@type='Date']"/>
                                <!-- ponekod je manjkal datum: v tem primeru pogledam, če je zapisan vsaj v YEAR polju -->
                                <xsl:if test="not(sistory:DATE[@type='Date'])  and sistory:YEAR">
                                    <dcterms:date xsi:type="dcterms:W3CDTF">
                                        <xsl:value-of select="sistory:YEAR"/>
                                    </dcterms:date>
                                </xsl:if>
                                <xsl:apply-templates select="sistory:DATE[@type='Date Created']"/>
                                <xsl:apply-templates select="sistory:DATE[@type='Date Valid']"/>
                                <xsl:apply-templates select="sistory:DATE[@type='Date Available']"/>
                                <xsl:apply-templates select="sistory:DATE[@type='Date Issued']"/>
                                <xsl:apply-templates select="sistory:DATE[@type='Date Modified']"/>
                                <xsl:apply-templates select="sistory:DATE[@type='Date Accepted']"/>
                                <xsl:apply-templates select="sistory:DATE[@type='Date Copyrighted']"/>
                                <xsl:apply-templates select="sistory:DATE[@type='Date Submited']"/>
                                <!-- sistory Type samo takrat, kadar ne obstaja dcterms:type -->
                                <xsl:choose>
                                    <xsl:when test="sistory:TYPE and sistory:TYPE_DC">
                                        <xsl:apply-templates select="sistory:TYPE_DC"/>
                                    </xsl:when>
                                    <xsl:when test="sistory:TYPE and not(sistory:TYPE_DC)">
                                        <xsl:apply-templates select="sistory:TYPE"/>
                                    </xsl:when>
                                    <xsl:when test="not(sistory:TYPE) and sistory:TYPE_DC">
                                        <xsl:apply-templates select="sistory:TYPE_DC"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:message>
                                            <xsl:text>Publikacija </xsl:text>
                                            <xsl:value-of select="sistory:ID"/>
                                            <xsl:text> nima označenega tipa (Type)</xsl:text>
                                        </xsl:message>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:apply-templates select="sistory:FORMAT[@formatType='Format']"/>
                                <xsl:apply-templates select="sistory:FORMAT[@formatType='Extent']"/>
                                <xsl:apply-templates select="sistory:FORMAT[@formatType='Medium']"/>
                                <xsl:apply-templates select="sistory:IDENTIFIER[@identifierType='Identifier']"/>
                                <!-- signaturo mapiram v dcterms:indentifier -->
                                <xsl:apply-templates select="sistory:IDENTIFIER[@identifierType='Sistory signatura']"/>
                                <xsl:apply-templates select="sistory:IDENTIFIER[@identifierType='Bibliographic citation']"/>
                                <xsl:apply-templates select="sistory:SOURCE[@sourceType='Source']"/>
                                <xsl:apply-templates select="sistory:LANGUAGE"/>
                                <xsl:if test="sistory:SOURCE[@sourceType='Vir - URN Naslov'] and not(contains(sistory:SOURCE[@sourceType='Vir - URN Naslov'],'SISTORY:ID:'))">
                                    <xsl:apply-templates select="sistory:SOURCE[@sourceType='Vir - URN Naslov']"/>
                                </xsl:if>
                                <xsl:apply-templates select="sistory:RELATION[@relationType='relation']"/>
                                <xsl:apply-templates select="sistory:RELATION[@relationType='isVersionOf']"/>
                                <xsl:apply-templates select="sistory:RELATION[@relationType='hasVersion']"/>
                                <xsl:apply-templates select="sistory:RELATION[@relationType='isReplacedBy']"/>
                                <xsl:apply-templates select="sistory:RELATION[@relationType='replaces']"/>
                                <xsl:apply-templates select="sistory:RELATION[@relationType='isRequiredBy']"/>
                                <xsl:apply-templates select="sistory:RELATION[@relationType='requires']"/>
                                <xsl:apply-templates select="sistory:RELATION[@relationType='isPartOf']"/>
                                <xsl:apply-templates select="sistory:RELATION[@relationType='hasPart']"/>
                                <xsl:apply-templates select="sistory:RELATION[@relationType='isReferencedBy']"/>
                                <xsl:apply-templates select="sistory:RELATION[@relationType='references']"/>
                                <xsl:apply-templates select="sistory:RELATION[@relationType='isFormatOf']"/>
                                <xsl:apply-templates select="sistory:RELATION[@relationType='hasFormat']"/>
                                <xsl:apply-templates select="sistory:RELATION[@relationType='conformsTo']"/>
                                <xsl:apply-templates select="sistory:COVERAGE[@coverageType='Coverage']"/>
                                <xsl:apply-templates select="sistory:COVERAGE[@coverageType='Spatial']"/>
                                <xsl:apply-templates select="sistory:COVERAGE[@coverageType='Temporal']"/>
                                <xsl:apply-templates select="sistory:COPYRIGHT"/>
                                <xsl:apply-templates select="sistory:RIGHTS[@rightsType='rights']"/>
                                <xsl:apply-templates select="sistory:RIGHTS[@rightsType='accessRights']"/>
                                <xsl:apply-templates select="sistory:RIGHTS[@rightsType='license']"/>
                                <xsl:apply-templates select="sistory:OTHER[@otherType='rightsHolder']"/>
                                <xsl:apply-templates select="sistory:AUDIENCE[@audienceType='audience']"/>
                                <xsl:apply-templates select="sistory:AUDIENCE[@audienceType='educationLevel']"/>
                                <xsl:apply-templates select="sistory:AUDIENCE[@audienceType='mediator']"/>
                                <xsl:apply-templates select="sistory:OTHER[@otherType='accrualMethod']"/>
                                <xsl:apply-templates select="sistory:OTHER[@otherType='accrualPeriodicity']"/>
                                <xsl:apply-templates select="sistory:OTHER[@otherType='accrualPolicy']"/>
                                <xsl:apply-templates select="sistory:OTHER[@otherType='instructionalMethod']"/>
                                <xsl:apply-templates select="sistory:OTHER[@otherType='provenance']"/>
                            </METS:xmlData>
                        </METS:mdWrap>
                    </METS:dmdSec>
                    <xsl:if test="sistory:COLLECTION">
                        <METS:dmdSec ID="MODS.{$sistoryID}" GROUPID="{$sistoryID}">
                            <METS:mdWrap MDTYPE="MODS" MIMETYPE="text/xml">
                                <METS:xmlData>
                                    <mods:relatedItem type="series">
                                        <mods:titleInfo>
                                            <mods:title>
                                                <xsl:value-of select="sistory:COLLECTION"/>
                                            </mods:title>
                                        </mods:titleInfo>
                                    </mods:relatedItem>
                                </METS:xmlData>
                            </METS:mdWrap>
                        </METS:dmdSec>
                    </xsl:if>
                    <!-- predvidevam, da sem do sedaj zapisal samo podatke o naslovu in opisu datotek (sem v resnici tudi avtorja datoteke, vendar zelo redko)  -->
                    <xsl:for-each select="sistory:PUBLICATION[sistory:ATTRIBUTE[@type=''] or sistory:ATTRIBUTE[@type='digitalDescription']]">
                        <xsl:variable name="fileName" select="@file"/>
                        <xsl:variable name="handle" select="$extraData/entity:files/entity:div/entity:aside/entity:div[entity:div[1][entity:div[entity:div[2][. = $fileName]]]]/entity:a/@href"/>
                        <xsl:variable name="fileID" select="tokenize($handle,'/')[last()]"/>
                        <METS:dmdSec ID="dmd-{$fileID}">
                            <METS:mdWrap MDTYPE="DC">
                                <METS:xmlData>
                                    <xsl:for-each select="sistory:ATTRIBUTE[@type='']">
                                        <dcterms:title>
                                            <xsl:value-of select="."/>
                                        </dcterms:title>
                                    </xsl:for-each>
                                    <xsl:for-each select="sistory:ATTRIBUTE[@type='digitalDescription']">
                                        <dcterms:description>
                                            <xsl:value-of select="."/>
                                        </dcterms:description>
                                    </xsl:for-each>
                                </METS:xmlData>
                            </METS:mdWrap>
                        </METS:dmdSec>
                    </xsl:for-each>
                    <xsl:if test="$extraData/entity:description_sl/entity:section or
                        $extraData/entity:description_en/entity:section or
                        number(sistory:PAGE) gt 0">
                        <METS:amdSec ID="amd-{$sistoryID}">
                            <METS:techMD ID="SISTORY.{$sistoryID}">
                                <METS:mdWrap MDTYPE="OTHER" OTHERMDTYPE="ENTITY" MIMETYPE="text/xml">
                                    <METS:xmlData  xmlns="http://sistory.si/schema/sistory/v3/entity" xsi:schemaLocation="http://sistory.si/schema/sistory/v3/entity ../../v3/sistory-entity.1.0.xsd">
                                        <xsl:if test="$extraData/entity:description_sl/entity:section">
                                            <description xml:lang="slv">
                                                <xsl:apply-templates select="$extraData/entity:description_sl/entity:section/entity:div/entity:ul/entity:li/entity:div/entity:div" mode="nodes"/>
                                            </description>
                                        </xsl:if>
                                        <xsl:if test="$extraData/entity:description_en/entity:section">
                                            <description xml:lang="eng">
                                                <xsl:apply-templates select="$extraData/entity:description_en/entity:section/entity:div/entity:ul/entity:li/entity:div/entity:div" mode="nodes"/>
                                            </description>
                                        </xsl:if>
                                        <xsl:if test="number(sistory:PAGE) gt 0">
                                            <page>
                                                <xsl:value-of select="sistory:PAGE"/>
                                            </page>
                                        </xsl:if>
                                    </METS:xmlData>
                                </METS:mdWrap>
                            </METS:techMD>
                        </METS:amdSec>
                    </xsl:if>
                    <!-- dodal sem podatke za video (trenutno samo youtube): -->
                    <xsl:variable name="youtube" select="$extraData/entity:files/entity:div/entity:aside/entity:div[@class='pub_file pub_link']/entity:div/entity:div[contains(entity:div[1],'Video:')]/entity:div[2]/entity:iframe/@src"/>
                    <xsl:if test="sistory:PUBLICATION or sistory:IMAGE or sistory:LINK or string-length($youtube) gt 0">
                        <METS:fileSec xmlns:xlink="http://www.w3.org/1999/xlink">
                            <xsl:if test="sistory:IMAGE">
                                <METS:fileGrp USE="THUMB">
                                    <METS:file ID="thumbnail">
                                        <METS:FLocat LOCTYPE="URL">
                                            <xsl:attribute name="xlink:href">
                                                <xsl:value-of select="concat('http://www.sistory.si/cdn/publikacije/',(xs:integer(round(number($sistoryID)) div 1000) * 1000) + 1,'-',(xs:integer(round(number($sistoryID)) div 1000) * 1000) + 1000,'/',$sistoryID,'/',sistory:IMAGE)"/>
                                            </xsl:attribute>
                                        </METS:FLocat>
                                    </METS:file>
                                </METS:fileGrp>
                            </xsl:if>
                            <xsl:if test="sistory:PUBLICATION or sistory:LINK or string-length($youtube) gt 0">
                                <METS:fileGrp USE="DEFAULT">
                                    <xsl:if test="sistory:LINK">
                                        <METS:file ID="external1" USE="EXTERNAL">
                                            <METS:FLocat USE="HTTP" LOCTYPE="URL" xlink:href="{sistory:LINK}"/>
                                        </METS:file>
                                    </xsl:if>
                                    <xsl:if test="string-length($youtube) gt 0">
                                        <METS:file ID="video1" USE="EXTERNAL">
                                            <METS:FLocat USE="YOUTUBE" LOCTYPE="URL" xlink:href="{$youtube}"/>
                                        </METS:file>
                                    </xsl:if>
                                    <xsl:for-each select="sistory:PUBLICATION">
                                        <xsl:variable name="fileName" select="@file"/>
                                        <xsl:variable name="handle" select="$extraData/entity:files/entity:div/entity:aside/entity:div[entity:div[1][entity:div[entity:div[2][. = $fileName]]]]/entity:a/@href"/>
                                        <xsl:variable name="fileID" select="tokenize($handle,'/')[last()]"/>
                                        <METS:file ID="{$fileID}" OWNERID="{$fileName}" MIMETYPE="{sistory:ATTRIBUTE[@type='digitalFormat']}">
                                            <xsl:if test="sistory:ATTRIBUTE[@type=''] or sistory:ATTRIBUTE[@type='digitalDescription']">
                                                <xsl:attribute name="DMDID">
                                                    <xsl:value-of select="concat('dmd-',$fileID)"/>
                                                </xsl:attribute>
                                            </xsl:if>
                                            <METS:FLocat LOCTYPE="HANDLE" xlink:href="https://hdl.handle.net/11686/{$fileID}"/>
                                        </METS:file>
                                    </xsl:for-each>
                                </METS:fileGrp>
                            </xsl:if>
                        </METS:fileSec>
                    </xsl:if>
                    <METS:structMap TYPE="logical" LABEL="sistory" xmlns:xlink="http://www.w3.org/1999/xlink">
                        <!-- najprej meni -->
                        <METS:div>
                            <METS:mptr LOCTYPE="HANDLE" xlink:href="http://hdl.handle.net/11686/menu{$menuID}"/>
                            <xsl:choose>
                                <!-- samostojna publikacija znotraj menija -->
                                <xsl:when test="not(sistory:PARENT) and not(sistory:CHILDREN)">
                                    <METS:div DMDID="DC.{$sistoryID}">
                                        <xsl:if test="sistory:IMAGE">
                                            <METS:fptr FILEID="thumbnail"/>
                                        </xsl:if>
                                        <xsl:if test="sistory:LINK">
                                            <METS:fptr FILEID="external1"/>
                                        </xsl:if>
                                        <xsl:if test="string-length($youtube) gt 0">
                                            <METS:fptr FILEID="video1"/>
                                        </xsl:if>
                                        <xsl:for-each select="sistory:PUBLICATION">
                                            <xsl:variable name="fileName" select="@file"/>
                                            <xsl:variable name="handle" select="$extraData/entity:files/entity:div/entity:aside/entity:div[entity:div[1][entity:div[entity:div[2][. = $fileName]]]]/entity:a/@href"/>
                                            <xsl:variable name="fileID" select="tokenize($handle,'/')[last()]"/>
                                            <METS:fptr FILEID="{$fileID}"/>
                                        </xsl:for-each>
                                    </METS:div>
                                </xsl:when>
                                <!-- če je sam parent, ki ima child publikacije -->
                                <xsl:when test="sistory:CHILDREN and not(sistory:PARENT)">
                                    <METS:div DMDID="DC.{$sistoryID}">
                                        <xsl:if test="sistory:IMAGE">
                                            <METS:fptr FILEID="thumbnail"/>
                                        </xsl:if>
                                        <xsl:if test="sistory:LINK">
                                            <METS:fptr FILEID="external1"/>
                                        </xsl:if>
                                        <xsl:if test="string-length($youtube) gt 0">
                                            <METS:fptr FILEID="video1"/>
                                        </xsl:if>
                                        <xsl:for-each select="sistory:PUBLICATION">
                                            <xsl:variable name="fileName" select="@file"/>
                                            <xsl:variable name="handle" select="$extraData/entity:files/entity:div/entity:aside/entity:div[entity:div[1][entity:div[entity:div[2][. = $fileName]]]]/entity:a/@href"/>
                                            <xsl:variable name="fileID" select="tokenize($handle,'/')[last()]"/>
                                            <METS:fptr FILEID="{$fileID}"/>
                                        </xsl:for-each>
                                        <!-- dodamo povezave na child publikacije -->
                                        <xsl:for-each select="sistory:CHILDREN/sistory:CHILD">
                                            <METS:div>
                                                <METS:mptr LOCTYPE="HANDLE" xlink:href="http://hdl.handle.net/11686/{.}"/>
                                            </METS:div>
                                        </xsl:for-each>
                                    </METS:div>
                                </xsl:when>
                                <!-- če je child publikacija -->
                                <xsl:when test="sistory:PARENT and not(sistory:CHILDREN)">
                                    <xsl:variable name="parentSIstoryID" select="sistory:PARENT"/>
                                    <xsl:choose>
                                        <!-- če je njegov parent tudi child od nekoga -->
                                        <xsl:when test="ancestor::sistory:root/sistory:publication[sistory:ID=$parentSIstoryID]/sistory:PARENT">
                                            <!-- dodamo najprej parenta od njegovega parenta -->
                                            <METS:div>
                                                <METS:mptr LOCTYPE="HANDLE" xlink:href="http://hdl.handle.net/11686/{ancestor::sistory:root/sistory:publication[sistory:ID=$parentSIstoryID]/sistory:PARENT}"/>
                                                <!-- potem dodamo njegovega parenta -->
                                                <METS:div>
                                                    <METS:mptr LOCTYPE="HANDLE" xlink:href="http://hdl.handle.net/11686/{sistory:PARENT}"/>
                                                    <!-- potem pa dodamo podatke o tej child publikaciji -->
                                                    <METS:div DMDID="DC.{$sistoryID}">
                                                        <xsl:if test="sistory:IMAGE">
                                                            <METS:fptr FILEID="thumbnail"/>
                                                        </xsl:if>
                                                        <xsl:if test="sistory:LINK">
                                                            <METS:fptr FILEID="external1"/>
                                                        </xsl:if>
                                                        <xsl:if test="string-length($youtube) gt 0">
                                                            <METS:fptr FILEID="video1"/>
                                                        </xsl:if>
                                                        <xsl:for-each select="sistory:PUBLICATION">
                                                            <xsl:variable name="fileName" select="@file"/>
                                                            <xsl:variable name="handle" select="$extraData/entity:files/entity:div/entity:aside/entity:div[entity:div[1][entity:div[entity:div[2][. = $fileName]]]]/entity:a/@href"/>
                                                            <xsl:variable name="fileID" select="tokenize($handle,'/')[last()]"/>
                                                            <METS:fptr FILEID="{$fileID}"/>
                                                        </xsl:for-each>
                                                    </METS:div>
                                                </METS:div>
                                            </METS:div>
                                        </xsl:when>
                                        <!-- drugače je njegov parent primarna entieta -->
                                        <xsl:otherwise>
                                            <!-- dodamo njegovega parenta -->
                                            <METS:div>
                                                <METS:mptr LOCTYPE="HANDLE" xlink:href="http://hdl.handle.net/11686/{sistory:PARENT}"/>
                                                <!-- potem pa dodamo podatke o tej child publikaciji -->
                                                <METS:div DMDID="DC.{$sistoryID}">
                                                    <xsl:if test="sistory:IMAGE">
                                                        <METS:fptr FILEID="thumbnail"/>
                                                    </xsl:if>
                                                    <xsl:if test="sistory:LINK">
                                                        <METS:fptr FILEID="external1"/>
                                                    </xsl:if>
                                                    <xsl:if test="string-length($youtube) gt 0">
                                                        <METS:fptr FILEID="video1"/>
                                                    </xsl:if>
                                                    <xsl:for-each select="sistory:PUBLICATION">
                                                        <xsl:variable name="fileName" select="@file"/>
                                                        <xsl:variable name="handle" select="$extraData/entity:files/entity:div/entity:aside/entity:div[entity:div[1][entity:div[entity:div[2][. = $fileName]]]]/entity:a/@href"/>
                                                        <xsl:variable name="fileID" select="tokenize($handle,'/')[last()]"/>
                                                        <METS:fptr FILEID="{$fileID}"/>
                                                    </xsl:for-each>
                                                </METS:div>
                                            </METS:div>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <!-- če je child publikacija, ki ima svoje child publikacije -->
                                <xsl:when test="sistory:PARENT and sistory:CHILDREN">
                                    <!-- dodamo njegovega parenta -->
                                    <METS:div>
                                        <METS:mptr LOCTYPE="HANDLE" xlink:href="http://hdl.handle.net/11686/{sistory:PARENT}"/>
                                        <!-- potem pa dodamo podatke o tej child publikaciji -->
                                        <METS:div DMDID="DC.{$sistoryID}">
                                            
                                            <xsl:if test="sistory:IMAGE">
                                                <METS:fptr FILEID="thumbnail"/>
                                            </xsl:if>
                                            <xsl:if test="sistory:LINK">
                                                <METS:fptr FILEID="external1"/>
                                            </xsl:if>
                                            <xsl:if test="string-length($youtube) gt 0">
                                                <METS:fptr FILEID="video1"/>
                                            </xsl:if>
                                            <xsl:for-each select="sistory:PUBLICATION">
                                                <xsl:variable name="fileName" select="@file"/>
                                                <xsl:variable name="handle" select="$extraData/entity:files/entity:div/entity:aside/entity:div[entity:div[1][entity:div[entity:div[2][. = $fileName]]]]/entity:a/@href"/>
                                                <xsl:variable name="fileID" select="tokenize($handle,'/')[last()]"/>
                                                <METS:fptr FILEID="{$fileID}"/>
                                            </xsl:for-each>
                                            <!-- dodamo povezave na child publikacije -->
                                            <xsl:for-each select="sistory:CHILDREN/sistory:CHILD">
                                                <METS:div>
                                                    <METS:mptr LOCTYPE="HANDLE" xlink:href="http://hdl.handle.net/11686/{.}"/>
                                                </METS:div>
                                            </xsl:for-each>
                                        </METS:div>
                                    </METS:div>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:message>
                                        <xsl:text>Ne morem procesirati METS:structMap publikacije </xsl:text>
                                        <xsl:value-of select="$sistoryID"/>
                                    </xsl:message>
                                </xsl:otherwise>
                            </xsl:choose>
                        </METS:div>
                    </METS:structMap>
                </METS:mets>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="entity:div[contains(@style,'max-width:75rem')]" mode="nodes">
        <xsl:apply-templates mode="nodes"/>
    </xsl:template>
    
    <xsl:template match="@* | node()" mode="nodes">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="nodes"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="sistory:TYPE">
        <dcterms:type xsi:type="dcterms:DCMIType">
            <xsl:choose>
                <xsl:when test="contains(.,'Besedilo')">Text</xsl:when>
                <xsl:when test="contains(.,'Povezava')">
                    <xsl:message>
                        <xsl:text>Pri publikaciji </xsl:text>
                        <xsl:value-of select="../sistory:ID"/>
                        <xsl:text> še vedno obstaja Povezava SIstory Type</xsl:text>
                    </xsl:message>
                </xsl:when>
                <xsl:when test="contains(.,'Slika')">StillImage</xsl:when>
                <xsl:when test="contains(.,'Video')">MovingImage</xsl:when>
                <xsl:when test="contains(.,'Avdio')">Sound</xsl:when>
                <xsl:when test="contains(.,'Prezentacija')">Event</xsl:when>
                <xsl:when test="contains(.,'Sistem')">Text</xsl:when>
                <xsl:when test="contains(.,'Analogno')">PhysicalObject</xsl:when>
            </xsl:choose>
        </dcterms:type>
    </xsl:template>
    <xsl:template match="sistory:TYPE_DC">
        <dcterms:type xsi:type="dcterms:DCMIType">
            <xsl:value-of select=" translate(@title,' ','')"/>
        </dcterms:type>
    </xsl:template>
    
    <!-- title skupina -->
    <xsl:template match="sistory:TITLE[@titleType='Title']">
        <dcterms:title xml:lang="{@lang}">
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:title>
    </xsl:template>
    <xsl:template match="sistory:TITLE[@titleType='Sistory:Title']">
        <dcterms:alternative xml:lang="eng">
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:alternative>
    </xsl:template>
    <xsl:template match="sistory:TITLE[@titleType='Alternative Title']" mode="z_anglescino">
        <dcterms:alternative xml:lang="{@lang}">
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:alternative>
    </xsl:template>
    <xsl:template match="sistory:TITLE[@titleType='Alternative Title']" mode="brez_anglescine">
        <xsl:if test=".[@lang!='eng']">
            <dcterms:alternative xml:lang="{@lang}">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:alternative>
        </xsl:if>
    </xsl:template>
    
    <!-- avtorji / ustvarjalci -->
    <xsl:template match="sistory:CREATOR">
        <dcterms:creator>
            <xsl:value-of select="concat(sistory:PRIIMEK,', ',sistory:IME)"/>
        </dcterms:creator>
    </xsl:template>
    <xsl:template match="sistory:CREATOR2">
        <dcterms:creator xml:lang="{@lang}">
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:creator>
    </xsl:template>
    
    <!-- Description -->
    <xsl:template match="sistory:DESCRIPTION[@descriptionType='Description']">
        <dcterms:description xml:lang="{@lang}">
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:description>
    </xsl:template>
    <xsl:template match="sistory:DESCRIPTION[@descriptionType='Abstracts']">
        <dcterms:abstract xml:lang="{@lang}">
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:abstract>
    </xsl:template>
    <xsl:template match="sistory:DESCRIPTION[@descriptionType='TableOfContents']">
        <dcterms:tableOfContents xml:lang="{@lang}">
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:tableOfContents>
    </xsl:template>
    
    <xsl:template match="sistory:SUBJECT[not(@subjectAttr)]">
        <dcterms:subject xml:lang="{@lang}">
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:subject>
    </xsl:template>
    <xsl:template match="sistory:SUBJECT[@subjectAttr='ARRS']">
        <dcterms:subject xml:lang="slv">
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:subject>
    </xsl:template>
    <xsl:template match="sistory:SUBJECT[@subjectAttr='UDK']">
        <dcterms:subject xsi:type="dcterms:UDC">
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:subject>
    </xsl:template>
    
    <xsl:template match="sistory:PUBLISHER">
        <dcterms:publisher>
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:publisher>
    </xsl:template>
    
    <xsl:template match="sistory:CONTRIBUTOR">
        <dcterms:contributor>
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:contributor>
    </xsl:template>
    
    <!-- začetek dateGroup -->
    <xsl:template match="sistory:DATE[@type='Date'][not(@format)]">
        <xsl:choose>
            <xsl:when test="string-length(.) = 4 and matches(.,'\d{4}')">
                <dcterms:date xsi:type="dcterms:W3CDTF">
                    <xsl:value-of select="normalize-space(.)"/>
                </dcterms:date>
            </xsl:when>
            <xsl:otherwise>
                <dcterms:date>
                    <xsl:value-of select="normalize-space(.)"/>
                </dcterms:date>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="sistory:DATE[@type='Date'][@format='W3CDTF']">
        <xsl:choose>
            <xsl:when test="contains(., '-01-01')">
                <dcterms:date xsi:type="dcterms:W3CDTF">
                    <xsl:value-of select="substring-before(.,'-')"/>
                </dcterms:date>
            </xsl:when>
            <xsl:otherwise>
                <dcterms:date xsi:type="dcterms:W3CDTF">
                    <xsl:value-of select="normalize-space(.)"/>
                </dcterms:date>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="sistory:DATE[@type='Date'][@format='Period']">
        <dcterms:date xsi:type="dcterms:Period">
            <xsl:apply-templates select="sistory:START"/><xsl:apply-templates select="sistory:END"/><xsl:apply-templates select="sistory:NAME"/><xsl:apply-templates select="sistory:SCHEME"/>
        </dcterms:date>
    </xsl:template>
    
    <xsl:template match="sistory:DATE[@type='Date Created'][@format='W3CDTF']">
        <xsl:choose>
            <xsl:when test="contains(., '-01-01')">
                <dcterms:created xsi:type="dcterms:W3CDTF">
                    <xsl:value-of select="substring-before(.,'-')"/>
                </dcterms:created>
            </xsl:when>
            <xsl:otherwise>
                <dcterms:created xsi:type="dcterms:W3CDTF">
                    <xsl:value-of select="normalize-space(.)"/>
                </dcterms:created>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Za pravilno formatiranje zapisa datuma obdobja v DC.
         V sistory bazi ima namreč vsaka vrednost svoje polje, v DC jih je potrebno združiti v en zapis, npr. start=2000; end=2000; name=ime; scheme=0; -->
    <xsl:template match="sistory:DATE[@type='Date Created'][@format='Period']">
        <dcterms:created xsi:type="dcterms:Period">
            <xsl:apply-templates select="sistory:START"/><xsl:apply-templates select="sistory:END"/><xsl:apply-templates select="sistory:NAME"/><xsl:apply-templates select="sistory:SCHEME"/>
        </dcterms:created>
    </xsl:template>
    
    <xsl:template match="sistory:DATE[@type='Date Valid']">
        <xsl:if test="@format='W3CDTF'">
            <xsl:choose>
                <xsl:when test="contains(., '-01-01')">
                    <dcterms:valid xsi:type="dcterms:W3CDTF">
                        <xsl:value-of select="substring-before(.,'-')"/>
                    </dcterms:valid>
                </xsl:when>
                <xsl:otherwise>
                    <dcterms:valid xsi:type="dcterms:W3CDTF">
                        <xsl:value-of select="normalize-space(.)"/>
                    </dcterms:valid>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="@format='Period'">
            <dcterms:valid xsi:type="dcterms:Period">
                <xsl:apply-templates select="sistory:START"/><xsl:apply-templates select="sistory:END"/><xsl:apply-templates select="sistory:NAME"/><xsl:apply-templates select="sistory:SCHEME"/>
            </dcterms:valid>
        </xsl:if>
        <xsl:if test="not(@format)">
            <dcterms:valid>
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:valid>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="sistory:DATE[@type='Date Available']">
        <xsl:if test="@format='W3CDTF'">
            <xsl:choose>
                <xsl:when test="contains(., '-01-01')">
                    <dcterms:available xsi:type="dcterms:W3CDTF">
                        <xsl:value-of select="substring-before(.,'-')"/>
                    </dcterms:available>
                </xsl:when>
                <xsl:otherwise>
                    <dcterms:available xsi:type="dcterms:W3CDTF">
                        <xsl:value-of select="normalize-space(.)"/>
                    </dcterms:available>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="@format='Period'">
            <dcterms:available xsi:type="dcterms:Period">
                <xsl:apply-templates select="sistory:START"/><xsl:apply-templates select="sistory:END"/><xsl:apply-templates select="sistory:NAME"/><xsl:apply-templates select="sistory:SCHEME"/>
            </dcterms:available>
        </xsl:if>
        <xsl:if test="not(@format)">
            <dcterms:available>
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:available>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="sistory:DATE[@type='Date Issued'][@format='W3CDTF']">
        <xsl:choose>
            <xsl:when test="contains(., '-01-01')">
                <dcterms:issued xsi:type="dcterms:W3CDTF">
                    <xsl:value-of select="substring-before(.,'-')"/>
                </dcterms:issued>
            </xsl:when>
            <xsl:otherwise>
                <dcterms:issued xsi:type="dcterms:W3CDTF">
                    <xsl:value-of select="normalize-space(.)"/>
                </dcterms:issued>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="sistory:DATE[@type='Date Issued'][@format='Period']">
        <dcterms:available xsi:type="dcterms:Period">
            <xsl:apply-templates select="sistory:START"/><xsl:apply-templates select="sistory:END"/><xsl:apply-templates select="sistory:NAME"/><xsl:apply-templates select="sistory:SCHEME"/>
        </dcterms:available>
    </xsl:template>
    
    <xsl:template match="sistory:DATE[@type='Date Modified']">
        <xsl:if test="@format='Period'">
            <dcterms:modified xsi:type="dcterms:Period">
                <xsl:apply-templates select="sistory:START"/><xsl:apply-templates select="sistory:END"/><xsl:apply-templates select="sistory:NAME"/><xsl:apply-templates select="sistory:SCHEME"/>
            </dcterms:modified>
        </xsl:if>
        <xsl:if test="@format='W3CDTF'">
            <xsl:choose>
                <xsl:when test="contains(., '-01-01')">
                    <dcterms:modified xsi:type="dcterms:W3CDTF">
                        <xsl:value-of select="substring-before(.,'-')"/>
                    </dcterms:modified>
                </xsl:when>
                <xsl:otherwise>
                    <dcterms:modified xsi:type="dcterms:W3CDTF">
                        <xsl:value-of select="normalize-space(.)"/>
                    </dcterms:modified>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="not(@format)">
            <dcterms:modified>
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:modified>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="sistory:DATE[@type='Date Accepted']">
        <xsl:if test="@format='W3CDTF'">
            <xsl:choose>
                <xsl:when test="contains(., '-01-01')">
                    <dcterms:dateAccepted xsi:type="dcterms:W3CDTF">
                        <xsl:value-of select="substring-before(.,'-')"/>
                    </dcterms:dateAccepted>
                </xsl:when>
                <xsl:otherwise>
                    <dcterms:dateAccepted xsi:type="dcterms:W3CDTF">
                        <xsl:value-of select="normalize-space(.)"/>
                    </dcterms:dateAccepted>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="not(@format)">
            <dcterms:dateAccepted>
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:dateAccepted>
        </xsl:if>
    </xsl:template>
    <xsl:template match="sistory:DATE[@type='Date Copyrighted']">
        <xsl:if test="@format='W3CDTF'">
            <xsl:choose>
                <xsl:when test="contains(., '-01-01')">
                    <dcterms:dateCopyrighted xsi:type="dcterms:W3CDTF">
                        <xsl:value-of select="substring-before(.,'-')"/>
                    </dcterms:dateCopyrighted>
                </xsl:when>
                <xsl:otherwise>
                    <dcterms:dateCopyrighted xsi:type="dcterms:W3CDTF">
                        <xsl:value-of select="normalize-space(.)"/>
                    </dcterms:dateCopyrighted>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="@format='Period'">
            <dcterms:dateCopyrighted xsi:type="dcterms:Period">
                <xsl:apply-templates select="sistory:START"/><xsl:apply-templates select="sistory:END"/><xsl:apply-templates select="sistory:NAME"/><xsl:apply-templates select="sistory:SCHEME"/>
            </dcterms:dateCopyrighted>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="sistory:DATE[@type='Date Submited']">
        <xsl:if test="@format='W3CDTF'">
            <xsl:choose>
                <xsl:when test="contains(., '-01-01')">
                    <dcterms:dateSubmitted xsi:type="dcterms:W3CDTF">
                        <xsl:value-of select="substring-before(.,'-')"/>
                    </dcterms:dateSubmitted>
                </xsl:when>
                <xsl:otherwise>
                    <dcterms:dateSubmitted xsi:type="dcterms:W3CDTF">
                        <xsl:value-of select="normalize-space(.)"/>
                    </dcterms:dateSubmitted>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="sistory:START">
        <xsl:value-of select="concat('start=',.,'; ')"/>
    </xsl:template>
    <xsl:template match="sistory:END">
        <xsl:value-of select="concat('end=',.,'; ')"/>
    </xsl:template>
    <xsl:template match="sistory:NAME">
        <xsl:value-of select="concat('name=',.,'; ')"/>
    </xsl:template>
    <xsl:template match="sistory:SCHEME">
        <xsl:value-of select="concat('scheme=',.,'; ')"/>
    </xsl:template>
    
    <!-- začetek format skupine -->
    <xsl:template match="sistory:FORMAT[@formatType='Format']">
        <xsl:choose>
            <xsl:when test="@formatAttr='IMT'">
                <dcterms:format xsi:type="dcterms:IMT">
                    <xsl:value-of select="normalize-space(.)"/>
                </dcterms:format>
            </xsl:when>
            <xsl:otherwise>
                <dcterms:format>
                    <xsl:value-of select="normalize-space(.)"/>
                </dcterms:format>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="sistory:FORMAT[@formatType='Extent']">
        <dcterms:extent>
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:extent>
    </xsl:template>
    <xsl:template match="sistory:FORMAT[@formatType='Medium']">
        <dcterms:medium>
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:medium>
    </xsl:template>
    
    <!-- začete identifier skupine -->
    <xsl:template match="sistory:IDENTIFIER[@identifierType='Identifier']">
        <dcterms:identifier>
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:identifier>
    </xsl:template>
    <xsl:template match="sistory:IDENTIFIER[@identifierType='Sistory signatura']">
        <dcterms:identifier>
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:identifier>
    </xsl:template>
    <xsl:template match="sistory:IDENTIFIER[@identifierType='Bibliographic citation']">
        <dcterms:bibliographicCitation>
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:bibliographicCitation>
    </xsl:template>
    
    <!-- source -->
    <xsl:template match="sistory:SOURCE[@sourceType='Vir - URN Naslov']">
        <dcterms:source xsi:type="dcterms:URI">
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:source>
    </xsl:template>
    <xsl:template match="sistory:SOURCE[@sourceType='Source']">
        <xsl:if test="@sourceAttr='xml:lang'">
            <dcterms:source xml:lang="{@lang}">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:source>
        </xsl:if>
        <xsl:if test="@sourceAttr='URI'">
            <dcterms:source xsi:type="dcterms:URI">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:source>
        </xsl:if>
    </xsl:template>
    
    <!-- language -->
    <xsl:template match="sistory:LANGUAGE">
        <dcterms:language xsi:type="dcterms:ISO639-3">
            <xsl:value-of select="@lang"/>
        </dcterms:language>
    </xsl:template>
    
    <!-- začetek relation skupine -->
    <xsl:template match="sistory:RELATION[@relationType='relation']">
        <xsl:if test="@relationAttr='xml:lang'">
            <dcterms:relation xml:lang="{@lang}">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:relation>
        </xsl:if>
        <xsl:if test="@relationAttr='URI'">
            <dcterms:relation xsi:type="dcterms:URI">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:relation>
        </xsl:if>
    </xsl:template>
    <xsl:template match="sistory:RELATION[@relationType='isVersionOf']">
        <xsl:if test="@relationAttr='xml:lang'">
            <dcterms:isVersionOf xml:lang="{@lang}">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:isVersionOf>
        </xsl:if>
        <xsl:if test="@relationAttr='URI'">
            <dcterms:isVersionOf xsi:type="dcterms:URI">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:isVersionOf>
        </xsl:if>
    </xsl:template>
    <xsl:template match="sistory:RELATION[@relationType='hasVersion']">
        <xsl:if test="@relationAttr='xml:lang'">
            <dcterms:hasVersion xml:lang="{@lang}">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:hasVersion>
        </xsl:if>
        <xsl:if test="@relationAttr='URI'">
            <dcterms:hasVersion xsi:type="dcterms:URI">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:hasVersion>
        </xsl:if>
    </xsl:template>
    <xsl:template match="sistory:RELATION[@relationType='isReplacedBy']">
        <xsl:if test="@relationAttr='xml:lang'">
            <dcterms:isReplacedBy xml:lang="{@lang}">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:isReplacedBy>
        </xsl:if>
        <xsl:if test="@relationAttr='URI'">
            <dcterms:isReplacedBy xsi:type="dcterms:URI">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:isReplacedBy>
        </xsl:if>
    </xsl:template>
    <xsl:template match="sistory:RELATION[@relationType='replaces']">
        <xsl:if test="@relationAttr='xml:lang'">
            <dcterms:replaces xml:lang="{@lang}">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:replaces>
        </xsl:if>
        <xsl:if test="@relationAttr='URI'">
            <dcterms:replaces xsi:type="dcterms:URI">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:replaces>
        </xsl:if>
    </xsl:template>
    <xsl:template match="sistory:RELATION[@relationType='isRequiredBy']">
        <xsl:if test="@relationAttr='xml:lang'">
            <dcterms:isRequiredBy xml:lang="{@lang}">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:isRequiredBy>
        </xsl:if>
        <xsl:if test="@relationAttr='URI'">
            <dcterms:isRequiredBy xsi:type="dcterms:URI">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:isRequiredBy>
        </xsl:if>
    </xsl:template>
    <xsl:template match="sistory:RELATION[@relationType='requires']">
        <xsl:if test="@relationAttr='xml:lang'">
            <dcterms:requires xml:lang="{@lang}">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:requires>
        </xsl:if>
        <xsl:if test="@relationAttr='URI'">
            <dcterms:requires xsi:type="dcterms:URI">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:requires>
        </xsl:if>
    </xsl:template>
    <xsl:template match="sistory:RELATION[@relationType='isPartOf']">
        <xsl:if test="@relationAttr='xml:lang'">
            <dcterms:isPartOf xml:lang="{@lang}">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:isPartOf>
        </xsl:if>
        <xsl:if test="@relationAttr='URI'">
            <dcterms:isPartOf xsi:type="dcterms:URI">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:isPartOf>
        </xsl:if>
    </xsl:template>
    <xsl:template match="sistory:RELATION[@relationType='hasPart']">
        <xsl:if test="@relationAttr='xml:lang'">
            <dcterms:hasPart xml:lang="{@lang}">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:hasPart>
        </xsl:if>
        <xsl:if test="@relationAttr='URI'">
            <dcterms:hasPart xsi:type="dcterms:URI">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:hasPart>
        </xsl:if>
    </xsl:template>
    <xsl:template match="sistory:RELATION[@relationType='isReferencedBy']">
        <xsl:if test="@relationAttr='xml:lang'">
            <dcterms:isReferencedBy xml:lang="{@lang}">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:isReferencedBy>
        </xsl:if>
        <xsl:if test="@relationAttr='URI'">
            <dcterms:isReferencedBy xsi:type="dcterms:URI">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:isReferencedBy>
        </xsl:if>
    </xsl:template>
    <xsl:template match="sistory:RELATION[@relationType='references']">
        <xsl:if test="@relationAttr='xml:lang'">
            <dcterms:references xml:lang="{@lang}">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:references>
        </xsl:if>
        <xsl:if test="@relationAttr='URI'">
            <dcterms:references xsi:type="dcterms:URI">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:references>
        </xsl:if>
    </xsl:template>
    <xsl:template match="sistory:RELATION[@relationType='isFormatOf']">
        <xsl:if test="@relationAttr='xml:lang'">
            <dcterms:isFormatOf xml:lang="{@lang}">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:isFormatOf>
        </xsl:if>
        <xsl:if test="@relationAttr='URI'">
            <dcterms:isFormatOf xsi:type="dcterms:URI">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:isFormatOf>
        </xsl:if>
    </xsl:template>
    <xsl:template match="sistory:RELATION[@relationType='hasFormat']">
        <xsl:if test="@relationAttr='xml:lang'">
            <dcterms:hasFormat xml:lang="{@lang}">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:hasFormat>
        </xsl:if>
        <xsl:if test="@relationAttr='URI'">
            <dcterms:hasFormat xsi:type="dcterms:URI">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:hasFormat>
        </xsl:if>
    </xsl:template>
    <xsl:template match="sistory:RELATION[@relationType='conformsTo']">
        <xsl:if test="@relationAttr='xml:lang'">
            <dcterms:conformsTo xml:lang="{@lang}">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:conformsTo>
        </xsl:if>
        <xsl:if test="@relationAttr='URI'">
            <dcterms:conformsTo xsi:type="dcterms:URI">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:conformsTo>
        </xsl:if>
    </xsl:template>
    
    <!-- začetek coverageGroup -->
    <xsl:template match="sistory:COVERAGE[@coverageType='Coverage']">
        <dcterms:coverage xml:lang="{@lang}">
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:coverage>
    </xsl:template>
    <xsl:template match="sistory:COVERAGE[@coverageType='Spatial']">
        <xsl:if test="@attr=''">
            <dcterms:spatial>
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:spatial>
        </xsl:if>
        <xsl:if test="@attr='Box'">
            <dcterms:spatial xsi:type="dcterms:Box">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:spatial>
        </xsl:if>
        <xsl:if test="@attr='Point'">
            <dcterms:spatial xsi:type="dcterms:Point">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:spatial>
        </xsl:if>
        <xsl:if test="@attr='ISO-3166'">
            <dcterms:spatial xsi:type="dcterms:ISO3166">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:spatial>
        </xsl:if>
    </xsl:template>
    <xsl:template match="sistory:COVERAGE[@coverageType='Temporal']">
        <xsl:if test="@format='Period'">
            <dcterms:temporal xsi:type="dcterms:Period">
                <xsl:apply-templates select="START"/><xsl:apply-templates select="END"/><xsl:apply-templates select="NAME"/><xsl:apply-templates select="SCHEME"/>
            </dcterms:temporal>
        </xsl:if>
        <xsl:if test="@format='W3CDTF'">
            <xsl:choose>
                <xsl:when test="contains(., '-01-01')">
                    <dcterms:temporal xsi:type="dcterms:W3CDTF">
                        <xsl:value-of select="substring-before(.,'-')"/>
                    </dcterms:temporal>
                </xsl:when>
                <xsl:otherwise>
                    <dcterms:temporal xsi:type="dcterms:W3CDTF">
                        <xsl:value-of select="normalize-space(.)"/>
                    </dcterms:temporal>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <!-- avtorske pravice -->
    <!-- iz morebitne html kode avtorske pravice razberi, če je ena od Creative Commons licenc in jih mapiraj v ustrezen DC element -->
    <xsl:template match="sistory:COPYRIGHT">
        <xsl:choose>
            <xsl:when test="contains(.,'nima soglasja')">
                <dcterms:rights xml:lang="slv">
                    <xsl:text>© </xsl:text>
                    <xsl:for-each select="../sistory:CREATOR">
                        <xsl:value-of select="concat(sistory:IME,' ',sistory:PRIIMEK)"/>
                        <xsl:if test="position() != last()">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:text> (Uredništvo portala SIstory nima soglasja avtorja za objavo dela.)</xsl:text>
                </dcterms:rights>
            </xsl:when>
            <xsl:when test="contains(.,'/by/4.0/')">
                <dcterms:license xsi:type="dcterms:URI">https://creativecommons.org/licenses/by/4.0/</dcterms:license>
            </xsl:when>
            <xsl:when test="contains(.,'/by-sa/4.0/')">
                <dcterms:license xsi:type="dcterms:URI">https://creativecommons.org/licenses/by-sa/4.0/</dcterms:license>
            </xsl:when>
            <xsl:when test="contains(.,'/by-nd/4.0/')">
                <dcterms:license xsi:type="dcterms:URI">https://creativecommons.org/licenses/by-nd/4.0/</dcterms:license>
            </xsl:when>
            <xsl:when test="contains(.,'/by-nc/4.0/')">
                <dcterms:license xsi:type="dcterms:URI">https://creativecommons.org/licenses/by-nc/4.0/</dcterms:license>
            </xsl:when>
            <xsl:when test="contains(.,'/by-nc-sa/4.0/')">
                <dcterms:license xsi:type="dcterms:URI">https://creativecommons.org/licenses/by-nc-sa/4.0/</dcterms:license>
            </xsl:when>
            <xsl:when test="contains(.,'/by-nc-nd/4.0/')">
                <dcterms:license xsi:type="dcterms:URI">https://creativecommons.org/licenses/by-nc-nd/4.0/</dcterms:license>
            </xsl:when>
            
            <xsl:when test="contains(.,'/by-nc-nd/2.5/si/')">
                <dcterms:license xsi:type="dcterms:URI">http://creativecommons.org/licenses/by-nc-nd/2.5/si/</dcterms:license>
                <dcterms:license xml:lang="slv">Priznanje avtorstva-Nekomercialo-Brez predelav 2.5 Slovenija (CC BY-NC-ND 2.5 SI)</dcterms:license>
            </xsl:when>
            <xsl:when test="contains(.,'/by-nc/2.5/si/')">
                <dcterms:license xsi:type="dcterms:URI">http://creativecommons.org/licenses/by-nc/2.5/si/</dcterms:license>
                <dcterms:license xml:lang="slv">Priznanje avtorstva-Nekomercialno 2.5 Slovenija (CC BY-NC 2.5 SI)</dcterms:license>
            </xsl:when>
            <xsl:when test="contains(.,'/by/2.5/si/')">
                <dcterms:license xsi:type="dcterms:URI">http://creativecommons.org/licenses/by/2.5/si/</dcterms:license>
                <dcterms:license xml:lang="slv">Priznanje avtorstva 2.5 Slovenija (CC BY 2.5 SI)</dcterms:license>
            </xsl:when>
            <xsl:when test="contains(.,'/by-nc-sa/2.5/si/')">
                <dcterms:license xsi:type="dcterms:URI">http://creativecommons.org/licenses/by-nc-sa/2.5/si/</dcterms:license>
                <dcterms:license xml:lang="slv">Priznanje avtorstva-Nekomercialno-Deljenje pod enakimi pogoji 2.5 Slovenija (CC BY-NC-SA 2.5 SI)</dcterms:license>
            </xsl:when>
            <xsl:when test="contains(.,'/by-nd/2.5/si/')">
                <dcterms:license xsi:type="dcterms:URI">http://creativecommons.org/licenses/by-nd/2.5/si/</dcterms:license>
                <dcterms:license xml:lang="slv">Priznanje avtorstva-Brez predelav 2.5 Slovenija (CC BY-ND 2.5 SI)</dcterms:license>
            </xsl:when>
            <xsl:when test="contains(.,'/by-sa/2.5/si/')">
                <dcterms:license xsi:type="dcterms:URI">http://creativecommons.org/licenses/by-sa/2.5/si/</dcterms:license>
                <dcterms:license xml:lang="slv">Priznanje avtorstva-Deljenje pod enakimi pogoji 2.5 Slovenija (CC BY-SA 2.5 SI)</dcterms:license>
            </xsl:when>
            <xsl:when test="contains(.,'/publicdomain/mark/1.0')">
                <dcterms:license xsi:type="dcterms:URI">http://creativecommons.org/publicdomain/mark/1.0/</dcterms:license>
                <dcterms:license xml:lang="eng">Public Domain Mark 1.0</dcterms:license>
                <dcterms:license xml:lang="slv">Avtorske pravice so potekle, delo je v javni domeni.</dcterms:license>
            </xsl:when>
            <xsl:when test="contains(.,'Free Access Mark')">
                <dcterms:license xml:lang="eng">Rights Reserved - Free Access</dcterms:license>
                <dcterms:license xml:lang="slv">Avtorske pravice so pridržane - prosti dostop.</dcterms:license>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>
                    <xsl:text>Ne najdem pretvorbe za avtorsko pravico dela </xsl:text>
                    <xsl:value-of select="../sistory:ID"/>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- še mapiranje DC elementov za avtorske pravice -->
    <!-- začetek rightsGroup -->
    <xsl:template match="sistory:RIGHTS[@rightsType='rights']">
        <xsl:if test="@rightsAttr='xml:lang'">
            <dcterms:rights xml:lang="{@lang}">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:rights>
        </xsl:if>
        <xsl:if test="@rightsAttr='URI'">
            <dcterms:rights xsi:type="dcterms:URI">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:rights>
        </xsl:if>
    </xsl:template>
    <xsl:template match="sistory:RIGHTS[@rightsType='accessRights']">
        <xsl:if test="@rightsAttr='xml:lang'">
            <dcterms:accessRights xml:lang="{@lang}">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:accessRights>
        </xsl:if>
        <xsl:if test="@rightsAttr='URI'">
            <dcterms:accessRights xsi:type="dcterms:URI">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:accessRights>
        </xsl:if>
    </xsl:template>
    <xsl:template match="sistory:RIGHTS[@rightsType='license']">
        <xsl:if test="@rightsAttr='xml:lang'">
            <dcterms:license xml:lang="{@lang}">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:license>
        </xsl:if>
        <xsl:if test="@rightsAttr='URI'">
            <dcterms:license xsi:type="dcterms:URI">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:license>
        </xsl:if>
    </xsl:template>
    <xsl:template match="sistory:OTHER[@otherType='rightsHolder']">
        <dcterms:rightsHolder xml:lang="{@lang}">
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:rightsHolder>
    </xsl:template>
    
    <!-- audience skupina -->
    <xsl:template match="sistory:AUDIENCE[@audienceType='audience']">
        <dcterms:audience xml:lang="{@lang}">
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:audience>
    </xsl:template>
    <xsl:template match="sistory:AUDIENCE[@audienceType='educationLevel']">
        <dcterms:educationLevel xml:lang="{@lang}">
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:educationLevel>
    </xsl:template>
    <xsl:template match="sistory:AUDIENCE[@audienceType='mediator']">
        <dcterms:mediator xml:lang="{@lang}">
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:mediator>
    </xsl:template>
    
    <!-- other skupina -->
    <xsl:template match="sistory:OTHER[@otherType='accrualMethod']">
        <dcterms:accrualMethod xml:lang="{@lang}">
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:accrualMethod>
    </xsl:template>
    <xsl:template match="sistory:OTHER[@otherType='accrualPeriodicity']">
        <dcterms:accrualPeriodicity xml:lang="{@lang}">
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:accrualPeriodicity>
    </xsl:template>
    <xsl:template match="sistory:OTHER[@otherType='accrualPolicy']">
        <dcterms:accrualPolicy xml:lang="{@lang}">
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:accrualPolicy>
    </xsl:template>
    <xsl:template match="sistory:OTHER[@otherType='instructionalMethod']">
        <dcterms:instructionalMethod xml:lang="{@lang}">
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:instructionalMethod>
    </xsl:template>
    <xsl:template match="sistory:OTHER[@otherType='provenance']">
        <dcterms:provenance xml:lang="{@lang}">
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:provenance>
    </xsl:template>
    
    
</xsl:stylesheet>