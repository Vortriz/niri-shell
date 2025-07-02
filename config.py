from ignis import utils
from ignis.app import IgnisApp

from modules import (
    Bar,
    ControlCenter,
    NotificationPopup,
    OSDBacklight,
    OSDMic,
    OSDSpeaker,
    Powermenu,
    Settings,
)

app = IgnisApp.get_default()

app.add_icons(f"{utils.get_current_dir()}/icons")
app.apply_css(utils.get_current_dir() + "/style.scss")

utils.exec_sh("gsettings set org.gnome.desktop.interface gtk-theme Material")
utils.exec_sh("gsettings set org.gnome.desktop.interface icon-theme Papirus")
utils.exec_sh(
    'gsettings set org.gnome.desktop.interface font-name "JetBrains Mono Regular 11"'
)


ControlCenter()

for monitor in range(utils.get_n_monitors()):
    Bar(monitor)

for monitor in range(utils.get_n_monitors()):
    NotificationPopup(monitor)

Powermenu()
OSDBacklight()
OSDMic()
OSDSpeaker()

Settings()
