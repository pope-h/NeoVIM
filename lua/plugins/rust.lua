-- return {
--   {
--     "mrcjkb/rustaceanvim",
--     version = "^4", -- Recommended
--     ft = { "rust" },
--     opts = {
--       server = {
--         on_attach = require("config.jump-to-definition").on_attach,  -- Your existing keybindings
--         settings = {
--           ["rust-analyzer"] = {
--             cargo = { allFeatures = true },
--             checkOnSave = { command = "clippy" },
--           },
--         },
--       },
--     },
--   },
-- }

-- return {
--   {
--     "mrcjkb/rustaceanvim",
--     version = "^4", -- Recommended
--     ft = { "rust" },
--     opts = {
--       server = {
--         on_attach = require("config.jump-to-definition").on_attach,  -- Your existing keybindings
--         settings = {
--           ["rust-analyzer"] = {
--             cargo = { allFeatures = true },
--             checkOnSave = { command = "clippy" },
--           },
--         },
--       },
--     },
--     config = function(_, opts)
--       vim.g.rustaceanvim = opts

--       vim.api.nvim_create_autocmd("BufWritePre", {
--         pattern = "*.rs",
--         callback = function()
--           local filepath = vim.fn.expand("%:p")
--           local is_solana = filepath:lower():match("solana") or
--                             vim.fn.filereadable(vim.fn.expand("%:p:h:h") .. "/Anchor.toml") == 1
--           if is_solana then
--             -- Trim all trailing whitespace
--             vim.cmd([[%s/\s\+$//e]])
--             vim.notify("Detected Solana file: " .. filepath)
--             -- Use rustfmt on the current file only
--             local result = vim.fn.system("rustfmt " .. vim.fn.shellescape(filepath))
--             if vim.v.shell_error == 0 then
--               vim.notify("rustfmt ran successfully")
--               vim.cmd("edit") -- Reload the file
--             else
--               vim.notify("rustfmt failed: " .. result)
--             end
--           else
--             vim.notify("Not a Solana file: " .. filepath)
--           end
--         end,
--       })
--     end,
--   },
-- }

return {
  {
    "mrcjkb/rustaceanvim",
    version = "^4",
    ft = { "rust" },
    opts = {
      server = {
        on_attach = function(_, bufnr)
          require("config.jump-to-definition").on_attach(_, bufnr)
          -- Format on save through LazyVim's built-in mechanisms
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              -- First ensure the file is valid Rust
              if vim.bo[bufnr].filetype == "rust" then
                -- Check for Solana project markers
                local is_solana = vim.fn.expand("%:p"):lower():find("solana") ~= nil
                  or vim.fn.filereadable(vim.fn.expand("%:p:h") .. "/Anchor.toml") == 1
                  or vim.fn.filereadable(vim.fn.expand("%:p:h:h") .. "/Anchor.toml") == 1
                -- Additional Solana-specific cleanup
                if is_solana then
                  vim.cmd([[keeppatterns %s/\s\+$//e]]) -- Remove trailing whitespace
                end
              end
            end,
          })
        end,
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            checkOnSave = {
              command = "clippy",
              extraArgs = { "--no-deps" }, -- Faster checks
            },
          },
        },
      },
    },
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        rust = {
          {
            "rustfmt",
            command = "rustfmt",
            args = { "--edition=2021", "--quiet" },
            stdin = true,
          },
        },
      },
    },
    init = function()
      -- Pre-cache rustfmt to avoid first-run delay
      vim.fn.system("rustfmt --version >/dev/null 2>&1")
    end,
  },
}
