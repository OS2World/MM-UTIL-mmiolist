{This program is in the God-Damned Public Domain
Darwin O'Connor
doconnor@reamined.on.ca}

program mmiolist;

uses strings, os2def, os2mm;

type
   TFourCC = record
      case integer of
      1: (i : fourcc);
      2: (c : array[0..3] of char);
      end;

var
   FormatInfo : MMFormatInfo;
   FormatList : array[1..101] of MMFormatInfo;
   loop : integer;
   Count : LONG;
   FourCC,
   Compress : TFourCC;
   Name,
   ProcType,
   MediaType : string;
   StrLen : LONG;
   CODECInfo : CODECINIFILEINFO;
   rc : ULONG;
   SyncMethod,
   CODECName : string;

begin
   FillChar(FormatInfo,SizeOf(FormatInfo),0);
   mmioGetFormats(@FormatInfo,100,@FormatList,@Count,0,0);
   Writeln('Formats:');
   for loop:=1 to Count do
      with FormatList[loop] do begin
         FourCC.i:=fccIOProc;
         SetLength(Name,lNameLength);
         mmioGetFormatName(@(FormatList[loop]),@(Name[1]),@StrLen,0,0);
         case ulIOProcType of
            MMIO_IOPROC_STORAGESYSTEM : ProcType:='Storage System';
            MMIO_IOPROC_FILEFORMAT : ProcType:='File Format';
            MMIO_IOPROC_DATAFORMAT : ProcType:='Data Format';
         else ProcType:='';
         end;
         case ulMediaType of
            MMIO_MEDIATYPE_AUDIO : MediaType:='Audio';
            MMIO_MEDIATYPE_IMAGE : MediaType:='Image';
            MMIO_MEDIATYPE_DIGITALVIDEO : MediaType:='DigialVideo';
            MMIO_MEDIATYPE_MIDI : MediaType:='MIDI';
            MMIO_MEDIATYPE_MOVIE : MediaType:='Movie';
            MMIO_MEDIATYPE_ANIMATION : MediaType:='Animatin';
            MMIO_MEDIATYPE_COMPOUND : MediaType:='Compound';
            MMIO_MEDIATYPE_OTHER : MediaType:='Other';
            MMIO_MEDIATYPE_UNKNOWN : MediaType:='Unknown';
         else ProcType:='';
         end;
         writeln(FourCC.c[0],FourCC.c[1],FourCC.c[2],FourCC.c[3],': (',ProcType,') Type: ',MediaType,' ',Name);
         write('Capability: ');
         if (ulFlags and MMIO_CANREADTRANSLATED)<>0 then write('Can Read Translated; ');
         if (ulFlags and MMIO_CANREADUNTRANSLATED)<>0 then write('Can Read Untranslated; ');
         if (ulFlags and MMIO_CANREADWRITETRANSLATED)<>0 then write('Can Read/Write Translated; ');
         if (ulFlags and MMIO_CANREADWRITEUNTRANSLATED)<>0 then write('Can Read/Write Untranslated; ');
         if (ulFlags and MMIO_CANWRITETRANSLATED)<>0 then write('Can Write Translated; ');
         if (ulFlags and MMIO_CANWRITEUNTRANSLATED)<>0 then write('Can Write Untranslated; ');
         if (ulFlags and MMIO_CANSEEKTRANSLATED)<>0 then write('Can Seek Translated; ');
         if (ulFlags and MMIO_CANSEEKUNTRANSLATED)<>0 then write('Can Seek Untranslated; ');
         if (ulFlags and MMIO_CANINSERTTRANSLATED)<>0 then write('Can Insert Translated; ');
         if (ulFlags and MMIO_CANINSERTUNTRANSLATED)<>0 then write('Can Insert Untranslated; ');
         if (ulFlags and MMIO_CANSAVETRANSLATED)<>0 then write('Can Save Translated; ');
         if (ulFlags and MMIO_CANSAVEUNTRANSLATED)<>0 then write('Can Save Untranslated; ');
         if (ulFlags and MMIO_CANMULTITRACKREADTRANSLATED)<>0 then write('Can Multitrack Read Translated; ');
         if (ulFlags and MMIO_CANMULTITRACKREADUNTRANSLATED)<>0 then write('Can Multitrack Read Untranslated; ');
         if (ulFlags and MMIO_CANMULTITRACKWRITETRANSLATED)<>0 then write('Can Multitrack Write Translated; ');
         if (ulFlags and MMIO_CANMULTITRACKWRITEUNTRANSLATED)<>0 then write('Can Multitrack Write Untranslated; ');
         if (ulFlags and MMIO_CANTRACKSEEKTRANSLATED)<>0 then write('Can Track Seek Translated; ');
         if (ulFlags and MMIO_CANTRACKSEEKUNTRANSLATED)<>0 then write('Can Track Seek Untranslated; ');
         if (ulFlags and MMIO_CANTRACKREADTRANSLATED)<>0 then write('Can Track Read Translated; ');
         if (ulFlags and MMIO_CANTRACKREADUNTRANSLATED)<>0 then write('Can Track Read Untranslated; ');
         if (ulFlags and MMIO_CANTRACKWRITETRANSLATED)<>0 then write('Can Track Write Translated; ');
         if (ulFlags and MMIO_CANTRACKWRITEUNTRANSLATED)<>0 then write('Can Track Write Untranslated; ');
         writeln;
      end;
   writeln;
   writeln('CODECs:');
   FillChar(CODECInfo,SizeOf(CODECInfo),0);
   CODECINFO.ulStructLen:=SizeOf(CODECInfo);
   rc:=mmioIniFileCODEC(@CODECInfo,MMIO_MATCHFIRST or MMIO_FINDPROC);
   while rc=MMIO_SUCCESS do begin
      with CODECInfo do begin
         FourCC.i:=fcc;
         Compress.i:=ulCompressType;
         case ulSyncMethod of
            CODEC_SYNC_METHOD_NO_DROP_FRAMES: SyncMethod:='No Frame Dropping';
            CODEC_SYNC_METHOD_DROP_FRAMES_IMMEDIATELY: SyncMethod:='Immediately Drop';
            CODEC_SYNC_METHOD_DROP_FRAMES_PRECEDING_KEY: SyncMethod:='Drop before Key Frame';
         else SyncMethod:='';
         end;
         SetLength(CODECName,255);
         StrLen:=255;
         mmioQueryCODECName(@CODECInfo,@(CODECName[1]),@StrLen);
         SetLength(CODECName,StrLen);
         writeln(FourCC.c[0],FourCC.c[1],FourCC.c[2],FourCC.c[3],': "',CODECName,'" ',strpas(@szDLLName),'.DLL: ',strpas(@szProcName),
            ' CompressType: ',Compress.c[0],Compress.c[1],Compress.c[2],Compress.c[3],' CompressSubType: ',ulCompressSubType,' Sync Method: ',SyncMethod);
         write('Capabilities: ');
         if (ulCapsFlags and CODEC_COMPRESS)<>0 then write('Compress; ');
         if (ulCapsFlags and CODEC_DECOMPRESS)<>0 then write('Decompress; ');
         if (ulCapsFlags and CODEC_WINDOW_CLIPPING)<>0 then write('Window Clipping; ');
         if (ulCapsFlags and CODEC_PALETTE_TRANS)<>0 then write('Palette Translation; ');
         if (ulCapsFlags and CODEC_SELFHEAL)<>0 then write('Self Healing; ');
         if (ulCapsFlags and CODEC_SCALE_PEL_HALVED)<>0 then write('Pel Halving; ');
         if (ulCapsFlags and CODEC_SCALE_CONTINUOUS)<>0 then write('Continuous Scaling; ');
         if (ulCapsFlags and CODEC_MULAPERTURE)<>0 then write('Multi-aperature; ');
         if (ulCapsFlags and CODEC_4_BIT_COLOR)<>0 then write('4 Bit Colour; ');
         if (ulCapsFlags and CODEC_8_BIT_COLOR)<>0 then write('8 Bit Colour; ');
         if (ulCapsFlags and CODEC_16_BIT_COLOR)<>0 then write('16 Bit Colour; ');
         if (ulCapsFlags and CODEC_24_BIT_COLOR)<>0 then write('24 Bit Colour; ');
         if (ulCapsFlags and CODEC_HARDWARE)<>0 then write('Hardware Assisted (',strpas(@szHWID),'); ');
         if (ulCapsFlags and CODEC_SYMMETRIC)<>0 then write('Symmetric Record; ');
         if (ulCapsFlags and CODEC_ASYMMETRIC)<>0 then write('Asymmetric Record; ');
         if (ulCapsFlags and CODEC_DIRECT_DISPLAY)<>0 then write('Display into video RAM; ');
         if (ulCapsFlags and CODEC_DEFAULT)<>0 then write('Loaded as Default; ');
         if (ulCapsFlags and CODEC_ORIGIN_LOWERLEFT)<>0 then write('Lower Left Window Origin; ');
         if (ulCapsFlags and CODEC_ORIGIN_UPPERLEFT)<>0 then write('Upper Left Window Origin; ');
         if (ulCapsFlags and CODEC_SET_QUALITY)<>0 then write('Set Quality; ');
         if (ulCapsFlags and CODEC_DATA_CONSTRAINT)<>0 then write('Data Constraint; ');
         writeln;
      end;
      rc:=mmioIniFileCODEC(@CODECInfo,MMIO_MATCHNEXT+MMIO_FINDPROC);
   end;
end.
