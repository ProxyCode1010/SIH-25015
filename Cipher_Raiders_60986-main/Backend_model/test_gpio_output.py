
# test_gpio_output.py
import lgpio, time
h = lgpio.gpiochip_open(0)
pins = [17,27,22]
for p in pins:
    lgpio.gpio_claim_output(h,p)
    print("Testing GPIO",p)
    lgpio.gpio_write(h,p,1)
    print("HIGH")
    time.sleep(1)
    lgpio.gpio_write(h,p,0)
    print("LOW")
    time.sleep(1)

