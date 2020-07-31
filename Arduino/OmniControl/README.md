# OmniRobot/Arduino/OmniControl

Program to upload to PCB during normal operation

Contents of OmniControl.ino: 

Motor Control:
go_Advance()
go_Back()
go_Right()
go_Left()
stop_Stop()
enable_Motors()
disable_Motors()

Ultrasonic Sensor Processing:
watch_FL()
watch_FR()
watch_L()
watch_R()

Modes:
obstacle_avoidance_mode()
joystick_gesture_mode()

General:
setup()
loop()

Contents of configuration.h:
constant declarations variable declarations pin numbers

Contents of OmniBLE.h
Bluetooth wrapper functionality
