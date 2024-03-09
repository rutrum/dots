{ config, lib, pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraLuaConfig = pkgs.lib.fileContents ./neovim.lua;

    # only needed if a plugin requires it
    # extraLuaPackages = luaPkgs: with luaPkgs; [ luautf8 ];

    extraPackages = with pkgs; [
      wl-clipboard
      vimPlugins.plenary-nvim # needed for null-ls
    ];

    plugins = with pkgs.vimPlugins; [

      # language specific plugins
      vim-nix # nix
      vim-parinfer # lisp
      vim-svelte # svelte

      #mason-nvim # for LSP?
      #mason-lspconfig-nvim 
      #nvim-lspconfig

      #{ plugin = none-ls-nvim;
      #  type = "lua";
      #  config = ''
      #    local null_ls = require("null-ls")
      #    null_ls.setup({
      #      sources = {
      #        null_ls.builtins.completion.luasnip,
      #        null_ls.builtins.code_actions.statix,
      #      },
      #    })
      #  '';
      #}

      { plugin = hop-nvim;
        type = "lua";
        config = "require('hop').setup()";
      }
      # better source code highlighting
      #(nvim-treesitter.withPlugins (parsers: with parsers; [
      #  tree-sitter-nix
      #]))

      # needs an icon set? maybe not urxvt
      # { plugin = lualine-nvim;
      #   type = "lua";
      #   config = ''
      #     require("lualine").setup()
      #   '';
      # }


      # quickly comment lines or blocks of code
      { plugin = comment-nvim;
        type = "lua";
        config = "require('Comment').setup()";
      }
    ];
  };
}
