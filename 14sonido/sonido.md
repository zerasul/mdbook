# 14. Música y Sonido

Por ahora, hemos estado trabajando principalmente con la parte visual; como mostrar fondos, sprites, colores ,fondos,etc. Pero un juego no está completo si no tiene su sonido. Tanto los efectos de sonido, como la música que nos haga mejorar la experiencia de juego.

Por ello, es importante conocer cómo añadir sonido a nuestro juego; desde los distintos efectos como el ataque, voz del personaje o incluso algún efecto más sofisticado. Es importante poder añadirlos y disfrutarlos una vez nuestro juego esté en marcha.

No podemos olvidar la música; ya que para muchos la banda sonora de juegos de Mega Drive, ha sido nuestra infancia y hoy en día solo con escuchar un par de acordes, ya nos transporta a aquella época. De ahí la gran importancia de la música en un videojuego.

En este capítulo, vamos a mostrar cómo la Mega Drive es capaz de reproducir sonido e incluso música y como podemos añadirla a nuestro juego y tener una mejor experiencia del mismo.

Comenzaremos hablando del sistema de sonido que trae la Sega Mega Drive, y cómo funcionan los distintos elementos que la componen. Además, hablaremos de cómo se puede crear esta música y por último, veremos algún ejemplo de cómo añadir música y sonido a nuestros juegos usando SGDK.

## Sistema de Sonido de la Sega Mega Drive

Comenzaremos hablando del Sistema de Sonido de la Sega Mega Drive; como hemos podido ver en el capítulo de la arquitectura, Sega Mega Drive, dispone de dos chips de sonido:

* Chip Yamaha YM2612; con sonido FM[^57] (6 canales).
* Chip PSG (SN76496); sonido 8 bits con capacidad de emitir 3 ondas de pulso y 1 canal de ruido. Este chip se encuentra dentro del propio VDP.

Estos dos chips, son orquestados por el procesador Zilog z80; este es quien envía o recibe la información del sonido. Ayudándose de la Ram de sonido (8Kb); a través del bus de 8 bits que conecta ambos chips.

[^57]: Sonido FM; se refiere al sonido generado a través de la variación de su frecuencia. De tal forma, que se genera una señal variando dicha frecuencia.

### Yamaha YM2612

Comenzaremos hablando del Yamaha YM2612; el cual es el chip encargado principalmente de emitir sonido FM o samples. Este chip nos permite hasta 6 canales para reproducir música o sonido.

Permite emitir hasta 5 señales FM a la vez; y una de samples aunque hay que tener cuidado a la hora de mezclar estas señales. Es importante saber que a la hora de trabajar con este chip, no se creen cuellos de botella a la hora de mezclar los sonidos o incluso que puedan mezclarse erróneamente.

### PSG

Además del chip de sonido Yamaha YM2612, la Sega Mega Drive tiene un chip de sonido para sonido 8 bits gracias al chip SN76496 de Texas Instruments[^58]  permite emitir sonido por varios canales y además, de ser el chip utilizado para emitir sonido en modo retrocompatibilidad (Master System).

[^58]: Texas Instruments es una marca registrada. Todos los derechos reservados.

Este chip permite emitir sonido por 4 canales; 3 para generación de ondas (tonos), y otro para ruido (noise). Este chip está incluido dentro del propio VDP, y permite ser utilizado junto al YM2612 como sistema de sonido para la Sega Mega Drive.

Este chip también es utilizado en otros proyectos de electrónica casera, como el proyecto Durango.

### Z80

Hemos visto los dos chips de sonido que provee la Sega Mega Drive; sin embargo, por ellos mismos no se podrían utilizar; ya que necesitan el procesador Zilog Z80, para poder ser orquestado.

Este procesador de 8 bits, tiene dos funcionalidades. La primera, dar soporte al sistema de sonido junto a 8 Kb de RAM; para orquestar los chips de sonido. Por otro lado, en modo retrocompatibilidad es el procesador principal para los juegos de Sega Master System.

Es importante conocer este procesador; ya que a la hora de trabajar con el sonido, hay que programar este a diferencia del resto de componentes, que suelen utilizar más el procesador Motorola 68000; por ello, es complicado el uso de sonido en Sega Mega Drive.

