return {
    --fzf alternative plugin written in lua, use with :FzfLua
    'ibhagwan/fzf-lua',
    cmd = 'FzfLua',
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
        -- find
        { "<leader><space>", "<cmd>FzfLua files<CR>", desc = "Find files (root dir)" },
        { "<leader>ff", "<cmd>FzfLua files resume=false<CR>", desc = "Find files (root dir)" },
        { "<leader>fF", "<cmd>FzfLua files root=false<CR>", desc = "Find files (cwd)" },
        { "<leader>fr", "<cmd>FzfLua oldfiles<CR>", desc = "Recent files" },
        { "<leader>fb", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<CR>", desc = "Buffers" },
        { "<leader>ft", "<cmd>FzfLua tabs<CR>", desc = "Tabs" },
        --TODO put these in lspconfig
        -- { "gr", "<cmd>FzfLua lsp_references<CR>", desc = "References" },
        -- { "gd", "<cmd>FzfLua lsp_definitions<CR>", desc = "Definitions" },
        -- search
        { '<leader>s"', "<cmd>FzfLua registers<cr>", desc = "Registers" },
        { "<leader>sa", "<cmd>FzfLua autocmds<cr>", desc = "Auto Commands" },
        { "<leader>sb", "<cmd>FzfLua grep_curbuf<cr>", desc = "Buffer" },
        { "<leader>sc", "<cmd>FzfLua command_history<cr>", desc = "Command History" },
        { "<leader>sC", "<cmd>FzfLua commands<cr>", desc = "Commands" },
        { "<leader>sd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Document Diagnostics" },
        { "<leader>sD", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Workspace Diagnostics" },
        { "<leader>sh", "<cmd>FzfLua help_tags<cr>", desc = "Help Pages" },
        { "<leader>sH", "<cmd>FzfLua highlights<cr>", desc = "Search Highlight Groups" },
        { "<leader>sj", "<cmd>FzfLua jumps<cr>", desc = "Jumplist" },
        { "<leader>sk", "<cmd>FzfLua keymaps<cr>", desc = "Key Maps" },
        { "<leader>sl", "<cmd>FzfLua loclist<cr>", desc = "Location List" },
        { "<leader>sM", "<cmd>FzfLua man_pages<cr>", desc = "Man Pages" },
        { "<leader>sm", "<cmd>FzfLua marks<cr>", desc = "Jump to Mark" },
        { "<leader>sR", "<cmd>FzfLua resume<cr>", desc = "Resume" },
        { "<leader>sq", "<cmd>FzfLua quickfix<cr>", desc = "Quickfix List" },
        -- lsp
        {
            "<leader>ss",
            function()
                require("fzf-lua").lsp_document_symbols({
                    regex_filter = symbols_filter,
                })
            end,
            desc = "Goto Symbol",
        },
        {
            "<leader>sS",
            function()
                require("fzf-lua").lsp_live_workspace_symbols({
                    regex_filter = symbols_filter,
                })
            end,
            desc = "Goto Symbol (Workspace)",
        },
    },
}
