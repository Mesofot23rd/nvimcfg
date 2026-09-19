return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },

  config = function()
    local config_path = vim.fn.stdpath 'config' .. '/formatter_configs/'
    require('conform').setup {
      -- Map of filetype to formatters
      formatters_by_ft = {
        zsh = { 'shfmt' },
        bash = { 'shfmt' },
        sh = { 'shfmt' },
        c = { 'clang-format' },
        cpp = { 'clang-format' },
        css = { 'biome' },
        -- cmake = { 'cmake-format' },
        java = { 'clang-format' },
        javascript = { 'biome' },
        typescript = { 'biome' },
        json = { 'biome' },
        html = { 'prettier', lsp_format = 'fallback' },
        kotlin = { 'ktlint' },
        lua = { 'stylua' },
        make = { 'mbake' },
        meson = { 'meson' },
        markdown = { 'deno_fmt' },
        go = { 'goimports', 'gofmt' }, -- Conform will run multiple formatters sequentially
        rust = { 'rustfmt' }, -- You can also customize some of the format options for the filetype
        toml = { 'tombi' },

        -- You can use a function here to determine the formatters dynamically
        python = function(bufnr)
          if require('conform').get_formatter_info('ruff_format', bufnr).available then
            return { 'ruff_format' }
          else
            return { 'isort', 'black' }
          end
        end,

        yaml = { 'yamlfmt' },

        -- Use the "*" filetype to run formatters on all filetypes.
        ['*'] = { 'codespell' },
        -- Use the "_" filetype to run formatters on filetypes that don't
        -- have other formatters configured.
        ['_'] = { 'trim_whitespace' },
      },

      -- If this is set, Conform will run the formatter synchronously before save.
      format_on_save = {
        lsp_format = 'fallback',
        timeout_ms = 500,
      },

      -- Custom formatters and overrides for built-in formatters
      formatters = {
        biome = {
          prepend_args = { 'format', '--config-path', config_path .. 'biome.json' },
        },
        ['clang-format'] = {
          prepend_args = { '-style=file:' .. config_path .. 'clang-format' },
        },
        deno_fmt = {
          prepend_args = { '--config', config_path .. 'deno.json' },
        },

        mbake = {
          command = 'mbake',
          prepend_args = { 'format', '--config', config_path .. 'bake.toml' },
        },
        prettier = {
          command = 'prettier',
          args = { '--config', config_path .. 'prettierrc.json', '$FILENAME' },
        },
        ruff_format = {
          args = { '--config', config_path .. 'ruff.toml' },
        },
        rustfmt = {
          args = { '--config-path', config_path .. 'rustfmt.toml' },
        },
        stylua = {
          prepend_args = { '--config-path', config_path .. 'stylua.toml' },
        },

        shfmt = {
          prepend_args = { '-i', '2', '-bn', '-fn', '-ci' },
        },
        tombi = {
          command = 'tombi',
          prepend_args = { 'format', '-- --config', config_path .. 'tombi.toml', '-' },
        },

        yamlfmt = {
          prepend_args = { '-conf', config_path .. 'yamlfmt.yaml' },
        },

        my_formatter = {
          -- This can be a string or a function that returns a string.
          -- When defining a new formatter, this is the only field that is required
          command = 'my_cmd',
          -- A list of strings, or a function that returns a list of strings
          -- Return a single string instead of a list to run the command in a shell
          args = { '--stdin-from-filename', '$FILENAME' },
          -- If the formatter supports range formatting, create the range arguments here
          range_args = function(self, ctx)
            return { '--line-start', ctx.range.start[1], '--line-end', ctx.range['end'][1] }
          end,
          -- Send file contents to stdin, read new contents from stdout (default true)
          -- When false, will create a temp file (will appear in "$FILENAME" args). The temp
          -- file is assumed to be modified in-place by the format command.
          stdin = false,
          -- A function that calculates the directory to run the command in
          cwd = require('conform.util').root_file { '.editorconfig', 'package.json' },
          require_cwd = true, -- When cwd is not found, don't run the formatter (default false)
          tmpfile_format = '.conform.$RANDOM.$FILENAME', -- When stdin=false, use this template to generate the temporary file that gets formatted
          -- When returns false, the formatter will not be used
          condition = function(self, ctx) return vim.fs.basename(ctx.filename) ~= 'README.md' end,
          -- Set to false to disable merging the config with the base definition.
          -- Can also be set to the name of the formatter to merge with (e.g. inherit = "black")
          inherit = true,
          -- When inherit = true, add these additional arguments to the beginning of the command.
          -- This can also be a function, like args
          prepend_args = { '--use-tabs' },
          -- When inherit = true, add these additional arguments to the end of the command.
          -- This can also be a function, like args
          append_args = { '--trailing-comma' },
        },

        -- These can also be a function that returns the formatter
        other_formatter = function(bufnr)
          return {
            command = 'my_cmd',
          }
        end,
      },
    }
  end,
}
