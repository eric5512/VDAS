from serial import Serial

class SerialInterface:
    __handler = Serial()
    __open = False
    __name = None

    def connect(port):
        SerialInterface.__handler.port = port
        SerialInterface.__handler.open()
        SerialInterface.__open = SerialInterface.__handler.is_open
        return SerialInterface.__open
    
    def send_command(com):
        return SerialInterface.__handler.write(com)
    
    def receive_data():
        data = dict()

        

        return data

