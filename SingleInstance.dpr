program SingleInstance;



uses SysUtils, Windows;

procedure ExecuteAndWait(const aCommando: string);
var
  tmpStartupInfo: TStartupInfo;
  tmpProcessInformation: TProcessInformation;
  tmpProgram: String;
begin
  tmpProgram := trim(aCommando);
  FillChar(tmpStartupInfo, SizeOf(tmpStartupInfo), 0);
  with tmpStartupInfo do
  begin
    cb := SizeOf(TStartupInfo);
    wShowWindow := SW_HIDE;
  end;

  if CreateProcess(nil, pchar(tmpProgram), nil, nil, true, CREATE_NO_WINDOW,
    nil, nil, tmpStartupInfo, tmpProcessInformation) then
  begin
    // loop every 10 ms
    while WaitForSingleObject(tmpProcessInformation.hProcess, 1000) > 0 do
    begin

    end;
    CloseHandle(tmpProcessInformation.hProcess);
    CloseHandle(tmpProcessInformation.hThread);
  end
  else
  begin
    RaiseLastOSError;
  end;
end;


var  Mutex : THandle = 0;
     Cmd, ExeName : String;
     i : integer;
     ClassName: String;
begin
  if ParamCount < 2 then Exit;
  try
    ExeName := ExtractFileName(ParamStr(1));
    try
      Mutex := CreateMutex(nil, True, PChar(ExeName));
      if (Mutex = 0) OR (GetLastError = ERROR_ALREADY_EXISTS) then
      begin
         Mutex := 0;
        //focus application?
      end
      else
      begin
        Cmd := Format('"%s"', [ParamStr(1)]);
        for i := 2 to ParamCount do
        begin
          Cmd := Cmd + Format(' "%s"', [ParamStr(i)]);
        end;
        ExecuteAndWait(Cmd);
      end;
    finally
      if (Mutex <>0) then CloseHandle(Mutex);
    end;
  Except
    On E : Exception do begin
      ClassName := E.ClassName;
      MessageBox(0, PChar(E.Message), PAnsiChar(ClassName),
        MB_ICONEXCLAMATION);
    end;
  end;
end.
