# 15. SRAM e interrupciones

Ya estamos acercándonos a la recta final de este libro. Hemos estado revisando tanto la parte visual, como el sonido. Además de estudiar toda la arquitectura de la Sega Mega Drive, vamos a revisar un apartado importante; tanto para guardar los progresos de nuestro juego, como para manejar las distintas interrupciones que podemos utilizar a la hora de dibujar la pantalla.

En primer lugar, tenemos que saber cómo vamos a almacenar los datos y tener en cuenta que no todos los tipos de cartucho se pueden utilizar. Por otro lado, veremos el uso de funciones de interrupción para poder actualizar los recursos de nuestro juego usando dichas interrupciones.

Por último, vamos a ver un ejemplo que utilizará estas interrupciones para poder realizar dichas modificaciones y ver como optimizar nuestro juego.

## Guardar el progreso de nuestros juegos

Muchos hemos sufrido, el no poder guardar el progreso de nuestros juegos en Mega Drive; solo algunos juegos disponían de esta capacidad de poder guardar dicho progreso en el cartucho. Esto es debido a que estos cartuchos, tienen una memoria SRAM [^64] junto con una pila de botón (que tenemos que tener cuidado que no se agote tras tantos años); también había algunos tipos especiales como _Sonic 3_ que tenía un tipo de memoria especial sin necesidad de Pila.

Por ello, si necesitamos almacenar información del progreso de nuestro juego, podemos utilizar esta memoria SRAM; necesitaremos un cartucho que tenga tanto la ROM, como dicha memoria estática.

![Cartucho con SRAM](15SRAM/img/sram.png "Cartucho con SRAM")
_Cartucho con SRAM (DragonDrive)_

[^64]: SRAM: Memoria RAM estática. Es una memoria estática de acceso aleatorio; que permite una gran velocidad pero normalmente de poco tamaño.

Aunque también existe la posibilidad de crear un generador de contraseñas; de tal forma que podamos mostrar dicho código al jugador para que pueda posteriormente continuar el progreso.

### SRAM

Como hemos podido comentar, podemos almacenar información en la memoria estática de tal forma que no se pierda dicha información al apagar la consola. Para ello, necesitaremos una forma de enviar información al cartucho para almacenar dicha información en la memoria SRAM.

Gracias a SGDK, podemos almacenar esta información de manera que podamos también recuperarla. Vamos a poner un caso de uso relacionado con cómo podemos almacenar o recuperar dicha información. Supongamos el siguiente ```struct``` en C:

```c
struct{
    u8 lives;
    u8 scene;
    u32 score;
    u32 checksum
}player;
```

Donde vemos que tenemos almacenada las vidas que tiene el jugador, escena por la que va, la puntuación y por último un checksum para poder comprobar que la información almacenada es correcta. Esta información la podemos almacenar en la SRAM, usando una serie de funciones.

En primer lugar, necesitaremos activar la memoria en modo escritura usando la función ```SRAM_enable```; que activa el acceso a la memoria SRAM en modo escritura. En caso de querer acceder solo en modo lectura, podemos usar la función ```SRAM_enableRO```; que activa la memoria SRAM en modo solo lectura.

Una vez activada, podemos escribir o leer sobre la memoria. Es importante conocer que la SRAM está dividida en palabras de 8 bits; por lo que a la hora de almacenar la información tenemos que tener esto en cuenta.

Veamos qué funciones necesitaremos para almacenar el anterior ```struct```; vemos que necesitaremos almacenar 2 variables de 8 bits y dos de 32 bits. Por lo que necesitaremos 10 bytes para almacenar toda la información.

Podemos usar las funciones ```SRAM_writeByte```,```SRAM_writeWord``` o ```SRAM_writeLong``` para almacenar la información en la memoria SRAM. Veamos cada una de ellas:

La función ```SRAM_writeByte``` almacena 1 byte en la SRAM en función del Offset que indica el offset en el espacio dentro de la SRAM (recuerda que cada palabra son 8 bits). Recibe los siguientes parámetros:

* _offset_: Indica el offset con el que se almacenará.
* _value_: Indica el valor a almacenar (un byte).

La función ```SRAM_writeWord``` almacena 1 palabra (de 2 bytes) en la SRAM. Recibe los siguientes parámetros:

* _offset_: Indica el offset con el que se almacenará.
* _value_: Indica el valor a almacenar (dos bytes).

Por último, la función ```SRAM_writeLong``` escribe un entero largo (32 bits) en la SRAM. Recibe los siguientes parámetros:

