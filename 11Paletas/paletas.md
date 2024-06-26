# 11. Paletas de Colores

No podemos hablar de la Sega Mega Drive y su desarrollo, si no hablamos de los colores y cómo se manejan por este sistema. Hasta ahora hemos estado hablando de las paletas y cómo las podemos manejar a la hora de tratar con los planos o los distintos sprites en los distintos ejemplos que hemos estado mostrando.

En este capítulo, vamos a mostrar los distintos colores que puede manejar la Mega Drive; así como almacenarlos en las distintas paletas que se dispone a nivel de hardware. Además, vamos a mostrar como realizar distintos efectos como transparencias o destacar algún color con respecto al fondo, gracias a los colores _HighLight_ y _Shadow_.

Por último, veremos un ejemplo donde manejaremos los distintos efectos y además, veremos algunas funciones avanzadas relacionadas con el pintado de pantalla que nos va a ayudar a añadir mayores efectos.

## Color en Sega Mega Drive

Hasta ahora hemos comentado, que Sega Mega Drive, puede mostrar hasta 64 colores en pantalla (en realidad 61 sin contar colores transparentes). Esto es debido a que Sega Mega Drive, trabaja siempre con paletas de colores de 16 colores y que solo se disponen de 4 paletas.

Sin embargo, no hemos podido ver cuantos colores en total puede mostrar Sega Mega Drive. Sega Mega Drive almacena los colores en una paleta de colores de 9 bits RGB. Esto quiere decir, que puede mostrar los 512 colores que es capaz de manejar Sega Mega Drive. Pero recordamos que solo podremos ver 64 colores por pantalla debido a las 4 paletas de 16 colores.

![Paleta de Colores](11Paletas/img/RGB_9bits_palette.png "Paleta de Colores")
_Paleta de Colores (Fuente: Wikipedia)_

Como podemos ver en la anterior imagen, se muestran los distintos colores que es capaz de mostrar la Sega Mega Drive. Esto es importante tenerlo en cuenta; ya que a la hora de trabajar los distintos gráficos, debemos saber a qué color corresponde en Sega Mega Drive si estamos trabajando con RGB desde nuestro equipo de desarrollo.

En el caso de que el color con el que estamos trabajando no corresponda a un color para la Sega Mega Drive, SGDK transformará este color al más aproximado.

Además, SGDK trae funciones y macros para trabajar con distintos colores. Por ejemplo:

```c
u16 vdpRedColor = 
    RGB8_8_8_TO_VDPCOLOR(255,0,0)

```

La macro ```RGB8_8_8_TO_VDPCOLOR```, permite transformar un color RGB definido por 3 parámetros (rojo, verde, azul) al color equivalente para VDP. Cada uno de los parámetros tiene un valor de 0 a 255. Esto puede ser interesante para modificar colores del entorno o hacer algún efecto con el mismo.

También existen equivalentes en otros formatos:

* ```RGB24_TO_VDPCOLOR```: Transforma un color en formato RGB 24 bits a VDP.
* ```RGB3_3_3_TO_VDPCOLOR```: Transforma un color en formato RGB (r,g,b) a VDP. Donde cada componente tiene un valor de 0 a 7.

Obviamente, es importante saber que a la hora de trabajar con los colores y paletas usando SGDK, normalmente se importa la información de la paleta junto con la información de los gráficos. Por ello, es importante que para ahorrar colores y no tener que estar cambiando la paleta; se reutilice la paleta para distintos gráficos.

Si durante el juego tenemos que cambiar la paleta y cargar distintos gráficos, esto puede ocasionar cuellos de botella ya que la información debe pasar de la ROM a la VRAM ya sea a través de CPU, o usando DMA. Usando cualquiera de estas alternativas, podemos generar dicho cuello de botella ya que comparten el bus.

## HighLight & Shadow

Hemos podido ver cómo trabajar con los distintos colores que nos provee la Sega Mega Drive. Usando las distintas paletas que tenemos disponibles, podemos trabajar con hasta 64 colores en pantalla. Sin embargo, este número es ampliable gracias entre otros al uso de HighLight y Shadow.

El uso de estos modos, permite ampliar el número de colores en pantalla; modificando el brillo de la paleta, de dos modos:

* _HighLight_: Aumenta el brillo al doble, mostrando colores más llamativos.
* _Shadow_: Disminuye el brillo a la mitad, mostrando colores más oscuros.

De esta forma, puede aumentar el número de colores y mostrar distintos efectos como puede ser el destacar un personaje u oscurecer una zona.

![Modos HighLight y Shadow](11Paletas/img/paletas.png "Modos HighLight y Shadow") _Modos HighLight y Shadow_

