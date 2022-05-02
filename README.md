# An IR-UWB Link Level Simulator

  **ELENE6904 Course Project**

  ## Description

  ## Usage

  The core simulation instance is "system_top.m". This function takes a setup structure that contains all the simulation parameters, run the simulation on the image "Lenna.bmp", and return the **Symbol Error Rate - SER**, each symbol contains 5-bits (range 0~31)

  The setup structure contains the following elements:

  ```
  ELEMENT           DESCRIPTION                                      TYPICAL VALUE
  setup.BW          BW of the transmitted signal (Hz)                2   GHz
  setup.fs          Simulation Sampling Frequency (Hz)               100 GHz
  setup.fc          Center Frequency of the Gaussian Pulse (Hz)      5   GHz
  setup.tframe      Duration of Each TX Frame (s)                    10  ns
  setup.tguard      Anti-Multipath Blanking Period (s)               3.5 ns
  setup.tstep       Data Step (s)                                    100 ps
  setup.tpulse      Gaussian Pulse Duration (s)                      1.5 ns
  setup.pulse_order Gaussian Pulse Derivative Order                  10
  setup.pulse_an    Gaussian Pulse Amplitude Scaling Factor          2e-4
  setup.sigma_data  Data Pulse Clock Uncertainty (x 1/fs)   
  setup.sigma_sync  Sync Pulse Clock Uncertainty (x 1/fs)
  setup.sigma_power Gaussian Pulse Amplitude Uncertainty             
  setup.SNR         SNR at RX (dB)                                   10  dB
  setup.fadeType    Unused, set to 'flat'                            'flat'
  setup.rayleighVelocity Unused                                       
  setup.flatAttenuation  Unused, Use FSPL instead
  setup.multiPathSetup   Unused
  setup.mode_bw     Transmit the Image as B&W?                       1
  setup.fspl_distance_m  FSPL Distance (m)                           1    m
  ```

  To get quick BER plots, run "system_tb.m"




