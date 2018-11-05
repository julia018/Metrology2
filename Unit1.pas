unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,StrUtils,
  StdCtrls;

type
  TForm1 = class(TForm)
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    function ReadUntil(ch:Char):Integer;
    function Analysis(ch:Char):Integer;
    procedure Skip(var ch:char);
  end;

const
  ArrIf: array [0..8] of string =('if','do','while','case','for','else','switch','break','default');

var
  ProgramFile:TextFile;
  AllOperators, CondOperators:Integer;
  Ml:Integer;
  Alph: set of char = ['A'..'Z','a'..'z','0'..'9','$','_','{'];
  FlPrevCase:boolean;
var
  Form1: TForm1;

implementation

{$R *.dfm}
procedure TForm1.Skip(var ch:char);

begin
  read(ProgramFile,ch);
  if ch='/' then
     while ch<>#13 do
      read(ProgramFile,ch)
  else
  begin
    if ch ='*'  then
    begin
      read(ProgramFile,ch);
      while (ch<>'*') do
      begin
        read(ProgramFile,ch);
      end;
    end;
  end
end;

function TForm1.ReadUntil(ch:Char):Integer;
var
  currStr:string;
  buf:Char;
  FlDo, FlRec, FlBreak:Boolean;
  Level, MaxLevel, numbcase:Integer;
  BufLevel:Integer;
  FlCase:boolean;
