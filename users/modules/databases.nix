{ pkgs, ... }:
{
  home.packages = with pkgs; [
    dbeaver
    sqlite-jdbc
    postgresql_jdbc
    mysql_jdbc
  ];
}
