<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:adms="http://www.w3.org/ns/adms#"
                xmlns:dcterms="http://purl.org/dc/terms/"
                xmlns:gr="http://purl.org/goodrelations/v1#"
                xmlns:irw="http://www.ontologydesignpatterns.org/ont/web/irw.owl#"
                xmlns:org="http://www.w3.org/ns/org#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:s="http://schema.org/"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:vcard="http://www.w3.org/2006/vcard/ns#"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:activities="http://purl.org/procurement/public-contracts-activities#"
                xmlns:authkinds="http://purl.org/procurement/public-contracts-authority-kinds#"
                xmlns:kinds="http://purl.org/procurement/public-contracts-kinds#"
                xmlns:proctypes="http://purl.org/procurement/public-contracts-procedure-types#"
                xmlns:criteria="http://purl.org/procurement/public-contracts-criteria#"
                xmlns:pc="http://purl.org/procurement/public-contracts#"
                xmlns:pcdt="http://purl.org/procurement/public-contracts-datatypes#"
                xmlns:pccz="http://purl.org/procurement/public-contracts-czech#"
                xmlns:pceu="http://purl.org/procurement/public-contracts-eu#"
                xmlns:f="http://opendata.cz/xslt/functions#"
                exclude-result-prefixes="fn f">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"
	            cdata-section-elements="s:streetAddress dcterms:description vcard:email vcard:fn s:description dcterms:title"/>

	<xsl:param name="baseURI">http://linked.opendata.cz/resource/</xsl:param>
	<xsl:variable name="domainURI" select="concat($baseURI, 'domain/fbo.gov/')"/>

	<xsl:template match="fbo-gov">
		<rdf:RDF>
			<xsl:apply-templates select="NOTICES"/>
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="NOTICES">
		<xsl:apply-templates select="PRESOL|COMBINE|SRCSGT|AWARD|JA|FAIROPP"/>
		<!-- TODO: Implement other types -->
	</xsl:template>

	<xsl:variable name="localityRegexp" select="'.*([;,]\s*([^\d;,]+)[;,]\s*|\s+([^\d\s,;]+)\s+)[A-Z]{2}\s+[\d-]+.+'"/>
	<xsl:variable name="countryRegexp" select="'.* ([A-Z]{2})\s+[0-9-]+'"/>

	<xsl:function name="f:classURI" as="xsd:anyURI">
		<xsl:param name="classLabel" as="xsd:string"/>
		<xsl:param name="id" as="xsd:string"/>
		<xsl:value-of select="f:pathIdURI(encode-for-uri(replace(lower-case($classLabel), '\s', '-')), $id)"/>
	</xsl:function>

	<xsl:function name="f:pathIdURI" as="xsd:anyURI">
		<xsl:param name="path" as="xsd:string"/>
		<xsl:param name="id" as="xsd:string"/>
		<xsl:value-of select="concat(f:pathURI($path), '/', encode-for-uri($id))"/>
	</xsl:function>

	<xsl:function name="f:pathURI" as="xsd:anyURI">
		<xsl:param name="path" as="xsd:string"/>
		<xsl:value-of select="concat($domainURI, $path)"/>
	</xsl:function>

	<xsl:function name="f:slugify" as="xsd:anyURI">
		<xsl:param name="text" as="xsd:string"/>
		<xsl:value-of select="encode-for-uri(translate(replace(lower-case(normalize-unicode($text, 'NFKD')), '\P{IsBasicLatin}', ''), ' ', '-'))" />
	</xsl:function>

	<xsl:template match="PRESOL|COMBINE|SRCSGT|AWARD|JA|FAIROPP">
		<pc:Contract>
			<xsl:variable name="fileReferenceNumber" select="SOLNBR/text()"/>

			<xsl:if test="$fileReferenceNumber">
				<xsl:attribute name="rdf:about">
					<xsl:value-of select="f:classURI('Contract', $fileReferenceNumber)"/>
				</xsl:attribute>
				<pc:referenceNumber>
					<adms:Identifier>
						<xsl:attribute name="rdf:about">
							<xsl:value-of select="f:classURI('Identifier', f:slugify($fileReferenceNumber))"/>
						</xsl:attribute>
						<skos:notation>
							<xsl:value-of select="$fileReferenceNumber"/>
						</skos:notation>
						<!--
							Not issued by the contracting authority.
							<adms:schemeAgency><xsl:value-of select="$authorityLegalName"/></adms:schemeAgency>
						-->
					</adms:Identifier>
				</pc:referenceNumber>
			</xsl:if>

			<xsl:variable name="authorityLegalName" select="normalize-space(OFFICE/text())"/>
			<pc:contractingAuthority>
				<gr:BusinessEntity>
					<xsl:if test="$authorityLegalName">
						<xsl:attribute name="rdf:about">
							<xsl:value-of select="f:classURI('Business Entity', f:slugify($authorityLegalName))"/>
						</xsl:attribute>
						<gr:legalName>
							<xsl:value-of select="$authorityLegalName"/>
						</gr:legalName>
					</xsl:if>
					<xsl:if test="OFFADD/text()">
						<s:address>
							<s:PostalAddress>
								<xsl:attribute name="rdf:about">
									<xsl:value-of select="f:classURI('Postal Address', fn:generate-id(OFFADD))"/>
								</xsl:attribute>
								<xsl:if test="OFFADD/text()">
									<s:streetAddress>
										<xsl:value-of select="OFFADD"/>
									</s:streetAddress>
								</xsl:if>
								<xsl:if test="OFFADD/text()">
									<s:addressLocality>
										<xsl:value-of
												select="replace(OFFADD/text(), $localityRegexp, '$2$3')"/>
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
											<xsl:value-of
													select="replace(OFFADD/text(), $countryRegexp, '$1')"/>
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
					<xsl:if test="AGENCY">
						<org:subOrganizationOf>
							<gr:BusinessEntity>
								<xsl:attribute name="rdf:about">
									<xsl:value-of select="f:classURI('Business Entity', f:slugify(AGENCY))"/>
								</xsl:attribute>
								<gr:legalName>
									<xsl:value-of select="AGENCY"/>
								</gr:legalName>
							</gr:BusinessEntity>
						</org:subOrganizationOf>
					</xsl:if>
				</gr:BusinessEntity>
			</pc:contractingAuthority>

			<xsl:if test="CONTACT/text()">
				<pc:contact>
					<vcard:VCard>
						<xsl:attribute name="rdf:about">
							<xsl:value-of select="f:classURI('VCard', fn:generate-id(CONTACT))"/>
						</xsl:attribute>
						<xsl:if test="matches(CONTACT/text(), '.+[\s:](\S+@\S+\.[a-z]{2,6})([\s&quot;].*|$)')">
							<vcard:email>
								<xsl:value-of
										select="replace(CONTACT/text(), '.+[\s:](\S+@\S+\.[a-z]{2,6})([\s&quot;].*|$)', '$1')"/>
							</vcard:email>
						</xsl:if>

						<xsl:if test="EMAIL/ADDRESS/text()">
							<vcard:email>
								<xsl:value-of select="EMAIL/ADDRESS/text()"/>
							</vcard:email>
						</xsl:if>
						<xsl:variable name="phoneRegex" select="'[^0-9(]{0,3}((\(\d{3}\))?[0-9-]+)[^0-9].+'"/>
						<xsl:if test="matches(CONTACT/text(), fn:concat('.+Phone', $phoneRegex))">
							<vcard:tel>
								<vcard:Work>
									<xsl:variable name="phone" select="replace(CONTACT/text(), fn:concat('.+Phone', $phoneRegex), '$1')"/>
									<xsl:attribute name="rdf:about">
										<xsl:value-of select="f:classURI('Work', replace($phone, '[^\d]', ''))"/>
									</xsl:attribute>
									<rdf:value>
										<xsl:value-of
												select="$phone"/>
									</rdf:value>
								</vcard:Work>
							</vcard:tel>
						</xsl:if>

						<xsl:if test="matches(CONTACT/text(), fn:concat('.+Fax', $phoneRegex))">
							<vcard:tel>
								<vcard:Fax>
									<xsl:variable name="fax" select="replace(CONTACT/text(), fn:concat('.+Fax', $phoneRegex), '$1')"/>
									<xsl:attribute name="rdf:about">
										<xsl:value-of select="f:classURI('Fax', replace($fax, '[^\d]', ''))"/>
									</xsl:attribute>
									<rdf:value>
										<xsl:value-of
												select="$fax"/>
									</rdf:value>
								</vcard:Fax>
							</vcard:tel>
						</xsl:if>

						<xsl:if test="CONTACT/text()">
							<vcard:fn>
								<xsl:value-of select="CONTACT"/>
							</vcard:fn>
						</xsl:if>
					</vcard:VCard>
				</pc:contact>
			</xsl:if>

			<xsl:call-template name="processDescriptionContractInformation"/>
			<xsl:apply-templates select="ARCHDATE|CLASSCOD|DATE|LINK|RESPDATE|SUBJECT"/>
			<xsl:call-template name="processAwardInformation"/>
		</pc:Contract>
	</xsl:template>

	<xsl:template name="processAwardInformation">
		<xsl:variable name="tenderCode" select="AWDNBR/text()"/>
		<xsl:if test="$tenderCode">
			<pc:awardedTender>
				<pc:Tender>
					<xsl:attribute name="rdf:about">
						<xsl:value-of select="f:classURI('Tender', $tenderCode)"/>
					</xsl:attribute>
					<adms:identifier>
						<adms:Identifier>
							<xsl:attribute name="rdf:about">
								<xsl:value-of select="f:classURI('Identifier', f:slugify($tenderCode))"/>
							</xsl:attribute>
							<skos:notation>
								<xsl:value-of select="$tenderCode"/>
							</skos:notation>
						</adms:Identifier>
					</adms:identifier>
					<xsl:if test="AWARDEE/text()">
						<pc:bidder>
							<gr:BusinessEntity>
								<xsl:variable name="awardeeLegalName" select="replace(AWARDEE/text(), '(.+?)[;,\s]+\d+.+', '$1')"/>
								<xsl:attribute name="rdf:about">
									<xsl:value-of select="f:classURI('Business Entity', f:slugify($awardeeLegalName))"/>
								</xsl:attribute>
								<gr:legalName>
									<xsl:value-of select="$awardeeLegalName"/>
								</gr:legalName>
								<s:address>
									<s:PostalAddress>
										<xsl:attribute name="rdf:about">
											<xsl:value-of select="f:classURI('Postal Address', fn:generate-id(AWARDEE))"/>
										</xsl:attribute>
										<s:streetAddress>
											<xsl:value-of select="AWARDEE"/>
										</s:streetAddress>
										<s:addressLocality>
											<xsl:value-of
													select="replace(AWARDEE/text(), $localityRegexp, '$2$3')"/>
										</s:addressLocality>
										<s:postalCode>
											<xsl:value-of select="replace(AWARDEE/text(), '.+[;,\s]+[A-Z]{2}[;,\s]+(\d+)([;,\s]+(USA?)?|)', '$1')"/>
										</s:postalCode>
										<s:addressCountry>
											<xsl:value-of
													select="replace(AWARDEE/text(), $countryRegexp, '$1')"/>
										</s:addressCountry>
									</s:PostalAddress>
								</s:address>
							</gr:BusinessEntity>
						</pc:bidder>
					</xsl:if>
					<xsl:if test="AWDAMT/text()">
						<pc:offeredPrice>
							<gr:UnitPriceSpecification>
								<xsl:attribute name="rdf:about">
									<xsl:value-of select="f:classURI('Price Specification', fn:generate-id(AWDAMT))"/>
								</xsl:attribute>
								<gr:hasCurrency>
									<xsl:text>USD</xsl:text>
								</gr:hasCurrency>
								<gr:hasCurrencyValue>
									<xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#float</xsl:attribute>
									<xsl:value-of select="replace(AWDAMT/text(), '[^\d.]', '')"/>
								</gr:hasCurrencyValue>
							</gr:UnitPriceSpecification>
						</pc:offeredPrice>
					</xsl:if>
				</pc:Tender>
			</pc:awardedTender>
		</xsl:if>

		<xsl:if test="AWDDATE/text()">
			<pc:awardDate>
				<xsl:call-template name="processDate">
					<xsl:with-param name="date" select="AWDDATE/text()" />
				</xsl:call-template>
			</pc:awardDate>
		</xsl:if>
	</xsl:template>

	<xsl:template match="ARCHDATE">
		<dcterms:available>
			<xsl:call-template name="processDate">
				<xsl:with-param name="date" select="text()"/>
			</xsl:call-template>
		</dcterms:available>
	</xsl:template>

	<xsl:template match="CLASSCOD">
		<xsl:call-template name="processClassificationCode">
			<xsl:with-param name="code" select="text()"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="DATE">
		<!-- Posting date -->
		<dcterms:dateSubmitted>
			<xsl:call-template name="processDate">
				<xsl:with-param name="date" select="text()"/>
			</xsl:call-template>
		</dcterms:dateSubmitted>
	</xsl:template>

	<xsl:template match="LINK">
		<dcterms:source>
			<xsl:apply-templates/>
		</dcterms:source>
	</xsl:template>

	<xsl:template match="RESPDATE">
		<pc:tenderDeadline>
			<xsl:call-template name="processDate">
				<xsl:with-param name="date" select="text()"/>
			</xsl:call-template>
		</pc:tenderDeadline>
	</xsl:template>

	<xsl:template match="SUBJECT">
		<dcterms:title xml:lang="en">
			<xsl:value-of select="substring-after(., '--')"/>
		</dcterms:title>
	</xsl:template>

	<xsl:template name="processDescriptionContractInformation">
		<xsl:if test="DESC/text()">
			<dcterms:description>
				<xsl:value-of select="DESC"/>
			</dcterms:description>
		</xsl:if>

		<xsl:if test="POPADDRESS/text()">
			<pc:location>
				<s:Place>
					<xsl:attribute name="rdf:about">
						<xsl:value-of select="f:classURI('Place', fn:generate-id(POPADDRESS))"/>
					</xsl:attribute>
					<s:address>
						<s:PostalAddress>
							<xsl:attribute name="rdf:about">
								<xsl:value-of select="f:classURI('Postal Address', fn:generate-id(POPADDRESS))"/>
							</xsl:attribute>
							<xsl:if test="POPCOUNTRY">
								<s:addressCountry>
									<xsl:value-of select="POPCOUNTRY"/>
								</s:addressCountry>
							</xsl:if>
							<xsl:if test="POPZIP">
								<s:postalCode>
									<xsl:value-of select="POPZIP"/>
								</s:postalCode>
							</xsl:if>
							<s:description>
								<xsl:value-of select="POPADDRESS"/>
							</s:description>
						</s:PostalAddress>
					</s:address>
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

	<xsl:template name="processClassificationCode">
		<xsl:param name="code"></xsl:param>
		<xsl:choose>
			<xsl:when test="matches($code, '[A-Z]')">
				<pc:kind rdf:resource="http://purl.org/procurement/public-contracts-kinds#Services"/>
				<pc:mainObject rdf:resource="{concat($baseURI, 'far-codes/services/concept/', .)}"/>
			</xsl:when>
			<xsl:when test="matches($code, '\d+')">
				<pc:kind rdf:resource="http://purl.org/procurement/public-contracts-kinds#Supplies"/>
				<pc:mainObject rdf:resource="{concat($baseURI, 'far-codes/supplies/concept/', .)}"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="processDate">
		<xsl:param name="date"/>
		<xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#date</xsl:attribute>
		<xsl:analyze-string select="$date" regex="(\d{{2}})(\d{{2}})(\d{{4}})">
			<xsl:matching-substring>
				<xsl:value-of select="xsd:date(concat(regex-group(3), '-', regex-group(1), '-', regex-group(2)))"/>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:value-of select="$date"/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>

</xsl:stylesheet>
