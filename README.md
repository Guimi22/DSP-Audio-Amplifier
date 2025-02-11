# DSP Audio System
This repository contains the relevant material from my Electronics Engineering Bachelor thesis, submitted on January of 2025. The DSP unit implemented on an Artix-7 (XC7A100T-1CSG324C) FPGA includes an I2S receiver block, a filtering and oversampling stage with OSR = 32, and a second-order $\Sigma \Delta$ modulator with PDM output. The present work explores the possibilities of highly customizable and low-power digital processing. The research includes the design of the filtering and noise-shaping stages, the programming of the FPGA, and the validation of the complete system, demonstrating the technical and practical feasibility of the proposal. This work highlights the potential of FPGAs as versatile platforms for the development of modern audio systems.

## Repository Contents
- [Vivado Project](https://github.com/Guimi22/DSP-Audio-Amplifier/tree/main/Projecte_Vivado): This directory contains the .tcl files required to generate the Vivado project, the IP fileset, and the .xdc constraints file for the Nexys 4 Legacy development board.
- [src](https://github.com/Guimi22/DSP-Audio-Amplifier/tree/main/SW): This directory includes the source VHDL code, the Matlab files used to simulate the behaviour of the filtering stage and the noise-shaper ($\Sigma \Delta$ modulator), and the arduino source code to programme an ESP32 in order to work as an I2S audio source.
- [Defensa](https://github.com/Guimi22/DSP-Audio-Amplifier/tree/main/Defensa): This directory stores the PowerPoint presentation used for the thesis defense. The defense was carried out in catalan.
- [Documentacio](https://github.com/Guimi22/DSP-Audio-Amplifier/tree/main/Memoria): This directory contains the memory for the Bachelor Thesis in pdf, and also can be found .tex files used to generate the document. The documentation is written down in catalan.

## Software Tools
- [Arduino IDE](https://www.arduino.cc/en/software): IDE to programme the ESP32-WROOM DEVKIT V1.
- [Matlab](https://es.mathworks.com/products/matlab.html): Design and validation of Filtering and Noise-shaping stages.
- [ModelSim](https://www.intel.com/content/www/us/en/software-kit/750666/modelsim-intel-fpgas-standard-edition-software-version-20-1-1.html): Design and validation of vhdl code.
- [Vivado](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2023-2.html): Final building of the DSP System for latter building on FPGA.

## Author
[Guillem Ropero Serrano](https://www.linkedin.com/in/guillemropero/) - Github profile: [Guimi22](https://github.com/Guimi22)

## License
This project is licensed under [MIT License](https://mit-license.org/) is a permissive open-source license that allows users to use, modify, distribute, and sublicense software with minimal restrictions. 
- **Permission to Use**: The software can be used for any purpose, including commercial use.
- **Modification and Distribution**: Users can modify, distribute, and sublicense the software.
- **Attribution Requirement**: The original license and copyright notice must be included in all copies or substantial portions of the software.
- **No Warranty**: The software is provided "as is," without any warranty of any kind.
- **Liability Disclaimer**: The authors are not liable for any damages arising from the use of the software.
