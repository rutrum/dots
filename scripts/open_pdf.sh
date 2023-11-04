file=$(fd . --no-ignore --extension pdf $HOME | rofi -dmenu)
if [ -n $file ]; then
    zathura $file &
fi
