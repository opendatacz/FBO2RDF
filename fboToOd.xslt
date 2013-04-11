<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:adms="http://www.w3.org/ns/adms#"
	xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:gr="http://purl.org/goodrelations/v1#"
	xmlns:irw="http://www.ontologydesignpatterns.org/ont/web/irw.owl#"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:s="http://schema.org/"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:vcard="http://www.w3.org/2006/vcard/ns#"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
	xmlns:activities="http://purl.org/procurement/public-contracts-activities#"
	xmlns:authkinds="http://purl.org/procurement/public-contracts-authority-kinds#"
	xmlns:kinds="http://purl.org/procurement/public-contracts-kinds#"
	xmlns:proctypes="http://purl.org/procurement/public-contracts-procedure-types#"
	xmlns:criteria="http://purl.org/procurement/public-contracts-criteria#"
	xmlns:pc="http://purl.org/procurement/public-contracts#"
	xmlns:pcdt="http://purl.org/procurement/public-contracts-datatypes#"
	xmlns:pccz="http://purl.org/procurement/public-contracts-czech#"
	xmlns:pceu="http://purl.org/procurement/public-contracts-eu#"
	exclude-result-prefixes="fn">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

	<xsl:template match="/">
		<rdf:RDF>
			<xsl:apply-templates select="NOTICES/PRESOL"/>
		</rdf:RDF>
	</xsl:template>
	
	<xsl:template match="PRESOL">
		<pc:Contract>
			<xsl:variable name="authorityLegalName" select="normalize-space(OFFICE/text())"/>
			<pc:contractingAuthority>
				<gr:BusinessEntity>
					<xsl:if test="$authorityLegalName">
						<gr:legalName><xsl:value-of select="$authorityLegalName"/></gr:legalName>
					</xsl:if>
					<xsl:if test="OFFADD/text()">
						<s:address>
							<s:PostalAddress>
								<xsl:if test="OFFADD/text()">
									<s:streetAddress>
										<xsl:value-of select="OFFADD"/>
									</s:streetAddress>
								</xsl:if>
								<xsl:if test="OFFADD/text()">
									<s:addressLocality>
										<xsl:value-of select="replace(OFFADD/text(), '.* ([^0-9]*) [A-Z]{2} [0-9-]+', '$1')"/>
									</s:addressLocality>
								</xsl:if>
								<xsl:if test="ZIP/text()">
									<s:postalCode>
										<xsl:value-of select="ZIP"/>
									</s:postalCode>
								</xsl:if>
								<xsl:choose>
									<xsl:when test="OFFADD/text()">
										<s:addressCountry>
											<xsl:value-of select="replace(OFFADD/text(), '.* ([A-Z]{2}) [0-9-]+', '$1')" />
										</s:addressCountry>
									</xsl:when>
									<xsl:otherwise>
										<s:addressCountry>
											<xsl:text>USA</xsl:text>
										</s:addressCountry>
									</xsl:otherwise>
								</xsl:choose>
							</s:PostalAddress>
						</s:address>
					</xsl:if>
				</gr:BusinessEntity>
			</pc:contractingAuthority>
			
			<xsl:variable name="fileReferenceNumber" select="SOLNBR/text()"/>
			<xsl:if test="$fileReferenceNumber">
				<pc:referenceNumber>
					<adms:Identifier>
						<skos:notation><xsl:value-of select="$fileReferenceNumber" /></skos:notation>
						<adms:schemeAgency><xsl:value-of select="$authorityLegalName"/></adms:schemeAgency>
					</adms:Identifier>
				</pc:referenceNumber>
			</xsl:if>
			
			<xsl:if test="CONTACT/text()">
				<pc:contact>
					<vcard:VCard>
						<xsl:if test="matches(CONTACT/text(), '.+ ([a-z0-9+_-]+@[a-z0-9-]+.[a-z]{2,4}).+')">
							<vcard:email>
								<xsl:attribute namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#" name="resource">
									<xsl:text>mailto:</xsl:text>
									<xsl:value-of select="replace(CONTACT/text(), '.+ ([a-z0-9+_-]+@[a-z0-9-]+.[a-z]{2,4}).+', '$1')"/>
								</xsl:attribute>
							</vcard:email>
						</xsl:if>
						
						<xsl:if test="EMAIL/ADDRESS/text()">
							<vcard:email>
								<xsl:attribute namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#" name="resource">
									<xsl:text>mailto:</xsl:text>
									<xsl:value-of select="EMAIL/ADDRESS/text()"/>
								</xsl:attribute>
							</vcard:email>
						</xsl:if>
				
						<xsl:if test="matches(CONTACT/text(), '.+Phone[^0-9]{0,3}([0-9])[^0-9].+')">
							<vcard:tel>
								<vcard:Work>
									<rdf:value>
										<xsl:value-of select="replace(CONTACT/text(), '.+Phone[^0-9]{0,3}([0-9])[^0-9].+', '$1')"/>
									</rdf:value>
								</vcard:Work>
							</vcard:tel>
						</xsl:if>
				
						<xsl:if test="matches(CONTACT/text(), '.+Fax[^0-9]{0,3}([0-9])[^0-9].+')">
							<vcard:tel>
								<vcard:Fax>
									<rdf:value>
										<xsl:value-of select="replace(CONTACT/text(), '.+Fax[^0-9]{0,3}([0-9])[^0-9].+', '$1')"/>
									</rdf:value>
								</vcard:Fax>
							</vcard:tel>
						</xsl:if>
				
						<xsl:if test="CONTACT/text()">
							<vcard:fn><xsl:value-of select="CONTACT"/></vcard:fn>
						</xsl:if>
					</vcard:VCard>
				</pc:contact>
			</xsl:if>
			
			<xsl:call-template name="processDescriptionContractInformation"/>
			
		</pc:Contract>
	</xsl:template>
	
	<xsl:template name="processDescriptionContractInformation">
		<xsl:if test="SUBJECT/text()">
			<dcterms:title><xsl:value-of select="SUBJECT"/></dcterms:title>
		</xsl:if>
		
		<xsl:if test="DESC/text()">
			<dcterms:description><xsl:value-of select="DESC"/></dcterms:description>
		</xsl:if>
		
		<xsl:if test="POPADDRESS/text()">
			<pc:location>
				<s:Place>
					<xsl:if test="POPADDRESS">
						<s:description>
							<xsl:value-of select="POPADDRESS" />
						</s:description>
					</xsl:if>
				</s:Place>
			</pc:location>
		</xsl:if>
		
		<xsl:if test="NAICS/text()">
			<pc:mainObject>
				<xsl:attribute namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#" name="resource">
					<xsl:text>http://purl.org/weso/pscs/naics/2012/resource/</xsl:text>
					<xsl:value-of select="NAICS"/>
				</xsl:attribute>
			</pc:mainObject>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>