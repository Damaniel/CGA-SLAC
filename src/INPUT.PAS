{ Functions and structures related to rendering the display

  Copyright 2025 Shaun Brandt

  Licensed under the MIT license.  See LICENSE.md.
}
unit Input;

interface

uses
    jfunc;

procedure process_input;

var
    g_exit_game: Boolean;

implementation

{ Get and handle keypresses. }
procedure process_input;
var
  keyRead: Char;
  extendedKey: Boolean;
  status: Integer;
  isSuccess: Boolean;
begin
    { If a key press (normal or extended) is detected, figure out what it is and process appropriately. }
    if keypressed then begin
        keyRead := readkey;
        extendedKey := False;

        { Detect extended keypress. }
        if (keyRead = #0) then begin
        extendedKey := True;
        keyRead := readkey;
        end;

        if keyRead = #27 then begin
            g_exit_game := True;
        end;
    end;
end;

end.
