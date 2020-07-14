# Cómo extraer información de facturas cfdi 3.3 México para análisis.

En este post compartiré la experiencia que hemos tenido dentro de [SW sapien®](https://sw.com.mx) al trabajar con documentos xml específicamente la versión **cfdi 3.3** para poder extraer información que posteriormente podemos analizar a través de diferentes herramientas como excel , bases de datos , aplicaciones de business intelligence.

En cuanto a temas de Big Data en SW sapien nos encontramos con el siguiente problema:

> “Cómo extraer la información de millones de documentos xml de una forma eficiente tomando en cuenta la estructura compleja que representa un cfdi 3.3 con sus diferentes complementos”

Cuando se trata de manipulación de documentos xml existen diferentes herramientas utilizadas en diferentes lenguajes. En este post nos enfocaremos en la utilización de **XSLT** ( Extensible Stylesheet Language Transformations) como herramienta de apoyo para extraer la información de una forma eficiente, lo cual nos permite una gran velocidad de transformación. De esta manera podemos procesar millones de documentos con un gran performance en cuanto a tiempos de procesamiento y utilización de recursos.

De acuerdo a la definición de Wikipedia [XSLT](https://en.wikipedia.org/wiki/XSLT) es un lenguaje para transformar documentos XML en otros documentos XML u otros formatos como HTML, **texto plano**, XSL que después se pueden convertir a formatos como PDF.

Para resolver nuestro problema utilizaremos XSLT para la transformación de un XML en **texto plano**.

El resultado que estamos esperando es muy similar a una cadena original que comúnmente se utiliza en cfdi 3.3 para el sellado de documentos con la diferencia en que siempre respetaremos el número de elementos de salida, para evitar que tengamos diferencia entre el número de columnas con cada transformación. 

Ejemplo:
```text
3.3~F~6~2019-09-28T21:05:58~20001000000300022815~12000.00~0.00~13920.00
```
Donde “~” es nuestro separador de columna. 

## XSLT Transformador

Para crear nuestro XSLT lo primero que tenemos que definir es el nodo que estaremos procesando y el template que debemos aplicar:
```xsl
<xsl:template match="/">        
    <xsl:apply-templates select="/cfdi:Comprobante"/>
</xsl:template>
```
Todo lo que encontremos dentro del nodo raíz y que haga match con el nodo cfdi:Comprobante será procesado por este template.

### Template cfdi:Comprobante
```xsl
<xsl:template match="cfdi:Comprobante">
    <!-- Iniciamos el tratamiento de los atributos de comprobante -->
    <xsl:call-template name="OnlyData">
        <xsl:with-param name="valor" select="./@Version"/>
    </xsl:call-template>
    <xsl:call-template name="Requerido">
        <xsl:with-param name="valor" select="./@Serie"/>
    </xsl:call-template>
    <xsl:call-template name="Requerido">
        <xsl:with-param name="valor" select="./@Folio"/>
    </xsl:call-template>
    <xsl:call-template name="Requerido">
        <xsl:with-param name="valor" select="./@Fecha"/>
    </xsl:call-template>
    <xsl:call-template name="Requerido">
        <xsl:with-param name="valor" select="./@NoCertificado"/>
    </xsl:call-template>
    <xsl:call-template name="Requerido">
        <xsl:with-param name="valor" select="./@SubTotal"/>
    </xsl:call-template>
    <xsl:call-template name="Requerido">
        <xsl:with-param name="valor" select="./@Descuento"/>
    </xsl:call-template>
    <xsl:call-template name="Requerido">
        <xsl:with-param name="valor" select="./@Total"/>
    </xsl:call-template>
</xsl:template>
```
Dentro de este template estamos definiendo la coincidencia con cfdi:Comprobante y sus atributos o elementos que estaremos procesando. En este caso tomaremos los valores de los atributos Version,Serie,Folio , Fecha,NoCertificado,Subtotal,Descuento,Total.

A estos atributos les aplicaremos el template **OnlyData** y **Requerido** respectivamente para darle formato al texto de salida.

### Template **OnlyData**

Mediante este template podemos transformar el dato a texto sin anteponer un separador ya que es el primer dato que vamos a procesar.Recibimos un parámetro de nombre “valor”, este parámetro lo procesamos a través de de otro template para normalizar el texto y sus espacios utilizando el template **ManejaEspacios**.
```xsl
<!-- Dato sin pipe. Uso para primer dato -->
<xsl:template name="OnlyData">
    <xsl:param name="valor"/>
    <xsl:call-template name="ManejaEspacios">
        <xsl:with-param name="s" select="$valor"/>
    </xsl:call-template>
</xsl:template>
```

### Template **ManejaEspacios**

El template **ManejaEspacios** recibe un parámetro llamado “s” el cual utiliza para pasar a través de una función llamada normalize-space donde recibe como parámetro un string. 
```xsl
<xsl:template name="ManejaEspacios">
    <xsl:param name="s"/>
    <xsl:value-of select="normalize-space(string($s))"/>
</xsl:template>
```
De acuerdo a la documentación esta función hace lo siguiente:
* It removes all leading spaces. (Elimina todos los espacios principales).
* It removes all trailing spaces. (Elimina todos los espacios finales).
* It replaces any group of consecutive whitespace characters with a single space. (Reemplaza cualquier grupo de caracteres de espacio en blanco consecutivos con un solo espacio).       

### Template **Requerido**

Para este template es necesario declarar una variable llamada “separator” . Esta variable sera utilizada para separar cada valor y poder convertir a columnas posteriormente.
```xsl
<xsl:variable name="separator" select="'~'" />
```
Con la variable separator definida previamente es posible utilizarla en otros templates de forma global. Dentro del template Requerido recibimos el parámetro “valor” y escribimos el valor de separator posteriormente escribimos el texto que contiene el parámetro valor aplicando el template **ManejaEspacios**.
```xsl
<xsl:template name="Requerido">
    <xsl:param name="valor"/>
    <xsl:value-of select="$separator" />
    <xsl:call-template name="ManejaEspacios">
        <xsl:with-param name="s" select="$valor"/>
    </xsl:call-template>
</xsl:template>
```
Cada vez que apliquemos el template “Requerido” estaremos escribiendo algo similar a lo siguiente:
```text
~texto
```
A este documento lo llamaremos **cfdi33.xslt**. A continuación utilizaremos python para aplicar la transformación de un cfdi33 xml a un formato columnar.

## Python transformador XSLT

Para este ejemplo utilizaremos **Python 3.8.0**. Crearemos nuestro virtualenv , activamos el virtualenv e instalamos las dependencias utilizando los siguientes comandos.

    python -m venv venv
    .\venv\Scripts\activate
    pip install -r .\requirements.txt

Las dependencias que necesitamos son:
```python
XlsxWriter==1.2.1
xlwt==1.3.0
lxml==4.4.1
```
Requerimos el archivo que creamos **cfdi33.xslt** y un documento xml cfdi 3.3 que nombraremos como **cfdi33.xml**.

Creamos nuestro archivo **main.py**, importamos las librerias necesarias:
```python
import os
import lxml.etree as ET
import xlsxwriter
```
Creamos una clase **Transformer**  con un constructor con el cual creamos el objeto XSLT que llamaremos **transformer** y un XML Parser para leer los documentos xml al que llamaremos **xml_parser**.
```python
class Transformer:
    def __init__(self):    
        with open('cfdi33.xslt', 'r', encoding='utf-8') as f_xslt:
        xslt = ET.parse(f_xslt)
        if xslt == None:
        raise UnicodeError("Cannot read xslt files. XSLT transformers are empty")
        self.transformer = ET.XSLT(xslt)    
        self.xml_parser = ET.XMLParser(recover=True)
```

Es importante recalcar que existen xml cfdi33 que contienen **BOM**. 

> The Byte-Order-Mark (or BOM), is a special marker added at the very beginning of an Unicode file encoded in UTF-8, UTF-16 or UTF-32. It is used to indicate whether the file uses the big-endian or little-endian byte order. The BOM is mandatory for UTF-16 and UTF-32, but it is optional for UTF-8.

Para este evitar errores al realizar un parse de un xml con BOM utilizando lxml.etree es necesario declarar el parser de la siguiente manera:
```python
self.xml_parser = ET.XMLParser(recover=True)
```
Si declaramos el XMLParser con la opción de encoding=’utf-8’ y el xml que leemos tiene BOM es altamente probable que que nos regrese una transformación vacía.
```python
self.xml_parser = ET.XMLParser(recover=True,encoding='utf-8')
```
Dentro de la clase Transformer vamos a definir 2 funciones que nos ayudarán con la transformación de xml a texto y de texto a una lista respectivamente.
```python
def to_columns_from_file(self, xml_file):
    if '.xml' in xml_file:
        try:        
            xml = ET.parse(xml_file, parser=self.xml_parser)
            return self.convert_to_columns(str(self.transformer(xml)))
        except Exception as ex:
            print(ex)
            return
```
Declaramos la función **to_columns_from_file**. Este método recibe un xml_file que contiene el full path del archivo xml que vamos a convertir, validamos si es un .xml file. Realizamos un parse del documento xml utilizando el parser **xml_parser** mediante la función ET.parse ( ET alias de lxml.etree ). Al resultado le aplicamos la transformación utilizando el **transformer** el cual recibe como parámetro el **xml** resultado del parse. 
```python
str(self.transformer(xml))
```
La sentencia anterior nos regresara la cadena de texto resultado de la transformación de xslt + xml aplicando el template que definimos a través del archivo cfdi33.xslt.

El resultado esperado es una cadena de texto. Ejemplo :
```text
3.3~F~6~2019-09-28T21:05:58~20001000000300022815~12000.00~0.00~13920.00
```
A esta cadena le aplicamos la función **convert_to_columns**.
```python
def convert_to_columns(self,line):
    return str(line).split("~")
```
Una vez que obtenemos nuestra cadena de texto resultado de la transformación del xslt + xml lo único que tenemos que hacer es transformarlo a una lista. Para eso definimos la función **convert_to_columns**. Esta función simplemente hace un split a un string utilizando el carácter “~” que definimos dentro de nuestro template **cfdi33.xslt** para separar cada valor del xml.

Para implementar la clase Transformer y poder obtener el resultado de la transformación utilizamos el siguiente codigo:
```python
if __name__ == "__main__":
    transformer = Transformer()
    result = transformer.to_columns_from_file('cfdi33.xml')
    print(result)
```
Utilizando la transformación de xml - texto y su transformación de texto a lista obtenemos el siguiente resultado:
```text
['3.3', 'F', '6', '2019-09-28T21:05:58', '20001000000300022815', '12000.00', '', '13920.00']
```
Un transformador **XSLT** es una forma muy eficiente de extraer información de documentos utilizando templates que podemos reutilizar. XSLT nos permite realizar la mayoría de las transformaciones necesarias para extraer la información de documentos xml que nos permite  reutilizar código, declaracion de variables , agrupaciones por valores etc. 

## Ventajas y Desventajas

### Ventajas de utilizar XSLT + Python
* XSLT es un estándar ampliamente utilizado. 
* Reutilización de código. 
* Facil de aprender. Poca curva de aprendizaje.
* Eficiente con xml pequeños.

### Desventajas de utilizar XSLT + Python
* El performance se degrada con documentos grandes. 
* El manejo de memoria es ineficiente.

## Benchmark
Al ejecutar algunas pruebas con 10,000 loops para diferentes tamaños de documentos estos son los resultados en segundos de ejecución con un equipo I7-8750H CPU @2.2GHz , 16GB RAM:
```text
10000 Loops,file size  5 kb, 7.7238973 seconds
10000 Loops,file size  185 kb, 38.2367447 seconds
10000 Loops, file size 1,516 kb, 52.62266699999999 seconds
10000 Loops, file size 8,846 kb, 1532.9386100000002 seconds
```
#### Github example:
[https://github.com/swsapien/xslt-cfdi-transform-example](https://github.com/swsapien/xslt-cfdi-transform-example)

Si necesitas convertir xml cfdi 3.3 puedes utilizar nuestra librería open source para transformar algunos tipos de documento cfdi 3.3 como documento de pagos (pagos10), nomina (nomina12), obtener el detalle de conceptos y los generales de un cfdi 3.3 y cfdi 3.2.

[https://pypi.org/project/pycfdi-transform/](https://pypi.org/project/pycfdi-transform/)

Si deseas colaborar a nuestra librería contactanos a dev@sw.com.mx o a través de nuestro repositorio en github:

[https://github.com/swsapien/pycfdi-transform](https://github.com/swsapien/pycfdi-transform)