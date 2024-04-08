# 8. Fondos

Hemos podido ya empezar a ver nuestros primeros ejemplos; pero nos falta el poder ver más colorido y poder jugar con las distintas características que nos ofrece la Sega Mega Drive.

Uno de los apartados más significativos a la hora de trabajar con juegos, son los fondos. Estos fondos son imágenes que podemos superponer para poder dar una sensación de profundidad. Sega Mega Drive permite trabajar con varios fondos (o planos), de tal forma que podemos dar ese movimiento y de una mayor interacción.

En este capítulo, nos centraremos en el uso de fondos o planos a través de SGDK y el uso de herramientas para poder gestionar estos fondos; como por ejemplo la herramienta _rescomp_.

Comenzaremos por hablar de cómo gestiona las imágenes o los gráficos la Sega Mega Drive, e iremos explicando los distintos conceptos relacionados con los fondos.

## Imágenes en Sega Mega Drive

En primer lugar, antes de entrar en más conceptos vamos a estudiar cómo se gestionan las imágenes o gráficos en la Sega Mega Drive, a través del VDP.

Veamos las características de los gráficos para Sega Mega Drive:

* Todo gráfico o imagen se dibuja dividido por Tiles [^50] de un tamaño de 8x8 píxeles.
* Solo se pueden almacenar 4096 Tiles (64Kb de VRAM).
* Las imágenes, están almacenadas en formato indexado [^51] no como RGB [^52].
* Sólo se pueden almacenar 4 paletas de 16 colores cada una.
* Normalmente, sólo se pueden mostrar 61 colores en pantalla.
* En cada paleta, el primer color se considera transparente.

[^50]: Un Tile es un fragmento de una imagen que se muestra como si fuese un mosaico; por lo que una imagen está compuesta por una serie de Tiles.
[^51]: Una imagen en formato indexado, almacena una paleta con los distintos colores que contiene; después cada píxel sólo tiene información del color que representa en dicha paleta.
[^52]: RGB (Red Green Blue) es un formato que se define en cada píxel almacenar el color rojo, verde y azul de tal forma que se pueda ver cada color combinando estos tres colores primarios.

Es importante conocer estas características a la hora de trabajar con imágenes en Mega Drive; para no perder calidad o algún color, si la paleta no está bien referenciada.

Además, hemos podido ver que solo se pueden mostrar 61 colores en pantalla. Esto es debido a los colores transparentes de cada una de las paletas; excepto la primera paleta (paleta 0), que se considera el color de fondo.

Toda esta información de las paletas y los distintos Tiles que se van a mostrar, se almacenan en la VRAM y son accesibles por el VDP; de tal forma que en algunas ocasiones gracias al uso del DMA, la CPU no necesita trabajar con ello; sino que el propio VDP realiza todo el trabajo de forma más eficiente.

Si se necesita conocer, los distintos colores y paletas que hay almacenadas; podemos usar algunas herramientas que nos trae emuladores como _Blastem_; pulsando la tecla <kbd>c</kbd>, podremos ver el contenido de las paletas del VDP.

![Visor VDP Blastem](8fondos/img/blastem.png "Visor VDP Blastem")
_Visor VDP Blastem_

Más adelante, veremos cómo importar imágenes y gráficos para nuestro juego usando la herramienta _rescomp_ de SGDK.

## Fondos

Como hemos comentado, una parte importante es el uso de fondos o planos como también se les conoce; Sega Mega Drive permite trabajar con 2 fondos a la vez de tal forma, que siempre se pintan estos dos fondos a la vez.

Un fondo no es más que un conjunto de Tiles que están almacenados en la memoria de vídeo; normalmente en cada fondo se establece en cada Tile un índice que apunta a un Tile de la memoria de vídeo; esto se conoce como Mapa. El conjunto de Tiles almacenados en la memoria se conoce como TileSet. Más adelante, hablaremos sobre los Tilesets y como se pueden utilizar.

En este apartado, solo hablaremos sobre los fondos y cómo podemos utilizarlos para nuestros juegos de forma estática.

