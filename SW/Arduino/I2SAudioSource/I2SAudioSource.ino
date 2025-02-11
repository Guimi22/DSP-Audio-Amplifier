// Codi ESP32 -- Font audio I2S
// Includes

    #include "SD.h"                         
    #include "driver/i2s.h"          
  
//----------------------
//----------------------
// Defines
 
//    SD Card
    #define SD_CS          5    
   
//    I2S

    #define I2S_DOUT      25    
    #define I2S_BCLK      27   
    #define I2S_LRC       26    
    #define I2S_NUM       0    

// Wav Fitxer
    #define NUM_BYTES_TO_READ_FROM_FILE 1024   

//----------------------

//----------------------
// structures and also variables
//  I2S configuration

      static const i2s_config_t i2s_config = 
      {
          .mode = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_TX), 
          .sample_rate = 44100,                                
          .bits_per_sample = I2S_BITS_PER_SAMPLE_16BIT,
          .channel_format = I2S_CHANNEL_FMT_RIGHT_LEFT,
          .communication_format = (i2s_comm_format_t)(I2S_COMM_FORMAT_I2S | I2S_COMM_FORMAT_I2S_MSB),
          .intr_alloc_flags = ESP_INTR_FLAG_LEVEL1,             
          .dma_buf_count = 8,                           
          .dma_buf_len = 64,                                    
          .use_apll=0,
          .tx_desc_auto_clear= true, 
          .fixed_mclk=-1    
      };
    
//----------------------
// Pin configuració      
      static const i2s_pin_config_t pin_config = 
      {
          .bck_io_num = I2S_BCLK,              
          .ws_io_num = I2S_LRC,                           
          .data_out_num = I2S_DOUT,                       
          .data_in_num = I2S_PIN_NO_CHANGE                  
      };
      
      struct WavHeader_Struct
      {
          //   RIFF Section    
          char RIFFSectionID[4];    
          uint32_t Size;             
          char RiffFormat[4];         
          
          //   Format Section    
          char FormatSectionID[4];   
          uint32_t FormatSize;       
          uint16_t FormatID;         
          uint16_t NumChannels;       
          uint32_t SampleRate;        
          uint32_t ByteRate;          
          uint16_t BlockAlign;       
          uint16_t BitsPerSample;  
        
          // Data Section
          char DataSectionID[4];      
          uint32_t DataSize;       
      }WavHeader;
//------------------

//  Global Variables/objects    
    
    File WavFile;                                
    static const i2s_port_t i2s_num = I2S_NUM_0;      

//-----------------


void setup() {    
    Serial.begin(115200);                               
    SDCardInit();
    i2s_driver_install(i2s_num, &i2s_config, 0, NULL);
    i2s_set_pin(i2s_num, &pin_config);
    WavFile = SD.open("/audioprova.wav");                   
    if(WavFile==false)
      Serial.println("Could not open 'wavfile.wav'");
    else
    {
      WavFile.read((byte *) &WavHeader,44); 
      DumpWAVHeader(&WavHeader);           
      if(ValidWavData(&WavHeader))    
        i2s_set_sample_rates(i2s_num, 44100);     
    }
}


void loop()
{    
    PlayWav();                                          
}

void PlayWav()
{
  static bool ReadingFile=true;                    
  static byte Samples[NUM_BYTES_TO_READ_FROM_FILE];   
  static uint16_t BytesRead;                          

  if(ReadingFile)                                    
  {
    BytesRead=ReadFile(Samples);                   
    ReadingFile=false;             
  }
  else
    ReadingFile=FillI2SBuffer(Samples,BytesRead);    
}

uint16_t ReadFile(byte* Samples)
{
    static uint32_t BytesReadSoFar=0;                   
    uint16_t BytesToRead;                           
    
    if(BytesReadSoFar+NUM_BYTES_TO_READ_FROM_FILE>WavHeader.DataSize)  
      BytesToRead=WavHeader.DataSize-BytesReadSoFar;          
    else
      BytesToRead=NUM_BYTES_TO_READ_FROM_FILE;             
      
    WavFile.read(Samples,BytesToRead);              
    BytesReadSoFar+=BytesToRead;         
    
    if(BytesReadSoFar>=WavHeader.DataSize)   
    {
      WavFile.seek(44);                    
      BytesReadSoFar=0;                                    
    }
    return BytesToRead;             
}

