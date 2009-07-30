<!-- Author: T. Wittrock, RZ Uni Kiel -->
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" encoding="UTF-8"/>

<xsl:template match="PATCH">
  <xsl:if test="@EXPIRED='False'">
    <xsl:value-of select="@KB_NUMBER"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="*">
  <xsl:if test="not(name()='ADMINAPPLICABLE' or name()='ERROR')">
    <xsl:apply-templates select="*"/>
  </xsl:if>
</xsl:template>

</xsl:transform>
