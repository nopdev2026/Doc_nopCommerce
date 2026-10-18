#!/usr/bin/env python3
"""Genera cover.png (7x10" @300 dpi = 2100x3000) para el volumen nopCommerce,
replicando la plantilla de "El Códice del Desarrollador" (portada de
javascript/cover.png): fondo blanco, título negro condensado a cuatro líneas,
cuadro amarillo con sigla, regla amarilla, VOLUMEN + tecnología, subtítulo a
dos líneas, fila de iconos, badge amarillo y autor.

Uso: python generar_portada.py [ruta_salida]   (por defecto cover.png en la raíz)
"""
import os
import sys

from PIL import Image, ImageDraw, ImageFont

W, H = 2100, 3000
YELLOW = (241, 185, 17)
BLACK = (0, 0, 0)
MARGIN = 105

FONTS_IMPACT = [r"C:\Windows\Fonts\impact.ttf", "/usr/share/fonts/truetype/impact.ttf"]
FONTS_BOLD = [
    r"C:\Windows\Fonts\segoeuib.ttf",
    r"C:\Windows\Fonts\bahnschrift.ttf",
    r"C:\Windows\Fonts\arialbd.ttf",
]


def _first(paths):
    for p in paths:
        if os.path.exists(p):
            return p
    raise SystemExit("No se encontró ninguna fuente: " + ", ".join(paths))


IMPACT = _first(FONTS_IMPACT)
BOLD = _first(FONTS_BOLD)