bool FillI2SBuffer(byte* Samples,uint16_t BytesInBuffer)
{
    
    size_t BytesWritten;                        
    static uint16_t BufferIdx=0;      
    uint8_t* DataPtr;              
    uint16_t BytesToSend;      
    
    DataPtr=Samples+BufferIdx;                               
    BytesToSend=BytesInBuffer-BufferIdx;                     
    i2s_write(i2s_num,DataPtr,BytesToSend,&BytesWritten,1);  
    BufferIdx+=BytesWritten;                          
    
    if(BufferIdx>=BytesInBuffer)                 
    {
      BufferIdx=0; 
      return true;                             
    }
    else
      return false;     
}

void SDCardInit()
{        
    pinMode(SD_CS, OUTPUT); 
    digitalWrite(SD_CS, LOW);
    if(!SD.begin(SD_CS))
    {
        Serial.println("Error talking to SD card!");
        while(true);                  
    }
}

bool ValidWavData(WavHeader_Struct* Wav)
{
  
  if(memcmp(Wav->RIFFSectionID,"RIFF",4)!=0) 
  {    
    Serial.print("Invalid data - Not RIFF format");
    return false;        
  }
  if(memcmp(Wav->RiffFormat,"WAVE",4)!=0)
  {
    Serial.print("Invalid data - Not Wave file");
    return false;           
  }
  if(memcmp(Wav->FormatSectionID,"fmt",3)!=0) 
  {
    Serial.print("Invalid data - No format section found");
    return false;       
  }
  if(memcmp(Wav->DataSectionID,"data",4)!=0) 
  {
    Serial.print("Invalid data - data section not found");
    return false;      
  }
  if(Wav->FormatID!=1) 
  {
    Serial.print("Invalid data - format Id must be 1");
    return false;                          
  }
  if(Wav->FormatSize!=16) 
  {
    Serial.print("Invalid data - format section size must be 16.");
    return false;                          
  }
  if((Wav->NumChannels!=1)&(Wav->NumChannels!=2))
  {
    Serial.print("Invalid data - only mono or stereo permitted.");
    return false;   
  }
  if(Wav->SampleRate>48000) 
  {
    Serial.print("Invalid data - Sample rate cannot be greater than 48000");
    return false;                       
  }
  if((Wav->BitsPerSample!=8)& (Wav->BitsPerSample!=16)) 
  {
    Serial.print("Invalid data - Only 8 or 16 bits per sample permitted.");
    return false;                        
  }
  return true;
}


void DumpWAVHeader(WavHeader_Struct* Wav)
{
  if(memcmp(Wav->RIFFSectionID,"RIFF",4)!=0)
  {
    Serial.print("Not a RIFF format file - ");    
    PrintData(Wav->RIFFSectionID,4);
    return;
  } 
  if(memcmp(Wav->RiffFormat,"WAVE",4)!=0)
  {
    Serial.print("Not a WAVE file - ");  
    PrintData(Wav->RiffFormat,4);  
    return;
  }  
  if(memcmp(Wav->FormatSectionID,"fmt",3)!=0)
  {
    Serial.print("fmt ID not present - ");
    PrintData(Wav->FormatSectionID,3);      
    return;
  } 
  if(memcmp(Wav->DataSectionID,"data",4)!=0)
  {
    Serial.print("data ID not present - "); 
    PrintData(Wav->DataSectionID,4);
    return;
  }  
  Serial.print("Total size :");Serial.println(Wav->Size);
  Serial.print("Format section size :");Serial.println(Wav->FormatSize);
  Serial.print("Wave format :");Serial.println(Wav->FormatID);
  Serial.print("Channels :");Serial.println(Wav->NumChannels);
  Serial.print("Sample Rate :");Serial.println(Wav->SampleRate);
  Serial.print("Byte Rate :");Serial.println(Wav->ByteRate);
  Serial.print("Block Align :");Serial.println(Wav->BlockAlign);
  Serial.print("Bits Per Sample :");Serial.println(Wav->BitsPerSample);
  Serial.print("Data Size :");Serial.println(Wav->DataSize);
}

void PrintData(const char* Data,uint8_t NumBytes)
{
    for(uint8_t i=0;i<NumBytes;i++)
      Serial.print(Data[i]); 
      Serial.println();  
}