**NOTA:**  Para aquellos que tengan la versión de este libro en escala de grises, podrán ver este y otros ejemplos en el repositorio de código fuente que acompaña este libro a todo color.

Podemos ver en la imagen anterior, como la misma paleta de colores puede estar en modo HighLight o modo Shadow ampliando el número de colores a poder mostrar con solo una paleta. Sin embargo, estos colores no son siempre ampliables por tres (es decir, que de 16 colores pasa a 48). Sino que depende de varios casos, se mostrarán más o menos colores.

En este apartado, vamos a mostrar cómo trabajan estos modos en la Sega Mega Drive. Ya que dependiendo de lo que se va a mostrar y de la prioridad del mismo, se tiene un comportamiento u otro. Vamos a ver cómo se comportan estos modos en planos y Sprites.

Para activar el modo HighLight/Shadow, puede usarse la función ```VDP_setHilightShadow``` la cual se indica si se activa o no. Recibe por parámetro con valor 1 o 0. Por ejemplo:

```c
VDP_setHilightShadow(1);
```

Vamos a ver cómo se comporta esta función al activarla en Planos o Sprites.

### Planos

A la hora de trabajar con planos, no se puede acceder al modo HighLight; ya que está preparado para Sprites. Sin embargo, si podemos acceder a los colores de los otros dos modos. Teniendo en cuenta las siguientes características:

* Si los Tiles tienen prioridad, se mostrará con los colores normales.
* Si los Tiles no tienen prioridad, se mostrará el modo shadow.
* Si un Tile con prioridad se solapa con otro sin prioridad, se mostrarán con el color normal.

### Sprites

Cuando se trabaja con Sprites, tenemos que tener en cuenta las siguientes características:

* Si la paleta utilizada es una de las 3 primeras, (```PAL0```, ```PAL1```, ```PAL2```), se comportará igual que los planos (con prioridad color normal, sin prioridad Shadow).
* Si la paleta utilizada es la cuarta (```PAL3```), tenemos que tener en cuenta los siguientes casos:
    * Si el fondo del Sprite tiene color Normal:
        * Los colores 14 y 15 de la paleta se mostrarán en modo _HighLight_.
        * El resto de colores se mostrarán normales.
    * Si el fondo del Sprite tiene color Shadow:
        * El color 14 de la paleta se mostrará en modo normal.
        * El color 15 de la paleta no se mostrará. Esto nos puede ayudar a simular transparencias.

Además, para los Sprites en modo Shadow se mostrarán sólo los píxeles del fondo más oscurecidos. Esto nos puede ayudar a simular sombras. Veremos más adelante en los ejemplos como realizar estos efectos.

Es importante saber que a la hora de trabajar con estos modos, puede cambiar el comportamiento dependiendo del emulador a utilizar. Por lo que puede ser interesante probarlo en hardware real; además de probarlo en algún emulador como _Blastem_ o _Kega Fusion_.

## Manejo de Paletas y colores en CRAM

Otro aspecto a tener en cuenta, es a la hora de trabajar con los distintos colores y cómo podemos manejar los distintos colores almacenados en la CRAM (Color RAM).

En este apartado, vamos a mostrar algunas funciones útiles que posteriormente usaremos en un ejemplo.

Es importante saber que el contenido de las 4 paletas se almacena en la CRAM y que puede ser accedida por un índice, desde el 0 al 63. Para acceder, podemos hacerlo a través de la función ```PAL_getColor```. La cual recibe el siguiente parámetro:

* _index_: índice de 0 a 63 para acceder al color de la CRAM.

Esta función devuelve el valor RGB del color que hay en dicha posición de la CRAM.

También se puede establecer el color que hay en una posición en concreto. En este caso se usará la función ```PAL_setColor``` la cual recibe los siguientes parámetros:

* _index_: Índice de la CRAM (0 a 63), para poder establecer el color a sustituir.
* _value_: Valor RGB del color a utilizar. En este caso, se pueden utilizar las funciones ```RGB8_8_8_TO_VDPCOLOR``` o similar, para establecer el valor del color.

Un aspecto a tener en cuenta, es que estas funciones modifican el valor de la CRAM que se encuentra junto al VDP; por lo tanto, el valor del color debe escribirse y si se utiliza tanto la CPU, como el DMA tenemos que tener en cuenta que puede haber un cuello de botella.

Puedes encontrar más información acerca de las funciones para modificar los colores de la CRAM tanto por CPU como por DMA, dentro de la propia documentación del SGDK.

### VDP Color Ramp

Como hemos visto, Mega Drive trabaja con una paleta de 9 bits RGB; sin embargo, para poder trabajar con los diferentes colores que nos permite proveer, no podemos cambiar estos colores linealmente: al contrario como puede ocurrir en otros ámbitos.

