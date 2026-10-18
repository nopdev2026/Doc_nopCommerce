import re
m = open('Manual de usuario V01 de nopCommerce.md', encoding='utf-8').read()
idx18 = m.find('#capitulo-18')
idx19 = m.find('#capitulo-19')
seg = m[idx18:idx19]
print(seg[:2600])
