import serial.tools.list_ports
import serial

# ports = list(serial.tools.list_ports.comports())
# for p in ports:
#     print(p)



ser = serial.Serial('COM3', 115200, timeout=10)

ser.write(b'YOU HAVE A S')
print(ser.read(12))
