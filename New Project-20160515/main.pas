program rpg;
{$mode objfpc} {R+} {Q+}
{
Proyecto "La Mazmorra de Azeroth". Realizado por los cadetes

CC/DC:
CC/DC:
Seccion:

Partes realizadas:

}

uses rpglib, crt;

{------------------- Modulos ----------------------------}

{---------------- Programa principal -----------------------}
var
   mapa   : tMapa;
begin 
   Randomize();

   {Los ficheros de texto tienen que estar copiados dentro de la carpeta del proyecto
   FreePascal} 
   PrintFile('intro.txt');
   PrintFile('instrucciones.txt');
   ReadMap('level1.txt',mapa);
   PrintFile('level1.txt');

end.