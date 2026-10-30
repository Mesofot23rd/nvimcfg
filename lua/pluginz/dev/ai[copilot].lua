return {
  'CopilotC-Nvim/CopilotChat.nvim',
  dependencies = {
    { 'nvim-lua/plenary.nvim', branch = 'master' },
  },
  build = 'make tiktoken',
  cmd = {
    'CopilotChat',
    'CopilotChatAgents',
    'CopilotChatClose',
    'CopilotChatCommit',
    'CopilotChatDocs',
    'CopilotChatExplain',
    'CopilotChatFix',
    'CopilotChatLoad',
    'CopilotChatModels',
    'CopilotChatOpen',
    'CopilotChatOptimize',
    'CopilotChatPrompts',
    'CopilotChatReset',
    'CopilotChatReview',
    'CopilotChatSave',
    'CopilotChatStop',
    'CopilotChatTests',
    'CopilotChatToggle',
  },
  opts = function()
    local user = vim.env.USER or 'User'
    user = user:sub(1, 1):upper() .. user:sub(2)

    return {
      -- See Configuration section for options
      layout = {
        -- These control the width of the aerial window.
        -- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
        -- min_width and max_width can be a list of mixed types.
        -- max_width = {40, 0.2} means "the lesser of 40 columns or 20% of total"
        max_width = { 40, 0.2 },
        width = nil,
        min_width = 10,
      },

      headers = {
        -- Icons: 👤 🤖
        user = '   ' .. user .. ' ',
        assistant = '   Copilot ',
        tool = ' 🔧 Tool ',
      },
    }
  end,
}
