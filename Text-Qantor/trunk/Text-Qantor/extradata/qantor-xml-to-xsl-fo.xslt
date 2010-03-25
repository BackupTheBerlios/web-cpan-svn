<xsl:stylesheet version = '1.0'
     xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
     xmlns:qant="http://web-cpan.berlios.de/Qantor/qantor-xml/"
     xmlns:xlink="http://www.w3.org/1999/xlink"
     xmlns:fo="http://www.w3.org/1999/XSL/Format"
     >

<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"
 />

<xsl:template match="/">
        <xsl:apply-templates select="//body" />  
</xsl:template>

<xsl:template match="body">
    <fo:root>
        <fo:layout-master-set>
            <fo:simple-page-master master-name="A4">
                <fo:region-body />
            </fo:simple-page-master>
        </fo:layout-master-set>
        <fo:page-sequence master-reference="A4">
            <fo:flow flow-name="xsl-region-body">
                <xsl:apply-templates select="p" />  
            </fo:flow>
        </fo:page-sequence>
    </fo:root>
</xsl:template>

<xsl:template match="p">
    <fo:block>
        <xsl:apply-templates />
    </fo:block>
</xsl:template>

<xsl:template match="b">
    <fo:inline font-weight="bold">
        <xsl:apply-templates />
    </fo:inline>
</xsl:template>

</xsl:stylesheet>
