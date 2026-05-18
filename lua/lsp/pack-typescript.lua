local astrocore = require("astrocore")
local utils = require("utils")
local decode_json = utils.decode_json
local check_json_key_exists = utils.check_json_key_exists

local lsp_rooter, biomerc_rooter

local has_biome = function(bufnr)
  if type(bufnr) ~= "number" then bufnr = vim.api.nvim_get_current_buf() end
  local rooter = require "astrocore.rooter"
  if not lsp_rooter then
    lsp_rooter = rooter.resolve("lsp", {
      ignore = {
        servers = function(client)
          return not vim.tbl_contains({ "vtsls", "typescript-tools", "volar", "biome", "tsserver" }, client.name)
        end,
      },
    })
  end
  if not biomerc_rooter then
    biomerc_rooter = rooter.resolve {
      "biome.json",
      "biome.jsonc",
      ".biomerc",
      ".biomerc.json",
      ".biomerc.jsonc",
    }
  end
  local biome_dependency = false
  for _, root in ipairs(astrocore.list_insert_unique(lsp_rooter(bufnr), { vim.fn.getcwd() })) do
    local package_json = decode_json(root .. "/package.json")
    if
      package_json
      and (
        check_json_key_exists(package_json, "dependencies", "@biomejs/biome")
        or check_json_key_exists(package_json, "devDependencies", "@biomejs/biome")
      )
    then
      biome_dependency = true
      break
    end
  end
  return biome_dependency or next(biomerc_rooter(bufnr))
end

local conform_formatter = function(bufnr)
  return has_biome(bufnr) and { "biome" } or {}
end

