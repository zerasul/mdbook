docker  run --rm -v "%CD%":/data pandoc/core -f gfm -t epub3 1introduccion/agradecimientos.md 1introduccion/second.md 1introduccion/introduccion.md 2historia/historia.md 3Arquitectura/arquitectura.md 4SGDK/sgdk.md 5config-entorno/config-entorno.md 6holamundo/holamundo.md 7controles/controles.md 8fondos/fondos.md 9Sprites/sprites.md 10Fisicas/fisicas.md 11Paletas/paletas.md 12TileSets/TileSets.md 13Scroll/scroll.md 14sonido/sonido.md 15SRAM/sram.md 16Debug/debug.md --toc --toc-depth=2 --metadata-file=title.txt --css=styles.css -o mdbook.epub