import RPi.GPIO as GPIO
import asyncio
import websockets
import json
import Adafruit_DHT


DHT_SENSOR = Adafruit_DHT.DHT11
DHT_PIN = 4

RED_PIN = 17
GREEN_PIN = 18
BLUE_PIN = 27

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(RED_PIN, GPIO.OUT)
GPIO.setup(GREEN_PIN, GPIO.OUT)
GPIO.setup(BLUE_PIN, GPIO.OUT)

red_pwm = GPIO.PWM(RED_PIN, 100)
green_pwm = GPIO.PWM(GREEN_PIN, 100)
blue_pwm = GPIO.PWM(BLUE_PIN, 100)

red_pwm.start(0)
green_pwm.start(0)
blue_pwm.start(0)


async def handle_connection(websocket, path):

    try:
        
        # Tạo hai coroutine chạy song song
        receive_coroutine = receive_data(websocket)
        send_coroutine = send_data(websocket)

        await asyncio.gather(receive_coroutine, send_coroutine)
    except websockets.ConnectionClosedError:
        print("Client disconnected")

async def receive_data(websocket):
    async for message in websocket:
        data = json.loads(message)
        argb_color_str = data['color']
        onoff = data['leb']
        print(argb_color_str)
        brightness = data['bright']

       
        #4280365555
        argb_color_int = int(argb_color_str, 16)
        alpha = (argb_color_int >> 24) & 0xFF
        red = (argb_color_int >> 16) & 0xFF
        green = (argb_color_int >> 8) & 0xFF
        blue = argb_color_int & 0xFF

        set_rgb_led(red, green, blue, onoff, brightness)

    

async def send_data(websocket):
        
    humidity, temperature = Adafruit_DHT.read(DHT_SENSOR, DHT_PIN)

    if humidity is not None and temperature is not None:
        #print(f"Temp={temperature:0.1f}C Humidity={humidity:0.1f}%")

        data_to_send = {
            'temperature': temperature,
            'humidity': humidity,
        }

        await websocket.send(json.dumps(data_to_send))
    else:
        print("Sensor failure. Check wiring.")

            

def set_rgb_led(red, green, blue, onoff, brightness):
    if onoff == 0:
        red_pwm.ChangeDutyCycle(0)
        green_pwm.ChangeDutyCycle(0)
        blue_pwm.ChangeDutyCycle(0)
    else:
        red_pwm.ChangeDutyCycle((red / 255) * 100 * (brightness / 100))
        green_pwm.ChangeDutyCycle((green / 255) * 100 * (brightness / 100))
        blue_pwm.ChangeDutyCycle((blue / 255) * 100 * (brightness / 100))

start_server = websockets.serve(handle_connection, "0.0.0.0", 8765)
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()