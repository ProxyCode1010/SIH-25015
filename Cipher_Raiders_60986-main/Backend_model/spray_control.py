
# spray_control.py
import lgpio
import time

CHIP = 0
h = lgpio.gpiochip_open(CHIP)

# BCM pins
PUMP = 17
NOZZLE = 27
BYPASS = 22

# prepare pins
for p in (PUMP, NOZZLE, BYPASS):
    lgpio.gpio_claim_output(h, p)

# pump always ON
lgpio.gpio_write(h, PUMP, 1)

def spray_infected():
    lgpio.gpio_write(h, NOZZLE, 1)
    lgpio.gpio_write(h, BYPASS, 0)
    print("[SPRAY] INFECTED: Nozzle ON, Bypass OFF")

def spray_healthy():
    lgpio.gpio_write(h, NOZZLE, 0)
    lgpio.gpio_write(h, BYPASS, 1)
    print("[SPRAY] HEALTHY: Nozzle OFF, Bypass ON")

def cleanup():
    lgpio.gpio_write(h, NOZZLE, 0)
    lgpio.gpio_write(h, BYPASS, 0)
    # pump keep as per design; if stopping:
    # lgpio.gpio_write(h, PUMP, 0)
