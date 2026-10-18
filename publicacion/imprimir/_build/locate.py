from pypdf import PdfReader

r = PdfReader(r'publicacion\imprimir\Manual_NopCommerce_Del_Desarrollador.pdf')

def pages_with(needle):
    return [i + 1 for i, pg in enumerate(r.pages) if needle in (pg.extract_text() or '')]

# Apertura cap 32: pagina con 'Nivel: Avanzado' y 'despliegue' en la cabecera.
cand = [p for p in pages_with('Avanzado') if 'despliegue' in (r.pages[p-1].extract_text() or '')]
print('cap32 candidatas:', cand[:5])

# Pagina de parte I: texto muy corto y que contiene 'Conceptos esenciales'.
sparse = []
for i, pg in enumerate(r.pages):
    t = (pg.extract_text() or '').strip()
    if 'Conceptos esenciales' in t and len(t) < 160:
        sparse.append((i + 1, t.replace('\n', ' | ')[:120]))
print('paginas parte I (sparse):', sparse[:3])

# Apertura cap 6 (arboles): primera pagina NO-toc con 'Proyectos de la soluci'.
c6 = [p for p in pages_with('Proyectos de la solución') if p > 6]
print('cap6 paginas:', c6[:3])

# Apendice A: pagina con 'Apéndice A' literal.
apa = pages_with('Apéndice A')
print('apendice A paginas:', apa[:5])

# Una prosa con flecha →: localizar pagina con '→' (pypdf lo extrae).
arrow = []
for i, pg in enumerate(r.pages):
    t = pg.extract_text() or ''
    if '→' in t:
        arrow.append(i + 1)
    if len(arrow) >= 5:
        break
print('paginas con →:', arrow)