begin
   numbcase:=0;
   currStr:='';
   FlDo:=False;
   FlRec:=False;
   buf:=ch;
   MaxLevel:=0;
   Level:=0;
   FlCase:=False;
   while( buf<>';') and  (not FlRec) and (buf<>#13)  do
   begin
     case buf of
      'A'..'Z','a'..'z','0'..'9':begin
                                   currStr:=currStr+buf;
                                   case AnsiIndexStr(currStr,ArrIf) of
                                      0:begin                              //if
                                          CondOperators:=CondOperators+1;
                                          AllOperators:=AllOperators+1;
                                          FlRec:=True;
                                          while(buf <> ')') do
                                          read(ProgramFile,buf);
                                          read(ProgramFile,buf);
                                          if buf = #13 then
                                          begin
                                            read(ProgramFile,buf);
                                            read(ProgramFile,buf);
                                          end;
                                          while not (buf in Alph) do
                                          begin
                                            read(ProgramFile,buf);
                                            if buf='/' then
                                             Skip(buf);
                                          end;
                                          if buf='{' then
                                            BufLevel:=Analysis(buf)
                                          else
                                            BufLevel:=ReadUntil(buf);
                                          Level:=1 + BufLevel;
                                          currStr:='';
                                        end;
                                      1:begin                              //do
                                          FlRec:=True;
                                          CondOperators:=CondOperators+1;
                                          AllOperators:=AllOperators+1;
                                          FlDo:=True;
                                          read(ProgramFile,buf);
                                          if buf = #13 then
                                          begin
                                            read(ProgramFile,buf);
                                            read(ProgramFile,buf);
                                          end;
                                          while not (buf in Alph) do
                                          begin
                                            read(ProgramFile,buf);
                                            if buf='/' then
                                             Skip(buf);
                                          end;
                                          if buf='{' then
                                            BufLevel:=Analysis(buf)
                                          else
                                            BufLevel:=ReadUntil(buf);
                                          Level:=1 + BufLevel;
                                          currStr:='';
                                        end;
                                      2:begin                              //while
                                          FlRec:=True;
                                          while(buf <> ')') do
                                          read(ProgramFile,buf);
                                          if not FlDo then
                                          begin
                                            read(ProgramFile,buf);
                                            if buf = #13 then
                                            begin
                                              read(ProgramFile,buf);
                                              read(ProgramFile,buf);
                                            end;
                                            while not (buf in Alph) do
                                            begin
                                               read(ProgramFile,buf);
                                              if buf='/' then
                                                Skip(buf);
                                            end;
                                            CondOperators:=CondOperators+1;
                                            AllOperators:=AllOperators+1;
                                            if buf='{' then
                                              BufLevel:=Analysis(buf)
                                            else
                                              BufLevel:=ReadUntil(buf);
                                            Level:=1 + BufLevel;
                                            currStr:='';
                                          end;
                                        end;
                                      3:begin                              //case
                                          if not FlPrevCase then
                                          begin
                                            CondOperators:=CondOperators+1;
                                            FlPrevCase:=True;
                                            numbcase:=numbcase+1;
                                            FlCase:= True;
                                            AllOperators:=AllOperators+1;
                                            while(buf <> ':') do
                                            read(ProgramFile,buf);
                                            read(ProgramFile,buf);
                                            if buf = #13 then
                                            begin
                                              read(ProgramFile,buf);
                                              read(ProgramFile,buf);
                                            end;
                                            while not (buf in Alph) do
                                            begin
                                              read(ProgramFile,buf);
                                              if buf='/' then
                                               Skip(buf);
                                            end;
                                            BufLevel:=Analysis(buf);
                                            Level:= BufLevel + numbcase;
                                            currStr:='';
                                          end;
                                        end;
                                      4:begin                              //for
                                          AllOperators:=AllOperators+3;
                                          FlRec:=True;
                                          CondOperators:=CondOperators+1;
                                          while(buf <> ')') do
                                           read(ProgramFile,buf);
                                          read(ProgramFile,buf);
                                          if buf = #13 then
                                          begin
                                            read(ProgramFile,buf);
                                            read(ProgramFile,buf);
                                          end;
                                          while not (buf in Alph) do
                                          begin
                                            read(ProgramFile,buf);
                                            if buf='/' then
                                             Skip(buf);
                                          end;
                                          if buf='{' then
                                            BufLevel:=Analysis(buf)
                                          else
                                            BufLevel:=ReadUntil(buf);
                                          Level:=1 + BufLevel;
                                          currStr:='';
                                        end;
                                      5:begin                              //else
                                          FlRec:=True;
                                          read(ProgramFile,buf);
                                          if buf = #13 then
                                          begin
                                            read(ProgramFile,buf);
                                            read(ProgramFile,buf);
                                          end;
                                          while not (buf in Alph) do
                                          begin
                                            read(ProgramFile,buf);
                                            if buf='/' then
                                             Skip(buf);
                                          end;
                                          if buf='{' then
                                            BufLevel:=Analysis(buf)
                                          else
                                            BufLevel:=ReadUntil(buf);
                                          Level:=1+BufLevel;
                                          currStr:='';
                                        end;

                                      6:begin                             //switch
                                          FlRec:=True;
                                          read(ProgramFile,buf);
                                          while(buf <> ')') do
                                           read(ProgramFile,buf);
                                            if buf = #13 then
                                          begin
                                            read(ProgramFile,buf);
                                            read(ProgramFile,buf);
                                          end;
                                          while not (buf in Alph) do
                                          begin
                                            read(ProgramFile,buf);
                                            if buf='/' then
                                             Skip(buf);
                                          end;
                                          if buf='{' then
                                            BufLevel:=Analysis(buf)
                                          else
                                            BufLevel:=ReadUntil(buf);
                                           currStr:='';
                                        end;
                                      7:begin                              //break

                                        end;
                                      8:begin                             //default
                                           FlRec:=True;
                                           read(ProgramFile,buf);
                                           if buf = #13 then
                                           begin
                                             read(ProgramFile,buf);
                                             read(ProgramFile,buf);
                                           end;
                                           while not (buf in Alph) do
                                           begin
                                             read(ProgramFile,buf);
                                             if buf='/' then
                                              Skip(buf);
                                           end;
                                           if buf='{' then
                                             BufLevel:=Analysis(buf)
                                           else
                                             BufLevel:=ReadUntil(buf);
                                           Level:=BufLevel;
                                           currStr:='';
                                        end;

                                   end;
                                   read(ProgramFile,buf);
                                 end;
      '/':begin
           Skip(buf);
          end;
     else
       begin
         read(ProgramFile,buf);
       end;
     end;
     if MaxLevel < Level then
      MaxLevel:=Level;

   end;

   if not FlRec then
   AllOperators:=AllOperators+1;

   Result:=MaxLevel;
end;


function TForm1.Analysis(ch:Char):Integer;
var
  buf:Char;
  currStr:string;
  FlDo, FlBreak:Boolean;
  Level, MaxLevel, BufLevel, numbcase:Integer;
begin
  FlDo:=False;
  MaxLevel:=0;
  Level:=0;
  buf:=ch;
  FlBreak:=False;
  currStr:='';
  numbcase:=0;
  while( buf<>'}') and (not FlBreak) and (not eof(ProgramFile)) do
  begin
    case buf of
     'A'..'Z','a'..'z','0'..'9': begin
                                   currStr:=currStr+buf;
                                  case AnsiIndexStr(currStr,ArrIf) of
                                      0:begin                              //if
                                          AllOperators:=AllOperators+1;
                                          CondOperators:=CondOperators+1;
                                          while(buf <> ')') do
                                           read(ProgramFile,buf);
                                          read(ProgramFile,buf);
                                          if buf = #13 then
                                          begin
                                            read(ProgramFile,buf);
                                            read(ProgramFile,buf);
                                          end;
                                          while not (buf in Alph) do
                                          begin
                                            read(ProgramFile,buf);
                                            if buf='/' then
                                             Skip(buf);
                                          end;
                                          if buf='{' then
                                            BufLevel:=Analysis(buf)
                                          else
                                            BufLevel:=ReadUntil(buf);
                                          Level:=1 + BufLevel;
                                          currStr:='';
                                        end;
                                      1:begin                              //do
                                          CondOperators:=CondOperators+1;
                                          FlDo:=True;
                                          read(ProgramFile,buf);
                                          if buf = #13 then
                                          begin
                                            read(ProgramFile,buf);
                                            read(ProgramFile,buf);
                                          end;
                                          while not (buf in Alph) do
                                          begin
                                            read(ProgramFile,buf);
                                            if buf='/' then
                                             Skip(buf);
                                          end;
                                          if buf='{' then
                                            BufLevel:=Analysis(buf)
                                          else
                                            BufLevel:=ReadUntil(buf);
                                          Level:=1 + BufLevel;
                                          currStr:='';
                                        end;
                                     2 :begin                              //while
                                          while(buf <> ')') do
                                           read(ProgramFile,buf);
                                          if not FlDo then
                                          begin
                                            read(ProgramFile,buf);
                                            if buf = #13 then
                                            begin
                                              read(ProgramFile,buf);
                                              read(ProgramFile,buf);
                                            end;
                                            while not (buf in Alph) do
                                            begin
                                              read(ProgramFile,buf);
                                              if buf='/' then
                                                Skip(buf);
                                            end;
                                            AllOperators:=AllOperators+1;
                                            CondOperators:=CondOperators+1;
                                            if buf='{' then
                                              BufLevel:=Analysis(buf)
                                            else
                                              BufLevel:=ReadUntil(buf);
                                            Level:=1 + BufLevel;
                                          end;
                                          currStr:='';
                                        end;
                                      3:begin                         //case
                                          if not FlPrevCase then
                                          begin
                                            CondOperators:=CondOperators+1;
                                            FlPrevCase:=True;
                                            numbcase:=numbcase+1;
                                            AllOperators:=AllOperators+1;
                                            while(buf <> ':') do
                                             read(ProgramFile,buf);
                                            read(ProgramFile,buf);
                                            if buf = #13 then
                                            begin
                                              read(ProgramFile,buf);
                                              read(ProgramFile,buf);
                                            end;
                                            while not (buf in Alph) do
                                            begin
                                              read(ProgramFile,buf);
                                              if buf='/' then
                                               Skip(buf);
                                            end;
                                            BufLevel:=Analysis(buf);
                                            Level:=numbcase + BufLevel;
                                            currStr:='';
                                          end;
                                        end;
                                      4:begin                              //for
                                          AllOperators:=AllOperators+3;
                                          CondOperators:=CondOperators+1;
                                          while(buf <> ')') do
                                           read(ProgramFile,buf);
                                          read(ProgramFile,buf);
                                          if buf = #13 then
                                          begin
                                            read(ProgramFile,buf);
                                            read(ProgramFile,buf);
                                          end;
                                          while not (buf in Alph) do
                                          begin
                                            read(ProgramFile,buf);
                                            if buf='/' then
                                             Skip(buf);
                                          end;
                                          if buf='{' then
                                            BufLevel:=Analysis(buf)
                                          else
                                            BufLevel:=ReadUntil(buf);
                                          Level:=1 + BufLevel;
                                          currStr:='';
                                        end;
                                      5:begin                              //else
                                          read(ProgramFile,buf);
                                          if buf = #13 then
                                          begin
                                            read(ProgramFile,buf);
                                            read(ProgramFile,buf);
                                          end;
                                          while not (buf in Alph) do
                                          begin
                                            read(ProgramFile,buf);
                                            if buf='/' then
                                             Skip(buf);
                                          end;
                                          if buf='{' then
                                            BufLevel:=Analysis(buf)
                                          else
                                            BufLevel:=ReadUntil(buf);
                                          Level:=1 + BufLevel;
                                          currStr:='';
                                        end;
                                      6:begin                              //switch

                                          read(ProgramFile,buf);
                                          while(buf <> ')') do
                                           read(ProgramFile,buf);
                                            if buf = #13 then
                                          begin
                                            read(ProgramFile,buf);
                                            read(ProgramFile,buf);
                                          end;
                                          while not (buf in Alph) do
                                          begin
                                            read(ProgramFile,buf);
                                            if buf='/' then
                                             Skip(buf);
                                          end;
                                          if buf='{' then
                                            BufLevel:=Analysis(buf)
                                          else
                                          BufLevel:=ReadUntil(buf);
                                          level:=BufLevel;
                                          currStr:='';
                                        end;
                                      7:begin                              //break
                                          FlBreak := True;
                                          read(ProgramFile,buf);
                                          FlPrevCase:=False;
                                          AllOperators:=AllOperators+1;
                                        end;
                                      8:begin                              //default
                                          read(ProgramFile,buf);
                                          if buf = #13 then
                                          begin
                                            read(ProgramFile,buf);
                                            read(ProgramFile,buf);
                                          end;
                                          while not (buf in Alph) do
                                          begin
                                            read(ProgramFile,buf);
                                            if buf='/' then
                                             Skip(buf);
                                          end;
                                          if buf='{' then
                                            BufLevel:=Analysis(buf)
                                          else
                                            BufLevel:=ReadUntil(buf);
                                          Level:=BufLevel;
                                          currStr:='';
                                        end;
                                  end;
                                  read(ProgramFile,buf);
                                 end;
     ';': begin
            AllOperators:=AllOperators+1;
            FlDo:=False;
            currStr:='';
            read(ProgramFile,buf);
            {if buf ='#10' then
            begin
              read(ProgramFile,buf);
              read(ProgramFile,buf);
            end;}
          end;
      '/':begin
           Skip(buf);
          end;
      #13:begin
            read(ProgramFile,buf);
            read(ProgramFile,buf);
            currStr:='';
            FlDo:=False;
          end;

    else
      begin

        currStr:='';
        read(ProgramFile,buf);
      end;
    end;
    if MaxLevel < Level then
    MaxLevel:=Level;
  end;
  Result:=MaxLevel;
end;


procedure TForm1.FormCreate(Sender: TObject);
var
  MaxL:integer;
begin
  AllOperators:=0;
  FlPrevCase:=False;
  CondOperators:=0;
  AssignFile(ProgramFile,'Program.txt');
  Reset(ProgramFile);
  MaxL:=0;
  while not eof(ProgramFile) do
  begin
    Ml:=Analysis(#0);
    if maxl<Ml then MaxL:=Ml;
  end;
  lbl1.Caption:=inttostr(maxl);
  lbl2.Caption:=inttostr(AllOperators);
  lbl3.Caption:=inttostr(CondOperators);
  CloseFile(ProgramFile);
  
end;



end.
