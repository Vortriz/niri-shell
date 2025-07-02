from ignis import widgets
from ignis import utils
from ignis.services.audio import AudioService
from ignis.services.backlight import BacklightService
from ..shared_widgets import MaterialBrightnessSlider, MaterialVolumeSlider

audio = AudioService.get_default()
backlight = BacklightService.get_default()


class OSD(widgets.RevealerWindow):
    def __init__(self, namespace: str, revealer):
        super().__init__(
            visible=False,
            popup=True,
            layer="overlay",
            anchor=["bottom"],
            namespace=f"ignis_OSD_{namespace}",
            css_classes=["rec-unset"],
            child=widgets.Box(child=[revealer]),
            revealer=revealer,
        )

    def set_property(self, property_name, value):
        if property_name == "visible":
            self.__update_visible()

        super().set_property(property_name, value)

    @utils.debounce(1500)
    def __update_visible(self) -> None:
        super().set_property("visible", False)


class OSDBacklight(OSD):
    def __init__(self):
        super().__init__(
            namespace="Backlight",
            revealer=widgets.Revealer(
                transition_type="crossfade",
                child=widgets.Box(
                    child=[
                        widgets.Icon(
                            pixel_size=26,
                            style="margin-right: 0.5rem;",
                            image="brightness",
                        ),
                        MaterialBrightnessSlider(sensitive=False),
                    ],
                    css_classes=["osd"],
                ),
                transition_duration=300,
                reveal_child=True,
            ),
        )


class OSDMic(OSD):
    def __init__(self):
        super().__init__(
            namespace="Microphone",
            revealer=widgets.Revealer(
                transition_type="crossfade",
                child=widgets.Box(
                    child=[
                        widgets.Icon(
                            pixel_size=26,
                            style="margin-right: 0.5rem;",
                            image=audio.microphone.bind("icon_name"),
                        ),
                        MaterialVolumeSlider(stream=audio.microphone, sensitive=False),
                    ],
                    css_classes=["osd"],
                ),
                transition_duration=300,
                reveal_child=True,
            ),
        )


class OSDSpeaker(OSD):
    def __init__(self):
        super().__init__(
            namespace="Speaker",
            revealer=widgets.Revealer(
                transition_type="crossfade",
                child=widgets.Box(
                    child=[
                        widgets.Icon(
                            pixel_size=26,
                            style="margin-right: 0.5rem;",
                            image=audio.speaker.bind("icon_name"),
                        ),
                        MaterialVolumeSlider(stream=audio.speaker, sensitive=False),
                    ],
                    css_classes=["osd"],
                ),
                transition_duration=300,
                reveal_child=True,
            ),
        )