Hemos podido ver que una escala para cada canal va de 0 a 255; pero no podemos ir cambiando en Mega Drive cada color unidad a unidad; esto es debido al llamado _"VDP Color Ramp"_.

El _VDP Color Ramp_ principalmente es debido a los propios componentes electrónicos que componen el VDP. En el VDP, se tiene para cada canal (R,G y B) un DAC; el cual establece una escala entre 0 y 1V (0-255) pero no de forma lineal. Además, esta escala cambia si está en modo Shadow o Highlight(También cambia en el modo de retrocompatibilidad de Master System).

**NOTA**: Un DAC (_Digital Analog Converter_), es un componente electrónico que pasa una señal digital (0 o 1) a un valor analógico utilizando una escala de voltajes.

Podemos ver en la siguiente tabla; que muestra una aproximación de estos valores, dependiendo del valor que se establezca en la CRAM:

| Valor CRAM | Normal | Shadow | Highlight |
|------------|--------|--------|-----------|
|      0     |    0   |    0   |    130    |
|      2     |   52   |   29   |    144    |
|      4     |   87   |   52   |    158    |
|      6     |   116  |   70   |    172    |
|      8     |   144  |   87   |    187    |
|      A     |   172  |   101  |    206    |
|      C     |   206  |   116  |    228    |
|      E     |   255  |   130  |    255    |

_Tabla 7: Valores para color utilizados por el VDP (Fuente: Plutiedev)_

También es importante mencionar, que este comportamiento también cambia dependiendo del modelo o revisión del VDP que integra cada Mega Drive. Por eso es importante probar en diferentes modelos de Mega Drive.

## Ejemplo con Efectos de Shadow y Paletas

En este capítulo hemos estado trabajando con las paletas de colores y los efectos que podemos hacer en ellas. Por ello, en el ejemplo que vamos a estudiar usaremos las distintas paletas de colores y su correspondientes efectos Shadow.

En este ejemplo, vamos a utilizar las características de la prioridad. Para poder simular un efecto de luces; simulando en este caso, la luz de unas farolas y ver cómo afecta a los distintos Sprites con las distintas características que pueda tener.

El ejemplo que vamos a estudiar llamado _ej8.colors_, lo puedes encontrar en el repositorio de ejemplos que acompaña a este libro. Recordamos que dicho repositorio; lo puedes encontrar en la siguiente dirección:

