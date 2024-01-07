from libevdev import EV_SW, EV_KEY, InputEvent

flip_keys = [
    EV_KEY.KEY_PROG2
]

laptop_mode_events = [
    InputEvent(EV_SW.SW_TABLET_MODE, 0)
]

tablet_mode_events = [
    InputEvent(EV_SW.SW_TABLET_MODE, 1)
]