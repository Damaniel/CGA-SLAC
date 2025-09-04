
unit Player;

interface

const
    PLAYER_BASE_HP = 20;
    PLAYER_BASE_SPEED = 100;
    PLAYER_BASE_LUCK = 10;
    PLAYER_BASE_ATTACK = 0;
    PLAYER_BASE_DEF = 0;

type

SLACPlayer=object
    level: Byte;
    hp: Integer;
    xp: Longint;
    money: Longint;
    atk: Integer;
    def: Integer;
    spd: Integer;
    luck: Integer;

    procedure Init;
end;

var
    g_player: SLACPlayer;


function getBaseHP(level: Integer) : Integer;
function getBaseAttack(level: Integer) : Integer;
function getBaseDefense(level: Integer) : Integer;
function getBaseSpeed(level: Integer) : Integer;
function getBaseLuck(level: Integer) : Integer;

implementation

procedure SLACPlayer.Init;
begin
    level := 1;
    xp := 0;
    money := 0;
    hp := getBaseHP(level);
    atk := getBaseAttack(level);
    def := getBaseDefense(level);
    spd := getBaseSpeed(level);
    luck := getBaseLuck(level);
end;

{ getBaseHP - returns the base HP value for the specified player level.

  Parameters:
    - level : the level of the player

  Returns:
    The base HP for the player at that level
}
function getBaseHP(level: Integer) : Integer;
begin
   getBaseHP := PLAYER_BASE_HP + ((level - 1) * 5);
end;

{ getBaseAttack - returns the base attack value for the specified player level.

  Parameters:
    - level : the level of the player

  Returns:
    The base attack for the player at that level
}
function getBaseAttack(level: Integer) : Integer;
begin
   getBaseAttack := PLAYER_BASE_ATTACK + level;
end;

{ getBaseDefense - returns the base defense value for the specified player level.

  Parameters:
    - level : the level of the player

  Returns:
    The base defense for the player at that level
}
function getBaseDefense(level: Integer) : Integer;
begin
   getBaseDefense := PLAYER_BASE_DEF + level;
end;

{ getBaseSpeed - returns the base speed value for the specified player level.

  Parameters:
    - level : the level of the player

  Returns:
    The base speed for the player at that level
}
function getBaseSpeed(level: Integer) : Integer;
begin
   getBaseSpeed := PLAYER_BASE_SPEED + (level - 1);
end;

{ getBaseLuck - returns the base luck value for the specified player level.

  Parameters:
    - level : the level of the player

  Returns:
    The base luck for the player at that level
}
function getBaseLuck(level: Integer) : Integer;
begin
   getBaseLuck := PLAYER_BASE_LUCK + (5 * (level div 10));
end;

end.