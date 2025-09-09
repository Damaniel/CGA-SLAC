{ GENERATE.PAS -  Item and enemy generators

  Copyright 2025 Shaun Brandt

  Licensed under the MIT license.  See LICENSE.md.
}
unit Textlog;

interface

uses
    Globals;

const
    NUM_LOG_ROWS = 2;
    LINE_WIDTH = 32;
var

g_text_log: array[0..NUM_LOG_ROWS-1] of String[LINE_WIDTH];

procedure clear_text_log;
procedure append_text_to_log(text: String);

implementation

procedure clear_text_log;
var
    idx: Integer;
begin
    for idx := 0 to NUM_LOG_ROWS - 1 do
    begin
        g_text_log[idx] := '';
    end;
end;

procedure append_text_to_log(text: String);
var
    idx: Integer;
begin
    { Push every line up one }
    for idx := 0 to NUM_LOG_ROWS - 1 do
    begin
        g_text_log[idx] := g_text_log[idx + 1];
    end;

    { Set the last line of the log to the specified text }
    g_text_log[NUM_LOG_ROWS - 1] := text;

    { Tell the game to update }
    g_render_components.render_text_box := True;
end;

end.