return {
    -- 1. MASON (Менеджер бинарников)
    {
        'williamboman/mason.nvim',
        config = function()
            require('mason').setup()
        end,
    },

    -- 2. MASON-LSPCONFIG (Автоматический запуск и настройки)
    {
        'williamboman/mason-lspconfig.nvim',
        dependencies = {
            'williamboman/mason.nvim',
            'neovim/nvim-lspconfig',
            'hrsh7th/cmp-nvim-lsp',
        },
        config = function()
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            require('mason-lspconfig').setup({
                ensure_installed = {
                    'lua_ls',       -- Lua
                    'basedpyright', -- Python (типы)
                    'ruff',         -- Python (быстрый линтер + форматирование)
                    'ts_ls',        -- JS/TS
                    'html',         -- HTML
                    'cssls',        -- CSS
                    'clangd',       -- C/C++
                },
                handlers = {
                    function(server_name)
                        local opts = { capabilities = capabilities }

                        -- Убираем жёлтые предупреждения (W): сообщаем lua_ls про глобальный объект vim
                        if server_name == 'lua_ls' then
                            opts.settings = {
                                Lua = {
                                    diagnostics = {
                                        globals = { 'vim' },
                                    },
                                    workspace = {
                                        library = vim.api.nvim_get_runtime_file('', true),
                                        checkThirdParty = false,
                                    },
                                },
                            }
                        end

                        require('lspconfig')[server_name].setup(opts)
                    end,
                },
            })

            -- Быстрая починка кода (Code Actions) на <Space> + c
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('UserLspConfig', {}),
                callback = function(ev)
                    local opts = { buffer = ev.buf }
                    vim.keymap.set({ 'n', 'v' }, '<space>c', vim.lsp.buf.code_action, opts)
                end,
            })
        end,
    },

    -- 3. NVIM-CMP (Автодополнение по TAB)
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
        },
        config = function()
            local cmp = require('cmp')
            local luasnip = require('luasnip')

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.confirm({ select = true })
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                }),
            })
        end,
    },
}