def fit_font(text, max_w, start, path=IMPACT):
    size = start
    while size > 10:
        f = ImageFont.truetype(path, size)
        if f.getlength(text) <= max_w:
            return f
        size -= 4
    return ImageFont.truetype(path, 10)


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else "cover.png"
    im = Image.new("RGB", (W, H), (255, 255, 255))
    d = ImageDraw.Draw(im)
    max_w = W - 2 * MARGIN

    # --- Título a cuatro líneas (negro, condensado) ---
    f_title = fit_font("DESARROLLADOR", max_w, 288)
    cap = int(f_title.size * 0.72)
    step = int(f_title.size * 0.74)
    y = 100 + cap
    for line in ("EL", "CÓDICE", "DEL", "DESARROLLADOR"):
        d.text((MARGIN, y), line, font=f_title, fill=BLACK, anchor="ls")
        y += step

    # --- Cuadro amarillo con sigla (esquina superior derecha) ---
    sq = 460
    d.rectangle([W - MARGIN - sq, 100, W - MARGIN, 100 + sq], fill=YELLOW)
    f_sig = fit_font("nop", sq - 80, 210)
    d.text((W - MARGIN - sq / 2, 100 + sq / 2), "nop", font=f_sig, fill=BLACK, anchor="mm")

    # --- Regla amarilla + VOLUMEN + tecnología (posiciones absolutas) ---
    y_rule = 1000
    d.rectangle([MARGIN, y_rule, MARGIN + 520, y_rule + 18], fill=YELLOW)
    f_vol = ImageFont.truetype(IMPACT, 85)
    base_vol = y_rule + 18 + 62                    # línea base VOLUMEN IV
    d.text((MARGIN, base_vol), "VOLUMEN IV", font=f_vol, fill=BLACK, anchor="ls")
    f_tec = fit_font("NOPCOMMERCE", max_w, 340)
    base_tec = base_vol + 70 + int(f_tec.size * 0.72)
    d.text((MARGIN, base_tec), "NOPCOMMERCE", font=f_tec, fill=YELLOW, anchor="ls")

    # --- Subtítulo a dos líneas ---
    f_sub = ImageFont.truetype(IMPACT, 78)
    base_s1 = base_tec + 95
    w1 = f_sub.getlength("MANUAL DE DESARROLLO")
    d.text((MARGIN, base_s1), "MANUAL DE DESARROLLO", font=f_sub, fill=YELLOW, anchor="ls")
    d.text((MARGIN + w1 + 22, base_s1), " DE LA", font=f_sub, fill=BLACK, anchor="ls")
    base_s2 = base_s1 + 96
    d.text((MARGIN, base_s2), "PLATAFORMA DE COMERCIO ELECTRÓNICO", font=f_sub, fill=BLACK, anchor="ls")

    # --- Fila de iconos de línea (amarillo) + etiquetas ---
    y_icons = base_s2 + 80
    n = 5
    col = max_w / n

    def cx(i):
        return MARGIN + col * i + col / 2

    def box(i, size=170):
        x0 = int(cx(i) - size / 2)
        return x0, y_icons, x0 + size, y_icons + size

    sw = 13
    # 1) Arquitectura: tres capas apiladas
    x0, yt, x1, yb = box(0)
    for k in (0, 46, 92):
        d.rounded_rectangle([x0 + 4, yt + 20 + k, x1 - 4, yt + 48 + k], radius=8,
                            outline=YELLOW, width=sw)
    # 2) Tema: ventana con barra superior
    x0, yt, x1, yb = box(1)
    d.rounded_rectangle([x0 + 2, yt + 12, x1 - 2, yb - 2], radius=12, outline=YELLOW, width=sw)
    d.line([x0 + 2, yt + 52, x1 - 2, yt + 52], fill=YELLOW, width=sw)
    d.ellipse([x0 + 18, yt + 26, x0 + 36, yt + 44], outline=YELLOW, width=sw - 2)
    d.rectangle([x0 + 30, yt + 80, x1 - 30, yb - 22], outline=YELLOW, width=sw - 2)
    # 3) Plugins: pieza con saliente circular
    x0, yt, x1, yb = box(2)
    d.rounded_rectangle([x0 + 2, yt + 50, x1 - 2, yb - 2], radius=12, outline=YELLOW, width=sw)
    d.arc([x0 + 48, yt + 2, x0 + 122, yt + 76], start=180, end=360, fill=YELLOW, width=sw)
    # 4) Eventos: rayo
    x0, yt, x1, yb = box(3)
    pts = [(x0 + 95, yt + 4), (x0 + 28, yt + 96), (x0 + 72, yt + 96), (x0 + 52, yb - 4),
           (x0 + 142, yt + 80), (x0 + 96, yt + 80)]
    d.line(pts + [pts[0]], fill=YELLOW, width=sw, joint="curve")
    # 5) Multi-tienda: toldo + cuerpo
    x0, yt, x1, yb = box(4)
    d.line([(x0 + 6, yt + 58), (x0 + 22, yt + 12), (x1 - 22, yt + 12), (x1 - 6, yt + 58)],
           fill=YELLOW, width=sw, joint="curve")
    d.line([x0 + 6, yt + 58, x1 - 6, yt + 58], fill=YELLOW, width=sw)
    d.rectangle([x0 + 22, yt + 58, x1 - 22, yb - 2], outline=YELLOW, width=sw)
    d.rectangle([x0 + 60, yt + 100, x0 + 110, yb - 2], outline=YELLOW, width=sw - 2)

    f_lab = ImageFont.truetype(BOLD, 46)
    for i, lab in enumerate(("ARQUITECTURA", "TEMA", "PLUGINS", "EVENTOS", "MULTI-TIENDA")):
        d.text((cx(i), y_icons + 232), lab, font=f_lab, fill=BLACK, anchor="mm")

    # --- Badge amarillo ---
    by = 2060
    d.rounded_rectangle([MARGIN, by, W - MARGIN, by + 230], radius=45, fill=YELLOW)
    f_badge = fit_font("</> | REFERENCIA TÉCNICA | ARQUITECTURA | EJEMPLOS C#", max_w - 160, 74)
    d.text((W / 2, by + 115), "</> | REFERENCIA TÉCNICA | ARQUITECTURA | EJEMPLOS C#",
           font=f_badge, fill=BLACK, anchor="mm")

    # --- Autor ---
    f_auth = fit_font("CÉSAR DELGADO", max_w, 280)
    d.text((MARGIN, H - 122), "CÉSAR DELGADO", font=f_auth, fill=YELLOW, anchor="ls")

    im.save(out)
    print("cover.png generado:", out)


if __name__ == "__main__":
    main()
