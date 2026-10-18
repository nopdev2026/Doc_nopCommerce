import re
m = open('Manual de usuario V01 de nopCommerce.md', encoding='utf-8').read()
caps = [(int(mm.group(1)), mm.start()) for mm in re.finditer(r'^## Cap[ií]tulo (\d+)\b', m, re.M)]
caps.append((9999, len(m)))
def whichchap(pos):
    for i in range(len(caps)-1):
        if caps[i][1] <= pos < caps[i+1][1]:
            return caps[i][0]
    return None
for kw in ['Multi-tienda','multitienda','Multi Store','varias tiendas','SMS','Twilio','Jotform','tiendas asignadas','Ajustes globales','Ajustes avanzados','configuration','cola de mensajes','Message queue','Elasticsearch','Lucene']:
    hits=[whichchap(mm.start()) for mm in re.finditer(re.escape(kw), m)]
    uniq=sorted(set(h for h in hits if h))
    print(f"{kw:22s} -> caps {uniq}  (n={len(hits)})")
