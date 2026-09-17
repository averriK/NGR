-- page-footer.lua
-- Appends the SRK page footer to book/html output, built from metadata.
-- Same data-driven pattern as footer.lua (revealjs).
-- footer-title (default: title) and footer-meta (default:
-- "SRK Consulting © <footer-year|render year>").

local function stringify(v)
  return v and pandoc.utils.stringify(v) or ""
end

local function escape(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local title_text = ""
local meta_text = ""

function Meta(meta)
  title_text = stringify(meta["footer-title"])
  -- Book renders: keep the report title constant across chapter pages.
  if title_text == "" and type(meta.book) == "table" and meta.book.title then
    title_text = stringify(meta.book.title)
  end
  if title_text == "" then title_text = stringify(meta.title) end
  meta_text = stringify(meta["footer-meta"])
  if meta_text == "" then
    local year = stringify(meta["footer-year"])
    if year == "" then year = os.date("%Y") end
    meta_text = "SRK Consulting © " .. year
  end
  local stamp = pandoc.system.environment()["QRT_RENDER_STAMP"] or ""
  if stamp ~= "" then meta_text = meta_text .. " · " .. stamp end
end

function Pandoc(doc)
  if title_text == "" and meta_text == "" then
    return nil
  end
  local html = '<div class="page-footer column-body"><div class="page-footer__inner"><div class="page-footer__content">'
  if title_text ~= "" then
    html = html .. '<div class="page-footer__title">' .. escape(title_text) .. '</div>'
  end
  html = html .. '<div class="page-footer__meta">' .. escape(meta_text) .. '</div></div></div></div>'
  table.insert(doc.blocks, pandoc.RawBlock('html', html))
  return doc
end
