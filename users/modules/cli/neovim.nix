{ config, lib, pkgs, ... }:
let
  telescope = "require('telescope.builtin')";
in {
  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    clipboard.providers.wl-copy.enable = true;

    plugins = {
      # all grammars by default
      treesitter = {
        enable = true;
      };
      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
      };
      surround.enable = true;
      nvim-ufo.enable = false;
    };
    extraPlugins = with pkgs.vimPlugins; [
      hop-nvim
      vim-nix
    ];

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };
    options = {
      relativenumber = true;

      # tabs
      tabstop = 4;
      shiftwidth = 4;
      expandtab = true;
      smartindent = true;

      updatetime = 100;
      mouse = "a";

      # don't keep things highlighted after search
      hlsearch = false;
      scrolloff = 8;
    };

    keymaps = [
      {
        action = "require('telescope.builtin').find_files";
        key = "<leader>ff";
        lua = true;
      }
      {
        action = "require('hop').hint_words";
        key = "<leader>w";
        lua = true;
      }
    ];

    extraConfigLua = ''
      require('hop').setup()
      local hop = require('hop');
      local directions = require('hop.hint').HintDirection
      vim.keymap.set("", 'f', function()
        hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true })
      end, {remap=true})
      vim.keymap.set("", 'F', function()
        hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true })
      end, {remap=true})
      vim.keymap.set("", 't', function()
        hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })
      end, {remap=true})
      vim.keymap.set("", 'T', function()
        hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })
      end, {remap=true})
    '';

    #colorschemes.catppuccin = {
    #  enable = true;
    #  flavour = "mocha";
    #};
  };
  #programs.neovim = {
  #  enable = true;
  #  defaultEditor = true;
  #  viAlias = true;
  #  vimAlias = true;
  #  vimdiffAlias = true;

  #  extraLuaConfig = pkgs.lib.fileContents ./neovim.lua;

  #  # only needed if a plugin requires it
  #  # extraLuaPackages = luaPkgs: with luaPkgs; [ luautf8 ];

  #  extraPackages = with pkgs; [
  #    wl-clipboard
  #    vimPlugins.plenary-nvim # needed for null-ls
  #  ];

  #  plugins = with pkgs.vimPlugins; [

  #    # language specific plugins
  #    #vim-nix # nix
  #    vim-parinfer # lisp
  #    vim-svelte # svelte

  #    #mason-nvim # for LSP?
  #    #mason-lspconfig-nvim 
  #    #nvim-lspconfig

  #    #{ plugin = none-ls-nvim;
  #    #  type = "lua";
  #    #  config = ''
  #    #    local null_ls = require("null-ls")
  #    #    null_ls.setup({
  #    #      sources = {
  #    #        null_ls.builtins.completion.luasnip,
  #    #        null_ls.builtins.code_actions.statix,
  #    #      },
  #    #    })
  #    #  '';
  #    #}

  #    { plugin = hop-nvim;
  #      type = "lua";
  #      config = "require('hop').setup()";
  #    }
  #    # better source code highlighting
  #    nvim-treesitter.withAllGrammars

  #    # needs an icon set? maybe not urxvt
  #    # { plugin = lualine-nvim;
  #    #   type = "lua";
  #    #   config = ''
  #    #     require("lualine").setup()
  #    #   '';
  #    # }


  #    # quickly comment lines or blocks of code
  #    { plugin = comment-nvim;
  #      type = "lua";
  #      config = "require('Comment').setup()";
  #    }
  #  ];
  #};
}
