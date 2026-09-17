-- cover-title.lua
-- In flat outputs (docx) the book assembly inserts a level-1 heading for
-- every chapter, including the cover (index.qmd, title "TOC"). The document
-- Title paragraph already opens the report, so that heading is noise.
-- Drops only the first level-1 header whose text is exactly "TOC".
local dropped = false

function Header(el)
  if not dropped and el.level == 1
      and pandoc.utils.stringify(el) == "TOC" then
    dropped = true
    return {}
  end
end
