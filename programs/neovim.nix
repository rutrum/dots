{ pkgs }:
let 
  # todo: figure out how to map the type to lua for all plugins
  plugins = with pkgs.vimPlugins; [

    # language specific plugins
    vim-nix # nix
    vim-parinfer # lisp
    vim-svelte
    { plugin = hop-nvim;
      type = "lua";
      config = "require('hop').setup()";
    }
    # better source code highlighting
    # nvim-treesitter.withPlugins (parsers: with parsers; [
    #   nix
    # ])

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
in {
  enable = true;
  defaultEditor = true;
  viAlias = true;
  vimAlias = true;
  extraLuaConfig = pkgs.lib.fileContents ./neovim.lua;

  # only needed if a plugin requires it
  # extraLuaPackages = luaPkgs: with luaPkgs; [ luautf8 ];

  inherit plugins;
}
