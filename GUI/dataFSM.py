from enum import Enum

class DataFSM:
    __slots__ = ('__state', '__substate', '__type', '__data')

    __STATES = Enum('STATES', ['START', 'HEADER', 'DATA'])
    __SUBSTATES = Enum('SUBSTATES', ['BYTE1', 'BYTE2'])

    __DIN = 0b00100000
    __ADC0 = 0b01000000
    __ADC1 = 0b01100000
    __CADC0 = 0b10000000
    __CADC1 = 0b10100000

    def __init__(self) -> None:
        self.__state = self.__STATES.START
        self.__substate = self.__SUBSTATES.BYTE1
    
    def __num_to_type(self) -> str:
        match self.__type:
            case self.__DIN:
                return 'DI'
            case self.__ADC0:
                return 'ADC0'
            case self.__ADC1:
                return 'ADC1'
            case self.__CADC0:
                return 'CADC0'
            case self.__CADC1:
                return 'CADC1'

    def recieve(self, byte: bytes):
        byte = byte[0]
        print(f"Received {byte}")
        match self.__state:
            case self.__STATES.START:
                if byte == 0:
                    self.__state = self.__STATES.HEADER
            case self.__STATES.HEADER:
                if byte in [self.__DIN , self.__ADC0 , self.__ADC1 , self.__CADC0 , self.__CADC1]:
                    self.__type = byte
                    self.__state = self.__STATES.DATA
                else:
                    self.__state = self.__STATES.START
            case self.__STATES.DATA:
                match self.__substate:
                    case self.__SUBSTATES.BYTE1:
                        self.__data = byte
                        
                        if self.__type == self.__DIN:
                            self.__state = self.__STATES.START
                            return (self.__num_to_type(), self.__data)
                        
                        self.__state = self.__SUBSTATES.BYTE2

                    case self.__SUBSTATES.BYTE2:
                        self.__data |= byte << 8
                        self.__state = self.__STATES.START
                        return (self.__num_to_type(), self.__data)