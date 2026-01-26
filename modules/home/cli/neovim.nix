{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  telescope = "require('telescope.builtin')";
in {
  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    clipboard.providers.wl-copy.enable = true;
    clipboard.providers.xclip.enable = true;

    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "frappe";
        transparent_background = true;
      };
    };

    lsp = {
      keymaps = [
        {
          key = "gd";
          lspBufAction = "definition";
        }
        {
          key = "gD";
          lspBufAction = "references";
        }
        {
          key = "gt";
          lspBufAction = "type_definition";
        }
        {
          key = "gi";
          lspBufAction = "implementation";
        }
        {
          key = "K";
          lspBufAction = "hover";
        }
        {
          action = inputs.nixvim.lib.nixvim.mkRaw "function() vim.diagnostic.jump({ count=-1, float=true }) end";
          key = "<leader>k";
        }
        {
          action = inputs.nixvim.lib.nixvim.mkRaw "function() vim.diagnostic.jump({ count=1, float=true }) end";
          key = "<leader>j";
        }
        {
          action = "<CMD>LspStop<Enter>";
          key = "<leader>lx";
        }
        {
          action = "<CMD>LspStart<Enter>";
          key = "<leader>ls";
        }
        {
          action = "<CMD>LspRestart<Enter>";
          key = "<leader>lr";
        }
        {
          action = inputs.nixvim.lib.nixvim.mkRaw "require('telescope.builtin').lsp_definitions";
          key = "gd";
        }
        {
          action = "<CMD>Lspsaga hover_doc<Enter>";
          key = "K";
        }
      ];
      servers = {
        # python
        ruff.enable = true;
        pyright.enable = true;

        # nix
        nixd.enable = true;

        # typst
        tinymist.enable = true;
      };
    };

    plugins = {
      # all grammars by default
      #treesitter = {
      #  enable = true;
      #};
      lspsaga.enable = true;
      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
      };
      nix.enable = true; # .nix
      vim-surround.enable = true;
      nvim-ufo.enable = false;
      typst-vim.enable = true;
      lsp = {
        enable = true;
        servers = {
          # markdown
          #marksman.enable = true;
          # does this do anything?
          #typst_lsp.enable = true;

          openscad_lsp = {
            enable = true;
            filetypes = ["scad"];
          };

          # html
          superhtml = {
            enable = false;
            autostart = true;
            package = pkgs.superhtml;
          };
        };
      };
      openscad = {
        enable = true;
      };
      web-devicons.enable = true;
      which-key = {
        # popup that lists keybindings
        enable = true;
      };
    };
    extraPlugins = with pkgs.vimPlugins; [
      hop-nvim
      nvim-treesitter-parsers.just
    ];

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };
    opts = {
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
        action.__raw = "require('telescope.builtin').find_files";
        key = "<leader>ff";
        options.desc = "Find files";
      }
      {
        action.__raw = "require('telescope.builtin').live_grep";
        key = "<leader>fg";
        options.desc = "Grep files";
      }
      {
        action.__raw = "require('telescope.builtin').buffers";
        key = "<leader>fb";
        options.desc = "Find buffers";
      }
      {
        action.__raw = "require('telescope.builtin').help_tags";
        key = "<leader>fh";
        options.desc = "Find help";
      }
      {
        action.__raw = "require('hop').hint_words";
        key = "<leader>w";
        options.desc = "Hop to word";
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
  };
}