## Driver de sonido

Como hemos estado hablando, el sistema de sonido, se compone de los dos chips (Yamaha y PSG), que son orquestados por el procesador Zilog Z80; por ello, es necesario enviar la información a este procesador, y que reproduzca las distintas instrucciones para que los chips emitan el sonido pertinente.

Esto requiere conocer y programar el procesador Zilog Z80, normalmente la programación no se realiza como estamos acostumbrados en este libro usando el lenguaje de programación C. Sino que se utiliza lenguaje ensamblador para el Z80.

```asm
printc:               ; Routine print character
 ld a,c
 call dtoa2d          ; Split A register into D and E

 ld a,d               ; Print first digit in D
 cp '0'               ; Don't bother printing leading 0
 jr z,printc2
 rst 16               ; Spectrum:Print character in 'A'
```

En el fragmento anterior, vemos un poco de ensamblador para el z80 (en este caso, es para ZX Spectrum); la creación de un programa para el Z80 para orquestar los chips de sonido, es lo que comúnmente se llama Driver de sonido.

Existen varias implementaciones de Drivers para sonido para Sega Mega Drive; como puede ser GEMS [^59], MUCOM88 [^60], 4PCM, XGM o XGM2. Cada uno ha sido utilizado en varios juegos y utilizado para componer música ya que traían herramientas para ello, como por ejemplo, un tracker [^61] para componer.

[^59]: GEMS (Genesis Editor for Music and Sound effects), es un driver de sonido para Sega Mega Drive desarrollado por _Recreational Brainware_.
[^60]: MUCOM88, es un driver de sonido desarrollado por _Yuzo Koshiro_, considerado uno de los mayores compositores de música para videojuegos (compositor de la Banda sonora de Streets of Rage).
[^61]: Music Tracker, es un secuenciador para componer música de forma electrónica; ya sea con un sintetizador, o con un programa de ordenador.

### XGM

Aunque hemos nombrado varios Drivers, vamos a centrarnos en el Driver _XGM_; este driver es uno de los utilizados por SGDK y que viene por defecto. Aunque podemos utilizar otros, en este caso nos centraremos en este Driver. Fue desarrollado para usarse íntegramente con el procesador z80; por lo que podemos utilizar el Motorola 68000 para otros usos. Ha sido desarrollado para usarse con el SGDK ya que ha sido hecho por el propio _Stephane Dallongeville_ (el propio autor de SGDK).

Entre sus características, tiene:

* Solo usa Z80.
* Desarrollado solo para minimizar que la CPU tenga que decodificar el sonido.
* Permite enviar sonido FM y PSG a la vez, utilizando los canales tanto para enviar sonido o los distintos samples; pudiendo llegar hasta 13 canales de sonido (5FM + 4PCM + 4PSG).
* Permite reproducir efectos de sonido en formato PCM con 16 niveles de prioridad; esto es útil a la hora de trabajar con distintas fuentes.

### XGM2

Es importante conocer, la segunda versión de este Driver el XGM2, ha sido liberado en enero de 2024; incluido en su versión beta, en la versión 2.00 de SGDK. Este driver incluye mejoras con respecto a la anterior versión ya que tenía bastantes problemas a la hora de compilar y generar los ficheros binarios; ya que consumían mucho espacio en la ROM (20/25% de la ROM podía ser la música). Este nuevo driver, incluye las siguientes funcionalidades:

* Ejecuta 100% en el Z80 (utiliza el m68K para calcular los tiempos).
* Soporte para pausa y reproducción de música.
* Velocidad de ejecución (tempo) ajustable.
* VGM input format.
* Reduce el uso de ROM con respecto a XGM.
* Volumen ajustable para FM y PSG.
* 3 canales PCM para 8 bit.

Puedes encontrar más información sobre el driver XGM2, en la documentación de SGDK 2.00.

## Crear música y Sonido

