import re
from pypdf import PdfReader

r = PdfReader(r'publicacion\imprimir\Manual_NopCommerce_Del_Desarrollador.pdf')
n = len(r.pages)
print('paginas:', n)

def find(needle, limit=8, start=1):
    # Comparacion insensible a saltos de linea: pypdf parte los titulos largos
    # en varias lineas, de modo que 'Rendimiento, compresion y despliegue' no
    # coincide con el texto crudo.
    need = re.sub(r'\s+', ' ', needle)
    hits = []
    for i, pg in enumerate(r.pages):
        if i + 1 < start:
            continue
        hay = re.sub(r'\s+', ' ', pg.extract_text() or '')
        if need in hay:
            hits.append(i + 1)
            if len(hits) >= limit:
                break
    return hits

# La TOC numerada de LaTeX ocupa las paginas 3..6; el cuerpo empieza en la 7.
# start=7 evita que las agujas devuelvan la propia TOC.
print('copyright pags:', find('Reservados todos los derechos'))
print('parte I  (Conceptos esenciales) pags:', find('Conceptos esenciales (recordatorio)', start=7))
print('parte II (Fundamentos) pags:', find('Fundamentos', start=7))
print('cap 1  (Arquitectura) pags:', find('Arquitectura, entidades y dependencias', start=7))
print('cap 32 (Rendimiento) pags:', find('Rendimiento, compresión y despliegue', start=7))
print('apendice A pags:', find('Recursos y referencias', start=7))

# Mapa de fuentes de la apertura del capitulo 32 (antes envenenada).
p32 = find('Rendimiento, compresión y despliegue', start=7)[0]
pg = r.pages[p32 - 1]
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
print(f'=== fuentes pagina {p32} (apertura cap 32) ===')
for name, t in out[:12]:
    print(f'  {name:44s} | {t}')

# TOC: numeros de capitulo y parte. Abarca las paginas 3..6.
toc_text = re.sub(r'\s+', ' ', ''.join(r.pages[p - 1].extract_text() or '' for p in range(3, 7)))
print('TOC paginas 3-6')
print('  entrada "1. Arquitectura":', bool(re.search(r'1\.\s+Arquitectura', toc_text)))
print('  entrada parte "I Conceptos esenciales":', bool(re.search(r'\bI\s+Conceptos esenciales', toc_text)))
print('  entrada parte "II Fundamentos":', bool(re.search(r'\bII\s+Fundamentos', toc_text)))
print('  entrada "32. Rendimiento":', bool(re.search(r'32\.\s+Rendimiento', toc_text)))

# Copyright sin mojibake.
cpy = r.pages[1].extract_text() or ''
print('copyright electronico ok:', 'electrónico' in cpy, '| mojibake:', 'Ã' in cpy)
