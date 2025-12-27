local astrocore = require("astrocore")
return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "kotlin" })
      end
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "kotlin" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique(
        opts.ensure_installed,
        { "kotlin-lsp", "ktlint", "ktfmt", "kotlin-debug-adapter" }
      )
    end,
  },
  {
    "mfussenegger/nvim-lint",
    event = "VeryLazy",
    ft = "kotlin",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.kotlin = { "ktlint" }
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "codymikol/neotest-kotlin",
    },
    config = function(_, opts)
      if not opts.adapters then opts.adapters = {} end
      table.insert(opts.adapters, require("neotest-kotlin")(astrocore.plugin_opts "neotest-kotlin"))
    end
  },
  {
    "stevearc/conform.nvim",
    event = "VeryLazy",
    ft = "kotlin",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      local package = "ktfmt"
      opts.formatters_by_ft.kotlin = { package }
    end
  },

  {
      "AlexandrosAlexiou/kotlin.nvim",
      ft = { "kotlin" },
      dependencies = {
          "mason.nvim",
          "mason-lspconfig.nvim",
          "stevearc/oil.nvim",
          "trouble.nvim",
      },
      config = function()
          require("kotlin").setup {
              -- Optional: Specify root markers for multi-module projects
              root_markers = {
                  "gradlew",
                  ".git",
                  "mvnw",
                  "settings.gradle",
              },

              -- Optional: Java Runtime to run the kotlin-lsp server itself
              -- NOT REQUIRED when using Mason (kotlin-lsp v261+ includes bundled JRE)
              -- Priority: 1. jre_path, 2. Bundled JRE (Mason), 3. System java
              --
              -- Use this if you want to run kotlin-lsp with a specific Java version
              -- Must point to JAVA_HOME (directory containing bin/java)
              -- Examples:
              --   macOS:   "/Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home"
              --   Linux:   "/usr/lib/jvm/java-21-openjdk"
              --   Windows: "C:\\Program Files\\Java\\jdk-21"
              --   Env var: os.getenv("JAVA_HOME") or os.getenv("JDK21")
              jre_path = nil,  -- Use bundled JRE (recommended)

              -- Optional: JDK for symbol resolution (analyzing your Kotlin code)
              -- This is the JDK that your project code will be analyzed against
              -- Different from jre_path (which runs the server)
              -- Required for: Analyzing JDK APIs, standard library symbols, platform types
              --
              -- Usually should match your project's target JDK version
              -- Examples:
              --   macOS:   "/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home"
              --   Linux:   "/usr/lib/jvm/java-17-openjdk"
              --   Windows: "C:\\Program Files\\Java\\jdk-17"
              --   SDKMAN:  os.getenv("HOME") .. "/.sdkman/candidates/java/17.0.8-tem"
              jdk_for_symbol_resolution = nil,  -- Auto-detect from project

              -- Optional: Specify additional JVM arguments for the kotlin-lsp server
              jvm_args = {
                  "-Xmx4g",  -- Increase max heap (useful for large projects)
              },

              -- Optional: Configure inlay hints (requires kotlin-lsp v261+)
              -- All settings default to true, set to false to disable specific hints
              inlay_hints = {
                  enabled = true,  -- Enable inlay hints (auto-enable on LSP attach)
                  parameters = true,  -- Show parameter names
                  parameters_compiled = true,  -- Show compiled parameter names
                  parameters_excluded = false,  -- Show excluded parameter names
                  types_property = true,  -- Show property types
                  types_variable = true,  -- Show local variable types
                  function_return = true,  -- Show function return types
                  function_parameter = true,  -- Show function parameter types
                  lambda_return = true,  -- Show lambda return types
                  lambda_receivers_parameters = true,  -- Show lambda receivers/parameters
                  value_ranges = true,  -- Show value ranges
                  kotlin_time = true,  -- Show kotlin.time warnings
              },
          }
      end,
  },
}