Hemos estado hablando de los Drivers que son los encargados de dar las instrucciones al procesador Z80 para orquestar los distintos chips de sonido; pero otro aspecto muy importante, es hablar sobre cómo podemos crear la música de nuestro juego. Para ello, se suelen utilizar Trackers o secuenciadores; para crear las distintas instrucciones que después el Driver leerá y procederá a ejecutar en los chips de sonido.

Aunque muchos Drivers ya tenían integrados algunos editores, como el _GEMS_ o el _MUCOM88_. Hoy en día se utilizan programas más modernos y sofisticados para poder crear la música en nuestro ordenador de forma mucho más sencilla.

### Deflemask

En este libro, comentaremos el uso de Deflemask; que es uno de los más utilizados. Este programa nos va a permitir crear nuestra música y exportarla a los distintos sistemas. Entre sus características tiene:

* Emulación en tiempo real de los distintos Chips de sonido (entre ellos el YM2612).
* Soporte para dispositivos MIDI [^62].
* Soporte para generación de ROMS.
* Uso del formato VGM [^63] como salida.

[^62]: MIDI; estándar tecnológico que describe un protocolo, interfaz y conectores, para poder utilizar instrumentos musicales para que se comuniquen con el ordenador.
[^63]: VGM; formato de audio de música para distintos dispositivos, pensado principalmente para videojuegos.

Este programa no es Software libre y tiene un coste de 9,99$; es uno de los más utilizados para crear música, por lo que no es para nada un mal precio. Además de que hay muchísimos tutoriales por internet acerca de este software para creación musical.

![Deflemask](14sonido/img/deflemask.png "Deflemask")
_Deflemask_

## Ejemplo con música y Sonido

Tras ver cómo se compone el sistema de sonido, los Drivers y como crear el sonido.
Vamos a ver dos ejemplos; el primer ejemplo vamos a utilizar el Driver original XGM, y todas las funciones relacionadas con el mismo.

El segundo ejemplo, se va a utilizar el nuevo driver XGM2. Además, también vamos a revisar todas las funciones relacionadas con este nuevo Driver de sonido. Además, vamos a repasar cómo importar los recursos para cada uno de los ejemplos.

### XGM

Veamos el primer ejemplo que puedes encontrar en el repositorio de ejemplos que acompaña a este libro. Este ejemplo corresponde a la carpeta _ej15.musicandsound_; donde podemos encontrar tanto el código como los recursos.

En primer lugar, vamos a mostrar como se puede importar los recursos de música o los efectos de sonido; utilizando la herramienta de _rescomp_ la cual es la encargada de leer los ficheros y pasarlos a binario. Tenemos que diferenciar, que los archivos con música están en formato VGM, mientras que los ficheros con efectos de sonido, tienen formato WAV.

Comenzaremos mostrando como se puede importar un fichero VGM para utilizarlo con el driver XGM.

```res
XGM name "file" timing options
```

Donde:

* _name_: Nombre del recurso para referenciar.
* _file_: Ruta dentro de la carpeta _res_ al fichero que contiene la música.
* _timing_: Indica el tempo a cargar; dependiendo del tipo de sistema puede tener el siguiente valor:
    * -1/AUTO: (NTSC o PAL dependiendo de la información almacenada en el VGM).
    * 0/NTSC: Indica que el sistema será NTSC.
    * 1/PAL: Indica que el sistema será PAL.
* _options_: parámetros adicionales para la herramienta que importa los ficheros VGM.

Como has podido ver, se le pueden pasar más parámetros adicionales para la herramienta _xgmtool_; esta herramienta es la que se utiliza para pasar del fichero VGM, a binario. Si necesitas más información sobre _xgmtool_, puedes consultar la documentación de SGDK.

Si por otro lado queremos importar un fichero con un efecto de sonido, podemos importar un fichero Wav; con dicho sonido. Vamos a ver cómo podemos importar un fichero Wav usando _rescomp_.

```res
WAV name wav-file driver out-rate far
```

Donde:

* _name_: Nombre del recursos para referenciar.
* _wav-file_: Ruta del fichero wav dentro de la carpeta res.
* _driver_: Driver de sonido a utilizar; puede ser:
    * 0/PCM: Driver de 1 solo canal de 8 bits.
    * 1/2/2ADPCM: Driver de 2 canales a 4 bits.
    * 3/4/4PCM: 4 canales a 8 bits.
    * 5/6/XGM: 4 canales con 8 bits.
    * XGM2: Puede mezclar hasta 3 samples (8 bit) de una frecuencia de 13.3Khz o 6.65Khz mientras se reproduce música.
