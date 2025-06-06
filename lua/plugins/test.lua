local neotest_golang_opts = {
    log_level = vim.log.levels.INFO,
}
local neotest_python_opts = {
    pytest_discover_instances = true,
}

-- testing in neovim
return {
    'nvim-neotest/neotest',
    dependencies = {
        'nvim-neotest/nvim-nio',
        'nvim-lua/plenary.nvim',
        'antoinemadec/FixCursorHold.nvim',
        'nvim-treesitter/nvim-treesitter',
        { 'fredrikaverpil/neotest-golang', version = '*' },
        'nvim-neotest/neotest-python',
    },
    config = function()
        -- using this approach because opts did not work
        require("neotest").setup({
            adapters = {
                require("neotest-python")(neotest_python_opts),
                require("neotest-golang")(neotest_golang_opts),
            },
            discovery = {
                concurrent = 8,
                enabled = true,
            },
        })
    end,
    keys = {
        {"<leader>t", "", desc = "+test"},
        {"<leader>tt", function() require('neotest').run.run() end, desc = "Run nearest (Neotest)" },
        {"<leader>tl", function() require('neotest').run.run_last() end, desc = "Rerun last (Neotest)" },
        {"<leader>tT", function() require('neotest').run.run(vim.fn.expand("%")) end, desc = "Run file (Neotest)"},
        {"<leader>tS", function() require('neotest').run.stop() end, desc = "Stop (Neotest)" },
        {"<leader>ta", function() require('neotest').run.attach() end, desc = "Attach (Neotest)" },
        {"<leader>tA", function() require('neotest').run.run(vim.uv.cwd()) end, desc = "Run all files (Neotest)" },
        {"<leader>ts", function() require('neotest').summary.toggle() end, desc = "Toggle summary (Neotest)" },
        {"<leader>to", function() require('neotest').output.open({ enter = false, auto_close = true }) end, desc = "Show output (Neotest)" },
        {"<leader>tO", function() require('neotest').output_panel.toggle() end, desc = "Toggle output panel (Neotest)" },
        {"<leader>tW", function() require('neotest').watch.toggle(vim.fn.expand("%")) end, desc = "Toggle watch file (Neotest)" },
        {"<leader>tw", function() require('neotest').watch.toggle() end, desc = "Toggle watch (Neotest)" },

    },
}
