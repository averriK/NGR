-- Quarto constructs footer divs before Lua filters run. Append the render
-- stamp to those existing divs, preserving their links and formatting.
function Pandoc(doc)
  local stamp = pandoc.system.environment()["QRT_RENDER_STAMP"] or ""
  if stamp == "" then return nil end

  return doc:walk({
    Div = function(div)
      if not div.classes:includes("footer") then return nil end
      local last = div.content[#div.content]
      if last and (last.t == "Para" or last.t == "Plain") then
        last.content:extend(pandoc.Inlines(" · " .. stamp))
      else
        div.content:insert(pandoc.Para(pandoc.Inlines(stamp)))
      end
      return div
    end
  })
end
