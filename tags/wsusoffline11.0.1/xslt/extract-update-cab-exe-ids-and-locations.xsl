<?xml version="1.0"?>
<!-- Author: H. Buhrmester -->
<!-- Filename: extract-update-cab-exe-ids-and-locations.xsl -->
<!-- This file extracts the following fields: -->
<!-- Field 1: File Id -->
<!-- Field 2: File Url (Location) -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:__="http://schemas.microsoft.com/msus/2004/02/OfflineSync" version="1.0">
  <xsl:output omit-xml-declaration="yes" indent="no" method="text" />
  <xsl:template match="/">
    <xsl:for-each select="__:OfflineSyncPackage/__:FileLocations/__:FileLocation">
      <xsl:if test="contains(@Url, 'http://') and contains(@Url, '/update/software/secu/') and not(contains(@Url, 'MUI') or contains(@Url, 'Mui') or contains(@Url, 'mui')) and (contains(@Url, '.cab') or contains(@Url, '.exe'))">
        <xsl:value-of select="@Id" />
        <xsl:text>,</xsl:text>
        <xsl:value-of select="@Url" />
        <xsl:text>&#10;</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
