-- plugins/cairo.lua
return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Manually set up the server if automatic registration fails
      local lspconfig = require("lspconfig")
      local configs = require("lspconfig.configs")
      
      -- Only register if not already registered
      if not configs.cairo_ls then
        configs.cairo_ls = {
          default_config = {
            cmd = { "scarb", "cairo-language-server", "--stdio" },
            filetypes = { "cairo" },
            root_dir = function(fname)
              return lspconfig.util.root_pattern("Scarb.toml", ".git")(fname)
                or lspconfig.util.path.dirname(fname)
            end,
            settings = {},
          },
        }
      end

      lspconfig.cairo_ls.setup({})
    end
  }
}