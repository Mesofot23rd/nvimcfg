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
  },
}
