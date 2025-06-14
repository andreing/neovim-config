-- Custom on_attach function that adds mappings after
-- the plugin is loaded
local custom_on_attach = function(bufnr)
    local gitsigns = require('gitsigns')

    local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
        if vim.wo.diff then
            vim.cmd.normal({']c', bang = true})
        else
            gitsigns.nav_hunk('next')
        end
    end)

    map('n', '[c', function()
        if vim.wo.diff then
            vim.cmd.normal({'[c', bang = true})
        else
            gitsigns.nav_hunk('prev')
        end
    end)

    -- Actions
    map('n', '<leader>h', '', { desc = "git" })
    map('v', '<leader>h', '', { desc = "git" })
    map('n', '<leader>hs', gitsigns.stage_hunk, { desc = "stage hunk" })
    map('n', '<leader>hr', gitsigns.reset_hunk, { desc = "reset hunk" })
    map('v', '<leader>hs', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = "stage hunk" })
    map('v', '<leader>hr', function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = "reset hunk" })
    map('n', '<leader>hS', gitsigns.stage_buffer, { desc = "stage buffer" })
    map('n', '<leader>hR', gitsigns.reset_buffer, { desc = "reset buffer" })
    map('n', '<leader>hp', gitsigns.preview_hunk, { desc = "preview hunk" })
    map('n', '<leader>hb', function() gitsigns.blame_line{full=true} end, { desc = "blame line" })
    map('n', '<leader>ht', gitsigns.toggle_current_line_blame, { desc = "toggle blame line" })
    map('n', '<leader>hd', gitsigns.diffthis, { desc = "diff against index" })
    map('n', '<leader>hD', function() gitsigns.diffthis('~') end, { desc = "diff against last commit" })
    map('n', '<leader>hP', gitsigns.preview_hunk_inline, { desc = "toggle show old version inline" })

    -- Text object
    map({'o', 'x'}, '<leader>hh', ':<C-U>Gitsigns select_hunk<CR>')
end

return {
    'lewis6991/gitsigns.nvim',
    event = 'BufReadPre',
    config = function()
        require'gitsigns'.setup({
            signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
            numhl      = true,  -- Toggle with `:Gitsigns toggle_numhl`
            linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
            word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
            watch_gitdir = {
                follow_files = true,
            },
            max_file_length = 5000,
            on_attach = custom_on_attach,
        })
    end,
}
