{ Miscellaneous utility functions.

  Copyright 2025 Shaun Brandt
  
  Licensed under the MIT license. See LICENSE.md.
}
unit Slacutil;

{ -------------------------------------------------------------------------- }
interface

{ getBaseHP - returns the base HP value for the specified player level. }
function getBaseHP(level: Integer) : Integer;

{ getBaseAttack - returns the base attack value for the specified player level. }
function getBaseAttack(level: Integer) : Integer;

{ getBaseDefense - returns the base defense value for the specified player level. }
function getBaseDefense(level: Integer) : Integer;

{ getBaseSpeed - returns the base speed value for the specified player level. }
function getBaseSpeed(level: Integer) : Integer;

{ getBaseLuck - returns the base luck value for the specified player level. }
function getBaseLuck(level: Integer) : Integer;
   
{ -------------------------------------------------------------------------- }
implementation

{ getBaseHP }
function getBaseHP(level: Integer) : Integer;
begin
   getBaseHP := 20 + ((level - 1) * 5);
end;

{ getBaseAttack }
function getBaseAttack(level: Integer) : Integer;
begin
   getBaseAttack := level;
end;

{ getBaseDefense }
function getBaseDefense(level: Integer) : Integer;
begin
   getBaseDefense := level;
end;

{ getBaseSpeed }
function getBaseSpeed(level: Integer) : Integer;
begin
   getBaseSpeed := 100 + (level - 1);
end;

{ getBaseLuck }
function getBaseLuck(level: Integer) : Integer;
begin
   getBaseLuck := 10 + (5 * (level div 10));
end;

end.
