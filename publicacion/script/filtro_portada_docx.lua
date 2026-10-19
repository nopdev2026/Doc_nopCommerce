-- Filtro DOCX: fija el ancho de la portada (cover*.png).
-- pandoc incrusta las imágenes a tamaño natural: cover_usuarios.png mide
-- 1024x1536 px (~10.7x16 in), demasiado para una página carta. Con width=6in
-- el alto resultante (9in, proporción 2:3 intacta) encaja en el área de texto
-- de una carta con márgenes de 1 in (6.5x9 in).
-- Solo se usa en la salida docx (build_docx_nopcommerce.ps1). El PDF no lo
-- necesita: filtro_libro_nopcommerce.lua elimina la portada del cuerpo y
-- header_usuario.tex la muestra con \maketitle a página completa.

if FORMAT ~= 'docx' then
  return {}
end

local function is_cover_image(src)
  return src:find('cover.*%.png$') ~= nil
end

function Image(img)
  if is_cover_image(img.src) then
    img.attr.attributes.width = '6in'
  end
  return img
end
