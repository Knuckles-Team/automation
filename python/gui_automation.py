import pyautogui
import platform
import time

# Moves to coordinate
#pyautogui.moveTo(x=500, y=500, duration=3)

# Moves in relation to current mouse location
#pyautogui.moveRel(50, 50, duration=1)

# # Move pixels in relation to current position and click
# pyautogui.click(50, 20, duration=1)
# pyautogui.doubleClick()
#
# # dragTo dragRel behave like move, but keep mouse clicked the whole time.
# pyautogui.dragTo(50, 20, duration=2)
# pyautogui.dragRel(50, 50, duration=2)

# Scroll wheel - Supports movements -/+
#pyautogui.scroll(-500)
#pyautogui.scroll(500)

# Keyboard functions
#pyautogui.typewrite("This is a test command")
# with pyautogui.hold('shift'):  # Press the Shift key down and hold it.
#     pyautogui.press(['left', 'left', 'left', 'left'])

# Alerts
#pyautogui.alert('Your computer will now restart.')

# Hot Keys
#pyautogui.press('esc')
#pyautogui.hotkey('ctrlleft', 'alt', 'delete')
#pyautogui.hotkey('enter')

def open_paint():
    print("Opening paint")
    if "ubuntu" in str(version).lower():
        time.sleep(1)
        pyautogui.hotkey('winleft')
        time.sleep(1)
        pyautogui.typewrite("xpaint")
        time.sleep(1)
        pyautogui.hotkey('enter')
        time.sleep(2)
        pyautogui.click(100, 100, duration=.2)
        time.sleep(1)
        pyautogui.click(100, 120, duration=.3)
        time.sleep(1)
        pyautogui.hotkey('winleft', 'up')
        time.sleep(1)
        pyautogui.click(169, 118, duration=.3)
        time.sleep(1)

    elif "windows" in str(system).lower() and ("10" in release or "11" in release):
        time.sleep(1)
        pyautogui.hotkey('winleft')
        pyautogui.typewrite("paint")
        pyautogui.hotkey('enter')
        time.sleep(2)

    x_start = 200
    y_start = 200
    pyautogui.click(200, 200, duration=.3)
    distance = 400
    while distance > 0:
        pyautogui.drag(distance, 0, duration=0.01)  # move right
        distance -= 5
        pyautogui.drag(0, distance, duration=0.01)  # move down
        pyautogui.drag(-distance, 0, duration=0.01)  # move left
        distance -= 5
        pyautogui.drag(0, -distance, duration=0.01)  # move up


def logout_user():
    if "ubuntu" in str(version).lower():
        pyautogui.hotkey('ctrlleft', 'alt', 'delete')
        time.sleep(2)
        pyautogui.hotkey('tab')
        time.sleep(1)
        pyautogui.hotkey('enter')
    elif "windows" in str(system).lower() and ("10" in release or "11" in release):
        pyautogui.hotkey('ctrlleft', 'alt', 'delete')
        pyautogui.hotkey('down')
        pyautogui.hotkey('down')
        pyautogui.hotkey('enter')
        time.sleep(2)
        pyautogui.hotkey('enter')


system = platform.system()
release = platform.release()
version = platform.version()

print(f"System: {system}\nRelease: {release}\nVersion: {version}\nScreen Size: {pyautogui.size()}")
open_paint()

