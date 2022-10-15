import pyautogui
import pynput
import keyboard
import platform
import time
pyautogui.PAUSE = 0

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

# Get coordinates
# pyautogui.displayMousePosition()

def aim_booster():
    time.sleep(1)
    print("Starting aimbooster")
    game_coordinates = [738, 246]
    pixel_margin_of_error = 10
    while True:
        pic = pyautogui.screenshot(region=(game_coordinates[0], game_coordinates[1], game_coordinates[0] + 596, game_coordinates[1] + 418))
        print("New Pic Taken")
        width, height = pic.size
        previous_point = [0, 0]
        for x in range(0, width, 5):
            for y in range(0, height, 5):
                r, g, b = pic.getpixel((x, y))
                if b == 195 and r == 255 and g == 219:
                    #print(f"FOUND AT: X {x + game_coordinates[0]} Y {y + game_coordinates[1]}")
                    point = [x + game_coordinates[0], y + game_coordinates[1]]

                    if (point[0] - pixel_margin_of_error) > previous_point[0] or previous_point[0] > (point[0] + pixel_margin_of_error)\
                            and (point[1] - pixel_margin_of_error) > previous_point[1] or previous_point[1] > (point[1] + pixel_margin_of_error):
                        print(f"Clicking Point: {point} Previous Point: {previous_point}")
                        pyautogui.click(point[0], point[1], duration=0.05)
                        previous_point = point

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
        pyautogui.click(100, 100, duration=.01)
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

def click_pynput(x, y, button):
    mouse.position = (x, y)
    button = pynput.mouse.Button['left'] if button=='left' else pynput.mouse.Button['right']
    mouse.click(button)


mouse = pynput.mouse.Controller()
system = platform.system()
release = platform.release()
version = platform.version()

print(f"System: {system}\nRelease: {release}\nVersion: {version}\nScreen Size: {pyautogui.size()}")
#aim_booster()
open_paint()

