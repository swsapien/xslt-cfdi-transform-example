import os
import lxml.etree as ET
import xlsxwriter
import timeit

if __name__ == "__main__":
    setup = "from main import Transformer"    
    print('10000 Loops 5 kb file size %s' % timeit.timeit("Transformer().to_columns_from_file('cfdi33.xml')",setup=setup,number=10000))
    print('10000 Loops 185 kb file size %s' % timeit.timeit("Transformer().to_columns_from_file('cfdi33_800.xml')",setup=setup,number=10000))
    print('10000 Loops 1,516 kb file size %s' % timeit.timeit("Transformer().to_columns_from_file('cfdi33_1516.xml')",setup=setup,number=10000))
    print('10000 Loops 8,846 kb file size %s' % timeit.timeit("Transformer().to_columns_from_file('cfdi33_50028.xml')",setup=setup,number=10000))