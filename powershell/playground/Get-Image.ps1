Function Get-Image {Param($imagepath) 
    [void][Reflection.Assembly]::LoadWithPartialName("System.Drawing")

    $supportedtags = @{
            0x100  = "ImageWidth"
            0x101  = "ImageHeight"
            0x0    = "GPSVersionID"
            0x5    = "GPSAltitudeRef"
            0x111  = "StripOffsets"
            0x116  = "RowsPerStrip"
            0x117  = "StripByteCounts"
            0xA002 = "PixelXDimension"
            0xA003 = "PixelYDimension"
            0x102  = "BitsPerSample"
            0x103  = "Compression"
            0x106  = "PhotometricInterpretation"
            0x112  = "Orientation"
            0x115  = "SamplesPerPixel"
            0x11C  = "PlanarConfiguration"
            0x212  = "YCbCrSubSampling"
            0x213  = "YCbCrPositioning"
            0x128  = "ResolutionUnit"
            0x12D  = "TransferFunction"
            0xA001 = "ColorSpace"
            0x8822 = "ExposureProgram"
            0x8827 = "ISOSpeedRatings"
            0x9207 = "MeteringMode"
            0x9208 = "LightSource"
            0x9209 = "Flash"
            0x9214 = "SubjectArea"
            0xA210 = "FocalPlaneResolutionUnit"
            0xA214 = "SubjectLocation"
            0xA217 = "SensingMethod"
            0xA401 = "CustomRendered"
            0xA402 = "ExposureMode"
            0xA403 = "WhiteBalance"
            0xA405 = "FocalLengthIn35mmFilm"
            0xA406 = "SceneCaptureType"
            0xA408 = "Contrast"
            0xA409 = "Saturation"
            0xA40A = "Sharpness"
            0xA40C = "SubjectDistanceRange"
            0x1E   = "GPSDifferential"
            0x9201 = "ShutterSpeedValue"
            0x9203 = "BrightnessValue"
            0x9204 = "ExposureBiasValue"
            0x201  = "JPEGInterchangeFormat"
            0x202  = "JPEGInterchangeFormatLength"
            0x11A  = "XResolution"
            0x11B  = "YResolution"
            0x13E  = "WhitePoint"
            0x13F  = "PrimaryChromaticities"
            0x211  = "YCbCrCoefficients"
            0x214  = "ReferenceBlackWhite"
            0x9102 = "CompressedBitsPerPixel"
            0x829A = "ExposureTime"
            0x829D = "FNumber"
            0x9202 = "ApertureValue"
            0x9205 = "MaxApertureValue"
            0x9206 = "SubjectDistance"
            0x920A = "FocalLength"
            0xA20B = "FlashEnergy"
            0xA20E = "FocalPlaneXResolution"
            0xA20F = "FocalPlaneYResolution"
            0xA215 = "ExposureIndex"
            0xA404 = "DigitalZoomRatio"
            0xA407 = "GainControl"
            0x2 = "GPSLatitude"
            0x4 = "GPSLongitude"
            0x6 = "GPSAltitude"
            0x7 = "GPSTimeStamp"
            0xB = "GPSDOP"
            0xD = "GPSSpeed"
            0xF = "GPSTrack"
            0x11 = "GPSImgDirection"
            0x14 = "GPSDestLatitude"
            0x16 = "GPSDestLongitude"
            0x18 = "GPSDestBearing"
            0x1A = "GPSDestDistance"
            0x132 = "DateTime"
            0x10E = "ImageDescription"
            0x10F = "Make"
            0x110 = "Model"
            0x131 = "Software"
            0x13B = "Artist"
            0x8298 = "Copyright"
            0xA004 = "RelatedSoundFile"
            0x9003 = "DateTimeOriginal"
            0x9004 = "DateTimeDigitized"
            0x9290 = "SubSecTime"
            0x9291 = "SubSecTimeOriginal"
            0x9292 = "SubSecTimeDigitized"
            0xA420 = "ImageUniqueID"
            0x8824 = "SpectralSensitivity"
            0x1 = "GPSLatitudeRef"
            0x3 = "GPSLongitudeRef"
            0x8 = "GPSSatellites"
            0x9 = "GPSStatus"
            0xA = "GPSMeasureMode"
            0xC = "GPSSpeedRef"
            0xE = "GPSTrackRef"
            0x10 = "GPSImgDirectionRef"
            0x12 = "GPSMapDatum"
            0x13 = "GPSDestLatitudeRef"
            0x15 = "GPSDestLongitudeRef"
            0x17 = "GPSDestBearingRef"
            0x19 = "GPSDestDistanceRef"
            0x1D = "GPSDateStamp"
            0x8828 = "OECF"
            0xA20C = "SpatialFrequencyResponse"
            0xA300 = "FileSource"
            0xA301 = "SceneType"
            0xA302 = "CFAPattern"
            0xA40B = "DeviceSettingDescription"
            0x9000 = "ExifVersion"
            0xA000 = "FlashpixVersion"
            0x9101 = "ComponentsConfiguration"
            0x927C = "MakerNote"
            0x9286 = "UserComment"
            0x1B = "GPSProcessingMethod"
            0x1C = "GPSAreaInformation"
           }
           
    $item = Get-Item $imagepath
    $bmp = new-object System.Drawing.Bitmap $imagepath
    $ObjectImage = New-Object PSObject
    $alltags = @{}     
    $Property = New-Object PSObject
    foreach($PropItem in $bmp.PropertyItems){

        if ($supportedtags.contains($PropItem.id)){
            #write-host $supportedtags.item($PropItem.id)
            $value = ""

            switch ($PropItem.Type)
                {
                    0x1{#8-bit unsigned int
                        if ($PropItem.Value.Length -eq 4){$value = "Version " + $PropItem.Value[0].ToString() + "." + $PropItem.Value[1].ToString()}
                        elseif($PropItem.Id -eq 0x5 -and $PropItem.Value[0] -eq 0){$value = "Sea level"}
                        else{$value = $PropItem.Value[0].ToString()}
                    }
                
                    0x2{#ASCII (8 bit ASCII code)
                        $value = [System.Text.Encoding]::ASCII.GetString($PropItem.Value).Trim('\0') 
                        
                    }
                    
                    0x3{#SHORT 16-bit unsigned int
                        
                        [UInt16] $uinttmp = [System.BitConverter]::ToUInt16($PropItem.Value, 0);
                        
                        switch ($PropItem.id)
                            {
                                0x8827{
                                        $value = "ISO-" + $uinttmp.ToString()
                                }
                                
                                0xA217{#sensing method
                                        switch ($uinttmp)
                                            {
                                                1{$value = "Not defined"}
                                                2{$value = "One-chip color area sensor"}                  
                                                3{$value = "Two-chip color area sensor"}
                                                4{$value = "Three-chip color area sensor"}
                                                5{$value = "Color sequential area sensor"}
                                                7{$value = "Trilinear sensor"}
                                                8{$value = "Color sequential linear sensor"}
                                                default{$value = "reserved"}
                                            }#end switch $uinttmp
                                }

                                0x8822{# Exposure program
                                        switch ($uinttmp)
                                            {
                                                0{$value = "Not defined"}
                                                1{$value = "Manual"}
                                                2{$value = "Normal program"}                  
                                                3{$value = "Aperture priority"}
                                                4{$value = "Shutter priority"}
                                                5{$value = "Creative program (biased toward depth of field)"}
                                                6{$value = "Action program (biased toward fast shutter speed)"}
                                                7{$value = "Portrait mode (for closeup photos with the background out of focus)"}
                                                8{$value = "Landscape mode (for landscape photos with the background in focus)"}
                                                default{$value = "reserved"}
                                            }#end switch $uinttmp
                                }     
                                                   
                                0x9207{# metering mode
                                        switch ($uinttmp)
                                            {
                                                0{$value = "unknown"}
                                                1{$value = "Average"}
                                                2{$value = "Center Weighted Average"}                  
                                                3{$value = "Spot"}
                                                4{$value = "MultiSpot"}
                                                5{$value = "Pattern"}
                                                6{$value = "Partial"}
                                                255{$value = "Other"}
                                                default{$value = "reserved"}
                                            }#end switch $uinttmp
                                }      
                                                      
                                0x9208{# Light source
                                        switch ($uinttmp)
                                            {
                                                0{$value = "unknown"}
                                                1{$value = "Daylight"}
                                                2{$value = "Fluorescent"}                  
                                                3{$value = "Tungsten (incandescent light)"}
                                                4{$value = "Flash"}
                                                9{$value = "Fine weather"}
                                                10{$value = "Cloudy weather"}
                                                11{$value = "Shade"}
                                                12{$value = "Daylight fluorescent (D 5700 – 7100K)"}
                                                13{$value = "Day white fluorescent (N 4600 – 5400K)"}
                                                14{$value = "Cool white fluorescent (W 3900 – 4500K)"}
                                                15{$value = "White fluorescent (WW 3200 – 3700K)"}
                                                17{$value = "Standard light A"}
                                                18{$value = "Standard light B"}
                                                19{$value = "Standard light C"}
                                                20{$value = "D55"}
                                                21{$value = "D65"}
                                                22{$value = "D75"}
                                                23{$value = "D50"}
                                                24{$value = "ISO studio tungsten"}
                                                255{$value = "ISO studio tungsten"}
                                                default{$value = "other light source"}
                                            }#end switch $uinttmp
                                }                          

                                0x9209{# Flash
                                        switch ($uinttmp)
                                            {
                                                0x0{$value = "Flash did not fire"}
                                                0x1{$value = "Flash fired"}
                                                0x5{$value = "Strobe return light not detected"}
                                                0x7{$value = "Strobe return light detected"}
                                                0x9{$value = "Flash fired, compulsory flash mode"}
                                                0xD{$value = "Flash fired, compulsory flash mode, return light not detected"}
                                                0xF{$value = "Flash fired, compulsory flash mode, return light detected"}
                                                0x10{$value = "Flash did not fire, compulsory flash mode"}
                                                0x18{$value = "Flash did not fire, auto mode"}
                                                0x19{$value = "Flash fired, auto mode"}
                                                0x1D{$value = "Flash fired, auto mode, return light not detected"}
                                                0x1F{$value = "Flash fired, auto mode, return light detected"}
                                                0x20{$value = "No flash function"}
                                                0x41{$value = "Flash fired, red-eye reduction mode"}
                                                0x45{$value = "Flash fired, red-eye reduction mode, return light not detected"}
                                                0x47{$value = "Flash fired, red-eye reduction mode, return light detected"}
                                                0x49{$value = "Flash fired, compulsory flash mode, red-eye reduction mode"}
                                                0x4D{$value = "Flash fired, compulsory flash mode, red-eye reduction mode, return light not detected"}
                                                0x4F{$value = "Flash fired, compulsory flash mode, red-eye reduction mode, return light detected"}
                                                0x59{$value = "Flash fired, auto mode, red-eye reduction mode"}
                                                0x5D{$value = "Flash fired, auto mode, return light not detected, red-eye reduction mode"}
                                                0x5F{$value = "Flash fired, auto mode, return light detected, red-eye reduction mode"}
                                                default{$value = "reserved"}
                                            }#end switch $uinttmp
                                }                           

                                0x0128{# ResolutionUnit
                                        switch ($uinttmp)
                                            {
                                                2{$value = "Inch"}
                                                3{$value = "Centimeter"}
                                                default{$value = "No Unit"}
                                            }#end switch $uinttmp
                                }
                                                              
                                0xA409{# Saturation
                                        switch ($uinttmp)
                                            {
                                                0{$value = "Normal"}
                                                1{$value = "Low saturation"}
                                                2{$value = "High saturation"}
                                                default{$value = "Reserved"}
                                            }#end switch $uinttmp
                                }   
                                                        
                                0xA40A{# Sharpness
                                        switch ($uinttmp)
                                            {
                                                0{$value = "Normal"}
                                                1{$value = "Soft"}
                                                2{$value = "Hard"}
                                                default{$value = "Reserved"}
                                            }#end switch $uinttmp
                                }       
                                                        
                                0xA408{# Contrast
                                        switch ($uinttmp)
                                            {
                                                0{$value = "Normal"}
                                                1{$value = "Soft"}
                                                2{$value = "Hard"}
                                                default{$value = "Reserved"}
                                            }#end switch $uinttmp
                                }                               

                                0x103{# Compression
                                        switch ($uinttmp)
                                            {
                                                1{$value = "Uncompressed"}
                                                6{$value = "JPEG compression (thumbnails only)"}
                                                default{$value = "Reserved"}
                                            }#end switch $uinttmp
                                }                              

                                0x106{# PhotometricInterpretation
                                        switch ($uinttmp)
                                            {
                                                2{$value = "RGB"}
                                                6{$value = "YCbCr"}
                                                default{$value = "Reserved"}
                                            }#end switch $uinttmp
                                }                              

                                0x112{# Orientation
                                        switch ($uinttmp)
                                            {
                                                1{$value = "The 0th row is at the visual top of the image, and the 0th column is the visual left-hand side."}
                                                2{$value = "The 0th row is at the visual top of the image, and the 0th column is the visual right-hand side."}
                                                3{$value = "The 0th row is at the visual bottom of the image, and the 0th column is the visual right-hand side."}
                                                4{$value = "The 0th row is at the visual bottom of the image, and the 0th column is the visual left-hand side."}
                                                5{$value = "The 0th row is the visual left-hand side of the image, and the 0th column is the visual top."}
                                                6{$value = "The 0th row is the visual right-hand side of the image, and the 0th column is the visual top."}
                                                7{$value = "The 0th row is the visual right-hand side of the image, and the 0th column is the visual bottom."}
                                                8{$value = "The 0th row is the visual left-hand side of the image, and the 0th column is the visual bottom."}
                                                default{$value = "Reserved"}
                                            }#end switch $uinttmp
                                }
                                
                                0x213{# YCbCrPositioning
                                        switch ($uinttmp)
                                            {
                                                1{$value = "centered"}
                                                6{$value = "co-sited"}
                                                default{$value = "Reserved"}
                                            }#end switch $uinttmp
                                }                                                              
                                 
                                0xA001{# ColorSpace
                                        switch ($uinttmp)
                                            {
                                                1{$value = "sRGB"}
                                                0xFFFF{$value = "Uncalibrated"}
                                                default{$value = "Reserved"}
                                            }#end switch $uinttmp
                                }    
                                                          
                                0xA401{# CustomRendered
                                        switch ($uinttmp)
                                            {
                                                0{$value = "Normal process"}
                                                1{$value = "Custom process"}
                                                default{$value = "Reserved"}
                                            }#end switch $uinttmp
                                }
                                                                
                                0xA402{# ExposureMode
                                        switch ($uinttmp)
                                            {
                                                0{$value = "Auto exposure"}
                                                1{$value = "Manual exposure"}
                                                2{$value = "Auto bracket"}
                                                default{$value = "Reserved"}
                                            }#end switch $uinttmp
                                }  
                                                           
                                0xA403{# WhiteBalance
                                        switch ($uinttmp)
                                            {
                                                0{$value = "Auto white balance"}
                                                1{$value = "Manual white balance"}
                                                default{$value = "Reserved"}
                                            }#end switch $uinttmp
                                }   
                                                          
                                0xA406{# SceneCaptureType
                                        switch ($uinttmp)
                                            {
                                                0{$value = "Standard"}
                                                1{$value = "Landscape"}
                                                2{$value = "Portrait"}
                                                3{$value = "Night scene"}
                                                default{$value = "Reserved"}
                                            }#end switch $uinttmp
                                }  
                                
                                0xA40C{# SubjectDistanceRange
                                        switch ($uinttmp)
                                            {
                                                0{$value = "unknown"}
                                                1{$value = "Macro"}
                                                2{$value = "Close view"}
                                                3{$value = "Distant view"}
                                                default{$value = "Reserved"}
                                            }#end switch $uinttmp
                                }     
                                                         
                                0x1E{# GPSDifferential
                                        switch ($uinttmp)
                                            {
                                                0{$value = "Measurement without differential correction"}
                                                1{$value = "Differential correction applied"}
                                                default{$value = "Reserved"}
                                            }#end switch $uinttmp
                                }
                                
                                0xA405{$value = $uinttmp.ToString() + " mm"}
                                default{$value = $uinttmp.ToString()}                            
                                                                                   
                            }#end switch propitem.id
                        
                        
                        
                        
                        
                    }
                     
                    0x4{#LONG 32-bit unsigned int
                        #write-host TYPE4
                        $value = [System.BitConverter]::ToUInt32($PropItem.Value, 0).ToString()
                    }           
                    
                    0x5{
                        #write-host TYPE5
                        $n = New-Object byte[] 4
                        $d = New-Object byte[] 4
                        $h = New-Object byte[] 8
                        $m = New-Object byte[] 8
                        $s = New-Object byte[] 8
                        [System.Array]::Copy($PropItem.value, 0, $n, 0, 4)
                        [System.Array]::Copy($PropItem.value, 4, $d, 0, 4)
                        
                        
                        [UInt32]$num = [System.BitConverter]::ToUInt32($n, 0)
                        [UInt32]$denom = [System.BitConverter]::ToUInt32($d, 0)
                        [double]$doubleresult = [System.Math]::Round([System.Convert]::ToDouble($num) / [System.Convert]::ToDouble($denom), 2)
                        [string]$normstrdefault = $num.ToString() + "/" + $denom.ToString()
                        #write-host -fore green $normstrdefault $doubleresult
                        switch ($PropItem.id)
                            {
                                0x9202{#ApertureValue
                                        $value = "F/" + [System.Math]::Round([System.Math]::Pow([System.Math]::Sqrt(2), $doubleresult), 2).ToString()
                                }                            
                                0x9205{#MaxApertureValue
                                        $value = "F/" + [System.Math]::Round([System.Math]::Pow([System.Math]::Sqrt(2), $doubleresult), 2).ToString()
                                }                          
                            
                                0x920A{#FocalLength
                                        $value = $doubleresult.ToString() + " mm"
                                }                          
                            
                                0x829D{#f-number
                                        $value = "F/"+ $doubleresult.ToString()
                                } 
                                 
                                0x11A{#Xresolution
                                        $value = $doubleresult.ToString()
                                }
                                  
                                0x11B{#Yresolution
                                        $value = $doubleresult.ToString()
                                }       
                                
                                0x829A{#ExposureTime
                                        $value = $normstrdefault.ToString() + " sec"
                                }   
                                
                                0x2{#GPSLatitude
                                        $value = "tobeimplemented"
                                } 
                                
                                0x4{#GPSLongitude
                                        $value = "tobeimplemented"
                                }   
                                
                                0x6{#GPSAltitude
                                        $value = $normstrdefault.ToString() + " meters"
                                }      
                                
                                0xA404{#Digital Zoom Ratio
                                        $value = $doubleresult.ToString()
                                        if ($value -eq 0){ $value = "none"}
                                } 
                                
                                0xB{#GPSDOP
                                        $value = $doubleresult.ToString()
                                } 
                                
                                0xD{#GPSSpeed
                                        $value = $doubleresult.ToString()
                                } 
                                
                                0xF{#GPSTrack
                                        $value = $doubleresult.ToString()
                                } 
                                
                                0x11{#GPSImgDir 
                                $value = $doubleresult.ToString()} 
                                
                                0x14{#GPSDestLatitude 
                                $value = "tobeimplemented"} 
                                
                                0x16{#GPSDestLongitude 
                                $value = "tobeimplemented"} 
                                
                                0x18{#GPSDestBearing 
                                $value = $doubleresult.ToString()} 
                                
                                0x1A{#GPSDestDistance 
                                $value = $doubleresult.ToString()}  
                                
                                0x7{#GPSTimeStamp 
                                $value = "tobeimplemented"}    
                                
                                default{$value = $normstrdefault}
                                                                                                   
                            }#end switch Proptitem.id
                        
                        
                        
                    }            
                    
                    0x7{#UNDEFINED (8-bit)
                        #
                        switch ($PropItem.id)
                            {
                                0xA300{#FileSource
                                        if ($PropItem.Value[0] -eq 3){
                                            $value = "DSC"
                                        }else{    
                                            $value = "reserved"
                                        }    
                                }
                                0xA301{#SceneType
                                        if ($PropItem.Value[0] -eq 1){
                                            $value = "A directly photographed image"
                                        }else{    
                                            $value = "reserved"
                                        }    
                                }
                                0x9000{#Exif Version
                                        $value = [System.Text.Encoding]::ASCII.GetString($PropItem.Value).Trim('\0')
                                }
                                
                                0xA000{#Flashpix Version
                                        $value = [System.Text.Encoding]::ASCII.GetString($PropItem.Value).Trim('\0')
                                        if ($value -eq "0100"){
                                            $value = "Flashpix Format Version 1.0"
                                        }else{    
                                            $value = "reserved"
                                        }    
                                }                                                            
                                   
                                0x927C{#MakerNote
                                        $value = [System.Text.Encoding]::ASCII.GetString($PropItem.Value).Trim('\0')
                                }
                                                                
                                0x9286{#UserComment
                                        $value = [System.Text.Encoding]::ASCII.GetString($PropItem.Value).Trim('\0')
                                }
                                
                                0x1B{#GPS Processing Method
                                        $value = [System.Text.Encoding]::ASCII.GetString($PropItem.Value).Trim('\0')
                                }
                                                                
                                0x1C{#GPS Area Info
                                        $value = [System.Text.Encoding]::ASCII.GetString($PropItem.Value).Trim('\0')
                                }
                                
                                0x9101{#Componentsconfig
                                        [string]$s = ""
                                        $vals = @("", "Y", "Cb", "Cr", "R", "G", "B" )
                                        [Byte[]]$bytes = $PropItem.Value 
                                        foreach ($b in $bytes){
                                            $s += $vals[$b]
                                        }
                                        $value = $s                                      
                                }                                
                                default{$value = "--"}                                                                
                            } #end switch 0x7                            
                        
                    }   
                    
                    0x9{#SLONG 32-bit int
                        #write-host TYPE9
                        $value = [System.BitConverter]::ToInt32($PropItem.Value, 0).ToString()
                    }  
                    
                    0xA{#SRATIONAL Two SLONGs signed
                        #write-host TYPEA
                        $n = New-Object byte[] 4
                        $d = New-Object byte[] 4
                        [System.Array]::Copy($PropItem.value, 0, $n, 0, 4)
                        [System.Array]::Copy($PropItem.value, 4, $d, 0, 4)
                        
                        [Int32]$num = [System.BitConverter]::ToInt32($n, 0)
                        [Int32]$denom = [System.BitConverter]::ToInt32($d, 0)
                        [double]$doubleresult = [System.Math]::Round([System.Convert]::ToDouble($num) / [System.Convert]::ToDouble($denom), 2)
                        [string]$normstrdefault = $num.ToString() + "/" + $denom.ToString()

                        switch ($PropItem.id)
                            {
                                0x9201{#ShutterSpeedValue
                                        $value = "1/" + [System.Math]::Round([System.Math]::Pow(2, $doubleresult), 2).ToString()
                                }  
                                                          
                                0x9203{#BrightnessValue
                                        $value = [System.Math]::Round($doubleresult, 4).ToString()
                                } 
                                                             
                                0x9204{#ExposureBiasValue
                                        $value = [System.Math]::Round($doubleresult, 2).ToString() + " eV"
                                } 
                                                             
                                default{$value = $normstrdefault}
                                                            
                            }#End Switch                         
                        
                                                
                        
                    }                            
                }#end switch
                
            Add-Member -input $Property NoteProperty ([string]$supportedtags.item($PropItem.id)) $Value
            $alltags.add($PropItem.id,$Property)   
        }#end if supportedtag


    }#end Foreach PropItem   
    add-Member -input $ObjectImage NoteProperty  Fullname $item.fullname
    add-Member -input $ObjectImage NoteProperty  Exif (($Property |gm).count -gt 4)
    add-Member -input $ObjectImage NoteProperty  Name $item.name
    add-Member -input $ObjectImage NoteProperty  LastWriteTime $item.LastWriteTime
    add-Member -input $ObjectImage NoteProperty  AllProperties $Property
    $bmp.Dispose()
    Remove-Variable item
    return $ObjectImage
}#endfunction get-Images