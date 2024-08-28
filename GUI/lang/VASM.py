from enum import Enum
from typing import Dict, List
from AST import AST

Device = Enum("Device", ["ADC0", "ADC1", "CADC0", "CADC1", "DI0", "DI1", "DI2", "DI3", "DI4", "DI5", "DI6", "DI7", "DO0", "DO1", "DO2", "DO3", "DO4", "DO5", "DO6", "DO7", "DAC0", "DAC1"])

class DeviceError(Exception):
    def __init__(self, device: str, function: str) -> None:
        super().__init__("")

def is_input(dev: Device) -> bool:
    return dev in (Device.ADC0, Device.ADC1, Device.CADC0, Device.CADC1, Device.DI0, Device.DI1, Device.DI2, 
        Device.DI3, Device.DI4, Device.DI5, Device.DI6, Device.DI7)

def is_digital(dev: Device) -> bool:
    return dev not in (Device.ADC0, Device.ADC1, Device.CADC0, Device.CADC1, Device.DAC0, Device.DAC1)

Devices = Dict[str, Device]

VOLTAGE_FS = 20.0

def get_devices(ast: List[AST]) -> Devices:
    ret = dict()
    for i in ast:
        if type(i) == AST.Init:
            try:
                ret[i.name] = Device[i.type]
            except KeyError:
                continue


def activate(dev: Device) -> bytes:
    match dev:
        case Device.DI0 | Device.DI1 | Device.DI2 | Device.DI3 | Device.DI4 | Device.DI5 | Device.DI6 | Device.DI7:
            return 0b00000000
        case Device.ADC0:
            return 0b00000100
        case Device.ADC1:
            return 0b00001000
        case Device.CADC0:
            return 0b00001100
        case Device.CADC1:
            return 0b00010000
        case _:
            raise DeviceError(dev.name, "activate")

def set_digital(dev: Device, value: bool) -> bytes:
    match dev:
        case Device.DO0:
            devb = 0b000
        case Device.DO1:
            devb = 0b001
        case Device.DO2:
            devb = 0b010
        case Device.DO3:
            devb = 0b011
        case Device.DO4:
            devb = 0b100
        case Device.DO5:
            devb = 0b101
        case Device.DO6:
            devb = 0b110
        case Device.DO7:
            devb = 0b111
        case _:
            raise DeviceError(dev.name, "set_digital")
    return (((0b001000 | devb) << 2) + (0b10 if value else 0b00)).to_bytes(1, 'big')

def set_analog(dev: Device, value: float):
    match dev:
        case Device.DAC0:
            devb = 0b0
        case Device.DAC1:
            devb = 0b1
        case _:
            raise DeviceError(dev.name, "set_analog")
    return ((((0b0100 | devb) << 12) + (int((value+10)/20)) & 0b111111111111)).to_bytes(2, 'big')
