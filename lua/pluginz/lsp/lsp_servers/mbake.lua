return {
    cmd = { 'mbake' },
    filetypes = { 'make' },
    root_dir = require('lspconfig.util').root_pattern('Makefile', '.git'),
}
