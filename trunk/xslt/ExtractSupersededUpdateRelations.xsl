<!-- Author: T. Wittrock, Kiel -->
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" encoding="UTF-8"/>
                        
<xsl:template match="*">
  <xsl:choose>
    <xsl:when test="name()='Update'">
      <xsl:text>#</xsl:text>
      <xsl:value-of select="@RevisionId"/>
      <xsl:text>#</xsl:text>
      <xsl:apply-templates select="*"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:when>
    <xsl:when test="name()='BundledBy'">
    </xsl:when>
    <xsl:when test="name()='Categories'">
    </xsl:when>
    <xsl:when test="name()='PayloadFiles'">
    </xsl:when>
    <xsl:when test="name()='Prerequisites'">
    </xsl:when>
    <xsl:when test="name()='Languages'">
    </xsl:when>
    <xsl:when test="name()='Revision'">
      <xsl:text>,_</xsl:text>
      <xsl:value-of select="@Id"/>
      <xsl:text>_</xsl:text>
    </xsl:when>
    <xsl:when test="name()='FileLocations'">
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="*"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:transform>
