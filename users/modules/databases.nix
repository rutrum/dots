{ pkgs, ... }:
{
  home.packages = with pkgs; [
    dbeaver-bin
    sqlite-jdbc
    postgresql_jdbc
    mysql_jdbc
  ];
}
