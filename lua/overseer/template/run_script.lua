--[[
--
-- 自定义模块，
--
-- 该模块需要定义在 .config/nvim/lua/overseer/template 文件夹中
--    > 需要返回一个表
--    > 可以使用 param 传递参数
-- 自定义组件存储在 .config/nvim/lua/overseer/component 文件夹中
--
--
--
--]]
return {
  -- 作为弹出的窗口的名称
  name = "run script",
  condition = {
    filetype = { "sh", "python" }
  },
  -- 执行任务时的一些配置
  builder = function()
    return {
      name = vim.fn.expand "%:t",
      cmd = vim.bo.filetype == "sh" and "sh" or "python3",
      cwd = vim.fn.expand "%:p:h",
      args = { vim.fn.expand "%:p" },
      components = {
        -- "task_list_on_start",
        "display_duration",
        "on_exit_set_status",
        "on_complete_notify"
      }
    }
  end,
}
