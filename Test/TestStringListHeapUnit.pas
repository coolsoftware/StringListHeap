unit TestStringListHeapUnit;

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

uses
  DUnitX.TestFramework, System.Classes, System.SysUtils, StringListHeap;

type
  [TestFixture]
  TestStringListHeap = class(TObject)
  strict private
    FHeap: TStringList;
    FAll: TStringList;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [TestAttribute]
    procedure TestA;
    [TestAttribute(False)]
    procedure TestB;
    [TestAttribute]
    procedure TestC;
    [TestAttribute]
    procedure TestD;
  private
    procedure HeapAdd(const S: String; AHeapSize: Integer = -1);
    procedure CheckHeap(AHeapSize: Integer = -1);
    function SortedText(AList:TStringList; ACount: Integer = -1): String;
  end;

implementation

{ TestStringListHeap }

procedure TestStringListHeap.CheckHeap(AHeapSize: Integer);
var
  I, J: Integer;
begin
  if (AHeapSize < 0) or (AHeapSize > FHeap.Count) then
    AHeapSize := FHeap.Count;
  for I := 1 to AHeapSize-1 do begin
    J := (I-1) shr 1;
    if FHeap[J] < FHeap[I] then
      Assert.FailFmt('Invalid heap: "%s" [%d] < "%s" [%d]', [FHeap[J], J, FHeap[I], I], ReturnAddress);
  end;
end;

procedure TestStringListHeap.HeapAdd(const S: String; AHeapSize: Integer);
var
  L: TStringList;
  I: Integer;
begin
  L := TStringList.Create;
  try
    L.Delimiter := ':';
    L.DelimitedText := S;
    for I := 0 to L.Count-1 do begin
      FHeap.HeapAdd(L[I], AHeapSize);
      FAll.Add(L[I]);
    end;
  finally
    L.Free;
  end;
end;

procedure TestStringListHeap.Setup;
begin
  FHeap := TStringList.Create;
  FAll := TStringList.Create;
end;

function TestStringListHeap.SortedText(AList: TStringList; ACount: Integer): String;
var
  L: TStringList;
  I: Integer;
begin
  L := TStringList.Create;
  try
    L.AddStrings(AList);
    L.Sort;
    Result := '';
    for I := 0 to L.Count-1 do begin
      if ACount = 0 then Break;
      if I > 0 then Result := Result + ':';      
      Result := Result + L[I];
      if ACount > 0 then Dec(ACount); 
    end;
  finally
    L.Free;
  end;
end;

procedure TestStringListHeap.TearDown;
begin
  FreeAndNil(FAll);
  FreeAndNil(FHeap);
end;

procedure TestStringListHeap.TestA;
begin
  HeapAdd('king:point:seller:formulate:refund:self:flawed:suburb:card:conglomerate');
  CheckHeap;
end;

procedure TestStringListHeap.TestB;
begin
  Assert.WillRaise(
    procedure
    begin
      FHeap.HeapAdd('test', 0)
    end,
    EArgumentException);
end;

procedure TestStringListHeap.TestC;
const
  HeapSize = 3;
var
  H, E: String;
begin
  HeapAdd('king:point:seller:formulate:refund:self:flawed:suburb:card:conglomerate', HeapSize);
  CheckHeap(HeapSize);
  H := SortedText(FHeap);
  E := SortedText(FAll, HeapSize);
  Assert.AreEqual(E, H);
end;

procedure TestStringListHeap.TestD;
const  
  HeapSize = 10;
  TestCount = 10000;  
  MaxInt = 500000;
var
  N: Integer;
  S, H, E: String;
begin
  Randomize;
  for N := 1 to TestCount do begin
    S := IntToStr(Random(MaxInt));
    FHeap.HeapAdd(S, HeapSize);
    FAll.Add(S);
  end;
  CheckHeap(HeapSize);
  H := SortedText(FHeap);
  E := SortedText(FAll, HeapSize);
  Assert.AreEqual(E, H);  
end;

end.