Es importante saber que un fondo se dibuja de arriba a abajo y de izquierda a derecha. De tal forma, que es más fácil de trabajar con ellos. Además, no podemos olvidar que los fondos trabajan a nivel de Tile no a nivel de píxel.

Por último, aunque la Sega Mega Drive tiene una resolución de pantalla de 320x240 (320x224 NTSC) que corresponden a 40x30 tiles en PAL, sí que se pueden almacenar más Tiles por fondo por lo cual podemos almacenar hasta 64x32 Tiles; de esta manera podríamos utilizar este sobrante para realizar scroll; que veremos en más detalle en un próximo capítulo.

### Fondo A, B y Window

Como hemos comentado, Sega Mega Drive tiene disponibles 2 fondos para trabajar con ellos (aparte del encargado de los Sprites).

* **Fondo A**; permite dibujar un plano completo.
* **Fondo B**; permite dibujar un plano completo.
* **Window**; es un plano especial, que permite escribir dentro del Plano A, el plano Window, tiene un scroll diferente del A y por lo tanto suele usarse para mostrar por ejemplo la interfaz de usuario.

![Visor de Planos de Gens Kmod](8fondos/img/planeExplorer.png "Visor de Planos de Gens Kmod")
_Visor de planos de Gens Kmod_

En la anterior imagen, podemos ver el visor de fondos de _Gens KMod_ donde podremos visualizar cada fondo para ver cómo se dibuja.

Además, los fondos A, B y el plano de Sprites (que veremos en el siguiente capítulo), tienen distinta prioridad; de tal forma que podemos dar esta prioridad a cada fondo dando la sensación de profundidad.

![Esquema de Prioridad de los Fondos](8fondos/img/esquemaplanos.png "Esquema de Prioridad de los Fondos")
_Esquema de Prioridad de los Fondos_

Como podemos ver en la anterior imagen, tanto el plano A, B además del plano de Sprites, pueden tener una prioridad baja o alta. De tal forma, que podemos jugar indistintamente con ellos para poder mostrarlos en distinto lugar y así, poder mostrar esa sensación de profundidad.

## Rescomp

Para poder importar los distintos recursos para nuestro juego, es necesario usar una herramienta que está incluida en el propio SGDK. Esta herramienta se llama _rescomp_ "Resource Compiler"; la cual va a permitir importar los recursos generando todo lo necesario para poder usarlo a través del propio SGDK.

Esta herramienta, genera todo lo necesario para importar los distintos tipos de recursos de nuestro juego (gráficos, sprites, música, sonido, binario...). Se basa en el uso de unos ficheros que describen cada recurso; estos ficheros tienen la extensión _.res_ e incluyen toda la descripción de los recursos a importar.

_Rescomp_, lee estos ficheros y generará uno o varios ficheros .s con la información del recurso y si no se indica lo contrario, un fichero cabecera de C _.h_. Veamos como se usa.

```bash
rescomp fichero.res [out.s] [-noheader]
```

Observamos que se reciben varios parámetros:

* _fichero.res_: nombre del fichero de recursos.
* _out.s (opcional)_: fichero .s resultado. Si no se indica, se genera un fichero .s con el nombre del recurso a importar.
* _-noheader_: indica que no se va a generar un fichero cabecera de C _.h_.

Podemos importar los siguientes tipos de recurso:

* _BITMAP_: Mapa de Bits.
* _PALETTE_: Paleta de colores.
* _TILEMAP_: Mapa de Tiles (a partir de la versión 1.80).
* _TILESET_: Tileset; contiene un conjunto de tiles que puede usarse para generar imágenes o sprites.
* _MAP_: Recurso tipo Mapa; contiene una paleta, un Tileset y la información del mapa (a partir de SGDK 1.60).
* _IMAGE_: Recurso tipo imagen; contiene una paleta, un Tileset y un Tilemap.
* _SPRITE_: Recurso tipo Sprite; se usa para controlar los Sprites y las animaciones.
* _XGM_: Recurso de música usando XGM (.vgm o .xgm).
* _XGM2_: Recurso de música usando el nuevo driver de sonido XGM2 (a partir de SGDK 2.00).
* _WAV_: Recurso de sonido.
* _OBJECTS_: Objectos con información desde un fichero .tmx de Tiled. Lo veremos en el capítulo 12.
* _BIN_: Información guardada en formato binario.