[https://github.com/zerasul/mdbook-examples](https://github.com/zerasul/mdbook-examples)

En este caso, vamos a mostrar un fondo que hemos generado nosotros usando distintos recursos que hemos encontrado por Internet; puedes ver dichos recursos y dar crédito a los autores en las referencias de este capítulo. Veamos el fondo que vamos a mostrar:

<div class="centered_image">
<img src="11Paletas/img/fondo1.png" title="Fondo Ejemplo" alt="Fondo Ejemplo"/>
<em>Fondo Ejemplo (Fuente: Open Game Art)</em>
</div>

Como podemos ver en la imagen, vemos un paisaje nocturno donde podemos observar 3 farolas. La idea del ejemplo, es mostrar que debajo de cada farola haya un haz de luz pero fuera de estas se note un color más oscuro. Este efecto lo podemos realizar usando un mapa de prioridad.

Esto se puede realizar usando otra imagen con las zonas que queremos iluminar; de esta forma, al poner ambas imágenes se mostrarán las zonas que estén pintadas en la segunda imagen; más claras que las que no, utilizando el efecto Shadow.

Veamos la imagen del mapa de prioridades:

<div class="centered_image">
<img src="11Paletas/img/fondo2.png" title="Mapa Prioridad" alt="Mapa Prioridad"/>
<em>Mapa Prioridad</em>
</div>

Como vemos en esta imagen, las zonas marcadas serán las que se mostrarán más claras que las que están de color negro; que coinciden con la posición de las farolas del primer fondo. Este efecto es debido a que a nivel de plano, los tiles con prioridad se mostrarán de forma normal; mientras que los Tiles que estén pintados sin prioridad, tendrán el efecto shadow; de ahí que tenga el efecto de iluminación. Veamos cómo se realiza este efecto a nivel de código para establecer la prioridad solo de las zonas que están marcadas.

Cada fondo se carga usando un fichero _.res_ con la definición de ambas imágenes:

```res
IMAGE bg_color1 "gfx/fondocolor1.png" NONE
IMAGE bg_prio "gfx/fondocolor2.png" NONE
```

En el código fuente, puedes encontrar la función ```drawPriorityMap```, la cual nos va a dibujar en el plano A el mapa de prioridades, a partir de la segunda imagen. Este recibe la imagen que contiene las prioridades por parámetro; veamos un fragmento con la función:

```c
    u16 tilemap_buff[MAXTILES];
    u16* priority_map_pointer=&tilemap_buff[0];

    for(int j=0;j<MAXTILES;j++)tilemap_buff[j]=0;

    u16 *shadow_tilemap = bg_map->
          tilemap->tilemap;
    u16 numTiles = MAXTILES;
    while(numTiles--){
        if(*shadow_tilemap){
            *priority_map_pointer |= 
                TILE_ATTR_PRIORITY_MASK;
        }
        priority_map_pointer++;
        shadow_tilemap++;
    }
    VDP_setTileMapDataRectEx(BG_A,
    &tilemap_buff[0],0,0,0,
    MAP_WITH,MAP_HEIGHT,MAP_WITH,CPU);
```

En primer lugar, podemos observar cómo se inicializa a vacío un buffer que utilizaremos para dibujar la imagen; posteriormente, vamos a ir recorriendo cada Tile del mapa de prioridad, y comparándola con una máscara especial.

La máscara ```TILE_ATTR_PRIORITY_MASK```; permite almacenar en cada Tile, sólo la información de prioridad; de tal forma que no se mostrará nada por pantalla; esto es importante para poder mostrar el fondo de atrás con los distintos efectos.

Una vez se ha rellenado el mapa de prioridades, se pinta en el plano A, usando la función ```VDP_setTileMapDataRectEx```; la cual nos va a permitir dibujar un rectángulo como mapa de Tiles por pantalla.

Tras haber dibujado este mapa, podemos dibujar el otro fondo de la forma que ya conocemos; pero sin prioridad:

```c
VDP_drawImageEx(BG_B, &bg_color1,
    TILE_ATTR_FULL(PAL0,FALSE,FALSE,
    FALSE,index),0,0,TRUE,CPU);
```

Vemos como esta imagen la dibujamos en el plano B sin prioridad y usamos la paleta 0.

Además en este caso, vamos a mostrar un Sprite que dibujaremos sin prioridad, y que podemos mover a la izquierda o a la derecha. Además de que se utilizará la paleta 1.

```c
 zera = SPR_addSprite(&zera_spr,
        zera_x,
        zera_y,
        TILE_ATTR(PAL1,FALSE,FALSE,FALSE));
```

Por último y más importante, tenemos que activar el modo Shadow HighLight; usando la función ```VDP_setHilightShadow```, estableciendo el valor a 1.

```c
    VDP_setHilightShadow(1);
```

Si todo ha ido bien, podemos ver una imagen parecida a esta:

![Ejemplo 8: Colores y Shadow](11Paletas/img/ej8.png "Ejemplo 8: Colores y Shadow")
_Ejemplo 8: Colores y Shadow_

Como vemos en la imagen, en cada farola se muestra una parte iluminada; esto es debido a que dichas zonas se están pintando Tiles con Prioridad; de tal forma que se muestran de forma normal; el resto de Tiles que no tienen prioridad, se muestran en modo Shadow. Con ello, confirmamos que el comportamiento con los planos.

También vemos que a nivel de Sprite, si vamos moviendo a nuestro personaje, es afectado también por el modo Shadow; de esta forma podemos dar la sensación de una iluminación que es afectada por nuestro personaje. Obviamente, podemos trabajar también con el modo _HighLight_, usando la Paleta 3, y jugando con los colores 14 y 15. Pero eso lo podemos ver en ejemplos más adelante.

Con este ejemplo, ya hemos podido ver cómo funcionan las paletas de colores y los modos _Shadow_ y _HighLight_.

## Referencias

* Paleta de Colores Mega Drive: [https://en.wikipedia.org/wiki/List_of_monochrome_and_RGB_color_formats#9-bit_RGB](https://en.wikipedia.org/wiki/List_of_monochrome_and_RGB_color_formats#9-bit_RGB)
* VDP Color Ramp: [https://plutiedev.com/vdp-color-ramp](https://plutiedev.com/vdp-color-ramp)
* Danibus (Aventuras en Mega Drive): [https://danibus.wordpress.com/2019/09/13/14-aventuras-en-megadrive-highlight-and-shadow/](https://danibus.wordpress.com/2019/09/13/14-aventuras-en-megadrive-highlight-and-shadow/)
* Open Game Art (Night Background): [https://opengameart.org/content/background-night](https://opengameart.org/content/background-night)
* Open Game Art (Nature TileSet): [https://opengameart.org/content/nature-tileset](https://opengameart.org/content/nature-tileset)
