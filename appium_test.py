from appium import webdriver
import time

desired_caps = {
    "platformName": "Android",
    "deviceName": "emulator-5554",
    "appPackage": "com.example.yourapp",       # Change to your app's package
    "appActivity": ".MainActivity",            # Change to your app's main activity
    "automationName": "UiAutomator2"
}

driver = webdriver.Remote("http://localhost:4723/wd/hub", desired_caps)

time.sleep(5)

# Example interaction:
try:
    element = driver.find_element("id", "com.example.yourapp:id/button")
    element.click()
except:
    print("Button not found!")

driver.quit()
