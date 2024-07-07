--[[
--
-- 启动前端项目的模板
--
-- 使用 params 定制启动的环境参数
--
--]]
return {
  name = "Web UI",
  condition = {
    filetype = {"vue", "javascript", "typescript", "react"},
  },
  params = {
    profile = { optional = false, type = "string", default = "dev" }
  },
  builder = function(params)
    return {
      name = vim.fn.getcwd(),
      cmd = "npm",
      args = { "run", params.profile },
      cwd = vim.fn.getcwd(),
      components = {
        "task_list_on_start",
        {"display_duration", detail_level = 1},
        "on_exit_set_status",
        "on_complete_notify",
        {"on_output_quickfix", open_on_exit = "failure"}
      }
    }
  end
}
