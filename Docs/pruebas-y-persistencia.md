# Pruebas y persistencia

OpenBooks conserva los favoritos con SwiftData y utiliza XCTest para verificar la búsqueda, la decodificación de datos y las operaciones del almacenamiento local.

## Favoritos

`SavedBook` contiene el identificador y los datos necesarios para recuperar un favorito. `SavedBooksRepository` realiza las operaciones con `ModelContext` y cumple el contrato `FavoriteBooksStore`. `BooksState` mantiene la colección que muestran las pantallas y actualiza `isSaved` después de guardar o quitar un libro correctamente.

Si un libro ya está guardado, no se crea otro registro con el mismo identificador. Si una operación falla, la aplicación presenta un aviso y evita confirmar un cambio que no llegó a guardarse.

## Pruebas XCTest

Los archivos de `OpenBooksTests/` comprueban:

- Interpretación de respuestas JSON, incluidos valores opcionales y descripciones en distintos formatos.
- Estado de carga, resultados, ausencia de coincidencias y errores de búsqueda.
- Persistencia de favoritos, control de duplicados y eliminación.
- Sincronización del estado de favoritos y actualización de los datos de las obras guardadas.

Las pruebas de búsqueda utilizan servicios controlados y las de persistencia usan un contenedor temporal de SwiftData en memoria. Así se pueden ejecutar sin alterar los favoritos personales ni depender de una respuesta real de Open Library.

Para ejecutar las pruebas, abre `OpenBooks.xcodeproj` en Xcode, selecciona el esquema **OpenBooks** y utiliza **Product → Test** (⌘U). El resultado de cada ejecución debe comprobarse en Xcode.

## Comprobación manual de las funciones

1. Abre Inicio y comprueba que las sugerencias se cargan desde Open Library.
2. Abre un libro y revisa la sección «Sobre este libro».
3. Busca un título conocido y comprueba sus resultados.
4. Abre Detalle y agrega el libro a Mis favoritos.
5. Cierra y vuelve a abrir la aplicación sin borrar sus datos.
6. Comprueba que el favorito continúa guardado y después quítalo.
7. Revisa los estados de búsqueda sin resultados y de error.
8. Comprueba la apariencia clara y oscura del sistema.

## Limitaciones

La información de los libros procede de un servicio externo; puede haber consultas lentas, sin coincidencias o con datos incompletos. Las pruebas controladas verifican la lógica interna, pero no garantizan la disponibilidad de Open Library.
