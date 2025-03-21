local M = {}

local fn = vim.fn
local api = vim.api

local hl_namespace = vim.api.nvim_create_namespace("WordHighlighter")
local hl_group = "CurSearch" --TODO write own group
local ts_utils = require 'nvim-treesitter.ts_utils'

-- private functions
local function get_current_word_range(matcher)
    local pos = api.nvim_win_get_cursor(0)
    local cursor = pos[2]
    local line = pos[1]
    local content = api.nvim_buf_get_lines(0, line - 1, line, false)[1]
    local content_len = string.len(content)
    local reverse_content = string.reverse(content)

    local word_start = string.find(reverse_content, matcher, content_len - cursor)
    local word_end = string.find(content, matcher, cursor + 1)

    if word_start == nil
    then
        word_start = 0
    else
        word_start = content_len - word_start + 2
    end

    if word_end == nil
    then
        word_end = content_len
    else
        word_end = word_end - 1
    end

    local range = {
        wstart = word_start,
        wend = word_end
    }

    return range
end

local function highlight_current_word()
    local pos = api.nvim_win_get_cursor(0)
    local col = pos[2]
    local line = pos[1] - 1
    local wrange = get_current_word_range('[^a-zA-Z0-9_]')
    local col_start = wrange.wstart
    local col_end = wrange.wend

    return api.nvim_buf_set_extmark(0, hl_namespace, line, col_start, {end_col = col_end, hl_group = hl_group})
end

--
--TODO figure out toggle 
function M.hl_toggle()
  local node = ts_utils.get_node_at_cursor()
  if node ~= nil then
    ts_utils.highlight_node(node, 0, hl_namespace, hl_group)
  else
    --use nvim api
    highlight_current_word()
  end
end
  
function M.hl_clear()
  api.nvim_buf_clear_namespace(0, hl_namespace, 0, -1)
end

return M
