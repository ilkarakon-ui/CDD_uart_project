import serial
import random
import time

num1 = random.getrandbits(512)
data1 = num1.to_bytes(64, byteorder='big')

num2 = random.getrandbits(512)
data2 = num2.to_bytes(64, byteorder='big')

int_add = num1 + num2
bin_add = data1 + data2

# Initialize serial port
ser = serial.Serial('COM3', 115200, timeout=10)

# FIX 1: Wait for the board to exit reset before sending data
time.sleep(2) 
ser.reset_input_buffer() # Clear any junk left in the buffer

print("Sending data to FPGA...")
ser.write(bin_add)


output_big = ser.read(69)

output = output_big[:65]
clock = output_big[65:]
clock_int = int.from_bytes(clock, byteorder='big')

if len(output) < 65:
    print(f"Timeout! Only received {len(output)} bytes out of 65.")
else:
    
    output_int = int.from_bytes(output, byteorder='big') >> 7
    
    print("\n--- Results ---")
    print(f"Expected Sum : {int_add}")
    print(f"FPGA Sum     : {output_int}")
    print(f"Match        : {output_int == int_add}")
    print(f"Clock        : {clock_int}")

ser.close()