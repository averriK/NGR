-- Quarto's resolved section number gets CAN's hanging-indent tab. Appendix
-- titles use the same localized prefix as Quarto's appendix references.
function Header(el)
  local number = el.attributes.number
  if el.level == 1 and number and number:match('^[A-Z]+$')
      and el.content[1] and el.content[1].t == 'Str'
      and el.content[1].text == 'Appendix' then
    local language = quarto.doc.language
    if language and language['crossref-apx-prefix'] then
      el.content[1].text = language['crossref-apx-prefix']
      return el
    end
  end
  if el.level > 3 or not number or #el.content < 2
      or el.content[1].t ~= 'Str' or el.content[1].text ~= number then return nil end
  if el.content[2].t == 'Space' or (el.content[2].t == 'Str' and el.content[2].text == '. ') then
    el.content[2] = pandoc.RawInline('openxml', '<w:r><w:tab/></w:r>')
  end
  return el
end

-- Quarto appends a qquad and the resolved label inside DisplayMath. LibreOffice
-- loses that spacing. Keep native math and put the label at Equation's right tab.
function Para(el)
  if #el.content ~= 1 then return nil end
  local span = el.content[1]
  if span.t ~= 'Span' or not span.identifier:match('^eq%-')
      or #span.content ~= 1 or span.content[1].t ~= 'Math' then return nil end
  local math = span.content[1]
  if math.mathtype ~= 'DisplayMath' then return nil end
  local formula, label = math.text:match('^(.-)%s*\\qquad(%([^()]+%))$')
  if not formula then error('Unsupported Quarto equation label: ' .. span.identifier) end
  span.content = {
    pandoc.RawInline('openxml', '<w:r><w:tab/></w:r>'),
    pandoc.Math('InlineMath', '\\displaystyle ' .. formula),
    pandoc.RawInline('openxml', '<w:r><w:tab/></w:r>'),
    pandoc.Str(label)
  }
  return pandoc.Div({el}, {['custom-style'] = 'Equation'})
end