* _out-rate_: Rate de salida para decodificar la salida. Solo utilizado para Z80_DRIVER_PCM.
* _far_: Parámetro adicional para añadir información al final de la ROM (usado para Bank-switch).

Una vez hemos podido ver cómo se pueden importar cada uno de los recursos, vamos a mostrar que recursos de sonido vamos a importar en este ejemplo:

```res
XGM music1 "music/infiltration_phase.vgm" AUTO
XGM music2 "music/guaguas2.vgm" AUTO
WAV sound1 "sound/Explosion2.wav" XGM 
WAV sound2 "sound/Jump4.wav" XGM 
WAV sound3 "sound/Teleport4.wav" XGM
```

Donde podemos comprobar que importamos 2 ficheros .vgm, y tres efectos de audio. Puedes consultar el resto de recursos importados en la propia carpeta _res_ del ejemplo.

Una vez importados los recursos, ya podemos centrarnos en el código; este juego realizará las siguientes acciones:

* Botón A: Reproduce la música 1.
* Botón B: Reproduce la música 2.
* Botón C: Reproduce el efecto de sonido actual.
* Botón Start: Para de reproducir Sonido.
* Botón Izquierda: Selecciona el anterior efecto de sonido.
* Botón derecha: Selecciona el siguiente efecto de sonido.

Teniendo esto en cuenta, vamos a proceder a mostrar parte del código fuente:

```c
u8 sound;
const u8* sounds[3];
```

Estas dos variables globales, las usaremos para referenciar que sonido hemos recolectado y almacenar la información de los efectos de sonido.

```c
sound=1;
sounds[0]=sound1;
sounds[1]=sound2;
sounds[2]=sound3;
```

Como podemos ver se ha inicializado los tres efectos de sonido y se ha establecido la variable a 1. De tal forma que cargaremos el primer sonido por defecto.

Tras ver las variables globales y cómo las vamos a inicializar, pasaremos a revisar la función ```inputHandler```; la cual es la encargada de gestionar cada vez que pulsamos un botón en el controlador. Vamos a revisar esta función:

```c
void inputHandler(u16 joy, u16 changed,
         u16 state){

    if(joy == JOY_1){
...
```

Recordamos que esta función obtendrá los valores de los botones que se han pulsado; de esta forma, podemos comprobar una a una que botones están pulsados y realizar cada acción; vamos a ver que ocurre en cada botón:

```c
if(changed & state & BUTTON_A){

    if(XGM_isPlaying()){
        XGM_stopPlay();
    }
    XGM_startPlay(music1);         
}
```

Al pulsar el botón A, se va a parar la música anterior y se volverá a reproducir la primera melodía. Como puedes ver, se utilizan varias funciones que son propias del uso del driver XGM. Veamos estas funciones.

La función ```XGM_isPlaying```, devuelve distinto de cero si el driver XGM está reproduciendo una canción.

La función ```XGM_stopPlay```, para la reproducción de la música actual del driver XGM.

La función ```XGM_startPlay```, reproduce un recurso de música utilizando el driver XGM. Recibe por parámetro el recurso que hemos importado usando _rescomp_.

Podemos comprobar que al pulsar el botón B, ocurre lo mismo pero reproduce la segunda canción:

```c
if(changed & state & BUTTON_B){
    if(XGM_isPlaying()){
        XGM_stopPlay();
    }
    XGM_startPlay(music2);
}
```

En el caso de pulsar el botón C, se reproducirá el sonido actual; veamos el fragmento de código:

```c
if(changed & state & BUTTON_C){
    XGM_setPCM(sound,sounds[sound-1]
        ,sizeof(sounds[sound-1]));
    XGM_startPlayPCM(sound,14,
        SOUND_PCM_CH4);
}
```

Podemos observar que se utilizan dos nuevas funciones, para poder reproducir un efecto de sonido. Veamos estas funciones.

