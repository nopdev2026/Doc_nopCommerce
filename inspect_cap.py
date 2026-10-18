import re
m = open('Manual de usuario V01 de nopCommerce.md', encoding='utf-8').read()
lines = m.split('\n')
# Mostrar encabezados H2/H3 del Capitulo 18
cap=None
for i,l in enumerate(lines):
    if l.startswith('## Cap'):
        cap = l
    if cap and 'capitulo-18' in (l.lower()) or (cap and 'Capítulo 18' in (cap)):
        pass
# mas directo: localizar Capitulo 18 y sus H3
idx18 = m.find('#capitulo-18')
idx19 = m.find('#capitulo-19')
seg = m[idx18:idx19]
print("=== H2/H3 dentro del Capitulo 18 ===")
for l in seg.split('\n'):
    if re.match(r'^#{2,3} ', l):
        print(l)
print()
print("=== numero total de H3 en todo el manual ===", len(re.findall(r'^### ', m, re.M)))
print("=== numero total de H2 en todo el manual ===", len(re.findall(r'^## ', m, re.M)))
