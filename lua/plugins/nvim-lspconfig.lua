local on_attach = require("util.lsp").on_attach
local diagnostic_signs = require("util.icons").diagnostic_signs
local typescript_organise_imports = require("util.lsp").typescript_organise_imports
local keybindings = require("config.jump-to-definition")

local config = function()
  require("neoconf").setup({})
  local cmp_nvim_lsp = require("cmp_nvim_lsp")
  local lspconfig = require("lspconfig")
  local capabilities = cmp_nvim_lsp.default_capabilities()

  -- Define highlight groups for diagnostics
  vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#FF0000", bold = true }) -- Red for errors
  vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#FFFF00", bold = true }) -- Yellow for warnings
  vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = "#FF0000" }) -- Red for error signs
  vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = "#FFFF00" }) -- Yellow for warning signs
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = "#FF0000" }) -- Red undercurl for errors
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = "#FFFF00" }) -- Yellow undercurl for warnings

  -- Enable inline diagnostics with custom colors
  vim.diagnostic.config({
    virtual_text = {
      prefix = "●", -- Marker for errors/warnings
      source = "if_many", -- Show source if multiple diagnostics
      format = function(diagnostic)
        if diagnostic.severity == vim.diagnostic.severity.ERROR then
          return string.format("%s %s", diagnostic.message, "[Error]")
        elseif diagnostic.severity == vim.diagnostic.severity.WARN then
          return string.format("%s %s", diagnostic.message, "[Warn]")
        end
        return diagnostic.message
      end,
    },
    signs = true, -- Gutter signs
    underline = true, -- Underline errors/warnings
    update_in_insert = false, -- Update after leaving insert mode
    severity_sort = true, -- Prioritize errors over warnings
  })

  -- Solidity (Nomic Foundation)

  -- Fetch Foundry remappings dynamically
  local function get_foundry_remappings()
    local handle = io.popen("forge remappings 2>/dev/null")
    if not handle then
      return {}
    end
    local result = handle:read("*a")
    handle:close()
    local remappings = {}
    for line in result:gmatch("[^\n]+") do
      local key, value = line:match("([^=]+)=(.+)")
      if key and value then
        remappings[key] = value
      end
    end
    return remappings
  end
  -- Solidity (Nomic Foundation)
  lspconfig.solidity.setup({
    cmd = { "nomicfoundation-solidity-language-server", "--stdio" },
    capabilities = capabilities,
    on_attach = keybindings.on_attach,
    filetypes = { "solidity" },
    root_dir = lspconfig.util.root_pattern("foundry.toml", "hardhat.config.*", "remappings.txt", ".git"),
    settings = {
      solidity = {
        includePath = "lib", -- Default Foundry include path, ignored if unused
        remappings = get_foundry_remappings(), -- Dynamic, empty if not Foundry
      },
    },
  })
  -- Lua
  lspconfig.lua_ls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          library = {
            vim.fn.expand("$VIMRUNTIME/lua"),
            vim.fn.expand("$XDG_CONFIG_HOME") .. "/nvim/lua",
          },
        },
      },
    },
  })

  -- JSON
  lspconfig.jsonls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    filetypes = { "json", "jsonc" },
  })

  -- Python
  lspconfig.pyright.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      pyright = {
        disableOrganizeImports = false,
        analysis = {
          useLibraryCodeForTypes = true,
          autoSearchPaths = true,
          diagnosticMode = "workspace",
          autoImportCompletions = true,
        },
      },
    },
  })

  -- TypeScript
  lspconfig.ts_ls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = {
      "typescript",
      "javascript",
      "typescriptreact",
      "javascriptreact",
    },
    commands = {
      TypeScriptOrganizeImports = typescript_organise_imports,
    },
    settings = {
      typescript = {
        indentStyle = "space",
        indentSize = 2,
      },
    },
  })

  -- Bash
  lspconfig.bashls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    filetypes = { "sh", "aliasrc" },
  })

  -- Emmet (web dev)
  lspconfig.emmet_ls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    filetypes = {
      "typescriptreact",
      "javascriptreact",
      "javascript",
      "css",
      "sass",
      "scss",
      "less",
      "svelte",
      "vue",
      "html",
    },
  })

  -- Docker
  lspconfig.dockerls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
  })

  -- C/C++
  lspconfig.clangd.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = {
      "clangd",
      "--offset-encoding=utf-16",
    },
  })

  -- Define diagnostic signs (ensure they match the colors)
  for type, icon in pairs(diagnostic_signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
  end

  -- EFM setup
  local solhint = require("efmls-configs.linters.solhint")
  local prettier_d = require("efmls-configs.formatters.prettier_d")
  local luacheck = require("efmls-configs.linters.luacheck")
  local stylua = require("efmls-configs.formatters.stylua")
  local flake8 = require("efmls-configs.linters.flake8")
  local black = require("efmls-configs.formatters.black")
  local eslint = require("efmls-configs.linters.eslint")
  local fixjson = require("efmls-configs.formatters.fixjson")
  local shellcheck = require("efmls-configs.linters.shellcheck")
  local shfmt = require("efmls-configs.formatters.shfmt")
  local hadolint = require("efmls-configs.linters.hadolint")
  local cpplint = require("efmls-configs.linters.cpplint")
  local clangformat = require("efmls-configs.formatters.clang_format")

  lspconfig.efm.setup({
    filetypes = {
      "lua",
      "python",
      "json",
      "jsonc",
      "sh",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "svelte",
      "vue",
      "markdown",
      "docker",
      "html",
      "css",
      "c",
      "cpp",
    },
    init_options = {
      documentFormatting = true,
      documentRangeFormatting = true,
      hover = true,
      documentSymbol = true,
      codeAction = true,
      completion = true,
    },
    settings = {
      languages = {
        solidity = { solhint },
        lua = { luacheck, stylua },
        python = { flake8, black },
        typescript = { eslint, prettier_d },
        json = { eslint, fixjson },
        jsonc = { eslint, fixjson },
        sh = { shellcheck, shfmt },
        javascript = { eslint, prettier_d },
        javascriptreact = { eslint, prettier_d },
        typescriptreact = { eslint, prettier_d },
        svelte = { eslint, prettier_d },
        vue = { eslint, prettier_d },
        markdown = { prettier_d },
        docker = { hadolint, prettier_d },
        html = { prettier_d },
        css = { prettier_d },
        c = { clangformat, cpplint },
        cpp = { clangformat, cpplint },
      },
    },
  })
end

return {
  "neovim/nvim-lspconfig",
  config = config,
  lazy = false,
  dependencies = {
    "windwp/nvim-autopairs",
    "williamboman/mason.nvim",
    "creativenull/efmls-configs-nvim",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-nvim-lsp",
  },
}

