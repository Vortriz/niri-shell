from ignis import widgets
from ignis.services.backlight import BacklightService

backlight = BacklightService.get_default()


class MaterialBrightnessSlider(widgets.Scale):
    def __init__(self, **kwargs):
        super().__init__(
            max=backlight.max_brightness,
            value=backlight.bind("brightness"),
            css_classes=["material-slider"],
            hexpand=True,
            step=5,
            **kwargs,
        )
