-- lua/plugins/neotest.lua
return {
  "nvim-neotest/neotest",
  dependencies = {
    "rouge8/neotest-rust", -- Rust adapter for neotest
    "nvim-lua/plenary.nvim", -- Required by neotest
    "nvim-treesitter/nvim-treesitter", -- Required by neotest
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-rust"),
      },
    })

  end,
}