* _offset_: Indica el offset con el que se almacenará.
* _value_: Indica el valor a almacenar (4 bytes).

Teniendo en cuenta las anteriores funciones, podemos crear la siguiente función para guardar el progreso.

```c
void savePlayerProgress(){

    SRAM_writeByte(0,player.lives);
    SRAM_writeByte(1,player.scene);
    SRAM_writeLong(2,player.score);
    u32 checksum= player.lives+
        player.scene+player.score;
    player.checksum=checksum;
    SRAM_writeLong(6,player.checksum);
}
```

Como podemos ver, realizaremos un checksum (de forma sencilla); sumando los valores almacenados y alimentándose en la memoria; de tal forma, que después en la lectura podamos comprobar que se ha realizado correctamente.

Vamos a ver como sería la operación inversa. Leer desde la memoria SRAM. En este caso, vamos a utilizar las siguientes funciones ```SRAM_readByte```, ```SRAM_readWord``` o ```SRAM_readLong```. Veamos cada una de estas funciones:

La función ```SRAM_readByte``` lee un byte desde la memoria SRAM. Recibe el siguiente parámetro:

* _offset_: Indica el offset con el que se leerá.

Esta función devuelve un entero de 1 byte con la información leída.

La función ```SRAM_readWord``` lee una palabra (2 bytes) desde la memoria SRAM. Recibe el siguiente parámetro:

* _offset_: Indica el offset con el que se leerá.

Esta función devuelve un entero de 2 bytes con la información leída.

La función ```SRAM_readLong``` lee un entero largo (4 bytes) desde la memoria SRAM. Recibe el siguiente parámetro:

* _offset_: Indica el offset con el que se leerá.

Esta función devuelve un entero de 4 bytes con la información leída.

Tras ver las funciones que leen desde la memoria SRAM, podemos crear una función para leer dicha información:

```c
void readGameProgress(){
    player.lives = SRAM_readByte(0);
    player.scene = SRAM_readByte(1);
    player.score = SRAM_readLong(2);
    player.checksum= SRAM_readLong(6);
}
```

Obviamente, quedaría por comprobar que el checksum leído es correcto con el cálculo de los datos del struct.

## Interrupciones

Hemos hablado de cómo utilizar la SRAM; pero ahora nos quedaría hablar de otro aspecto importante a la hora de trabajar con Sega Mega Drive.

En los ejemplos, has podido ver que hemos ido haciendo cada acción, y después hemos esperado a que termine de repintar la pantalla; debido al uso de la función ```SYS_doVBlankProcess()```, la cual gestiona el repintado de pantalla y el hardware hasta que se ha terminado de pintar completamente la pantalla.

Tenemos que tener en cuenta que esta consola está pensada para ser usada en televisores CRT; es decir, que se van pintando por cada línea  de izquierda a derecha y de arriba a abajo; por lo que en cada pasada, se debe esperar a que tanto el VDP como la televisión, acaben de pintar.

Durante este tiempo de pintado, la CPU puede estar muy ociosa; de tal forma que puede ser interesante este tiempo para poder realizar operaciones y optimizar el tiempo de la CPU; ya que si se tarda mucho en realizar todas las operaciones antes de esperar al pintado, puede ocurrir una bajada en las imágenes por segundo (50 para PAL y 60 para NTSC); por lo que es mejor optimizar el uso de la CPU.

Para ello, podemos utilizar las interrupciones; las cuales nos van a permitir ejecutar código durante estos periodos que se está terminando de pintar la pantalla. Estas interrupciones, son lanzadas por el VDP al terminar de pintar tanto un conjunto de líneas, como la propia pantalla. Veamos un esquema.

![Interrupciones Mega Drive](15SRAM/img/hblank.jpg "Interrupciones Mega Drive")
_Interrupciones Mega Drive_

Como podemos ver en el esquema, por cada vez que se pinta una línea, se lanza una interrupción _HBlank_, cuando se reposiciona para pintar la siguiente. En este tiempo, se puede utilizar para actualizar parte de nuestro código como puede ser actualizar las paletas.

Por otro lado, podemos observar que cuando se termina de pintar la pantalla, se lanza otra interrupción la _VBlank_, la cual también podemos utilizar para actualizar partes de nuestro juego como pueden ser los fondos y/o paleta; de esta forma podemos crear animaciones en los propios fondos.

Siempre has de saber, que tanto HBlank como VBLank tiene un corto periodo de tiempo para ejecutar código por lo que no podemos utilizar operaciones muy complejas. Por ello, tenemos que tener mucho cuidado a la hora de utilizar estas interrupciones.

