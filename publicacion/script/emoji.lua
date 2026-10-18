-- emoji.lua — Convierte los marcadores emoji del texto (⚠️ 💡 🆕 🔄) en
-- imágenes PNG embebidas. Compartido por los filtros de pandoc (docx, epub,
-- libro/LaTeX) para que Amazon KDP los renderice sin depender de fuentes emoji.
-- Los PNG son glifos de Noto Color Emoji (SIL OFL 1.1), incrustables.
-- Uso desde un filtro:
--   local emoji = dofile(<ruta a emoji.lua>)
--   function Str(s) return emoji.replace_str(s.text) end

local M = {}

-- Secuencias emoji (incluye ⚠ sin selector de variación) -> PNG y texto alt.
M.map = {
  ["\u{26A0}\u{FE0F}"] = { src = "publicacion/emoji/small_emoji_u26a0.png", alt = "aviso" },
  ["\u{26A0}"]         = { src = "publicacion/emoji/small_emoji_u26a0.png", alt = "aviso" },
  ["\u{1F4A1}"]        = { src = "publicacion/emoji/small_emoji_u1f4a1.png", alt = "idea" },
  ["\u{1F195}"]        = { src = "publicacion/emoji/small_emoji_u1f195.png", alt = "nuevo" },
  ["\u{1F504}"]        = { src = "publicacion/emoji/small_emoji_u1f504.png", alt = "muta" },
}

-- Claves ordenadas de más a menos largas (para que "⚠️" gane a "⚠").
local keys = {}
for k in pairs(M.map) do keys[#keys + 1] = k end
table.sort(keys, function(a, b) return #a > #b end)

-- Devuelve la primera posición y la secuencia emoji encontrada en `text`.
local function find_first(text)
  local best_pos, best_key = nil, nil
  for _, k in ipairs(keys) do
    local p = text:find(k, 1, true)
    if p and (best_pos == nil or p < best_pos) then
      best_pos, best_key = p, k
    end
  end
  return best_pos, best_key
end

-- Devuelve una lista de inlines (Str / Image) con los emojis como imágenes.
function M.replace_str(text)
  local out = {}
  local rest = text
  while rest ~= "" do
    local pos, key = find_first(rest)
    if not pos then
      out[#out + 1] = pandoc.Str(rest)
      break
    end
    if pos > 1 then
      out[#out + 1] = pandoc.Str(rest:sub(1, pos - 1))
    end
    local e = M.map[key]
    local img = pandoc.Image({ pandoc.Str(e.alt) }, e.src)
    img.attr = pandoc.Attr("", { "emoji" }, { height = "0.9em" })
    out[#out + 1] = img
    rest = rest:sub(pos + #key)
  end
  return out
end

return M