La función ```XGM_setPCM``` inicializa el sonido a reproducir utilizando el Driver XGM; recibe los siguientes parámetros:

* _id_: Identificador que tendrá este sonido.
* _sound_: Sonido a inicializar (nombre del recurso importado con rescomp).
* _length_: longitud del sonido a reproducir.

La función ```XGM_startPlayPCM``` reproduce un efecto de sonido previamente inicializado; recibe los siguientes parámetros:

* _id_: Identificador asignado en el anterior paso.
* _prioridad_: define la prioridad con la que se reproducirá el sonido puede tener un valor de entre 0 y 15; siendo 0 la menor y 15 la mayor.
* _channel_: canal a reproducir el sonido; puede seleccionar los distintos canales permitidos por el driver XGM. En este caso, ```SOUND_PCM_CH4``` indica que se utilizará el canal 4 como PCM. Consulta la documentación de SGDK, para saber todos los canales disponibles.

Una vez hemos visto que ocurre al pulsar el botón C, vamos a ver qué ocurre cuando se pulsa el botón Start.

```c
if(changed & state & BUTTON_START){
    XGM_stopPlay();
    XGM_stopPlayPCM(SOUND_PCM_CH4);
}
```

En este caso se trata de parar la reproducción tanto de la música, como del efecto de sonido que esté reproduciéndose. Para ello se utilizan dos funciones; ```XGM_stopPlay``` que para la reproducción de la música actual.

Por otro lado, la función ```XGM_stopPlayPCM```; para la reproducción del efecto de sonido que se este reproduciendo en un canal específico; recibe los siguientes parámetros:

* _channel_: canal que parará la reproducción del sonido. Tiene los mismos datos que en la anterior función. Consulta la documentación de SGDK, para saber todos los canales disponibles.

Para finalizar, al pulsar los botones izquierda o derecha, se seleccionará el anterior o siguiente efecto de sonido; pero no lo reproducirá.

```c
 if(changed & state & BUTTON_RIGHT){
    sound++;
    if(sound==4) sound=1;
}else if (changed & state & BUTTON_LEFT)
{
    sound--;
    if(sound==0) sound=3;
}
```

### XGM2

Vamos ahora a centrarnos en el nuevo Driver XGM2; para este caso, vamos a reutilizar el ejemplo anterior y cambiarlo para su uso con el Driver de Sonido XGM2. Este ejemplo se encuentra en el repositorio que acompaña a este libro, en la carpeta _ej15b.xgm2_.

**NOTA**: Necesitarás SGDK 2.00 o superior para este ejemplo.

Veamos en primer lugar, cómo importar los recursos usando _rescomp_. En este caso, vamos a utilizar un nuevo tipo de objeto, para importar la música utilizando este nuevo driver:

```res
XGM2 nombre "fichero" opciones
```

Where:

* _name_: Nombre del recurso.
* _file_: Fichero VGM; este debe encontrarse en la carpeta _res_.
* _options_: Opciones adicionales que se pueden utilizar a la hora de llamar a la nueva herramienta _xgm2tool_; incorporada en la versión SGDK 2.00.

En el caso de ficheros _WAV_, se hace de la misma forma del ejemplo anterior pero indicando el tipo de controlador como _XGM2_; por ejemplo:

```
WAV sound1 "sound/Explosion2.wav" XGM2  
```

Después de importar todos los recursos, podemos centrarnos en el código. El código es el mismo que en el ejemplo anterior; pero vamos a utilizar las nuevas funciones añadidas para utilizar el controlador de sonido _XGM2_.

Vamos a centrarnos en la función ```main```. Podemos ver dos nuevas funciones; las funciones ```XGM2_setFMVolume``` y ```XGM2_setPSGVolume```. Estas funciones controlan el volumen de los chips FM y PSG. Se trata de una nueva función añadida con el controlador de sonido XGM2.

La función ```XGM2_setFMVolume```; establece el volumen actual del sonido FM; recibe el siguiente parámetro:

* _volume_: un entero entre 0 y 100; para establecer el volumen del sonido FM.

