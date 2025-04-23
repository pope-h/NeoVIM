-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
-- auto-format on save
local lsp_fmt_group = vim.api.nvim_create_augroup("LspFormattingGroup", {})
vim.api.nvim_create_autocmd("BufWritePre", {
  group = lsp_fmt_group,
  callback = function()
    local efm = vim.lsp.get_clients({ name = "efm" })

    if vim.tbl_isempty(efm) then
      return
    end

    vim.lsp.buf.format({ name = "efm", async = true })
  end,
})

-- highlight on yank
local highlight_yank_group = vim.api.nvim_create_augroup("HighlightYankGroup", {})
vim.api.nvim_create_autocmd("TextYankPost", {
  group = highlight_yank_group,
  callback = function()
    vim.highlight.on_yank()
  end,
})
-- Autocommand for Solidity files
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.sol",
  callback = function()
    vim.cmd("silent! !forge fmt %") -- Run forge fmt
    vim.cmd("e!") -- Reload the file to reflect changes
  end,
})

-- Autocommand for Rust files
-- vim.api.nvim_create_autocmd("BufWritePre", {
--     pattern = "*.rs",
--     callback = function()
--         vim.lsp.buf.format({ async = false })
--     end,
-- })

