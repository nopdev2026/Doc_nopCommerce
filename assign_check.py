import re
m = open('Manual de usuario V01 de nopCommerce.md', encoding='utf-8').read()
# mapa de caps: (num, inicio)
caps = [(int(mm.group(1)), mm.start()) for mm in re.finditer(r'^## Cap[ií]tulo (\d+)\b', m, re.M)]
caps.append((999, len(m)))
def whichchap(pos):
    for i in range(len(caps)-1):
        if caps[i][1] <= pos < caps[i+1][1]:
            return caps[i][0]
    return None
for kw in ['multitienda','Multi-store','multitiendas','varias tiendas','web farm','granja','equilibr','balancing','Azure','Linux','local']:
    for mm in re.finditer(re.escape(kw), m):
        print(f"{kw:14s} -> Cap {whichchap(mm.start())}")
        break
