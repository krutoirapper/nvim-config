return {
    {
        'williamboman/mason.nvim',
        config = function()
            require('mason').setup()
        end,
    },

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
                    'basedpyright',
                    'ruff',
                    'clangd',
                },
                handlers = {
                    function(server_name)
                        require('lspconfig')[server_name].setup({
                            capabilities = capabilities,
                        })
                    end,
                },
            })

            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(ev)
                    local opts = { buffer = ev.buf }
                    vim.keymap.set({ 'n', 'v' }, '<space>c', vim.lsp.buf.code_action, opts)
                    vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
                end,
            })

            vim.api.nvim_create_autocmd('BufWritePre', {
                callback = function(args)
                    vim.lsp.buf.format({ bufnr = args.buf, async = false })
                end,
            })
        end,
    },

    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            'windwp/nvim-autopairs',
        },
        config = function()
            local cmp = require('cmp')
            local luasnip = require('luasnip')
            local cmp_autopairs = require('nvim-autopairs.completion.cmp')

            cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

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
                    { name = 'buffer' },
                }),
            })
        end,
    },
}
