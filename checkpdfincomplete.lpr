program checkpdfincomplete;

// {$DEFINE DELETE}

uses
  SysUtils, StrUtils, Classes, LazFileUtils;

Type
  TPDFStatus = (PDFOk, EmptyPDF, PDFIncompleted, NotPDFFile, NotExistsPDFFile, ErrorOnLoadPDF);

function CorrectPath(dir: String): String;
begin
  if Not (StrUtils.RightStr(dir, 1) = '\') then begin
    dir += '\';
  end;

  Result := dir;
end;

function CheckFilePDF(fileName: String): TPDFStatus;
var
  streamFile: Classes.TStringList;
begin
  if Not LazFileUtils.FileExistsUTF8(fileName) then begin
    Result := NotExistsPDFFile;
    Exit;
  end;

  if (LazFileUtils.FileSizeUtf8(fileName) = 0) then begin
    Result := EmptyPDF;
    Exit;
  end;

  streamFile := Classes.TStringList.Create;
  try
    try
      streamFile.LoadFromFile(fileName);
    except
      Result := ErrorOnLoadPDF;
      Exit;
    end;
    if StrUtils.LeftStr(streamFile.Strings[0], 4) = '%PDF' then begin
        if streamFile.Strings[streamFile.Count - 1] = '%%EOF' then begin
            Result := PDFOk;
          end
          else begin
            Result := PDFIncompleted;
        end;
      end
      else begin
        Result := NotPDFFile;
    end;
  finally
    streamFile.Free;
  end;
end;

procedure ProcessDir(dir: String);
var
  searchRec:  SysUtils.TSearchRec;
begin
  dir := CorrectPath(dir);
  if SysUtils.FindFirst(dir + '*', faAnyFile, searchRec) = 0 then begin
    repeat
      if Not ((searchRec.Name = '.') or (searchRec.Name = '..'))then begin
        if ((searchRec.Attr and faDirectory) = faDirectory) then begin
            ProcessDir(dir + searchRec.Name);
          end
          else begin
            if System.UpCase(SysUtils.ExtractFileExt(searchRec.Name)) = '.PDF' then begin
              case CheckFilePDF(dir + searchRec.Name) of
                PDFIncompleted: begin
                  WriteLn('');
                  WriteLn('Incompleted PDF file!');
                  WriteLn('File: ' + dir + searchRec.Name);
                  WriteLn('------------------------');
                  {$IFDEF DELETE}
                    WriteLn('Deleting empty PDF file!');
                    WriteLn('File: ' + dir + searchRec.Name);
                    WriteLn('------------------------');
                    LazFileUtils.DeleteFileUTF8(dir + searchRec.Name);
                  {$ENDIF}
                end;
                NotPDFFile: begin
                  WriteLn('');
                  WriteLn('Not a PDF file!');
                  WriteLn('File: ' + dir + searchRec.Name);
                  WriteLn('------------------------');
                end;
                NotExistsPDFFile: begin
                  WriteLn('');
                  WriteLn('PDF file not exists!');
                  WriteLn('File: ' + dir + searchRec.Name);
                  WriteLn('------------------------');
                end;
                EmptyPDF: begin
                  WriteLn('');
                  WriteLn('PDF file is empty!');
                  WriteLn('File: ' + dir + searchRec.Name);
                  WriteLn('------------------------');
                  {$IFDEF DELETE}
                    WriteLn('Deleting empty PDF file!');
                    WriteLn('File: ' + dir + searchRec.Name);
                    WriteLn('------------------------');
                    LazFileUtils.DeleteFileUTF8(dir + searchRec.Name);
                  {$ENDIF}
                end;

                ErrorOnLoadPDF: begin
                  WriteLn('');
                  WriteLn('Error accessing PDF file!');
                  WriteLn('File: ' + dir + searchRec.Name);
                  WriteLn('------------------------');
                end;
              end;
            end;
        end;
      end;
    until SysUtils.FindNext(searchRec) <> 0;
  end;
end;

begin
  ProcessDir('C:\Users\euripedeseas\Documents\COMAER\Publicações\');
  // ProcessDir('C:\Users\euripedeseas\Documents\COMAER\BCA\');
  WriteLn('--------------------');
  WriteLn('Press ENTER to exit!');
  ReadLn();
end.