Veamos cómo se puede utilizar cada una de estas interrupciones.

### HBlank

La Interrupción HBlank, ocurre cada vez que pinta una línea o _scanline_; aunque en muchas ocasiones no es necesario utilizar una función de interrupción por cada línea; por ello, Mega Drive dispone de un registro de interrupción ($0A), que va a actuar de contador e irá decrementándose hasta llegar a cero.

Cuando este registro llega a cero, es cuando se llamará a la función de interrupción asociada. Esto podemos controlarlo a nivel de SGDK; por lo que podemos controlar qué código ejecutaremos.

Es muy importante, tener en cuenta que el tiempo que pasa desde que se lanza la interrupción hasta que se empieza a pintar la siguiente línea, es muy corto por lo que estas funciones no pueden ser muy pesadas.

Veamos qué funciones tiene SGDK para trabajar con este tipo de interrupción.

La función ```VDP_setHIntCounter```, permite establecer el valor del contador de interrupción para que se ejecute cada X líneas hay que tener en cuenta que el contador llega hasta el valor 0 por lo que un valor de 5 será desde 5 hasta 0 (5+1); recibe el siguiente parámetro:

* _value_: Valor a establecer indicando cuantas líneas van a pintarse hasta lanzar la interrupción; si se establece a 0, será en cada línea (scanLine).

Por otro lado, la función ```VDP_setHInterrupt```, activa o desactiva la interrupción _Hblank_ de tal forma que no se lanzará la función de interrupción. Recibe el siguiente parámetro:

* _value_: se activa si es distinto de cero o se desactiva si se le pasa un cero.

Por último, para establecer la función que se utilizará para la interrupción HBlank, se usará la función ```SYS_setHIntCallback```, que recibe el siguiente parámetro:

* _CB_: Puntero a función callback será una función que no tendrá parámetros y no devuelve nada; aunque es necesario que tenga como prefijo ```HINTERRUPT_CALLBACK```. Es importante saber que esta función no puede realizar operaciones muy pesadas; aunque puede cambiar la paleta de colores (CRAM), Scroll o algún otro efecto.

**Palette Swapping**

Uno de los efectos que mucha gente se ha preguntado cómo se realiza, es el efecto "agua" en los títulos de _Sonic the hedgehog_. Este efecto de cambio de colores cuando Sonic estaba bajo el agua, se realizaba utilizando una técnica llamada _Palette Swapping_ o intercambio de paletas o colores.

Esta técnica, se basaba en el uso de los scanlines y las correspondientes interrupciones HBlank; que cambia los colores de una paleta "al vuelo" mientras se estaba dibujando la pantalla.

Esto permitía entre otros, ampliar el número de colore simultáneos por pantalla; sin embargo, esto podría dar algunos problemas al tener que estar actualizando la CRAM e incluso, cargando diferentes recursos en cada línea; dando lugar a cuellos de botella por el uso continuado del Bus tanto por la CPU, como el uso continuo del DMA.

Además, también podían aparecer los llamados _CRAM Dots_ que son algunos glitches o puntos de pantalla del intercambio al vuelo de estos colores. En Sonic, se disimulaban pareciendo las "olas" del propio agua.

A esta técnica también suele referirse como _Blast Processing_ como un término de Marketing apodado por _Sega of America_, para referirse a la capacidad superior a nivel hardware de la Sega Mega Drive. Esto era debido a que el chip VDP, era capaz de trabajar a más velocidad gracias al uso del DMA que tenía incorporado la Mega Drive.

Para más información acerca del Palette Swapping y Blast Processing, consulta las referencias de este capítulo.

### VBlank

Tras ver la interrupción horizontal, podemos ver la interrupción vertical; que ocurre cuando se termina de pintar toda la pantalla; esta interrupción es mucho mayor el tiempo que tarda en realizarse. Por ello, se puede utilizar para realizar más cambios que para las interrupciones horizontales.

Vamos a ver cómo podemos utilizar esta interrupción y las funciones que nos provee SGDK para trabajar con este tipo de interrupción. Es importante conocer, que para este tipo de interrupción es muy útil realizar todas las operaciones que están relacionadas con el VDP como actualizar los fondos o los propios Sprites.

Es muy importante tener esto en cuenta ya que realizar estos cambios en el hilo principal, es mucho más costoso; por lo que tenemos que evitar realizar estos cambios en dicho hilo.

