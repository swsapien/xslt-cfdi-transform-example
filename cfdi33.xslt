<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:cfdi="http://www.sat.gob.mx/cfd/3" xmlns:cce11="http://www.sat.gob.mx/ComercioExterior11" xmlns:donat="http://www.sat.gob.mx/donat" xmlns:divisas="http://www.sat.gob.mx/divisas" xmlns:implocal="http://www.sat.gob.mx/implocal" xmlns:leyendasFisc="http://www.sat.gob.mx/leyendasFiscales" xmlns:pfic="http://www.sat.gob.mx/pfic" xmlns:tpe="http://www.sat.gob.mx/TuristaPasajeroExtranjero" xmlns:nomina12="http://www.sat.gob.mx/nomina12" xmlns:registrofiscal="http://www.sat.gob.mx/registrofiscal" xmlns:pagoenespecie="http://www.sat.gob.mx/pagoenespecie" xmlns:aerolineas="http://www.sat.gob.mx/aerolineas" xmlns:valesdedespensa="http://www.sat.gob.mx/valesdedespensa" xmlns:consumodecombustibles="http://www.sat.gob.mx/consumodecombustibles" xmlns:notariospublicos="http://www.sat.gob.mx/notariospublicos" xmlns:vehiculousado="http://www.sat.gob.mx/vehiculousado" xmlns:servicioparcial="http://www.sat.gob.mx/servicioparcialconstruccion" xmlns:decreto="http://www.sat.gob.mx/renovacionysustitucionvehiculos" xmlns:destruccion="http://www.sat.gob.mx/certificadodestruccion" xmlns:obrasarte="http://www.sat.gob.mx/arteantiguedades" xmlns:ine="http://www.sat.gob.mx/ine" xmlns:iedu="http://www.sat.gob.mx/iedu" xmlns:ventavehiculos="http://www.sat.gob.mx/ventavehiculos" xmlns:terceros="http://www.sat.gob.mx/terceros" xmlns:pago10="http://www.sat.gob.mx/Pagos" xmlns:detallista="http://www.sat.gob.mx/detallista" xmlns:ecc12="http://www.sat.gob.mx/EstadoDeCuentaCombustible12" xmlns:consumodecombustibles11="http://www.sat.gob.mx/ConsumoDeCombustibles11" xmlns:gceh="http://www.sat.gob.mx/GastosHidrocarburos10" xmlns:ieeh="http://www.sat.gob.mx/IngresosHidrocarburos10" xmlns:tfd="http://www.sat.gob.mx/TimbreFiscalDigital" version="2.0">

    <xsl:variable name="separator" select="'~'" />
    <!-- Manejador de datos requeridos -->
    <xsl:template name="Requerido">
        <xsl:param name="valor" />
        <xsl:value-of select="$separator" />
        <xsl:call-template name="ManejaEspacios">
            <xsl:with-param name="s" select="$valor" />
        </xsl:call-template>
    </xsl:template>

    <!-- Dato sin pipe. Uso para primer dato -->
    <xsl:template name="OnlyData">
        <xsl:param name="valor" />
        <xsl:call-template name="ManejaEspacios">
            <xsl:with-param name="s" select="$valor" />
        </xsl:call-template>
    </xsl:template>

    <!-- Normalizador de espacios en blanco -->
    <xsl:template name="ManejaEspacios">
        <xsl:param name="s" />
        <xsl:value-of select="normalize-space(string($s))" />
    </xsl:template>

    <!-- Con el siguiente método se establece que la salida deberá ser en texto -->
    <xsl:output method="text" version="1.0" encoding="UTF-8" indent="no" />
    <!-- Aplicamos el template cfdi:Comprobante al root del documento.  -->
    <xsl:template match="/">
        <xsl:apply-templates select="/cfdi:Comprobante" />
    </xsl:template>
    
    <!-- Definimos el template cfdi:Comprobante  -->
    <xsl:template match="cfdi:Comprobante">
        <!-- Iniciamos el tratamiento de los atributos de comprobante -->
        <xsl:call-template name="OnlyData">
            <xsl:with-param name="valor" select="./@Version" />
        </xsl:call-template>
        <xsl:call-template name="Requerido">
            <xsl:with-param name="valor" select="./@Serie" />
        </xsl:call-template>
        <xsl:call-template name="Requerido">
            <xsl:with-param name="valor" select="./@Folio" />
        </xsl:call-template>
        <xsl:call-template name="Requerido">
            <xsl:with-param name="valor" select="./@Fecha" />
        </xsl:call-template>
        <xsl:call-template name="Requerido">
            <xsl:with-param name="valor" select="./@NoCertificado" />
        </xsl:call-template>
        <xsl:call-template name="Requerido">
            <xsl:with-param name="valor" select="./@SubTotal" />
        </xsl:call-template>
        <xsl:call-template name="Requerido">
            <xsl:with-param name="valor" select="./@Descuento" />
        </xsl:call-template>
        <xsl:call-template name="Requerido">
            <xsl:with-param name="valor" select="./@Total" />
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>