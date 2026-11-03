-- Distro agnostic Neovim plugin to upgrade your current distro(neovim config) from its github remote.

return {
  'Zeioth/distroupgrade.nvim',
  dependencies = 'nvim-lua/plenary.nvim',
  event = 'User BaseFile',
  cmd = {
    'DistroFreezePluginVersions',
    'DistroReadChangelog',
    'DistroReadVersion',
    'DistroUpdate',
    'DistroUpdateRevert',
  },
  opts = {
    channel = 'stable', -- stable/nightly
    overwrite_uncommited_local_changes = true,
  },
}
