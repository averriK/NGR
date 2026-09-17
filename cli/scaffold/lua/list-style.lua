-- list-style.lua
-- Map BulletList/OrderedList to List Bullet/List Number styles from reference.docx.
-- Restructures lists into styled Divs so Pandoc doesn't add its own numPr.

local bullet_styles = {
  "List Bullet",    -- depth 1
  "List Bullet 2",  -- depth 2
  "List Bullet 3",  -- depth 3
}

local number_styles = {
  "List Number",    -- depth 1
  "List Number 2",  -- depth 2
  "List Number 3",  -- depth 3
}

local function process_items(items, styles, depth)
  local result = {}
  local style = styles[math.min(depth, #styles)]

  for _, item in ipairs(items) do
    local content = {}
    local deferred = {}
    for _, block in ipairs(item) do
      if block.t == "BulletList" then
        -- Flush current content as a styled Div before nested list
        if #content > 0 then
          table.insert(result, pandoc.Div(content, {['custom-style'] = style}))
          content = {}
        end
        -- Nested bullet list: recurse at depth+1
        local nested = process_items(block.content, bullet_styles, depth + 1)
        for _, b in ipairs(nested) do
          table.insert(result, b)
        end
      elseif block.t == "OrderedList" then
        -- Flush current content as a styled Div before nested list
        if #content > 0 then
          table.insert(result, pandoc.Div(content, {['custom-style'] = style}))
          content = {}
        end
        -- Nested ordered list: recurse at depth+1
        local nested = process_items(block.content, number_styles, depth + 1)
        for _, b in ipairs(nested) do
          table.insert(result, b)
        end
      else
        table.insert(content, block)
      end
    end
    -- Flush any remaining content
    if #content > 0 then
      table.insert(result, pandoc.Div(content, {['custom-style'] = style}))
    end
  end
  return result
end

-- Use topdown traversal so outer lists are processed first,
-- allowing recursive depth tracking for nested lists.
return {{
  traverse = 'topdown',
  BulletList = function(bl)
    return process_items(bl.content, bullet_styles, 1)
  end,
  OrderedList = function(ol)
    return process_items(ol.content, number_styles, 1)
  end,
}}
