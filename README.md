# Code_test-Pokedex-Ekatena-SCRAPING-WEB
Hacer un servicio/script del sitio https://www.pokemon.com/el/pokedex/ que extraiga la informacion de cada pokemon y que guarde la informacion en una base de datos. Ademas, se debe de proveer una interfaz de consulta, que recibira un nombre y regrese la informacion del pokemon.

### GEMAS UTILIZADAS
 - 'httparty'
 - 'nokogiri'
 - 'activerecord'
 - 'postgresql'
 
### 💡 COMO CORRER EL SCRIPT
Desde la terminal ubicandonos dentro del directorio donde esten todos los archivos del script
#### 1.- Instalar las dependencias necesarias con: 
    bundle install

#### 2.- Iniciar el sistema gestor de db en mi caso 'postgresql':  
    sudo service postgresql start

#### 3.- Configurar el archivo 'database.yml' segun corresponda:
    adapter: #postgresql, mysql, sqlite etc.
    host: 'localhost'
    database: 'scraping'
    username: #username
    password: #password

#### 4.- Generar la base de datos con:
    rake db:create

(con esto bastara para crear la db y la tabla correspondiente...'No hace falta correr migraciones o crear tablas de manera manual')
#### 5.- Ejecutar el script con: 
    ruby scraper.rb 

#### 6.- Eperar a que el script termine 
Ejemplo de como se vera la consola durante la carga de los datos (si es que todo va correctamente).
- Tiempo aproximado: ⏰ No mas de 15 minutos (con un internet de 10mbps)
```
    Obteniendo los datos...Pokemon#[189]
    Obteniendo los datos...Pokemon#[190]
    Obteniendo los datos...Pokemon#[191]
    Obteniendo los datos...Pokemon#[192]
    Obteniendo los datos...Pokemon#[193]
    Obteniendo los datos...Pokemon#[194]
    Obteniendo los datos...Pokemon#[195]
 ```
## ⚠️ NOTAS IMPORTANTES 
#### [ESTO SOLO SUCEDE DURANTE LA CARGA DE LOS DATOS UNA VEZ CARGADOS Y GUARDADOS NO SUCEDERA MAS]
Durante el testeo en base a prueba y error durante la codificación del script se detectaron algunas irregularidades las cuales provocaban que el script durante la carga de los datos, se parara en base a un problema con la cantidad de peticiones realizadas [Cabe destacar que dicho limite/irregularidad es externo a la codificación del mismo]...ya que pertenece a los paquetes internos del lenguaje en si en especifico el que utiliza Ruby para ejecutar las peticiones web, dicho error se encontro que lo provocaba y se podia solucionar extendiendo solo algunos segundos el timeout de respuesta de las peticiones [DENTRO DE LOS PAQUETES DE RUBY NO DE ESTE SCRIPT], pero eso es externo a la solución planteada para la problematica que da solución este script, y basicamente inescesario para dar solución a la problematica, ya que se encontro una manera mas eficaz y sencilla de solucionar esto la cual se expone a continuación.

## ✅ Solución a la limitante
SOLO SI SUCEDE DURANTE LA EJECUCION DEL SCRIPT DEBES HACER ESTO:
- Simplemente se debe volver a correr el script con:
```ruby scrapper.rb```
y automaticamente retomara el punto hasta donde llego y continuara hasta terminar de cargar los datos.
- Correr el script las veces nescesarias para terminar de cargar los datos (si es que sucede...no sucede siempre).
### [durante el testeo se debio ejecutar algunas veces, alrededor de 2 veces maximo] 

## 💻 Como manipular el script 
Una vez que todos los datos se cargaron el script, mostrara una interfaz en la terminal dentro de la cual solo debes ingresar el nombre del Pokemon 🐛 a buscar y listo los datos seran msotrados dentro de la terminal.
- Ejemplo:
```
Ingresa el nombre en [minusculas] del pokemon a buscar:
mewtwo
```
- Respuesta:
```
|||||||||||||||||||RESULTADOS DE Mewtwo||||||||||||||||||


No. de Pokemon: 150
Nombre: Mewtwo
/////////////////////Descripciones://////////////////////////
Mewtwo:

 VERSION AZUL: Su ADN es casi el mismo que el de Mew. Sin embargo, su tamaño y carácter son muy diferentes.
VERSION ROJA:Su ADN es casi el mismo que el de Mew. Sin embargo, su tamaño y carácter son muy diferentes.

Mega-Mewtwo X:

 VERSION AZUL: Su poder psíquico ha incrementado su masa muscular. Posee una fuerza de agarre de una tonelada y puede correr 100 m en dos segundos.
VERSION ROJA:Su poder psíquico ha incrementado su masa muscular. Posee una fuerza de agarre de una tonelada y puede correr 100 m en dos segundos.

Mega-Mewtwo Y:

 VERSION AZUL: Aunque su cuerpo se ha encogido, el poder tan extraordinario que atesora le permite reducir a escombros un rascacielos con solo pensarlo.
VERSION ROJA:Aunque su cuerpo se ha encogido, el poder tan extraordinario que atesora le permite reducir a escombros un rascacielos con solo pensarlo.
//////////////////////////////////////////////////////////////

************************Altura:************************
 Mewtwo: 2,0 m
Mega-Mewtwo X: 2,3 m
Mega-Mewtwo Y: 1,5 m


************************PESO************************
 Mewtwo: 122,0 kg
Mega-Mewtwo X: 127,0 kg
Mega-Mewtwo Y: 33,0 kg


************************GENERO************************
 Unknown


************************CATEGORIA************************
 Genético


************************HABILIDAD************************
 Mewtwo: Presión,
Mega-Mewtwo X: Impasible,
Mega-Mewtwo Y: Insomnio,


************************TIPO************************
 Mewtwo: Psíquico,
Mega-Mewtwo X: Psíquico,Lucha,
Mega-Mewtwo Y: Psíquico,


************************DEBILIDAD************************

Mewtwo: Fantasma, Siniestro, Bicho
Mega-Mewtwo X: Fantasma, Hada, Volador
Mega-Mewtwo Y: Fantasma, Siniestro, Bicho,


************************PUNTOS BASE************************

----Mewtwo----
Ps: 7,
Attack: 7,
Defense: 6,
Especial_attack: 10,
Especial_defense: 6,
Velocity: 8,

----Mega-Mewtwo X----
Ps: 7,
Attack: 12,
Defense: 6,
Especial_attack: 10,
Especial_defense: 6,
Velocity: 8,

----Mega-Mewtwo Y----
Ps: 7,
Attack: 9,
Defense: 5,
Especial_attack: 12,
Especial_defense: 8,
Velocity: 9,

************************EVOLUCIÓN************************
 > Mewtwo



||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

```
- Y por ultimo despues de la respuesta se mostrara hasta el final un menu dentro cual podras decidir continuar o salir:
```
==================MENU====================
1......................Buscar otro pokemon
[cualquier tecla que no sea 1].......salir
==========================================
==Ingresa una opcion y presiona [ENTER]:==
```
















