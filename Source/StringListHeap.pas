unit StringListHeap;

{ **************************************************************************** }
{                                                                              }
{ This file is part of StringListHeap project                                  }
{                                                                              }
{ Created by Vitaly Yakovlev                                                   }
{ Copyright: (c) 2022 Vitaly Yakovlev                                          }
{ Website: https://blog.coolsoftware.ru/                                       }
{                                                                              }
{ License: BSD 2-Clause License.                                               }
{                                                                              }
{ Redistribution and use in source and binary forms, with or without           }
{ modification, are permitted provided that the following conditions are met:  }
{                                                                              }
{ 1. Redistributions of source code must retain the above copyright notice,    }
{    this list of conditions and the following disclaimer.                     }
{                                                                              }
{ 2. Redistributions in binary form must reproduce the above copyright notice, }
{    this list of conditions and the following disclaimer in the documentation }
{    and/or other materials provided with the distribution.                    }
{                                                                              }
{ THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"  }
{ AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,        }
{ THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR       }
{ PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR            }
{ CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,        }
{ EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,          }
{ PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;  }
{ OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,     }
{ WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR      }
{ OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF       }
{ ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                                   }
{                                                                              }
{ Last edit by: Vitaly Yakovlev                                                }
{ Date: August 23, 2022                                                        }
{ Version: 1.0                                                                 }
{                                                                              }
{ v1.0:                                                                        }
{ - Initial release                                                            }
{                                                                              }
{ **************************************************************************** }


interface

uses System.Classes, System.SysUtils;

type
  TStringListHeapCompare = function(List: TStringList; Index: Integer;
    const S: String; const AObject: TObject): Integer;

  TStringListHeap = class helper for TStringList
  protected
    function CompareStrings(const S1, S2: string): Integer; virtual;
  public
    // AHeapSize value -1 means "no heap limit"
    function HeapAdd(const S: String; AHeapSize: Integer = -1): Integer;
    function HeapListAdd(const S: String; SCompare: TStringListHeapCompare; AHeapSize: Integer = -1): Integer;
    function HeapAddObject(const S: String; AObject: TObject; AHeapSize: Integer = -1): Integer;
    function HeapListAddObject(const S: String; AObject: TObject; SCompare: TStringListHeapCompare; AHeapSize: Integer = -1): Integer;
  end;

implementation

resourcestring
  SInvalidHeapSize = 'Invalid heap size';

{ TStringListHeap }

function StringListHeapCompareStrings(List: TStringList; Index: Integer;
  const S: String; const AObject: TObject): Integer;
begin
  Result := List.CompareStrings(List[Index], S);
end;

function TStringListHeap.CompareStrings(const S1, S2: string): Integer;
begin
  if UseLocale then
    if CaseSensitive then
      Result := AnsiCompareStr(S1, S2)
    else
      Result := AnsiCompareText(S1, S2)
  else
    if CaseSensitive then
      Result := CompareStr(S1, S2)
    else
      Result := CompareText(S1, S2);
end;

function TStringListHeap.HeapAdd(const S: String; AHeapSize: Integer): Integer;
begin
  Result := HeapListAddObject(S, nil, StringListHeapCompareStrings, AHeapSize);
end;

function TStringListHeap.HeapAddObject(const S: String; AObject: TObject;
  AHeapSize: Integer): Integer;
begin
  Result := HeapListAddObject(S, AObject, StringListHeapCompareStrings, AHeapSize);
end;

function TStringListHeap.HeapListAdd(const S: String;
  SCompare: TStringListHeapCompare; AHeapSize: Integer): Integer;
begin
  Result := HeapListAddObject(S, nil, SCompare, AHeapSize);
end;

function TStringListHeap.HeapListAddObject(const S: String; AObject: TObject;
  SCompare: TStringListHeapCompare; AHeapSize: Integer): Integer;
var
  I, J: Integer;
begin
  if (AHeapSize <= 0) and (AHeapSize <> -1) then
    raise EArgumentException.CreateRes(@SInvalidHeapSize);
  if (AHeapSize = -1) or (Count < AHeapSize) then begin
    Result := AddObject(S, AObject);
    while Result > 0 do begin
      I := (Result-1) shr 1;
      if SCompare(Self, I, S, AObject) >= 0 then Break;
      Exchange(I, Result);
      Result := I;
    end;
  end
  else if SCompare(Self, 0, S, AObject) <= 0 then
    Result := -1
  else begin
    Result := 0;
    Put(Result, S);
    PutObject(Result, AObject);
    while True do begin
      I := (Result shl 1) + 1;
      if I >= AHeapSize then Break;
      J := I;
      if I+1 < AHeapSize then begin
        if SCompare(Self, I, Get(I+1), GetObject(I+1)) < 0 then
          J := I+1;
      end;
      if SCompare(Self, J, S, AObject) <= 0 then Break;
      Exchange(J, Result);
      Result := J;
    end;
  end;
end;

end.