return {
  ---@type LazySpec
  {
    "AstroNvim/astrolsp",
    optional = true,
    ---@type function
    ---@diagnostic disable: missing-fields
    opts = function(_, opts)
      return astrocore.extend_tbl(opts, {
        config = {
          vtsls = {
            root_dir = require("lspconfig.util").root_pattern(
              "nx.json",
              "tsconfig.json",
              "package.json",
              "jsconfig.json"
            ),
            on_attach = function(client, _)
              local existing_capabilities = vim.deepcopy(client.server_capabilities)
              if existing_capabilities == nil then return end
              existing_capabilities.documentFormattingProvider = nil
              local existing_filters = existing_capabilities.workspace.fileOperations.didRename.filters or {}
              local new_glob = "**/*.{ts,cts,mts,tsx,js,cjs,mjs,jsx,vue}"
              for _, filter in ipairs(existing_filters) do
                if filter.pattern and filter.pattern.matches == "file" then
                  filter.pattern.glob = new_glob
                  break
                end
              end
              existing_capabilities.workspace.fileOperations.didRename.filters = existing_filters

              client.server_capabilities = existing_capabilities

              astrocore.set_mappings({
                n = {
                  ["<Leader>lA"] = {
                    function() vim.lsp.buf.code_action { context = { only = { "source", "refactor", "quickfix" } } } end,
                    desc = "Lsp All Action",
                  },
                  gs = {
                    function() require("vtsls").commands.goto_source_definition() end,
                    desc = "Goto Source Definition (vtsls)",
                  },
                },
              }, { buffer = true })
            end,
            filetypes = {
              "angular",
              "javascript",
              "javascriptreact",
              "javascript.jsx",
              "typescript",
              "typescriptreact",
              "typescript.tsx",
            },
            settings = {
              complete_function_calls = true,
              vtsls = {
                enableMoveToFileCodeAction = true,
                autoUseWorkspaceTsdk = true,
                experimental = {
                  maxInlayHintLength = 30,
                  completion = {
                    enableServerSideFuzzyMatch = true,
                  },
                },
                tsserver = {
                  globalPlugins = {},
                },
              },
              typescript = {
                updateImportsOnFileMove = { enabled = "always" },
                suggest = {
                  completeFunctionCalls = true,
                },
                inlayHints = {
                  parameterNames = { enabled = "literals" },
                  parameterTypes = { enabled = true },
                  variableTypes = { enabled = true },
                  propertyDeclarationTypes = { enabled = true },
                  functionLikeReturnTypes = { enabled = true },
                  enumMemberValues = { enabled = true },
                },
              },
              javascript = {
                updateImportsOnFileMove = { enabled = "always" },
                inlayHints = {
                  parameterNames = { enabled = "literals" },
                  parameterTypes = { enabled = true },
                  variableTypes = { enabled = true },
                  propertyDeclarationTypes = { enabled = true },
                  functionLikeReturnTypes = { enabled = true },
                  enumMemberValues = { enabled = true },
                },
              },
            },
          },
        },
      })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique(
        opts.ensure_installed, { "vtsls", "biome"  }
      )
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "js" })
    end,
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    config = function()
      local success, js_debug_adapter_path = pcall(function ()
        return utils.get_pkg_path("js-debug-adapter", "/js-debug/src/dapDebugServer.js")
      end)
      if not success then return end

      local dap = require "dap"
      if not dap.adapters["pwa-node"] then
        require("dap").adapters["pwa-node"] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "node",
            args = {
              js_debug_adapter_path,
              "${port}",
            },
          },
        }
      end
      if not dap.adapters["node"] then
        dap.adapters["node"] = function(cb, config)
          if config.type == "node" then config.type = "pwa-node" end
          local nativeAdapter = dap.adapters["pwa-node"]
          if type(nativeAdapter) == "function" then
            nativeAdapter(cb, config)
          else
            cb(nativeAdapter)
          end
        end
      end

      if not dap.adapters["pwa-chrome"] then
        dap.adapters["pwa-chrome"] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "node",
            args = {
              js_debug_adapter_path,
              "${port}",
            },
          },
        }
      end
      local js_filetypes = { "typescriptreact", "typescript", "javascript", "javascriptreact", "vue" }

      local vscode = require "dap.ext.vscode"
      vscode.type_to_filetypes["node"] = js_filetypes
      vscode.type_to_filetypes["pwa-node"] = js_filetypes
      vscode.type_to_filetypes["pwa-chrome"] = js_filetypes

      for _, language in ipairs(js_filetypes) do
        if not dap.configurations[language] then
          dap.configurations[language] = {
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch file",
              program = "${file}",
              cwd = "${workspaceFolder}",
            },
            {
              type = "pwa-node",
              request = "attach",
              name = "Attach",
              processId = require("dap.utils").pick_process,
              cwd = "${workspaceFolder}",
            },
            {
              type = "pwa-chrome",
              request = "launch",
              name = "Launch Chrome with localhost",
              url = function()
                local co = coroutine.running()
                return coroutine.create(function()
                  Snacks.input({prompt =  "Enter URL: ", default = "http://localhost:5137"}, function(url)
                    if url == nil or url == "" then
                      return
                    else
                      coroutine.resume(co, url)
                    end
                  end)
                end)
              end,
              webRoot = "${workspaceFolder}",
              protocol = "inspector",
              sourceMaps = true,
              skipFiles = {
                "<node_internals>/**", "node_modules/**", "${workspaceFolder}/node_modules/**"
              },
              resolveSourceMapLocations = {
                "${workspaceFolder}/apps/**/**",
                "${workspaceFolder}/**",
                "!**/node_modules/**",
                "!**/bower_components/**"
              },
            },
            {
              type = "pwa-chrome",
              request = "attach",
              name = "Attach Program (pwa-chrome, select port)",
              webRoot = "${workspaceFolder}",
              protocol = "inspector",
              sourceMaps = true,
              port = function() return vim.fn.input("select port: ", "9222") end,
              skipFiles = {
                "<node_internals>/**", "node_modules/**", "${workspaceFolder}/node_modules/**"
              },
            }
          }
        end
      end
    end,
  },
  {
    "vuki656/package-info.nvim",
    dependencies = { "MunifTanjim/nui.nvim", lazy = true },
    event = "BufRead package.json",
  },
  {
    "yioneko/nvim-vtsls",
    lazy = true,
    dependencies = {
      "AstroNvim/astrocore",
      opts = {
        autocmds = {
          nvim_vtsls = {
            {
              event = "LspAttach",
              desc = "Load nvim-vtsls with vtsls",
              callback = function(args)
                if assert(vim.lsp.get_client_by_id(args.data.client_id)).name == "vtsls" then
                  require("vtsls")._on_attach(args.data.client_id, args.buf)
                  vim.api.nvim_del_augroup_by_name "nvim_vtsls"
                end
              end,
            },
          },
        },
      },
    },
    config = function(_, opts) require("vtsls").config(opts) end,
  },
  {
    "dmmulroy/tsc.nvim",
    cmd = { "TSC" },
    opts = {},
  },
  {
    "dmmulroy/ts-error-translator.nvim",
    opts = {},
    ft = { "typescript", "vue" },
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      { "marilari88/neotest-vitest" },
      { "nvim-neotest/neotest-jest", config = function() end }
    },
    opts = function(_, opts)
      if not opts.adapters then opts.adapters = {} end
      table.insert(opts.adapters, require "neotest-vitest"(astrocore.plugin_opts "neotest-vitest"))
      table.insert(opts.adapters, require "neotest-jest"(astrocore.plugin_opts "neotest-jest"))
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      if not opts.formatters_by_ft then opts.formatters_by_ft = {} end
      local supported_ft = {
        "astro",
        "css",
        "graphql",
        -- "html",
        "javascript",
        "javascriptreact",
        "json",
        "jsonc",
        -- "markdown",
        "svelte",
        "typescript",
        "typescriptreact",
        "vue",
        -- "yaml",
      }
      for _, filetype in ipairs(supported_ft) do
        opts.formatters_by_ft[filetype] = conform_formatter
      end
    end
  }
}