Comenzaremos por la función ```SYS_setVBlankCallback``` que establece la función que establece la función que se ejecutará en la interrupción de _VBlank_. Esta función utiliza el tiempo que hay cuando se llama a ```SYS_doVBlankProcess``` y aprovecha el tiempo mientras se está pintando la pantalla. Recibe los siguientes parámetros:

* _CB_: puntero a la función de interrupción. Esta función no recibe ningún parámetro ni devuelve ningún dato.

También existe la función ```SYS_setVIntCallback``` que establece también la función de interrupción funcionando de igual manera que la anterior. Pero en este caso, desde que se lanza la propia interrupción y se acaba de pintar la pantalla. Recibe los siguientes parámetros:

* _CB_: puntero a la función de interrupción. Esta función no recibe ningún parámetro ni devuelve ningún dato.

### Uso eficiente de CPU y DMA

Hemos podido ver en diferentes partes de este libro, el uso de CPU o DMA ya que una de las principales mejoras de la Mega Drive, es el poder utilizar este dispositivo para enviar información desde la ROM (o RAM) hasta el VDP sin intervención de la propia CPU.

Sin embargo, hay un inconveniente y es que tanto la CPU como el DMA comparten el mismo BUS y tienen que compartirlo; por lo que si se abusa del DMA puede haber problemas de envío de información por el mismo bus. Estos problemas van desde quedarse la pantalla congelada o glitches en los distintos tiles que se están dibujando.

Hemos podido ver diferentes modos para utilizar tanto la CPU como el DMA; por lo que vamos a repasar algunos de ellos:

* ```CPU```: En este modo se utiliza el propio procesador Motorola 68000 para enviar la información sin intervenir el DMA.
* ```DMA```: En este modo se envía toda la información posible por el DMA para que sea dibujada por el propio VDP. Sin embargo, esto puede dar problemas si el bus esta ocupado por la CPU o se envía demasiada información.
* ```DMA_QUEUE```: En este modo, se utiliza una cola para enviar poco a poco la información; en este caso se utiliza la propia interrupción _VBlank_ para enviar esta información. Aunque el envío es más lento que el anterior caso, nos evitamos en todo lo posible sobrecargar el bus.
* ```DMA_QUEUE_COPY```: En este último modo, se realiza una copia de los datos y se envía a una cola. Es menos eficiente que el anterior caso, pero permite utilizar una copia de los datos en vez de los datos en sí mismos. En ocasiones puede ser mejor utilizar esta opción.

Dependiendo de las operaciones que utilicemos, puede ser útil de un modo u otro. Por ejemplo a la hora de cargar Tiles de un mapa, suele ser más eficiente utilizar la cola para el DMA.

Por otro lado, para cargar un fondo estático ó añadir un Sprite, dependerá si es una carga inicial, o se realiza al vuelo. En el caso de la carga inicial, puede ser más óptimo el utilizar la CPU; mientras que si se carga al vuelo, es más útil el usar la DMA.

Por supuesto, esto también dependerá del número de bytes que se tengan que enviar a través del bus; para operaciones pesadas, siempre es mejor utilizar la CPU como una carga inicial y después solo cambiar el mostrar o no un Sprite por ejemplo.

También otro aspecto importante, es cuando realizar estas cargas; se recomienda utilizar el tiempo de la interrupción VBlank, para realizar estos cambios. Esto suele ser útil para utilizar el tiempo más óptimo los recursos mientras se está pintando la pantalla.

Por supuesto, siempre es importante revisar la documentación de SGDK, para ver las distintas funciones y cómo se puede realizar esta transferencia de datos.

Por último, siempre es importante el uso de las distintas herramientas que tenemos disponibles a través de los emuladores para por ejemplo, poder ver las paletas o incluso cómo esta utilizándose la memoria del VDP; así se puede decidir en cada momento cuando usar CPU o DMA.

## Ejemplo con Interrupciones

Ya hemos podido ver las distintas funciones para trabajar con interrupciones; por lo que podemos pasar a realizar un ejemplo de uso con estas funciones. Puedes encontrar el ejemplo de este capítulo, en el repositorio de ejemplos que acompaña a este libro; que puedes encontrar en la siguiente dirección:

