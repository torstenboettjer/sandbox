# grafik
Home directory for desktop publishing tools

fix the glx startup error for krita

```sh
export QT_XCB_GL_INTEGRATION=none
```

copy icons

```sh
cp ./icon/*.svg $HOME/.local/share/icons/hicolor/scalable/apps/
```

copy desktop files

```sh
sudo cp ./desktop/*.desktop $HOME/.local/share/applications/

```
