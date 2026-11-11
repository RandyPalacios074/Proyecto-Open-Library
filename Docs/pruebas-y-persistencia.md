# Pruebas y persistencia de favoritos

Este documento explica cómo guardamos los libros favoritos y cómo comprobamos las operaciones principales de OpenBooks.

## Guardado de favoritos

Utilizamos SwiftData para conservar los libros seleccionados, incluso después de cerrar la aplicación.

- `SavedBook` es el modelo que representa un favorito guardado. Conserva un identificador, título, autor, año y disponibilidad de portada.
- `SavedBooksRepository` permite consultar, guardar y eliminar los registros utilizando el contexto de SwiftData. Cumple el protocolo `FavoriteBooksStore`, que utiliza `BooksState`.
- `BooksState` mantiene los libros que mostramos en las pantallas, actualiza `isSaved` cuando cambia un favorito y prepara los errores de guardado para que la interfaz los muestre.
- `OpenBooksApp` configura el contenedor de SwiftData, crea el servicio de favoritos y se lo proporciona a `BooksState` antes de presentar las pantallas.

Al guardar un libro, comprobamos si su identificador ya existe. Si ya está registrado, no se agrega otra copia. Si ocurre un problema al guardar o eliminar, mostramos un mensaje en lugar de cambiar la interfaz como si la operación hubiera terminado correctamente.

Los libros simulados de XCTest conservan identificadores derivados de autor y título. Los resultados remotos utilizan la clave estable de cada obra de Open Library. Al guardar un favorito remoto también conservamos su portada y temas disponibles.

## Pruebas unitarias con XCTest

Utilizamos XCTest para revisar las respuestas JSON, la búsqueda y el guardado sin depender de una consulta real a Open Library. Los escenarios de éxito, error y resultados vacíos se prueban con servicios simulados.

### Búsqueda

1. Una consulta válida obtiene libros del servicio simulado y muestra contenido.
2. Una respuesta sin libros muestra el estado sin resultados.
3. Un error del servicio muestra un mensaje y permite volver a consultar.
4. Una consulta vacía no genera resultados.
5. Una consulta nueva reemplaza los resultados anteriores.
6. Repetir la misma consulta no duplica libros en la colección.
7. La decodificación JSON interpreta título, autores, año, portada y temas.
8. Si faltan datos opcionales, los modelos pueden decodificarse.
9. Una respuesta JSON sin documentos se interpreta como una lista vacía.

### Favoritos

10. Guardar un libro permite recuperarlo mediante otro contexto de SwiftData dentro de la prueba.
11. Intentar guardar el mismo libro dos veces no genera registros duplicados.
12. Eliminar un favorito hace que ya no aparezca entre los registros guardados.
13. Utilizar un índice de libro inválido no modifica los favoritos.
14. Agregar y quitar un favorito desde `BooksState` mantiene la colección y los registros sincronizados.
15. Si falla la consulta del servicio de favoritos, `BooksState` prepara un mensaje de error para la interfaz.
16. Si falla el guardado de un favorito, el estado del libro no se marca como guardado y se informa el error.
17. Un libro obtenido de Open Library se recupera de SwiftData con su identificador, portada y temas.

Las pruebas de SwiftData utilizan una configuración temporal en memoria y los errores del servicio se comprueban con un servicio simulado. Así podemos comprobar sus operaciones sin modificar la colección de una persona que utilice la aplicación.

## Comprobación al cerrar y reabrir

Además de las pruebas unitarias, revisamos el siguiente recorrido en un simulador de iOS:

1. Abrir OpenBooks y agregar *1984* a Mis favoritos.
2. Confirmar que aparece en la colección.
3. Cerrar OpenBooks por completo.
4. Volver a abrir la aplicación sin borrar sus datos.
5. Entrar a Mis favoritos y comprobar que *1984* continúa guardado.
6. Quitar el favorito y comprobar que la colección queda vacía.

Este recorrido permite distinguir entre un favorito que solamente permanece durante la navegación y uno que realmente se recupera después de cerrar la aplicación.

## Pendientes

La búsqueda normal ya consulta Open Library mediante HTTPS. Falta confirmar el comportamiento en un dispositivo real y completar la revisión de accesibilidad. La cantidad y disponibilidad de datos dependen de la API externa.
