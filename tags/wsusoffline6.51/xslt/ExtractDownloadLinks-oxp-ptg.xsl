<!-- Author: T. Wittrock, RZ Uni Kiel -->
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" encoding="UTF-8"/>

<xsl:template match="DLBINARY">
  <xsl:if test="contains(., 'http://') and (contains(., 'xp-') or contains(., 'XP-')) and not(contains(., 'MUI') or contains(., 'Mui') or contains(., 'mui')) and (contains(., '-ptg') or contains(., '-PTG')) and contains(., '.exe')">
    <xsl:value-of select="."/>
    <xsl:text>&#10;</xsl:text>
  </xsl:if>
  <xsl:if test="contains(., 'http://') and contains(., '2002-') and not(contains(., 'MUI') or contains(., 'Mui') or contains(., 'mui')) and (contains(., '-ptg') or contains(., '-PTG')) and contains(., '.exe')">
    <xsl:value-of select="."/>
    <xsl:text>&#10;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="LOCAL">
  <xsl:if test="@LANGNAME='ENU'">
    <xsl:apply-templates select="*"/>
  </xsl:if>
</xsl:template>

<xsl:template match="*">
  <xsl:apply-templates select="*"/>
</xsl:template>

</xsl:transform>
