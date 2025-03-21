-- Set <space> as the leader key
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Have nerd font installed and active in terminal ( <== should show a skull and bones and ligature)
vim.g.have_nerd_font = true

-- Enable mouse mode (resize splits etc)
vim.opt.mouse = 'a'
-- Enable line numbers and relative line numbers by default
vim.opt.number = true
vim.opt.relativenumber = true

-- UI defaults
vim.opt.hlsearch = true
vim.opt.showmode = false
vim.opt.background = dark
vim.opt.splitright = true
vim.opt.splitbelow = false
vim.opt.cursorline = true

-- Formatting defaults
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.showbreak = '+++ '
vim.opt.breakindent = true

-- Find/replace defaults
-- Case-insensitive matching unless \C or 1+ capital letters in search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Misc defaults
vim.opt.undofile = true
vim.opt.signcolumn = 'auto'
vim.opt.updatetime = 250 --default is 4000 (ms)
vim.opt.maxmempattern = 100000

-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.opt.inccommand = 'split' -- nosplit/split


-- [[Base keymaps]] --

vim.keymap.set('n', '<leader>S', '<cmd>source $MYVIMRC<CR>', { desc = 'Source vim config' })
vim.keymap.set('n', '<leader>v', '<cmd>tabedit $MYVIMRC<CR>', { desc = 'Open vim config' })

vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Save buffer' })

vim.keymap.set('v', '//', 'y/<C-R>"<CR>', { desc = 'Search for selection', remap = false })
vim.keymap.set('n', '<CR>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight', remap = false })
vim.keymap.set('n', '<C-J>', 'ciW<CR><Esc><cmd>if match( @", "^\\s*$") < 0<Bar>exec "norm P-$diw+"<Bar>endif<CR>', { desc = 'Newline (normal)' })
vim.keymap.set('n', '<leader>o', '<cmd>CtrlP<CR>', { desc = 'New file' })

-- copy/paste to system clipboard
vim.keymap.set({'n', 'v'}, '<leader>p', '"+p', { desc = '' })
vim.keymap.set({'n', 'v'}, '<leader>P', '"+P', { desc = '' })
vim.keymap.set('v', '<leader>y', '"+y', { desc = '' })
vim.keymap.set('v', '<leader>Y', '"+Y', { desc = '' })
vim.keymap.set('v', '<leader>d', '"+d', { desc = '' })

vim.keymap.set('n', '<leader>qh', '<cmd>helpclose<CR>', { desc = 'Close help window' })

vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- TODO maybe port "vp doesn't replace paste buffer

-- Build mapping
-- :set makeprg to change build command.
-- You can use "%<" to insert the current file name without extension,
-- or "#<" to insert the alternate file name without extension, for example: >
--   :set makeprg=make\ #<.o
vim.keymap.set('n', 'mm', ':wa<CR>:echo &makeprg<CR>:make<CR>', { desc = 'Build project' })

-- [[Base autocommands]] --
vim.api.nvim_create_augroup("vimrc", { clear = true })

-- Resize splits when the window in resized
-- FIXME this does not work
vim.api.nvim_create_autocmd("VimResized", {
    callback = function()
        vim.cmd('exe "normal! <c-w>="')
    end,
    group = "vimrc",
})

-- Set makeprg for Go
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = {"*.go"},
    callback = function()
        vim.opt.makeprg = 'make\\ #<.o'
    end,
    group = "vimrc",
})

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  --group = vim.api.nvim_create_augroup('my-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
  group = "vimrc",
})

-- [[lazy.vim plugin manager]] --
require'config.lazy'
