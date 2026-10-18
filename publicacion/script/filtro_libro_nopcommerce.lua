-- Filtro Lua para el libro impreso (KDP Paperback 7"x10") del
-- "Manual de desarrollo V01 de nopCommerce" — derivado de filtro_libro.lua
-- de la colección (javascript/publicacion/script/filtro_libro.lua).
--
-- Diferencias respecto al filtro de la colección:
-- 1) Solo se elimina el PRIMER H1 (título del documento); los H1 restantes
--    ("Parte I…VII" y "Apéndices") se convierten en \part de la clase book.
--    En "Apéndices" se emite además \appendix (capítulos A/B/C) y se renombra
--    \chaptername para que la apertura diga "Apéndice A…".
-- 2) La sección estática "Índice general" (no "Tabla de contenido") se
--    elimina junto con su lista de VIÑETAS (el índice del manual no es una
--    lista numerada). Se conserva también el borrado de listas numeradas.
-- 3) Los títulos "Capítulo N — …" y "Apéndice X — …" pierden la marca
--    inicial para que la clase book numere: "Capítulo 1. Visión general" /
--    "Apéndice A. Recursos y referencias" (numeración canónica).
-- El resto es idéntico a la colección: primer BlockQuote (metadatos V01)
-- eliminado, HorizontalRule eliminados, tablas longtable, emojis, portada
-- (cover.png) fuera del cuerpo (la muestra el \maketitle).

local skip_list = false
local subtitle_removed = false
local title_removed = false

-- Emojis como imágenes embebidas (Noto Color Emoji, para KDP).
local script_dir = PANDOC_SCRIPT_FILE and PANDOC_SCRIPT_FILE:match("^(.*)[/\\][^/\\]*$") or "."
local emoji = dofile(script_dir .. "/emoji.lua")

