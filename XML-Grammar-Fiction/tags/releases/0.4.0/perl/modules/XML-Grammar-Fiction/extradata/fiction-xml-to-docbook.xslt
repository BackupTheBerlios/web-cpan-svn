<xsl:stylesheet version = '1.0'
    xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
    xmlns:fic="http://web-cpan.berlios.de/modules/XML-Grammar-Fortune/fiction-xml-0.2/"
    xmlns="http://docbook.org/ns/docbook"
    xmlns:xlink="http://www.w3.org/1999/xlink">

<xsl:output method="xml" encoding="UTF-8" indent="yes"
 />

<xsl:template match="/">
        <xsl:apply-templates select="//fic:body" />  
</xsl:template>

<xsl:template match="fic:body">
    <article>
        <xsl:attribute name="xml:id">
            <xsl:value-of select="@xml:id" />
        </xsl:attribute>
        <xsl:attribute name="xml:lang">
            <xsl:value-of select="@xml:lang" />
        </xsl:attribute>
        <info>
            <title>
                <xsl:value-of select="fic:title" />
            </title>
        </info>
        <xsl:apply-templates select="fic:section" />
    </article>
</xsl:template>

<xsl:template match="fic:section">
    <section>
        <xsl:attribute name="xml:id">
            <xsl:value-of select="@xml:id" />
        </xsl:attribute>
        <!-- Make the title the title attribute or "ID" if does not exist. -->
        <info>
        <title>
            <xsl:choose>
                <xsl:when test="fic:title">
                    <xsl:value-of select="fic:title" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@xml:id" />
                </xsl:otherwise>
            </xsl:choose> 
        </title>
    </info>
        <xsl:apply-templates select="fic:section|fic:blockquote|fic:p|fic:ol|fic:ul" />
    </section>
</xsl:template>

<xsl:template match="fic:p">
    <para>
        <xsl:apply-templates />
    </para>
</xsl:template>

<xsl:template match="fic:b">
    <emphasis role="bold">
        <xsl:apply-templates/>
    </emphasis>
</xsl:template>

<xsl:template match="fic:blockquote">
    <blockquote>
        <xsl:apply-templates/>
    </blockquote>
</xsl:template>

<xsl:template match="fic:i">
    <emphasis>
        <xsl:apply-templates/>
    </emphasis>
</xsl:template>

<xsl:template match="fic:ol">
    <orderedlist>
        <xsl:apply-templates/>
    </orderedlist>
</xsl:template>

<xsl:template match="fic:ul">
    <itemizedlist>
        <xsl:apply-templates/>
    </itemizedlist>
</xsl:template>

<xsl:template match="fic:li">
    <listitem>
        <xsl:apply-templates/>
    </listitem>
</xsl:template>

<xsl:template match="fic:span">
    <xsl:choose>
        <xsl:when test="@xlink:href">
            <link>
                <xsl:attribute name="xlink:href">
                    <xsl:value-of select="@xlink:href" />
                </xsl:attribute>
                <xsl:apply-templates/>
            </link>
        </xsl:when>
        <xsl:otherwise>
            <xsl:apply-templates/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
</xsl:stylesheet>
