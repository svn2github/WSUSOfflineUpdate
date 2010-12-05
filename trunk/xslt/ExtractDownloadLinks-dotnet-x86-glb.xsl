<!-- Author: T. Wittrock, Kiel -->
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" encoding="UTF-8"/>

<xsl:template match="*">
  <xsl:choose>
    <xsl:when test="name()='FileLocation'">
      <xsl:if test="contains(@Url, 'http://') and contains(@Url, '/ndp') and contains(@Url, '-x86_') and contains(@Url, '.exe')">
        <xsl:value-of select="@Url"/>
        <xsl:text>&#10;</xsl:text>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="*"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:transform>
