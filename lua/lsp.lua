local keymap = vim.keymap
local fn = vim.fn

-- Mappings for diagnostic window
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = "open quickfix list (floating)" }, opts)
keymap.set('n', ',n', vim.diagnostic.goto_prev, { desc = "quickfix: goto previous" }, opts)
keymap.set('n', ',p', vim.diagnostic.goto_next, { desc = "quickfix: goto next" }, opts)
keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = "open quickfix list" }, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local custom_lsp_attach = function(client, bufnr)
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
      keymap.set(mode, l, r, opts)
  end

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

-- setup lspkind
-- setup() is also available as an alias
require('lspkind').init({
    -- DEPRECATED (use mode instead): enables text annotations
    --
    -- default: true
    -- with_text = true,

    -- defines how annotations are shown
    -- default: symbol
    -- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
    mode = 'symbol_text',

    -- default symbol map
    -- can be either 'default' (requires nerd-fonts font) or
    -- 'codicons' for codicon preset (requires vscode-codicons font)
    -- WARN somehow 'codicons' works and 'default' don't
    --
    -- default: 'default'
    preset = 'codicons',

    -- override preset symbols
    --
    -- default: {}
    symbol_map = {
      Text = "󰉿",
      Method = "󰆧",
      Function = "󰊕",
      Constructor = "",
      Field = "󰜢",
      Variable = "󰀫",
      Class = "󰠱",
      Interface = "",
      Module = "",
      Property = "󰜢",
      Unit = "󰑭",
      Value = "󰎠",
      Enum = "",
      Keyword = "󰌋",
      Snippet = "",
      Color = "󰏘",
      File = "󰈙",
      Reference = "󰈇",
      Folder = "󰉋",
      EnumMember = "",
      Constant = "󰏿",
      Struct = "󰙅",
      Event = "",
      Operator = "󰆕",
      TypeParameter = "",
    },
})

-- Set up the different language servers
-- python-lsp
local lspconfig = require('lspconfig')
if fn.executable("pylsp") > 0 then
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
    --black = { enabled = true, skip_string_normalization = true },
    black = { enabled = false, skip_string_normalization = true },
    autopep8 = { enabled = false },
    yapf = { enabled = false },
    --rope_autoimport = { enabled = true },
    rope_autoimport = { enabled = false },
    -- linter options
    --pylint = { enabled = true, executable="pylint" },
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

  local pylsp_flags = {
    -- This is the default in Nvim 0.7+
    debounce_text_changes = 150,
  }
  -- pylsp; A Python 3.6+ implementation of the Language Server Protocol.
  lspconfig.pylsp.setup{
    on_attach = custom_lsp_attach,
    flags = pylsp_flags,
    settings = {
      pylsp = {
        skip_token_initialization = true,
        plugins = pylsp_plugins,
      }
    }
  }
else
  vim.notify("pylsp not found!", vim.log.levels.WARN, { title = "nvim-config" })
end


-- ruff stuff (ruff server)
if fn.executable("ruff") > 0 then
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client == nil then
          return
        end
        if client.name == 'ruff' then
          -- Disable hover in favor of python-lsp
          client.server_capabilities.hoverProvider = false
        end
      end,
      desc = 'LSP: Disable hover capability from Ruff',
    })

    lspconfig.ruff.setup{
        trace = 'messages',
        init_options = {
            settings = {
                logLevel = 'debug',
            }
        }
    }
else
    vim.notify("ruff not found!", vim.log.levels.WARN, { title = "nvim-config" })
end


-- golang stuff (gopls)
lspconfig.gopls.setup{
    on_attach = custom_lsp_attach,
    settings = {
      gopls = {
        staticcheck = true,
        completeUnimported = true,
        usePlaceholders = true,
        experimentalPostfixCompletions = true,
        diagnosticsDelay = "300ms",
      },
    },
}

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
