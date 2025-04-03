return {
    -- nvim port of solarized
    {
        'maxmx03/solarized.nvim',
        lazy = false,
        priority = 1000,
        opts = {variant = 'spring'},
        config = function(_, opts)
            vim.o.termguicolors = true
            vim.o.background = 'dark'
            require('solarized').setup(opts)
            vim.cmd.colorscheme 'solarized'
        end,
    },
    -- some sensible defaults
    {'tpope/vim-sensible'},
    -- detect tabstop and shiftwidth automatically
    {'tpope/vim-sleuth'},
    -- nvim utilities
    {'nvim-lua/plenary.nvim'},
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        lazy = false,
        config = function ()
            local configs = require'nvim-treesitter.configs'
            configs.setup {
                ensure_installed = {
                    "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "bash", "go", "python", "java"
                },
                highlight = { enable = true },
            }
        end,
    },
    -- automatic commenting shortcuts
    -- NOTE Not really sure this one is necessary
    --{'preservim/nerdcommenter'},
    -- highly configurable status bar for vim
    {'vim-airline/vim-airline'},
    -- treesitter compatible rainbow delimiters
    {
        'hiphish/rainbow-delimiters.nvim',
    },
    -- Super fast git decorations implemented purely in Lua
    -- golang synax highlighting
    {
        'charlespascoe/vim-go-syntax',
        ft = 'go',
    },
    -- show key-bindings in a popup
    {
        'folke/which-key.nvim',
        event = 'VimEnter',
        opts = {
            delay = 60,
        },
        -- Document existing key chains
        spec = {
            {'<leader>t', group = '+test', mode = { 'n' } },
            {'<leader>f', group = '+find', mode = { 'n' } },
            {'<leader>s', group = '+search', mode = { 'n' } },
        },
        --keys = {
            --{'<leader>+', function() require('which-key').show({ global = false }) end},
        --},
    },
    -- paired characters
    {'echasnovski/mini.pairs'},
    -- my own highlight plugin
    -- FIXME does not work as is with the plugin system in Lazy
    -- {
    --     dir = 'lua/word-highlight',
    --     -- lazy = false,
    --     -- dependencies = 'nvim-treesitter/nvim-treesitter',
    --     keys = {
    --         {"<leader>ll", require'word-highlight'.hl_toggle, noremap = false , desc = "Highlight word under cursor"},
    --         {"<leader>lc", require'word-highlight'.hl_clear, noremap = false, desc = "Clear highlights"},
    --     },
    -- },
    -- use icon glyphs in plugins that supports them (should always be loaded last)
    {
        'ryanoasis/vim-devicons',
        priority = 1, -- I think 1 is the lowest prio? (really should be set as dependency)
    },
    --TODO nvim-cmp?
}
