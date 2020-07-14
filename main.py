import lxml.etree as ET
import xlsxwriter
import timeit

class Transformer:
  def __init__(self):    
    with open('cfdi33.xslt', 'r', encoding='utf-8') as f_xslt:
      xslt = ET.parse(f_xslt)
    if xslt == None:
      raise UnicodeError("Cannot read xslt files. XSLT transformers are empty")
    self.transformer = ET.XSLT(xslt)    
    self.xml_parser = ET.XMLParser(recover=True)
  
  def to_columns_from_file(self, xml_file):
    if '.xml' in xml_file:
      try:        
        xml = ET.parse(xml_file, parser=self.xml_parser)
        return self.convert_to_columns(str(self.transformer(xml)))
      except Exception as ex:
        print(ex)
        return
  
  def convert_to_columns(self,line):
    return str(line).split("~")

if __name__ == "__main__":
    transformer = Transformer()
    result = transformer.to_columns_from_file('cfdi33.xml')
    print(result)