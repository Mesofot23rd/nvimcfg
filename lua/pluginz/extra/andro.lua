return {
  {
    'iamironz/android-nvim-plugin',
    enabled = false,
    lazy = false, -- Load this plugin immediately
    config = function()
      require('android').setup {
        -- Add your specific configuration options here
      }
    end,
  },
}