Una vez que hemos terminado de revisar los botones y de cómo funciona cada caso, ya podemos compilar y ejecutar nuestro ejemplo. Dejamos para el lector, el poder revisar cómo mostramos la pantalla cargando una imagen y un TileSet. Si todo va correctamente, podrás ver y oír este ejemplo en el emulador.

Por otro lado, la función ```XGM2_setPSGVolume``` controla el volumen del chip PSG. Recibe el siguiente parámetro:

* _volume_: un entero entre 0 y 100; para ajustar el volumen del sonido FM.

Ahora vamos a centrarnos en la función ```inputhandler```; esta función tiene la misma funcionalidad y estructura que el ejemplo anterior. Pero ahora vamos a ver las nuevas funciones para su uso con el controlador de sonido XGM2.

Primero, vamos a ver la función ```XGM2_play```; esta función reproduce el recurso actual usando el XGM2 Sound Driver; veamos los Parámetros:

* _resource_: puntero del recurso a reproducir.

Otras funciones que podemos encontrar; puede ser ```XGM2_stop```. Esta función detiene la música actual. También podemos ver la función ```XG2_isPlaying``` que devuelve ```TRUE``` si hay música reproduciéndose o ```FALSE``` en caso contrario.

Centrémonos en las funciones de sonido PCM para el controlador de sonido XGM2. Podemos encontrar la función ```XGM2_playPCM``` reproduce un sonido PCM utilizando un canal. Veamos los parámetros:

* _resource_: Puntero del recurso a reproducir.
* _len_: Len del recurso; debe ser 256 Múltiple.
* _channel_: Canal a utilizar; puede utilizar el enum ```SoundPCMChannel``` para seleccionar el canal. Consulte la documentación de SGDK para más información.

Por último, podemos ver la función ```XGM2_stopPCM``` que detiene el sonido PCM que se está reproduciendo actualmente; esta función recibe el siguiente parámetro:

* _channel_: Canal a utilizar; puede utilizar la enumeración ```SoundPCMChannel``` para seleccionar el canal. Consulte la documentación de SGDK para más información.

Existen más funciones para utilizar con el driver de sonido XGM2; consulte la documentación de SGDK para obtener más información.

Una vez que hemos terminado de revisar los botones y cómo funciona en cada caso, podemos compilar y ejecutar ambos ejemplos (que tendrán el mismo comportamiento pero utilizando distintos drivers). Dejamos al lector que revise cómo mostramos la pantalla cargando una imagen y un TileSet. Si todo va correctamente, podrás ver y escuchar este ejemplo en el emulador.

![Ejemplo 15: Música y Sonido](14sonido/img/ej15.png "Ejemplo 15: Música y Sonido")
_Ejemplo 15: Música y Sonido_

Quiero dar las gracias a _Diego Escudero_ por dejarnos las melodías para este ejemplo.

## Referencias

* Arquitectura Mega Drive: [https://www.copetti.org/writings/consoles/mega-drive-genesis/](https://www.copetti.org/writings/consoles/mega-drive-genesis/)
* Listado de Juegos y Drivers: [http://gdri.smspower.org/wiki/index.php/Mega_Drive/Genesis_Sound_Driver_List](http://gdri.smspower.org/wiki/index.php/Mega_Drive/Genesis_Sound_Driver_List)
* GEMS: [https://segaretro.org/GEMS](https://segaretro.org/GEMS)
* MUCOM88: [https://onitama.tv/mucom88/index_en.html](https://onitama.tv/mucom88/index_en.html)
* XGM: [https://raw.githubusercontent.com/Stephane-D/SGDK/master/bin/xgm.txt](https://raw.githubusercontent.com/Stephane-D/SGDK/master/bin/xgm.txt)
* XGM2: [https://github.com/Stephane-D/SGDK/blob/master/bin/xgm2.txt](https://github.com/Stephane-D/SGDK/blob/master/bin/xgm2.txt)
* Deflemask: [https://www.deflemask.com/](https://www.deflemask.com/)
* Sound Effects (Open Game Art): [https://opengameart.org/content/sound-effects-mini-pack15](https://opengameart.org/content/sound-effects-mini-pack15)