Durante los próximos capítulos, veremos cada uno de estos recursos y cómo se utilizan. En este capítulo, nos centraremos en el uso de paleta y de imágenes como recurso.

Veamos un ejemplo de definición de recurso:

```res
TILESET moontlset "moontlset.png" 0
PALETTE moontlset_pal "moontlset.png" 0
```

En el ejemplo anterior, podemos ver como se definen los recursos como TileSet y como Paleta.

**NOTA**: Si utiliza la extensión _Genesis Code_ incluye un editor con ayuda contextual a la hora de utilizar los ficheros _.res_.

Por último, es importante saber que si usamos el fichero _makefile_ que trae SGDK por defecto, se llama automáticamente a rescomp cuando se añade un fichero .res (debe insertarse en la carpeta _res_); por lo que no es necesario que la llamemos nosotros. Además, si se necesita más información acerca de rescomp, puede encontrar la documentación de este en el propio SGDK:

[https://github.com/Stephane-D/SGDK/blob/master/bin/rescomp.txt](https://github.com/Stephane-D/SGDK/blob/master/bin/rescomp.txt)

### Imágenes y Paletas con Rescomp

Como hemos podido ver, se pueden importar tanto Paletas, imágenes u otros recursos. Vamos a ver que opciones y como se define los recursos de Paleta y de Imagen.

#### Paleta

Una paleta es la información de los 16 colores que podemos almacenar para usarlo en los distintos gráficos. Es importante, que toda imagen que usemos para SGDK debe estar almacenada como indexado de 4 u 8 bpp.

**NOTA**: A partir de la versión 1.80, se podrán usar imágenes RGB con una información adicional para la paleta. Simplemente añadir en los primeros píxeles una muestra de la paleta a utilizar. Para más información, consultar la documentación de SGDK.

Para definir un recurso de paleta para rescomp; se usa la siguiente sintaxis:

```res
PALETTE pal1 "imagen.png"
```

Donde:

* _pal1_: Nombre del recurso a referenciar.
* _"imagen.png"_: Nombre de la imagen con la información de la paleta. Puede ser un fichero bmp, png o .pal.

#### Imagen

Una imagen para SGDK, contiene un tileset, una paleta y un tilemap de una imagen normalmente estática. Veamos un ejemplo con las opciones disponibles para definir un recurso de tipo imagen en rescomp:

```res
IMAGE img1 "img_file" BEST NONE [mapbase]
```

Donde:

* _img1_: nombre del recurso.
* _"Img_file"_: Fichero de la imagen a importar; Debe ser un fichero de imagen indexado en formato bmp o png.
* _BEST_: Indica el algoritmo de compresión a utilizar; puede tener los siguientes valores:
    * -1/BEST/AUTO: Usa la mejor compresión.
    * 0/NONE: No usa ninguna compresión.
    * 1/APLIB: Algoritmo aplib (buena compresión, pero más lento).
    * 2/FAST/LZ4W: Algoritmo LZ4 (menor compresión, pero más rápido).
* _NONE_: Indica la optimización que se puede realizar al importar la imagen. Puede tener los siguientes valores:
    * 0/NONE: No realiza ninguna optimización.
    * 1/ALL: Elimina los tiles duplicados y los espejados.
    * 2/DUPLICATE: Elimina solo los tiles duplicados.
* _mapbase_: Define los valores por defecto como puede ser la prioridad, paleta a usar por defecto (PAL0,PAL1,PAL2, PAL3),etc...

## Ejemplo con fondos

Una vez hemos podido ver cómo se tratan las imágenes y como importarlas usando la herramienta _rescomp_, ahora vamos a ver un ejemplo de cómo usar estas imágenes; aprovechando los dos fondos disponibles y viendo su uso de distintas prioridades.

Este ejemplo, podemos verlo en el repositorio de ejemplos que acompaña a este libro, con el nombre de _ej5.backgrounds_; el cual podemos observar que vamos a mostrar 2 fondos como los que siguen:

![Fondos para el ejemplo](8fondos/img/fondosejemplo.png "Fondos para el ejemplo")_Fondos a Usar para el ejemplo (Fuente: Open Game Art)_

Como vemos en la figura anterior, tenemos 2 imágenes; la primera un fondo azul imitando al cielo; y la segunda un fondo de baldosas amarillas con un fondo negro.

Vamos a centrarnos en esta segunda imagen; la cual vemos ese fondo negro. Este fondo, será transparente ya que será el primer color de la paleta de dicha imagen.

**NOTA**: Si utilizamos la extensión _Genesis Code_, podemos ver la paleta de dicha imagen. Si no se muestra, puede hacer click derecho en el título de la imagen y pulsar la opción _reopen With..._.

![Detalles Imagen 2](8fondos/img/bgbdetails.png "Detalles Imagen 2")
_Detalles Imagen 2_

Podemos observar en la anterior imagen, que el primer color es el negro y que es una imagen de 16 colores. Este detalle es importante ya que se usará como color transparente.

Una vez se tienen las dos imágenes, vamos a centrarnos en importar ambas imágenes usando la herramienta _rescomp_. Por lo tanto tenemos que definir un fichero _.res_ con el siguiente contenido:

```res
IMAGE bg_a "gfx/bga.bmp" NONE 
IMAGE bg_b "gfx/bgb.bmp" NONE
```

Podemos observar que se han creado 2 recursos de tipo ```IMAGE```; los cuales no tienen ninguna compresión. Si compilamos ahora nuestro proyecto de forma manual, o usando el comando de Genesis Code: _Genesis Code: Compile Project_, veremos que se generará un fichero _.h_. Este fichero lo usaremos para referenciar los recursos generados.

Una vez hemos visto cómo se han importado estos recursos, vamos a centrarnos en el código; el cual podemos ver el código fuente:

```c
#include <genesis.h>

#include "gfx.h"

int main()
{
    VDP_setScreenWidth320();    
    u16 ind = TILE_USER_INDEX;
    VDP_drawImageEx(BG_B,&bg_a,
    TILE_ATTR_FULL(PAL0,FALSE,FALSE,FALSE
        ,ind),0,0,TRUE,CPU);
    ind+=bg_a.tileset->numTile;
    VDP_drawImageEx(BG_A,&bg_b,
    TILE_ATTR_FULL(PAL1,FALSE,FALSE,FALSE
        ,ind),0,0,TRUE,CPU);
    ind+=bg_b.tileset->numTile;
    while(1)
    {
        //For versions prior to SGDK 1.60
        // use VDP_waitVSync instead.
        SYS_doVBlankProcess();
    }
    return (0);
}
```

Veamos en detalle el anterior ejemplo; en primer lugar, incluimos la cabecera de la librería LibMD (Genesis.h), seguido de la cabecera de los recursos generados con rescomp. Además, podemos observar la llamada a una función ```VDP_setScreenWidth320```; la cual establece la resolución horizontal a 320px (por defecto es esta resolución).

Seguidamente, podemos observar que se guarda en una variable el valor de ```TILE_USER_INDEX```; esta constante nos va a indicar el índice donde se va a poder acceder a la memoria donde están almacenados los Tiles. Esto es importante para no mostrar Tiles que no necesitemos en ese momento o zonas de memoria vacía que pueda dar error; ya que las primeras posiciones de la memoria de vídeo, SGDK las utiliza para inicializar las paletas etc...

**NOTA**: Si utilizas una versión de SGDK inferior a 1.80, debes usar la variable ```TILE_USERINDEX```.

A continuación, podemos ver la llamada a la función ```VDP_drawImageEx```; la cual nos permitirá dibujar una imagen dentro de un fondo; veamos cuales son los parámetros de esta función:

* _plano_: Plano a utilizar; puede tener los valores ```BG_A```, ```BG_B``` o ```WINDOW```; para indicar el plano a utilizar (para versiones anteriores a SGDK 1.60, usar ```PLAN_A```, ```PLAN_B```).
* _image_: Dirección de memoria donde está el recurso de imagen a utilizar; puede usarse el operador _&_ junto al nombre que hemos dado al recurso al definirlo en rescomp.
* _TileBase_: Indica el Tile base por el que se cargará la imagen. Esto se realizará a través de la macro ```TILE_ATTR_FULL```; que veremos más adelante.
* _X_: posición X en Tiles.
* _Y_: posición Y en Tiles.
* _loadPal_: indica si se cargará la paleta o no.
* _dma_: Indica si se usara dma o CPU. Esto es importante ya que el uso de DMA, evita que la CPU tenga que trabajar a la hora de pasar la información de la ROM a la VRAM. Por lo tanto se puede establecer el valor a ```DMA``` para usar el dma, o ```CPU``` para usar la propia CPU; hay que tener muy en cuenta que tanto la CPU como la DMA, utilizan el mismo Bus y puede haber cuellos de botella a la hora de pasar los datos de la ROM a la RAM o VRAM.

Hemos podido ver que para definir el Tile base por el que cargar la imagen, se puede utilizar la macro ```TILE_ATTR_FULL```; la cual recibe los siguientes parámetros:

* _PalIndex_: Índice de la paleta a utilizar. Puede ser ```PAL0```, ```PAL1```, ```PAL2``` o ```PAL3```. Para indicar las 4 paletas disponibles.
* _Prioridad_: Indica la prioridad por la que se cargará. ```TRUE``` para prioridad alta, o ```FALSE```; para prioridad baja.
* _VFLIP_: Espejado Vertical. Indica si estará espejado verticalmente (```TRUE``` para espejado o ```FALSE``` en caso contrario).
* _HFLIP_: Espejado Horizontal. Indica si estará espejado horizontalmente  (```TRUE``` para espejado o ```FALSE``` en caso contrario).
* _index_: Indica el índice del que se guardará en la memoria de vídeo. Se utilizará la variable de indices para almacenarlo en memoria.

Como podemos ver en el ejemplo, vemos que se carga en el Plano B el recurso llamado _bg_a_ y que se guardará en la paleta ```PAL0```; es decir, la primera paleta disponible. Además, de que estará con baja prioridad; y que se cargará usando CPU y no DMA.

Seguidamente vemos la siguiente línea:

```c
ind+=bg_a.tileset->numTile;
```

La cual actualiza el índice a utilizar para guardar en la memoria de vídeo, se aumenta el valor hasta el final de los tiles que contiene la imagen. Esto es importante para no sobrescribir la memoria de vídeo. Seguidamente vemos la segunda llamada:

```c
VDP_drawImageEx(BG_A,&bg_b,
TILE_ATTR_FULL(PAL1,FALSE,FALSE,FALSE
,ind),0,0,TRUE,CPU);
```

La cual indica que se cargará la segunda imagen en el Plano A y con baja prioridad, esta se pintará encima del plano anterior según el esquema de prioridades. Además, podemos observar que se cargará la paleta 1, y que se utilizará la CPU para cargarlo.

Por último, podemos ver que se vuelve a aumentar el índice para almacenar en la memoria de vídeo para otras imágenes posteriormente. Además de la llamada a la función ```SYS_doVBlankProcess```; para esperar a que se termine de pintar la pantalla.

Si compilamos y ejecutamos el ejemplo, podemos ver lo siguiente:

![Ejemplo5: Fondos](8fondos/img/ej5.png "Ejemplo 5: Fondos")
_Ejemplo5: Fondos_

Con este ejemplo, ya podemos ver cómo cargar imágenes usando _recomp_ y dibujarlas en los distintos planos o fondos disponibles. En los siguientes capítulos, veremos más usos de los fondos y cómo podemos usar más funcionalidades que nos provee SGDK.

## Referencias

* SGDK: [https://github.com/Stephane-D/SGDK](https://github.com/Stephane-D/SGDK).
* Danibus (Aventuras en Mega Drive): [https://danibus.wordpress.com/](https://danibus.wordpress.com/).
* Ohsat Games: [https://www.ohsat.com/tutorial/mdmisc/creating-graphics-for-md/](https://www.ohsat.com/tutorial/mdmisc/creating-graphics-for-md/).
* Manual Software Mega Drive: [https://segaretro.org/images/a/a2/Genesis_Software_Manual.pdf](https://segaretro.org/images/a/a2/Genesis_Software_Manual.pdf).
