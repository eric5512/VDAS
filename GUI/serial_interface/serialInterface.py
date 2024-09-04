from serial import Serial

from serial_interface.dataFSM import DataFSM

class SerialInterface:
    __handler = Serial()

    __fsm = DataFSM()

    def connect(port):
        SerialInterface.__handler.port = port
        # SerialInterface.__handler.baudrate = 921600
        SerialInterface.__handler.baudrate = 256000
        SerialInterface.__handler.open()
        return SerialInterface.__handler.is_open
    
    def send_command(com):
        return SerialInterface.__handler.write(com)
    
    def receive_data_process(on_received):
        while True:
            while SerialInterface.__handler.in_waiting == 0:
                pass
            byte = SerialInterface.__handler.read()
            if((ret := SerialInterface.__fsm.recieve(byte)) != None):
                on_received(ret)

    def close():
        if SerialInterface.__handler.is_open:
            SerialInterface.__handler.close()