-- Glifos ausentes en TeX Gyre Pagella usados en prosa: se emiten como
-- RawInline con cambio de fuente ACOTADO a un grupo {\symbolfont\char"XXXX}.
-- (No se usa \newunicodechar: sus caracteres activos rompen microtype.)
local FALLBACK = {
  ["\u{2192}"] = '\\char"2192', -- →
  ["\u{2190}"] = '\\char"2190', -- ←
  ["\u{2193}"] = '\\char"2193', -- ↓
  ["\u{25B2}"] = '\\char"25B2', -- ▲
  ["\u{25BC}"] = '\\char"25BC', -- ▼
  ["\u{2264}"] = '\\char"2264', -- ≤
  ["\u{2265}"] = '\\char"2265', -- ≥
  ["\u{2500}"] = '\\char"2500', -- ─
  ["\u{2502}"] = '\\char"2502', -- │
  ["\u{251C}"] = '\\char"251C', -- ├
  ["\u{2514}"] = '\\char"2514', -- └
  ["\u{250C}"] = '\\char"250C', -- ┌
  ["\u{2510}"] = '\\char"2510', -- ┐
  ["\u{2518}"] = '\\char"2518', -- ┘
  ["\u{2524}"] = '\\char"2524', -- ┤
  ["\u{252C}"] = '\\char"252C', -- ┬
  ["\u{2534}"] = '\\char"2534', -- ┴
  ["\u{253C}"] = '\\char"253C', -- ┼
}

-- Devuelve true si `text` contiene algún glifo de FALLBACK.
local function has_fallback(text)
  for k in pairs(FALLBACK) do
    if text:find(k, 1, true) then return true end
  end
  return false
end

-- Parte `text` en inlines: los glifos FALLBACK pasan a RawInline LaTeX.
local function split_fallback(text)
  local out = {}
  local i = 1
  while true do
    local best_p, best_k, best_rep = nil, nil, nil
    for k, rep in pairs(FALLBACK) do
      local p = text:find(k, i, true)
      if p and (not best_p or p < best_p) then
        best_p, best_k, best_rep = p, k, rep
      end
    end
    if not best_p then
      if i <= #text then out[#out + 1] = pandoc.Str(text:sub(i)) end
      break
    end
    if best_p > i then
      out[#out + 1] = pandoc.Str(text:sub(i, best_p - 1))
    end
    out[#out + 1] = pandoc.RawInline("latex", "{\\symbolfont" .. best_rep .. "}")
    i = best_p + #best_k
  end
  return out
end

-- ===== Rutas largas: permitir el plegado de línea =====
-- Tanto en código como en texto plano, un token largo con separadores ("/"
-- "." "_" "-") es indivisible para TeX: xelatex no puede plegarlo y la línea
-- se desborda fuera del margen (hasta 125 mm en el manual de desarrollo), con
-- el texto RECORTADO en el borde de la página. La solución es rehacer el token
-- en segmentos separados por \allowbreak.
--
-- El umbral MIN_RUTA acota el alcance: solo se tocan tokens largos, de modo
-- que la maquetación y la paginación del resto del libro quedan intactas.
-- 25 cubre rutas de tabla como "Admin/WidgetsSwiper/Configure" (28).
local MIN_RUTA = 25

local function es_separador(ch)
  return ch == "/" or ch == "." or ch == "_" or ch == "-"
end

-- Devuelve la lista de segmentos si `s` es una ruta larga plegable; si no, nil.
local function segmentos_de(s)
  if #s < MIN_RUTA then return nil end
  local segs, last, tiene_sep = {}, 1, false
  for i = 1, #s do
    if es_separador(s:sub(i, i)) then
      -- El separador se queda al final del segmento: no se abre renglón
      -- con "/" o "." en primera posición.
      segs[#segs + 1] = s:sub(last, i)
      last = i + 1
      tiene_sep = true
    end
  end
  if not tiene_sep then return nil end
  if last <= #s then segs[#segs + 1] = s:sub(last) end
  if #segs < 2 then return nil end
  return segs
end

local function from_segs(segs, make)
  local out = {}
  for i, seg in ipairs(segs) do
    if i > 1 then
      -- El `{}` es imprescindible: sin él, TeX leería `\allowbreakProduct`
      -- (en texto plano no hay llave que corte) como UN solo control sequence
      -- undefined. En `\texttt{…}` no hacía falta porque lo cortaba la llave.
      out[#out + 1] = pandoc.RawInline("latex", "\\allowbreak{}")
    end
    out[#out + 1] = make(seg)
  end
  return out
end

local function partir_token(inlines)
  local out = {}
  for _, inl in ipairs(inlines) do
    if inl.tag == "Str" then
      local segs = segmentos_de(inl.text)
      if segs then
        for _, x in ipairs(from_segs(segs, function(t) return pandoc.Str(t) end)) do
          out[#out + 1] = x
        end
      else
        out[#out + 1] = inl
      end
    else
      out[#out + 1] = inl
    end
  end
  return out
end

function Str(s)
  local out = {}
  for _, inline in ipairs(emoji.replace_str(s.text)) do
    if inline.tag == "Str" and has_fallback(inline.text) then
      for _, x in ipairs(split_fallback(inline.text)) do
        out[#out + 1] = x
      end
    else
      out[#out + 1] = inline
    end
  end
  -- Rutas largas escritas sin acentos en la fuente (típico en celdas de
  -- tabla): se plegan igual que el código.
  return partir_token(out)
end

function Code(c)
  local segs = segmentos_de(c.text)
  if not segs then return nil end
  return from_segs(segs, function(t) return pandoc.Code(t) end)
end

-- ===== Tablas: longtable con maquetación unificada (MaquetaciónLibroGlobal.md) =====
-- Cabecera E8E8E8 centrada/negrita, datos a la izquierda, rejilla completa
-- 999999 0,5 pt, celdas 8 pt (\scriptsize via \AtBeginEnvironment{longtable}).
-- Se reconstruye el longtable para poder inyectar \rowcolor, \hline y \textbf.

local function simple_cell_latex(cell)
  local blocks = cell.contents
  if #blocks > 1 then return nil end
  local b = blocks[1]
  if b and b.tag ~= "Para" and b.tag ~= "Plain" then return nil end
  local s = pandoc.write(pandoc.Pandoc(blocks), "latex")
  s = s:gsub("%s+$", ""):gsub("^%s+", "")
  return s
end

local function fmt_width(w)
  return string.format("%.4f", w)
end

function Table(tbl)
  if not tbl.head or #tbl.head.rows == 0 then return nil end
  local ncols = #tbl.colspecs
  if ncols == 0 then return nil end

  -- Solo reconstruimos tablas con celdas simples (párrafos/plains).
  local rows = {}
  local function collect_rows(rows_in, out)
    for _, r in ipairs(rows_in) do
      local cells = {}
      for _, c in ipairs(r.cells) do
        local s = simple_cell_latex(c)
        if not s then return false end
        cells[#cells + 1] = s
      end
      out[#out + 1] = { header = false, cells = cells }
    end
    return true
  end
  for _, tb in ipairs(tbl.bodies) do
    if not collect_rows(tb.body or tb.rows, rows) then return nil end
  end
  local header_cells = {}
  for _, c in ipairs(tbl.head.rows[1].cells) do
    local s = simple_cell_latex(c)
    if not s then return nil end
    header_cells[#header_cells + 1] = s
  end

  local gaps = 2 * (ncols - 1)
  local spec = "|"
  for i, cs in ipairs(tbl.colspecs) do
    local w = cs.width or 0
    if w <= 0 then w = 1 / ncols end
    spec = spec
      .. ">{\\raggedright\\arraybackslash}p{(\\linewidth - "
      .. gaps .. "\\tabcolsep) * \\real{" .. fmt_width(w) .. "}}|"
  end

  local function render_row(cells, header)
    local parts = {}
    for _, s in ipairs(cells) do
      if header then
        s = "\\begin{minipage}[b]{\\linewidth}\\centering\\textbf{" .. s .. "}\\end{minipage}"
      end
      parts[#parts + 1] = s
    end
    return table.concat(parts, " & ") .. " \\\\"
  end

  local out = {}
  out[#out + 1] = "\\begingroup\n"
  out[#out + 1] = "\\begin{longtable}{" .. spec .. "}\n"
  out[#out + 1] = "\\hline\n"
  out[#out + 1] = "\\rowcolor[HTML]{E8E8E8}\n"
  out[#out + 1] = render_row(header_cells, true) .. "\n"
  out[#out + 1] = "\\hline\n"
  out[#out + 1] = "\\endhead\n"
  for _, r in ipairs(rows) do
    out[#out + 1] = render_row(r.cells, false) .. "\n"
    out[#out + 1] = "\\hline\n"
  end
  out[#out + 1] = "\\endlastfoot\n"
  out[#out + 1] = "\\end{longtable}\n"
  out[#out + 1] = "\\endgroup"

  return pandoc.RawBlock("latex", table.concat(out))
end

-- El índice estático del manual se llama "Índice general" (la colección
-- usa "Tabla de contenido"): se reconocen ambas formas.
local function is_toc_header(h)
  if h.level ~= 2 then return false end
  local t = pandoc.utils.stringify(h.content)
  return t == "Índice general" or t == "Tabla de contenido"
end

local function is_cover_image(el)
  if el.tag ~= "Image" then return false end
  local src = el.src
  return src:find("cover%.png$") ~= nil
end

function Figure(f)
  local img = f.content[1] and f.content[1].content[1]
  if img and is_cover_image(img) then
    return {}
  end
  return nil
end

function Para(p)
  local cover = p.content[1]
  if cover and is_cover_image(cover) then
    return {}
  end
  return nil
end

-- Convierte inlines a LaTeX escapado (para \part).
local function latex_of(inlines)
  local s = pandoc.write(pandoc.Pandoc({ pandoc.Plain(inlines) }), "latex")
  return (s:gsub("%s+$", ""))
end

-- Quita la marca inicial "Capítulo N — " / "Apéndice X — " del título.
-- Los títulos del manual son texto plano (verificado); si no hay coincidencia
-- se conserva el contenido inline original.
local function strip_chapter_mark(h)
  local s = pandoc.utils.stringify(h.content)
  local new = s:gsub("^Capítulo%s+%d+%s+—%s*", "")
  if new == s then
    new = s:gsub("^Apéndice%s+[%u]+%s+—%s*", "")
  end
  if new ~= s then
    h.content = { pandoc.Str(new) }
  end
  return h
end

-- Quita la marca "Parte N — " del título de parte: la clase book imprime
-- "PARTE N" (partname + número romano) y en la TOC queda "I Fundamentos".
local function strip_part_mark(h)
  local s = pandoc.utils.stringify(h.content)
  local new = s:gsub("^Parte%s+[%u]+%s+—%s*", "")
  if new ~= s then
    h.content = { pandoc.Str(new) }
  end
  return h
end

-- Quita la numeración explícita de secciones de apéndice ("A.1 ", "A.1.1 "):
-- la clase book ya numera con \thechapter (\appendix => A.1, A.1.1).
-- Los títulos del manual sin ese prefijo no coinciden con el patrón.
local function strip_appendix_number(h)
  local s = pandoc.utils.stringify(h.content)
  local new = s:gsub("^%u+%.%d+%.%d+%s+", "")
  if new == s then
    new = s:gsub("^%u+%.%d+%s+", "")
  end
  if new ~= s then
    h.content = { pandoc.Str(new) }
  end
  return h
end

function Header(h)
  -- Zona del índice estático: cualquier encabezado posterior cierra la zona
  -- y el "Índice general" (más abajo) la vuelve a abrir. Así se eliminan
  -- TODAS las listas anidadas del índice —pandoc las recorre de dentro
  -- hacia fuera— sin afectar a las listas del cuerpo del libro.
  if not is_toc_header(h) then
    skip_list = false
  end
  if h.level == 1 then
    if not title_removed then
      title_removed = true
      return {} -- quita el título del documento (va en la portada)
    end
    -- H1 restantes: "Parte I…VII" y "Apéndices" -> \part de la clase book.
    local txt = pandoc.utils.stringify(h.content)
    if txt == "Apéndices" then
      -- \part*: la parte de apéndices no continúa la numeración (VIII).
      return pandoc.RawBlock("latex",
        "\\appendix\n\\renewcommand{\\chaptername}{Apéndice}\n"
        .. "\\part*{Apéndices}\n\\phantomsection\n"
        .. "\\addcontentsline{toc}{part}{Apéndices}")
    end
    h = strip_part_mark(h)
    return pandoc.RawBlock("latex", "\\part{" .. latex_of(h.content) .. "}")
  end
  if is_toc_header(h) then
    skip_list = true
    return {}
  end
  h.level = math.max(1, h.level - 1)
  if h.level == 1 then
    h = strip_chapter_mark(h)
  elseif h.level == 2 or h.level == 3 then
    h = strip_appendix_number(h)
  end
  return h
end

function BlockQuote(bq)
  -- El primer BlockQuote es la cabecera de metadatos del documento
  -- (versión, versión de referencia, fuente, última revisión): se elimina.
  if not subtitle_removed then
    subtitle_removed = true
    return {}
  end
  -- Los demás blockquotes ("Trampas frecuentes") pueden contener encabezados
  -- Markdown de ejemplo. Se neutralizan para que no contaminen la TOC.
  local inner = pandoc.walk_block(bq, {
    Header = function(h)
      return pandoc.Para(h.content)
    end,
  })
  return inner
end

function OrderedList(el)
  if skip_list then
    return {}
  end
  return nil
end

-- El "Índice general" del manual es una lista de VIÑETAS anidadas: se
-- eliminan todas las listas de la zona (sin cerrarla) hasta el siguiente
-- encabezado, porque pandoc visita primero las listas anidadas.
function BulletList(el)
  if skip_list then
    return {}
  end
  return nil
end

function HorizontalRule()
  return {}
end
