vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.clipboard = 'unnamedplus'

vim.o.relativenumber = true

vim.o.signcolumn = 'yes'

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

vim.o.updatetime = 300

-- vim.o.termguicolors = true

vim.o.mouse = 'a'

local hop = require('hop')
local directions = require('hop.hint').HintDirection
-- override f
--vim.keymap.set('', 'f', function()
--    hop.hint_char1({direction = directions.AFTER_CURSOR, current_line_only = true })
--end, {remap=true});
-- leader + f look for word
vim.keymap.set('', '<leader>f', function()
    hop.hint_words()
end);
