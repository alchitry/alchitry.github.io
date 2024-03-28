+++
title = "AVR Interface"
weight = 13
+++

The Mojo doesn't just have an FPGA, but it also has a microcontroller (AVR). While you normally won't program the microcontroller yourself, it offers some functionality to the FPGA. The two main functions the microcontroller performs are USB->serial conversion and an analog to digital conversion (ADC). This allows your design to send and receive data over the USB port and read the voltages on the analog input pins once the FPGA has been configured.

### CCLK

When the FPGA is first configured, the AVR may not be ready for the FPGA to set some of it's pins as outputs. This is because the pins that are used to talk to the AVR are also used to configure the FPGA! It is important for the FPGA to wait until the **CCLK** signal is high for at least 512 cycles before taking control of it's outputs. The modules **avr_interface.v** and **cclk_detector.v** included in the [base project](https://github.com/embmicro/mojo-base-project/archive/master.zip) do just that.

### USB->Serial

There are three pins that are used to communicate over the USB port.

|Signal Name|Direction|Description|
|---|---|---|
|avr_tx|input|This is the tx signal of the AVR. and the rx signal for the FPGA.|
|avr_rx|output|This is the rx signal of the AVR and the tx signal for the FPGA.|
|avr_rx_busy|input|The AVR can't always send data over the serial port. When it is unable to accept any more data this signal will go high. This could be because the USB port is not connected to a computer, there is no application on the computer reading data from the serial port, or the buffer in the AVR is full.<br><br>You must monitor this signal if you do not want to lose data.|

The serial port operates at 500K baud. Due to the fact that the AVR needs to perform other tasks, you will not get the full throughput of 500K baud.

### ADC

These are the signals used to read the analog pins.

|Signal Name|Direction|Description|
|---|---|---|
|spi_miso|output|Data pin from the FPGA (slave) to the AVR (master)|
|spi_mosi|input|Data pin from the AVR (master) to the FPGA (slave)|
|spi_ss|input|Slave select, active low|
|spi_sck|input|SPI data clock. Data clocked in on rising edges and setup on falling.|
|spi_channel[3:0]|output|ADC channel select pins. These are used to determine which analog pin should be sampled.|

The AVR is the master of the SPI bus and only sends data to the FPGA when there are new samples.

The **spi_channel** lines specify which channel should be sampled. Valid channels are 0, 1, 4, 5, 6, 7, 8, 9. Those correspond to A0, A1, A4-A9 on the Mojo board respectively. Selecting an invalid channel will disable the ADC.

Once the ADC is enabled by selecting a valid channel, it runs in free-running mode which means it will automatically sample that channel as fast as it can. The samples from the ADC are buffered and sent over the SPI bus when the AVR has time to do so. This means that the rate samples are sent over the SPI bus does not necessarily equal the rate or time they were sampled. However, it is safe to assume that the samples are evenly spaced in time.

Another side effect of the samples being buffered is that changing channels does not guarantee that the next sample sent over the SPI port will be from the new channel. To compensate for this each sample also includes the channel it was sampled from.

Each sample is 10 bits wide. The 4 upper bits of the two bytes correspond to the channel the sample was taken from.

Each SPI transfer sends over two bytes. The first byte is the 8 LSBs of the sample. The second byte contains the channel and the 2 MSBs of the sample.

#### Configure the ADC

It is possible to configure the ADC with your own settings.

The settings for the pre-scaler (sample rate), high-power mode, and AREF select are configurable. To access these settings you first need to enable the ADC by selecting a valid channel.

Once a valid channel is selected and samples are being sent of the SPI port, you can enter configuration mode by sending 0xAA as the reply for the first byte. The reply for the second byte of the transfer contains the configuration data.

|   |   |   |   |
|---|---|---|---|
|XX|AREF Select [1:0]|High Power Mode|Pre-Scaler [2:0]|

Information on what these mean can be found in the [datasheet for the ATmega32U4](https://www.microchip.com/en-us/product/atmega16u4?tab=documents) on pages 307-312.

The default values are, pre-scaler = 5 (divide by 32), high-power mode is enabled, AREF = AVcc.

You should not set the pre-scaler lower than 5. If you need higher accuracy you can set it higher.

### Included FPGA Modules

The [Mojo base project](https://github.com/embmicro/mojo-base-project/archive/master.zip) includes the **avr_interface.v** module and all the supporting modules to interface with the AVR. It handles all the low level SPI and serial buses. It breaks out an interface which is much easier to use.

For the ADC, you can simply supply which channel you want to read in the **channel** input and when a new sample comes in **new_sample** goes high for one clock cycle. The sample is available on the signals **sample** and **sample_channel** for the corresponding channel.

For the serial port, you supply data to **tx_data** and pulse **new_tx_data** high for one clock cycle when you have data to send. You must first check that **tx_busy** is low. Data from the AVR is supplied through the **rx_data** signal and **new_rx_data** signals when the data is valid.