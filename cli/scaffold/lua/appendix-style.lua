-- appendix-style.lua
-- Restyle appendix headings to appendix paragraph styles from reference.docx.
--
-- Detection: walks headers top-down. When it sees a level-1 Header
-- whose text starts with "Reference" (the References chapter), the
-- next level-1 Header flips into appendix mode. A plain "Appendix"
-- marker is kept as a section cover; subsequent appendix headers are
-- converted to styled paragraphs.

local style_map = {
  [1] = "Appx1Cover",
  [2] = "Appx2Cover",
  [3] = "TOC3Heading",
}

local found_references = false
local in_appendix = false

local function normalized_header_text(h)
  return pandoc.utils.stringify(h.content):lower()
end

local function is_appendix_marker(h)
  local text = normalized_header_text(h)
    :gsub("%s+", " ")
    :gsub("^%s+", "")
    :gsub("%s+$", "")
    :gsub("%.$", "")
  return text == "appendix" or text == "appendices"
end

return {{
  traverse = 'topdown',
  Header = function(h)
    -- Detect the References heading (level 1, text starts with "Reference")
    if h.level == 1 and not found_references then
      if normalized_header_text(h):match("^reference") then
        found_references = true
        return nil
      end
    end

    -- Next H1 after References flips into appendix mode
    if found_references and not in_appendix and h.level == 1 then
      in_appendix = true
    end

    -- In appendix: convert Header to styled paragraph
    if in_appendix then
      local style = style_map[h.level]
      if h.level == 1 and is_appendix_marker(h) then
        style = "SectionCover"
      end
      if style then
        local div = pandoc.Div(
          {pandoc.Para(h.content)},
          {['custom-style'] = style}
        )
        div.identifier = h.identifier
        return {div}
      end
    end

    return nil
  end,
}}
