{----------------------------------------------------------------------
RPGlib es una libreria para ayudar al desarrollo de un videojuego
de tipo RPG desde el simbolo del sistema o un terminal de texto.

Autor: Ruben Martinez Cantin   <rmcantin@unizar.es>
    2016 - Centro Universitario de la Defensa.

Este codigo es de dominio publico segundo la licencia Creative Commons CC0
http://creativecommons.org/publicdomain/zero/1.0/legalcode
----------------------------------------------------------------------}

unit rpglib;
{$mode objfpc} {R+} {Q+}

interface

const
   NFILS = 20;     {Tamanios maximos del mapa para que se vea bien}
   NCOLS = 49;
   
type
   {Mapa de ocupacion. Es decir, cada celda del array nos dice si la
   casilla del mapa esta ocupada por una pared o no. Ademas, como el
   mapa puede ser de diferentes tamanios, nos guardamos tambien el
   numero de filas y columnas}

   tMapa = record
              ocupado           : array[1..NFILS,1..NCOLS] of boolean;
              nfilas, ncolumnas : integer;
           end;                 

{----------------------------------------------------}
{                       Modulos                      }
{----------------------------------------------------}
function ReadCharacter(filename     : string;
                           fila     : integer;
                       var name     : string;
                       var acciones : integer;
                       var vida     : integer;
                       var mana     : integer;
                       var espada   : integer;
                       var armadura : integer):boolean;
{
Funcion que lee los datos del personaje (jugador o enemigo) de la
"fila" determinada del fichero con nombre "filename".  Si la fila
existe y se ha leido correctamente, devuelve true. Si esa fila no
existe, devuelve false.
}

procedure ReadMap(filename : string; var mapa: tMapa );
{
Modulo que carga los datos del mapa desde el fichero
}

procedure PrintFile(filename : string);
{
Modulo que escribe por pantalla el contenido de un fichero de
texto. Se usa para la intro, las instrucciones, etc.
}

procedure DrawMap(const mapa : tMapa );
{
Modulo que dibuja el mapa por pantalla.
Antes de hacerlo, borra toda la pantalla.
}

procedure DrawSymbol(x,y : integer; s:char ; color:integer);
{
Modulo que dibuja un simbolo (caracter) en la posicion (x,y) de la
pantalla con el color indicado. La lista de colores que
reconoce Pascal puede verse en

   http://www.freepascal.org/docs-html/rtl/crt/index-2.html

Despues de escribir el caracter, el color se vuelve a poner a blanco
automaticamente, pero el cursor se queda en la posicion contigua.
}

procedure DrawStats(nombre                 : string;
                    acciones, max_acciones : integer;
                    vida, max_vida         : integer;
                    mana, max_mana         : integer;
                    espada, armadura       : integer );
{
Muestra la tabla de estadisticas junto al mapa.
}


procedure DrawMonsterStats(nombre         : string;
                           vida, max_vida : integer;
                           fila           : integer );
{
Muestra las estadisticas para un monstruo debajo de las estadisticas
del jugador. Es necesario decir que fila de la lista de monstruos se
va a rellenar cada vez (1, 2, ...).
}



{------------------------------------------------------------------

A partir de aqui comienza la implementacion de los modulos. Para poder utilizarlos, la
informacion vista hasta aqui es suficiente.

------------------------------------------------------------------}

implementation

uses crt;

procedure TrimWhite(data : string; var i: integer );
{
Posiciona el puntero i en la siguiente posicion que no es espacio en blanco.
}

begin
   while (i <= length(data)) and (data[i] = ' ') do
   begin
      i := i + 1
   end
end; { TrimWhilte }


procedure GetValue(data : string; var res : string; var i: integer );
{
Pone en res la cadena de caracteres de data, limpi‡ndola de espacios en blanco.
}

begin
   TrimWhite(data,i);
   res := '';
   while (i <= length(data)) and (data[i] <> ' ') do
   begin
      res := res + data[i];
      i := i + 1;
   end;
end; { GetValue }




function ReadCharacter(filename     : string;
                           fila     : integer;
                       var name     : string;
                       var acciones : integer;
                       var vida     : integer;
                       var mana     : integer;
                       var espada   : integer;
                       var armadura : integer): boolean;
{
Funcion que lee los datos del personaje (jugador o enemigo) de la
"fila" determinada del fichero con nombre "filename".  Si la fila
existe y se ha leido correctamente, devuelve true. Si esa fila no
existe, devuelve false.
}

var
   f      : text;
   linea  : string;
   i,j,ec : integer;
   foo    : string;
