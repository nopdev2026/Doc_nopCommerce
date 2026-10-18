import re
from pypdf import PdfReader

r = PdfReader(r'publicacion\imprimir\Manual_NopCommerce_Del_Desarrollador.pdf')
n = len(r.pages)
print('paginas:', n)

def find(needle, limit=8):
    hits = []
    for i, pg in enumerate(r.pages):
        if needle in (pg.extract_text() or ''):
            hits.append(i + 1)
            if len(hits) >= limit:
                break
    return hits

print('copyright pags:', find('Reservados todos los derechos'))
print('parte i pags:', find('Fundamentos'))
print('cap 28 pags:', find('Rendimiento, compresión y despliegue'))
print('apendice A pags:', find('Recursos y referencias'))

# Mapa de fuentes de la apertura del capitulo 28 (antes envenenada).
p28 = find('Rendimiento, compresión y despliegue')[0]
pg = r.pages[p28 - 1]
out = []
def visitor(text, cm, tm, font_dict, fs):
    t = text.strip()
    if not t or not font_dict:
        return
    name = str(font_dict.get('/BaseFont', '?')).replace('Identity-H', '')
    if out and out[-1][0] == name:
        out[-1][1] += ' ' + t[:34]
    else:
        out.append([name, t[:34]])
pg.extract_text(visitor_text=visitor)
print(f'=== fuentes pagina {p28} (apertura cap 28) ===')
for name, t in out[:12]:
    print(f'  {name:44s} | {t}')

# TOC: numeros de capitulo y parte.
tocp = find('Índice general')[0]
t = r.pages[tocp - 1].extract_text() or ''
print('TOC pagina', tocp)
print('  entrada "1 Visión general":', bool(re.search(r'1\s+Visi', t)))
print('  entrada parte "I Fundamentos":', bool(re.search(r'I\s+Fundamentos', t)))
print('  entrada "28 Rendimiento":', bool(re.search(r'28\s+Rendimiento', t)))

# Copyright sin mojibake.
cpy = r.pages[1].extract_text() or ''
print('copyright electronico ok:', 'electrónico' in cpy, '| mojibake:', 'Ã' in cpy)
