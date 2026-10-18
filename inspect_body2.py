import re
m = open('Manual de usuario V01 de nopCommerce.md', encoding='utf-8').read()
# Buscar el encabezado real de Capitulo 18 (linea que empieza por '## Cap')
h18 = re.search(r'^## Cap[ií]tulo 18\b.*$', m, re.M)
h19 = re.search(r'^## Cap[ií]tulo 19\b.*$', m, re.M)
seg = m[h18.start():h19.start()]
print("LONGITUD CAP18:", len(seg))
print("=== primeras 2400 chars ===")
print(seg[:2400])
