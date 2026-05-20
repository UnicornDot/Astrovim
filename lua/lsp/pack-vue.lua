local astrocore = require("astrocore")
local utils = require("utils")

return {
  {
    "AstroNvim/astrolsp",
    optional = true,
    ---@type AstroLSPOpts
    ---@diagnostic disable-next-line: assign-type-mismatch
    opts = function(_, opts)
      local vtsls_ft = astrocore.list_insert_unique(vim.tbl_get(opts, "config", "vtsls", "filetypes") or {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx"
      }, { "vue" })

      opts.config = vim.tbl_deep_extend("keep", opts.config or {}, {
        volar = {
          on_init = function(client)
            client.handlers["tsserver/request"] = function(_, result, context)
              local clients = vim.lsp.get_clients { bufnr = context.bufnr, name = "vtsls" }
              if #clients == 0 then
                vim.notify(
                  "Could not found `vtsls` lsp client, vue_lsp would not work without it.",
                  vim.log.levels.ERROR
                )
                return
              end
              local ts_client = clients[1]

              local param = unpack(result)
              local id, command, payload = unpack(param)
              ts_client:exec_cmd({
                title = "vue_request_forward", -- You can give title anything as it's used to represent a command in the UI, `:h Client:exec_cmd`
                command = "typescript.tsserverRequest",
                arguments = {
                  command,
                  payload,
                },
              }, { bufnr = context.bufnr }, function(_, r)
                local response_data = { { id, r.body } }
                client:notify("tsserver/response", response_data)
              end)
            end
          end,
        },
        vtsls = {
          filetypes = vtsls_ft,
          settings = {
            vtsls = {
              tsserver = {
                globalPlugins = {}
              },
            },
          },
          before_init = function(_, config)
            local registry_ok, registry = pcall(require, "mason-registry")
            if not registry_ok then return end
            local vue_plugin_config
            if registry.is_installed "vue-language-server" then
              vue_plugin_config = {
                name = "@vue/typescript-plugin",
                location = vim.fn.expand "$MASON/packages/vue-language-server/node_modules/@vue/language-server",
                languages = { "vue" },
                configNamespace = "typescript",
                enableForWorkspaceTypeScriptVersions = true,
              }
              astrocore.list_insert_unique(config.settings.vtsls.tsserver.globalPlugins, { vue_plugin_config })
            else
              vue_plugin_config = {
                name = "@vue/typescript-plugin",
                location = utils.get_pkg_path("vue-language-server", "/node_modules/@vue/language-server"),
                languages = { "vue" },
                configNamespace = "typescript",
                enableForWorkspaceTypeScriptVersions = true,
              }
            end
            local style_plugin_config= {
              name = "@styled/typescript-styled-plugin",
              location = utils.get_global_npm_path(),
              enableForWorkspaceTypeScriptVersions = true,
            }
            local nx_plugin_config = {
              name = "@monodon/typescript-nx-imports-plugin",
              location = utils.get_global_npm_path(),
              enableForWorkspaceTypeScriptVersions = true
            }
            astrocore.list_insert_unique(config.settings.vtsls.tsserver.globalPlugins, {
              vue_plugin_config, style_plugin_config, nx_plugin_config
            })

          end
        },
      })
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "volar" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = true,
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique(
        opts.ensure_installed, { "vue-language-server" }
      )
    end,
  }
}
