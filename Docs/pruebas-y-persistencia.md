# Pruebas y persistencia de favoritos

Este documento explica cómo guardamos los libros favoritos y cómo comprobamos las operaciones principales de OpenBooks.

## Guardado de favoritos

Utilizamos SwiftData para conservar los libros seleccionados, incluso después de cerrar la aplicación.

- `SavedBook` es el modelo que representa un favorito guardado. Conserva un identificador, título, autor, año y disponibilidad de portada.
- `SavedBooksRepository` permite consultar, guardar y eliminar los registros utilizando el contexto de SwiftData. Cumple el protocolo `FavoriteBooksStore`, que utiliza `BooksState`.
- `BooksState` mantiene los libros que mostramos en las pantallas, actualiza `isSaved` cuando cambia un favorito y prepara los errores de guardado para que la interfaz los muestre.
- `OpenBooksApp` configura el contenedor de SwiftData, crea el servicio de favoritos y se lo proporciona a `BooksState` antes de presentar las pantallas.

Al guardar un libro, comprobamos si su identificador ya existe. Si ya está registrado, no se agrega otra copia. Si ocurre un problema al guardar o eliminar, mostramos un mensaje en lugar de cambiar la interfaz como si la operación hubiera terminado correctamente.

Actualmente los identificadores de los libros locales se generan a partir del autor y del título. Cuando integremos Open Library tendremos que utilizar los identificadores que proporcione esa fuente.

## Pruebas unitarias con XCTest

Utilizamos XCTest para revisar la búsqueda y el guardado sin depender de una consulta real a Open Library.

### Búsqueda

1. Buscar «Harry Potter» devuelve los cuatro resultados de prueba correspondientes.
2. Buscar «Orgullo y prejuicio» devuelve los tres resultados de prueba correspondientes.
3. Realizar una búsqueda vacía muestra el estado sin resultados.
4. Buscar un título inexistente después de una búsqueda válida actualiza los resultados y muestra el estado sin resultados.

### Favoritos

5. Guardar un libro permite recuperarlo mediante otro contexto de SwiftData dentro de la prueba.
6. Intentar guardar el mismo libro dos veces no genera registros duplicados.
7. Eliminar un favorito hace que ya no aparezca entre los registros guardados.
8. Utilizar un índice de libro inválido no modifica los favoritos.
9. Agregar y quitar un favorito desde `BooksState` mantiene la colección y los registros sincronizados.
10. Si falla la consulta del servicio de favoritos, `BooksState` prepara un mensaje de error para la interfaz.
11. Si falla el guardado de un favorito, el estado del libro no se marca como guardado y se informa el error.

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

Todavía no realizamos consultas a Open Library. Las pruebas de búsqueda utilizan los datos de `MockBooks.swift`. También debemos seguir revisando la interfaz, la accesibilidad y el modo claro y oscuro en el simulador.
