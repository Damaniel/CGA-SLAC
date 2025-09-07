{ Functions and structures related to enemies

  Copyright 2025 Shaun Brandt

  Licensed under the MIT license.  See LICENSE.md.
}
unit Enemy;

interface

uses
    Globals;

const
    MAX_ENEMIES = 150;
    NO_ENEMY = -1;

type

SLACEnemy=object
    enemy_idx: Shortint;
    is_alive: Boolean;
    cur_hp: Integer;
end;

var
  { The enemies currently in the level }
  g_enemy_list: array[0..MAX_ENEMIES-1] of SLACEnemy;

function get_first_available_enemy_slot: Integer;
function is_valid_enemy(index: Integer) : Boolean;

procedure get_enemy_data(index: Integer; var s: SLACEnemy);
procedure delete_enemy_at(index: Integer);
procedure add_new_enemy_at(index: Integer; enemy_uid: Integer);
procedure clear_enemy_list;

implementation

function get_first_available_enemy_slot : Integer;
var
    idx: Integer;
    found_index: Boolean;
begin
    found_index := false;
    for idx := 0 to MAX_ENEMIES - 1 do
    begin
        if g_enemy_list[idx].enemy_idx = NO_ENEMY then
        begin
            get_first_available_enemy_slot := idx;
            found_index := True;
            break;
        end;
    end;

    if found_index = False then
    begin
        get_first_available_enemy_slot := -1;
    end;
end;

function is_valid_enemy(index: Integer) : Boolean;
begin
    if g_enemy_list[index].enemy_idx = NO_ENEMY then
    begin
        is_valid_enemy := False;
    end
    else begin
        is_valid_enemy := True;
    end;
end;

procedure get_enemy_data(index: Integer; var s: SLACEnemy);
begin
    s := g_enemy_list[index];
end;

procedure delete_enemy_at(index: Integer);
begin
    g_enemy_list[index].enemy_idx := NO_ENEMY;
    g_enemy_list[index].cur_hp := -1;
    g_enemy_list[index].is_alive := False;
end;

procedure add_new_enemy_at(index: Integer; enemy_uid: Integer);
begin
    g_enemy_list[index].enemy_idx := enemy_uid;
    g_enemy_list[index].cur_hp := g_monster_data[enemy_uid].hp;
    g_enemy_list[index].is_alive := True;
end;

procedure clear_enemy_list;
var
    idx: Integer;
begin
    for idx := 0 to MAX_ENEMIES - 1 do
    begin
        delete_enemy_at(idx);
    end;
end;

end.
