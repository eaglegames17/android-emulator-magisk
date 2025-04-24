def generate_appium_test(package, activity, element_id=None, input_text=None):
    script = f"""
from appium import webdriver
from appium.webdriver.common.appiumby import AppiumBy
import time

desired_caps = {{
    "platformName": "Android",
    "deviceName": "emulator-5554",
    "appPackage": "{package}",
    "appActivity": "{activity}",
    "automationName": "UiAutomator2",
    "noReset": True
}}

driver = webdriver.Remote("http://localhost:4723/wd/hub", desired_caps)
time.sleep(5)
"""
    if element_id and input_text:
        script += f'driver.find_element(AppiumBy.ID, "{element_id}").send_keys("{input_text}")\n'
    elif element_id:
        script += f'driver.find_element(AppiumBy.ID, "{element_id}").click()\n'

    script += """
time.sleep(3)
driver.quit()
"""
    with open("test_appium.py", "w") as f:
        f.write(script)
    print("[✓] Appium test saved as test_appium.py")


# Example usage
generate_appium_test("com.example.yourapp", "com.example.yourapp.MainActivity", "com.example.yourapp:id/input_id", "Test message")