[https://github.com/zerasul/mdbook-examples](https://github.com/zerasul/mdbook-examples)

La carpeta en la que encontrarás el ejemplo es _ej16.interrupts_; en la cual encontrarás un ejemplo sencillo, en el que podremos controlar a un personaje. En este caso, vamos a cambiar la forma de interactuar con el juego.

En primer lugar, trabajaremos con una serie de variables donde almacenaremos el estado del jugador; para ello utilizaremos el siguiente ```struct```:

```c
struct{
    Sprite* sprite;
    u16 x;
    u16 y;
    u8 anim;
}player;
```

En este caso, almacenaremos el Sprite a utilizar, posición de x e y, además de la animación actual (utilizaremos una serie de constantes para establecerla). Vamos a definir las siguientes dos funciones:

```c
void vblank_int_function();
void handleInput();
```

La primera función ```vblank_int_function``` es la que utilizaremos como función para la interrupción _vBlank_ de tal forma, que la utilizaremos para actualizar la pantalla (fondos, Sprites,etc).

Por otro lado, la función ```handleInput``` utilizaremos para gestionar los controles (de forma síncrona).

Veamos el inicio de la función principal:

```c
 SYS_disableInts();
u16 ind = TILE_USER_INDEX;
VDP_drawImageEx(BG_A,&back1,
    TILE_ATTR_FULL(PAL0,FALSE,
    FALSE,FALSE,ind),0,0,
    TRUE,CPU);
ind+=back1.tileset->numTile;
player.x=30;
player.y=20;
player.anim=IDLE;
PAL_setPalette(PAL1,
    player_sprt.palette->data,CPU);
player.sprite = SPR_addSprite(&player_sprt,
    player.x,player.y,
    TILE_ATTR(PAL1,FALSE,FALSE,FALSE));
SYS_enableInts();
```

Vemos que al inicio de la inicialización, deshabilitamos las interrupciones con la función ```SYS_disableInts``` y ```SYS_enableInts``` que activa las interrupciones. Siempre es importante deshabilitar las interrupciones cuando se está cargando información (añadiendo sprites, fondos,etc).

Una vez añadido el fondo y el sprite, ya podemos activar la función de la interrupción _VBlank_; que lo realizaremos con la función ```SYS_setVBlankCallback```; estableciendo el puntero a la función.

Si revisamos la función de interrupción ```vblank_int_function```, podemos ver que se realiza en esta función:

```c
void vblank_int_function(){

    SPR_setPosition(player.sprite,player.x,player.y);
    SPR_setAnim(player.sprite,player.anim);
    SPR_update();
}
```

En esta función, vemos que se actualiza la posición del Sprite, su animación y se actualizan los Sprites. Esto se realiza en el tiempo que se termina de pintar la pantalla.

Ahora podemos pasar a revisar la función ```handleInput``` que va a gestionar los controles. Veamos un fragmento:

```c
u16 value = JOY_readJoypad(JOY_1);

if(value & BUTTON_RIGHT){
    player.anim= RIGHT;
    player.x++;
}else{
...
```

Podemos observar que se comprueba el valor leído del mando 1 (```JOY_1```), y se actualiza el estado del struct. De tal forma, que se actualizará cuando se realice la interrupción _VBlank_. De esta forma, el juego es mucho más eficiente ya que toda operación con el VDP, se puede realizar en la función de interrupción; mientras que el hilo principal, sirve para actualizar el estado a pintar.

Ahora podemos compilar y ejecutar el ejemplo, donde podemos ver como se puede mover el personaje; de esta forma es más eficiente que en otros ejemplos. Ya hemos podido ver el contenido de este capítulo; donde hemos visto dos aspectos importantes a la hora de trabajar creando juegos. Por un lado, el uso de la SRAM por si queremos almacenar el progreso del juego, y por otro lado el uso de interrupciones.

![Ejemplo 16: Interrupciones](15SRAM/img/ej16.png "Ejemplo 16: Interrupciones")
_Ejemplo 16: Interrupciones_

## Referencias

* Sega/Mega Drive Interrupts: [https://segaretro.org/Sega_Mega_Drive/Interrupts](https://segaretro.org/Sega_Mega_Drive/Interrupts).
* SGDK: [https://github.com/Stephane-D/SGDK](https://github.com/Stephane-D/SGDK).
* Danibus (github): [https://github.com/danibusvlc/aventuras-en-megadrive](https://github.com/danibusvlc/aventuras-en-megadrive).
* DragonDrive (PCM Flash): [https://dragonbox.de/](https://dragonbox.de/)
* Palette Swapping: [https://rasterscroll.com/mdgraphics/graphical-effects/palette-swapping/](https://rasterscroll.com/mdgraphics/graphical-effects/palette-swapping/)
* Blast Processing: [https://segaretro.org/Blast_processing](https://segaretro.org/Blast_processing)
