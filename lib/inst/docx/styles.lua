-- Map semantic Pandoc tables before Quarto creates its caption/layout wrappers.
function Table(el)
  if el.attributes['custom-style'] then return nil end
  el.attributes['custom-style'] = 'SRKDataTable'
  return el
end