begin
   try
      assign(f,filename);
      reset(f);
      readCharacter := false;
      j := 1;
      while not eof(f) and (j < fila) do
      begin
         readln(f,linea);
         j := j + 1;
      end;
      if not eof(f) then
      begin
         readln(f,linea);
         i := 1;
         GetValue(linea,name,i);
         GetValue(linea,foo,i); val(foo,acciones,ec);
         GetValue(linea,foo,i); val(foo,vida,ec);
         GetValue(linea,foo,i); val(foo,mana,ec);
         GetValue(linea,foo,i); val(foo,espada,ec);
         GetValue(linea,foo,i); val(foo,armadura,ec);
         if ec = 0 then
         begin
            readCharacter := true
         end
      end;
      close(f);
   except
      writeln('Error leyendo ficha de enemigos:', filename);
   end
end; { ReadCharacter }


procedure ReadMap(filename : string; var mapa: tMapa );
{
Modulo que carga los datos del mapa desde el fichero
}

var
   f     : text;
   i,j   : integer;
   linea : string;
begin
   try
      assign(f,filename);
      reset(f);
      mapa.nfilas := 0;
      mapa.ncolumnas := 0; 
      i := 0;
  
      {Primera linea}
      if not eof(f) then
      begin
         readln(f,linea);
         if (linea[1] = '#') then
         begin
            i := i + 1;
            mapa.ncolumnas := length(linea);
            for j:= 1 to mapa.ncolumnas do
            begin
               mapa.ocupado[i,j] := linea[j] = '#'
            end
         end
      end;

      {Resto de filas}
      while not eof(f) do
      begin
         readln(f,linea);
         if (linea[1] = '#') and (mapa.ncolumnas = length(linea)) then
         begin
            i := i + 1;
            for j:= 1 to mapa.ncolumnas do
            begin
               mapa.ocupado[i,j] := linea[j] = '#'
            end
         end
      end;
      mapa.nfilas := i;
      close(f);
   except
     writeln('Error leyendo mapa:', filename);
   end;
end; { ReadMap }


procedure PrintFile(filename : string);
{
Modulo que escribe por pantalla el contenido de un fichero de
texto. Se usa para la intro, las instrucciones, etc.
}

var
   f     : text;
   linea : string;
begin
   clrscr;
   try
      assign(f,filename);
      reset(f);
      while not eof(f) do
      begin
         readln(f,linea);
         writeln(linea);
      end;
      close(f);
   except
     writeln('Error leyendo fichero:', filename)
   end;
   write('Pulse una tecla para continuar...');
   readkey()
end; { PrintFile }


procedure DrawMap(const mapa : tMapa );
{
Modulo que dibuja el mapa por pantalla.
Antes de hacerlo, borra toda la pantalla.
}

var
   i,j : integer;
begin
   clrscr;
   TextColor(YELLOW);
   for i := 1 to mapa.nfilas do
   begin
      for j := 1 to mapa.ncolumnas do
      begin
         if mapa.ocupado[i,j] then
         begin
            write('#')
         end
         else
         begin
            write(' ');
         end
      end;
      writeln()
   end;
   NormVideo()
end; { DrawMap }


procedure DrawSymbol(x,y : integer; s:char ;color:integer);
{
Modulo que dibuja un simbolo (caracter) en la posicion (x,y) de la
pantalla con el color indicado. La lista de colores que
reconoce Pascal puede verse en
   http://www.freepascal.org/docs-html/rtl/crt/index-2.html
Despues de escribir el caracter, el color se vuelve a poner a blanco
automaticamente, pero el cursor se queda en la posicion contigua.
}

begin
   gotoXY(x,y);
   TextColor(color);
   write(s);
   NormVideo()
end; { DrawSymbol }


procedure DrawStats(nombre                 : string;
                    acciones, max_acciones : integer;
                    vida, max_vida         : integer;
                    mana, max_mana         : integer;
                    espada, armadura       : integer );
{
Muestra la tabla de estadisticas junto al mapa.
}

begin
   gotoXY(50,1); writeln('-----------------------');
   gotoXY(50,2); writeln('Nombre:   ',nombre);
   gotoXY(50,3); writeln('Acciones: ',acciones,'/',max_acciones);
   gotoXY(50,4); writeln('Vida:     ',vida,'/',max_vida);
   gotoXY(50,5); writeln('Mana:     ',mana,'/',max_mana);
   gotoXY(50,6); writeln('Espada:   ',espada,' | Armadura: ',armadura);
   gotoXY(50,7); writeln('-----------------------');
end; { DrawStats }

procedure drawMonsterStats(nombre         : string;
                           vida, max_vida : integer;
                           fila           : integer );
{
Muestra las estadisticas para un monstruo debajo de las estadisticas
del jugador. Es necesario decir que fila de la lista de monstruos se
va a rellenar cada vez (1, 2, ...).
}

var
   i : integer;
begin
   gotoXY(50,7+fila);
   write(nombre);
   for i := 1 to 10 - length(nombre) do
   begin
      write(' ');
   end;
   writeln(' | Vida : ', vida,'/', max_vida);
end; { DrawMonsterStats }


end.
