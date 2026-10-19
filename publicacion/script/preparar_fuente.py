#!/usr/bin/env python3
"""Prepara una copia temporal del manual para el build LaTeX 7x10.

El manual cerrado (fuente) NUNCA se modifica; este script genera una copia
idéntica salvo por dos transformaciones mecánicas de maquetación:

  1) Sustituye cada bloque ```mermaid por su imagen pre-renderizada (mermaid-cli),
     en el orden de aparición: la imagen i corresponde al bloque i.
  2) Limita el ancho natural de las imágenes que desbordan el texto
     (7x10" con márgenes 20/23/22 mm => ancho útil 5.1 in, alto útil 8.0 in)
     añadiendo el atributo {width=X.XXin} que pandoc convierte a
     \\includegraphics[width=...]. Las imágenes que ya caben quedan intactas.

Uso:
  python preparar_fuente.py extraer-mermaid <fuente.md> <out.mmd>
      Extrae los bloques ```mermaid y escribe sus rutas, una por línea, en
      stdout. Con un solo bloque (caso histórico) usa <out.mmd> tal cual; con
      N>1 usa la serie <out>_1.mmd … <out>_N.mmd y elimina los previos.
  python preparar_fuente.py preparar <fuente.md> <destino.md> [img1.png ...]
      Escribe la copia transformada: el bloque i se reemplaza por la imagen i.
      Se exige igualdad entre bloques e imágenes (un desfase colocaría un
      diagrama en el lugar de otro). '' o ningún argumento deja los bloques
      como código.
"""
import re
import sys

MAX_W_IN = 5.1   # ancho útil de la caja de texto (7in - márgenes)
MAX_H_IN = 8.0   # alto útil por página (10in - márgenes)

MERMAID_RE = re.compile(r"```mermaid[^\n]*\n(.*?)\n```", re.DOTALL)
IMG_RE = re.compile(r"(!\[[^\]]*\]\(([^)]+)\))(\{[^}]*\})?")


def extraer_mermaid(src: str, out_path: str) -> list:
    """Escribe los bloques mermaid y devuelve las rutas escritas."""
    import glob
    import os

    blocks = MERMAID_RE.findall(src)
    stem, _ext = os.path.splitext(out_path)

    # Varrido de la serie numerada: evita ficheros huérfanos cuando cambia
    # el número de bloques entre ejecuciones.
    for old in glob.glob(stem + "_*.mmd"):
        os.remove(old)

    if len(blocks) <= 1:
        paths = [out_path]
        with open(out_path, "w", encoding="utf-8", newline="\n") as f:
            f.write(blocks[0] if blocks else "")
        return paths

    paths = []
    for i, body in enumerate(blocks, 1):
        path = f"{stem}_{i}.mmd"
        with open(path, "w", encoding="utf-8", newline="\n") as f:
            f.write(body)
        paths.append(path)
    return paths


def _natural_in(path: str):
    """(ancho_in, alto_in) naturales de la imagen; None si no se puede leer."""
    try:
        from PIL import Image
    except ImportError:
        return None
    try:
        with Image.open(path) as im:
            w_px, h_px = im.size
            dpi = im.info.get("dpi")
            d = float(dpi[0]) if dpi and dpi[0] else 72.0
    except Exception:
        return None
    return w_px / d, h_px / d


def _cap_width(src_text: str, base_dir: str) -> str:
    """Añade {width=...} a las imágenes que desbordan el ancho/alto útiles."""
    import os

    def repl(m):
        whole, path = m.group(1), m.group(2)
        existing = m.group(3)
        if existing or path.startswith(("http:", "https:")):
            return whole
        nat = _natural_in(os.path.join(base_dir, path))
        if not nat:
            return whole
        w_in, h_in = nat
        if w_in <= MAX_W_IN and h_in <= MAX_H_IN:
            return whole
        width = min(MAX_W_IN, MAX_H_IN * (w_in / h_in))
        return f"{whole}{{width={width:.2f}in}}"

    # Solo se tocan líneas de imagen fuera de bloques de código.
    out, in_fence = [], False
    for line in src_text.split("\n"):
        if line.startswith("```"):
            in_fence = not in_fence
        out.append(line if in_fence else IMG_RE.sub(repl, line))
    return "\n".join(out)


def preparar(src_path: str, dst_path: str, images: list) -> None:
    with open(src_path, "r", encoding="utf-8") as f:
        src = f.read()

    images = [img for img in images if img]
    if images:
        n_blocks = len(MERMAID_RE.findall(src))
        if len(images) != n_blocks:
            raise SystemExit(
                f"error: la fuente tiene {n_blocks} bloques mermaid y se "
                f"pasaron {len(images)} imágenes; el desfase colocaría un "
                f"diagrama en el lugar de otro"
            )
        it = iter(images)
        src = MERMAID_RE.sub(
            lambda m: f"![Diagrama de flujo del proceso]({next(it)})", src
        )

    src = _cap_width(src, ".")
    with open(dst_path, "w", encoding="utf-8", newline="\n") as f:
        f.write(src)


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    modo = sys.argv[1]
    if modo == "extraer-mermaid" and len(sys.argv) == 4:
        with open(sys.argv[2], "r", encoding="utf-8") as f:
            for path in extraer_mermaid(f.read(), sys.argv[3]):
                print(path)
        return 0
    if modo == "preparar" and len(sys.argv) >= 4:
        preparar(sys.argv[2], sys.argv[3], sys.argv[4:])
        return 0
    print(__doc__)
    return 2


if __name__ == "__main__":
    sys.exit(main())
