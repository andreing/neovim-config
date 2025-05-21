-- TODO remove this function
local custom_lsp_attach = function(event)
    -- print("custom_lsp_attach")
    local bufnr = event.buf

    -- Enable completion triggered by <c-x><c-o>
    --    See `:help omnifunc` and `:help ins-completion` for more information.
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Use LSP as the handler for formatexpr.
    --    See `:help formatexpr` for more information.
    vim.api.nvim_buf_set_option(bufnr, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')

    -- Mappings
    local map = function(mode, l, r, opts)
        opts = opts or {}
        opts.silent = true
        opts.noremap = true
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
    end

    local code_action_all = function()
        local params = vim.lsp.util.make_range_params()
        params.context = {
            triggerKind = vim.lsp.protocol.CodeActionTriggerKind.Invoked,
            diagnostics = vim.lsp.diagnostic.get_line_diagnostics(),
        }
        local results =  vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params)
        for cid, result in pairs(results) do
            for _, action in pairs(result.result or {}) do
                print(string.format("%d: %s", cid, action.title))
            end
        end
        return results
    end

    map('n', '<leader>cA', code_action_all, { desc = "try fetching all code actions"})

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    map('n', 'gD', vim.lsp.buf.declaration, { desc = "go to declaration" })
    map('n', 'gd', vim.lsp.buf.definition, { desc = "go to definition" })
    map('n', 'K', vim.lsp.buf.hover)
    map('n', 'gi', vim.lsp.buf.implementation, { desc = "go to implementation" })
    map('n', '<C-k>', vim.lsp.buf.signature_help)
    map('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, { desc = "add workspace folder" })
    map('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, { desc = "remove workspace folder" })
    map('n', '<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, { desc = "list workspace folders" })
    map('n', '<leader>D', vim.lsp.buf.type_definition, { desc = "go to type def"})
    map('n', '<leader>rn', vim.lsp.buf.rename, { desc = "Rename" })
    map('n', '<leader>ca', vim.lsp.buf.code_action, { desc = "LSP code action"})
    map('v', '<leader>ca', function(range) vim.lsp.buf.code_action({range=range}) end, { desc = "LSP code action"})
    map('n', 'gr', vim.lsp.buf.references, { desc = "list references for symbol under cursor" })
    map('n', '<leader>=', vim.lsp.buf.format, { desc = "format code" })

    -- For plugins with an `on_attach` callback, call them here. For example:
    -- require('completion').on_attach()
end

-- pylsp config
-- TODO move to separate module
local pylsp_settings = function()
  local venv_path = os.getenv('VIRTUAL_ENV')
  local py_path = nil
  -- decide which python executable to use for mypy (will assume that mypy is installed in any venv used)
  if venv_path ~= nil then
    py_path = venv_path .. "/bin/python3"
  else
    py_path = vim.g.python3_host_prog
  end

  --vim.notify(string.format("Using py_path = %s  for mypy", py_path))

  local pylsp_plugins = {
    -- formatter options
    black = { enabled = false, skip_string_normalization = true },
    autopep8 = { enabled = false },
    yapf = { enabled = false },
    rope_autoimport = { enabled = false },
    -- linter options
    pylint = { enabled = false },
    ruff = { enabled = false },
    pyflakes = { enabled = false },
    pycodestyle = { enabled = false },
    flake8 = { enabled = false },
    -- type checker
    pylsp_mypy = {
      enabled = true,
      overrides = { "--python-executable", py_path, true },
      report_progress = true,
      live_mode = true
    },
    -- auto-completion options
    jedi_completion = { fuzzy = true },
    -- import sorting
    isort = { enabled = false }
  }

  return {
      pylsp = {
          plugins = pylsp_plugins,
          skip_token_initialization = true,
      },
  }
end


local gopls_settings = function()
    -- organize imports on write
    -- TODO putting this here as I do not know where else it would belong
    -- should problably make separate files per lsp and do this sort of thing on require(...)
    vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
            local params = vim.lsp.util.make_range_params()
            params.context = {only = {"source.organizeImports"}}
            -- buf_request_sync defaults to a 1000ms timeout. Depending on your
            -- machine and codebase, you may want longer. Add an additional
            -- argument after params if you find that you have to write the file
            -- twice for changes to be saved.
            -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
            local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
            for cid, res in pairs(result or {}) do
                for _, r in pairs(res.result or {}) do
                    if r.edit then
                        local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
                        vim.lsp.util.apply_workspace_edit(r.edit, enc)
                    end
                end
            end
            vim.lsp.buf.format({async = false})
        end
    })

    return {
      gopls = {
        staticcheck = true,
        completeUnimported = true,
        usePlaceholders = true,
        experimentalPostfixCompletions = true,
        diagnosticsDelay = "120ms",
      },
    }
end


return {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        -- Automatically install LSPs and related tools to stdpath for Neovim
        -- Mason must be loaded before its dependents so we need to set it up here.
        -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
        { 'williamboman/mason.nvim', opts = {} },
        'williamboman/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',

        -- Useful status updates for LSP.
        { 'j-hui/fidget.nvim', opts = {} },

        -- Allows extra capabilities provided by nvim-cmp
        'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('my-lsp-attach', { clear = true }),
            callback = function(event)
                custom_lsp_attach(event)
                local map = function(keys, func, desc, mode)
                    mode = mode or 'n'
                    vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                end
                --
                -- -- Jump to the definition of the word under your cursor.
                -- --  This is where a variable was first declared, or where a function is defined, etc.
                -- --  To jump back, press <C-t>.
                -- -- map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
                --
                -- -- Find references for the word under your cursor.
                -- map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
                --
                -- -- Jump to the implementation of the word under your cursor.
                -- --  Useful when your language has ways of declaring types without an actual implementation.
                -- map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
                --
                -- -- Jump to the type of the word under your cursor.
                -- --  Useful when you're not sure what type a variable is and you want to see
                -- --  the definition of its *type*, not where it was *defined*.
                -- map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
                --
                -- -- Fuzzy find all the symbols in your current document.
                -- --  Symbols are things like variables, functions, types, etc.
                -- map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
                --
                -- -- Fuzzy find all the symbols in your current workspace.
                -- --  Similar to document symbols, except searches over your entire project.
                -- map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
                --
                -- -- Rename the variable under your cursor.
                -- --  Most Language Servers support renaming across files, etc.
                -- map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
                --
                -- -- Execute a code action, usually your cursor needs to be on top of an error
                -- -- or a suggestion from your LSP for this to activate.
                -- map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
                --
                -- -- WARN: This is not Goto Definition, this is Goto Declaration.
                -- --  For example, in C this would take you to the header.
                -- map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
                --
                -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
                ---@param client vim.lsp.Client
                ---@param method vim.lsp.protocol.Method
                ---@param bufnr? integer some lsp support methods only in specific files
                ---@return boolean
                local function client_supports_method(client, method, bufnr)
                    if vim.fn.has 'nvim-0.11' == 1 then
                        return client:supports_method(method, bufnr)
                    else
                        return client.supports_method(method, { bufnr = bufnr })
                    end
                end

                -- The following two autocommands are used to highlight references of the
                -- word under your cursor when your cursor rests there for a little while.
                --    See `:help CursorHold` for information about when this is executed
                --
                -- When you move your cursor, the highlights will be cleared (the second autocommand).
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
                    local highlight_augroup = vim.api.nvim_create_augroup('my-lsp-highlight', { clear = false })
                    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.document_highlight,
                    })

                    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.clear_references,
                    })

                    vim.api.nvim_create_autocmd('LspDetach', {
                        group = vim.api.nvim_create_augroup('my-lsp-detach', { clear = true }),
                        callback = function(event2)
                            vim.lsp.buf.clear_references()
                            vim.api.nvim_clear_autocmds { group = 'my-lsp-highlight', buffer = event2.buf }
                        end,
                    })
                end

                -- The following code creates a keymap to toggle inlay hints in your
                -- code, if the language server you are using supports them
                --
                -- This may be unwanted, since they displace some of your code
                if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
                    map('<leader>ih', function()
                        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                    end, 'Toggle [I]nlay [H]ints')
                end
            end,
        })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
          -- See `:help lspconfig-all` for a list of all the pre-configured LSPs
          lua_ls = {
              -- cmd = { ... },
              -- filetypes = { ... },
              -- capabilities = {},
              settings = {
                  Lua = {
                      completion = {
                          callSnippet = 'Replace',
                      },
                      -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                      diagnostics = { disable = { 'missing-fields' } },
                  },
              },
          },

          pylsp = {
              -- cmd = { ... },
              -- filetypes = { ... },
              -- capabilities = {},
              settings = pylsp_settings(),
          },

          ruff = {
              -- cmd = { ... },
              -- filetypes = { ... },
              capabilities = { hoverProvider = false, },
              settings = {},
          },

          gopls = {
              -- cmd = { ... },
              -- filetypes = { ... },
              -- capabilities = {},
              on_attach = function (event)
                -- print("gopls on_attach")
                -- FIXME this will not work. Guess the load order is fucked.
                -- fix would be to somehow have a static map of keymaps which
                -- can be modified like how Lazy does it if you include the
                -- whole config
                -- vim.keymap.set('n', '<leader>ca', function() vim.lsp.buf.code_action() end, { desc = "LSP code action (gopls)", buffer = event.bufnr, silent = false, remap = true })
              end,
              settings = gopls_settings(),
          },
      }

      -- Ensure the servers and tools above are installed
      --
      -- To check the current status of installed tools and/or manually install
      -- other tools, you can run
      --    :Mason
      --
      -- You can press `g?` for help in this menu.
      --
      -- `mason` had to be setup earlier: to configure its options see the
      -- `dependencies` table for `nvim-lspconfig` above.
      --
      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {}, -- explicitly set to an empty table (installs configured via mason-tool-installer)
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }

    end,
}
