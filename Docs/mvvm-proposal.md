# Organización de la arquitectura MVVM

Este documento explica cómo organizamos el código de OpenBooks y por qué separamos las responsabilidades. La idea es mantener las pantallas sencillas y que los datos no tengan que modificarse desde varias vistas.

---

## 1. Estructura actual del proyecto

Actualmente los archivos Swift están repartidos en carpetas según su función.

### `Models/Book.swift`

Define la información de un libro: identificador, título, autor, año, disponibilidad de portada, estado de favorito, sinopsis, género y temas. La ficha utiliza únicamente los datos que se muestran en la aplicación. Incluye el identificador de portada cuando lo proporciona Open Library.

### `Models/SavedBook.swift`

Define los datos que se guardan localmente con SwiftData. Cada favorito conserva su identificador, título, autor, año, portada y temas disponibles. El identificador sirve para reconocer un libro y evitar que se agregue dos veces.

### `OpenBooksTests/MockBooks.swift`

Contiene libros de muestra para las pruebas automatizadas. La aplicación normal obtiene las sugerencias y las búsquedas desde Open Library.

### `Views/ContentView.swift`

Es la vista principal. Controla la navegación entre Inicio, Buscar, Resultados, Detalle y Mis favoritos. Mantiene el estado de navegación y dos instancias de `SearchViewModel`: una para las sugerencias y otra para la búsqueda del usuario. Recibe `BooksState` desde el punto de entrada de la aplicación y le comunica las acciones de favoritos. No obtiene el contexto de SwiftData ni realiza operaciones de almacenamiento directamente.

### `Views/HomeView.swift`

Muestra la pantalla Inicio, los libros sugeridos que proporciona Open Library y los accesos a Buscar y Mis favoritos. Presenta carga, contenido, sin resultados o error y permite reintentar. También utiliza el modo claro u oscuro del sistema para mostrar la ilustración del gato, los libros y la lámpara. Las sugerencias se distribuyen en una cuadrícula vertical y aparecen al desplazarse hacia abajo, sin tener que abrir otra pantalla.

### `Views/SearchView.swift`

Muestra el campo donde escribimos una consulta. El texto está conectado a `SearchViewModel` mediante un `@Binding` y la búsqueda se ejecuta cuando el usuario presiona Enter o Buscar.

### `Views/SearchResultsView.swift`

Recibe los índices y el estado de búsqueda que ya calculó `SearchViewModel`. Muestra los libros que corresponden a esos índices o los mensajes de los distintos estados. Muestra los estados de carga, contenido, sin resultados y error. El mensaje de error proviene del ViewModel y se puede reintentar.

### `Views/BookDetailView.swift`

Muestra la portada y la información del libro. La ficha incluye autor, año de publicación, género, sinopsis y temas cuando están disponibles. El contenido se puede desplazar y el botón Agregar/Quitar de favoritos permanece visible. La vista comunica esa acción a `ContentView` mediante `onSaveOrDelete`.

### `Views/MyBooksView.swift`

Representa Mis favoritos. Utiliza la colección compartida para mostrar los libros guardados o el mensaje de lista vacía. No necesita guardar por separado otra lista de favoritos.

### `Views/Components/`

Contiene partes reutilizables de las pantallas, como las filas, las portadas, los botones de la barra inferior y el estado vacío. También contiene `BookColors.swift`, una extensión de `Color` que centraliza los nombres de los recursos de color. Así evitamos repetirlas en varias vistas.

### `ViewModels/SearchViewModel.swift`

Guarda el texto, los índices de resultados y el estado de la búsqueda. Realiza consultas asíncronas mediante `BookSearchService`, actualiza los resultados y administra los cuatro estados de la interfaz.

### `ViewModels/BooksState.swift`

Mantiene la colección de libros que comparten las pantallas. Recibe el servicio de favoritos mediante un protocolo, recupera los registros guardados y sus datos de presentación, actualiza `isSaved` y administra el mensaje de error del almacenamiento.

### `Services/SavedBooksRepository.swift`

Define el protocolo `FavoriteBooksStore` y su implementación `SavedBooksRepository`. El repositorio consulta, guarda y elimina favoritos con SwiftData. `BooksState` utiliza el protocolo, por lo que no depende de una implementación de almacenamiento concreta.

### `OpenBooksApp.swift`

Es el punto de entrada. Configura SwiftData, crea el servicio de favoritos y prepara el servicio de búsqueda de Open Library. Proporciona las dependencias a las vistas.

---

## 2. Separación de responsabilidades

En OpenBooks separamos tres responsabilidades principales para que sea más sencillo entender el proyecto.

### Interfaz

Las vistas muestran información y reciben las acciones del usuario. Inicio muestra sugerencias, Buscar permite escribir, Resultados presenta coincidencias y Detalle deja agregar o quitar favoritos. No es necesario que estas pantallas conozcan cómo se guarda un registro en SwiftData.

### Datos

`Book` representa los datos que necesita la interfaz. `SavedBook` representa los datos de un favorito guardado. Aunque tienen información relacionada, no cumplen la misma función: uno se utiliza para mostrar libros y el otro para conservarlos localmente.

### Estado y lógica

- `SearchViewModel` mantiene la búsqueda y determina los resultados.
- `BooksState` mantiene la colección de libros, la actualiza cuando cambian los favoritos guardados y administra los errores de almacenamiento.
- `SavedBooksRepository` realiza las operaciones de guardar, consultar y eliminar mediante SwiftData y cumple el protocolo `FavoriteBooksStore`.
- `ContentView` se encarga de la navegación y comunica las acciones de favoritos al modelo de estado, sin manejar directamente el contexto ni los errores de SwiftData.

`OpenLibraryBookSearchService` construye solicitudes, valida los códigos HTTP y decodifica JSON. Esta separación evita realizar comunicación de red u operaciones de almacenamiento dentro de las vistas.

---

## 3. MVVM aplicado a OpenBooks

### Model

Representa los datos de la aplicación. En este proyecto utilizamos `Book` y `SavedBook`.

### View

Representa lo que ve el usuario y permite interactuar con la aplicación. Por ejemplo, `HomeView`, `SearchView`, `SearchResultsView`, `BookDetailView` y `MyBooksView`.

### ViewModel

Se encarga del estado y la lógica que necesita la interfaz. `SearchViewModel` resuelve la búsqueda; `BooksState` administra el estado compartido de los libros.

El flujo de búsqueda queda así:

```text
Usuario escribe en Buscar
          ↓
SearchViewModel recibe el texto
          ↓
Consulta el servicio de Open Library mediante async/await
          ↓
Convierte los datos recibidos y actualiza los resultados
          ↓
SearchResultsView los presenta
```

`ContentView` utiliza `@Bindable` para conectar `searchText` con `SearchView`. Cuando se presiona Enter, llama a `searchBooks()` y abre Resultados. La búsqueda consulta Open Library y cambia a carga, contenido, sin resultados o error según la respuesta.

El flujo de favoritos es diferente:

```text
Usuario toca Agregar o Quitar de favoritos
          ↓
BookDetailView comunica la acción
          ↓
ContentView llama a BooksState
          ↓
BooksState utiliza FavoriteBooksStore para guardar o eliminar
          ↓
SavedBooksRepository ejecuta la operación con SwiftData
          ↓
BooksState vuelve a consultar los favoritos
          ↓
Mis favoritos refleja el cambio
```

---

## 4. Organización del proyecto

La estructura actual de archivos es:

```text
OpenBooks/
├── Models/
│   ├── Book.swift
│   ├── SavedBook.swift
│   └── OpenLibrarySearchResponse.swift
├── ViewModels/
│   ├── BooksState.swift
│   ├── SearchViewModel.swift
│   └── SearchViewState.swift
├── Views/
│   ├── Components/ (incluye BookColors.swift)
│   ├── ContentView.swift
│   ├── HomeView.swift
│   ├── SearchView.swift
│   ├── SearchResultsView.swift
│   ├── BookDetailView.swift
│   └── MyBooksView.swift
├── Services/
│   ├── SavedBooksRepository.swift
│   └── OpenLibraryBookSearchService.swift
└── OpenBooksApp.swift

OpenBooksTests/
├── MockBooks.swift
├── SearchViewModelTests.swift
├── SavedBooksRepositoryTests.swift
└── OpenLibraryResponseTests.swift
```

También contamos con recursos de imágenes y colores utilizados por las vistas, que cambian según la apariencia del sistema. Los nombres de los colores se mantienen en una extensión de `Color` para evitar repetirlos en cada pantalla.

### Estado local y compartido

La ruta de navegación (`path`) y la sección seleccionada (`showingMyBooks`) pertenecen a `ContentView` porque son datos de navegación. `HomeView` tiene un estado local para mostrar más sugerencias.

El texto, los resultados y el estado de cada consulta pertenecen a su instancia de `SearchViewModel`. Inicio realiza una consulta por tema y Buscar utiliza el texto del usuario. Los libros y su estado de favorito se comparten mediante `BooksState`. No se necesita mantener otra copia de los favoritos en cada pantalla.

### Guardado local

`OpenBooksApp` crea el contenedor y entrega el servicio a `BooksState`. `SavedBooksRepository` utiliza el contexto de SwiftData para consultar, agregar y eliminar libros guardados. `BooksState` se comunica a través de `FavoriteBooksStore` y actualiza `isSaved` en los libros que mostramos. Así, cuando se cierra OpenBooks y se vuelve a abrir, los favoritos pueden recuperarse.

---

### Cómo utilizamos los estados de SwiftUI

Para organizar la interfaz diferenciamos entre los valores que solo necesita una vista y los que deben compartirse.

**`@State` en `ContentView`**

Se utiliza para conservar la ruta de navegación, la sección principal que está abierta y las dos instancias de `SearchViewModel`. `BooksState` se crea una sola vez en `OpenBooksApp`, con el servicio de datos ya configurado, y `ContentView` recibe esa misma instancia. No se crean copias independientes de favoritos en cada pantalla.

**`@State` en `HomeView`**

Se utiliza para mostrar u ocultar las sugerencias adicionales. Esta decisión solo afecta a Inicio, por eso no necesita estar en `BooksState`.

**`@Observable`**

Permite que `SearchViewModel` y `BooksState` comuniquen los cambios que necesita mostrar SwiftUI. Cuando cambia una búsqueda o el estado de favorito de un libro, la interfaz puede actualizarse con los datos nuevos.

**`@Binding` y `@Bindable`**

El texto escrito en Buscar pertenece a `SearchViewModel`. `ContentView` conecta ese valor mediante `@Bindable` y `SearchView` lo utiliza con `@Binding`. De esa forma, la pantalla de búsqueda no necesita crear una copia independiente del texto.

### Ejemplo de una búsqueda

Si escribimos «Harry Potter», el ViewModel consulta Open Library. Los resultados se incorporan a la colección compartida y se muestran en Resultados. La cantidad de libros depende de la respuesta real.

Cuando la respuesta está vacía, establece el estado sin resultados y deja vacía la lista de índices. El resultado de una búsqueda anterior no permanece como si correspondiera a la consulta nueva.

Mientras la consulta está en curso se muestra carga. Si el servidor falla, se presenta el mensaje recibido y la opción de volver a intentar.

### Ejemplo al guardar un libro

Cuando abrimos *1984* desde Inicio, vemos el botón Agregar a favoritos. Al tocarlo, `BookDetailView` comunica la acción a `ContentView`. Después, `BooksState` solicita el guardado a través de `FavoriteBooksStore` y vuelve a leer los registros. Si ocurre un error, `BooksState` prepara el mensaje que presenta la interfaz. Si el guardado fue correcto, la navegación abre Mis favoritos y *1984* aparece en la lista.

Si volvemos a abrir el libro desde Mis favoritos, aparece Quitar de favoritos. La eliminación sigue la misma ruta de comunicación. Al volver a entrar a la aplicación, `BooksState` consulta SwiftData para saber cuáles se encuentran guardados.

### Aspecto claro y oscuro

En Inicio, `HomeView` consulta `colorScheme` para decidir si muestra `HeroReferenceDay` o `HeroReferenceNight`. Los colores de las pantallas se obtienen mediante una extensión de `Color` y sus recursos de color, que incluyen valores para el aspecto claro y oscuro. Esto ya está escrito en el código, pero todavía es necesario revisar en el simulador que el texto, los botones y las imágenes se vean bien en ambos modos.

---

## 5. Beneficios y cosas pendientes

### Lo que mejoramos

- La búsqueda tiene su lógica en `SearchViewModel`, no dentro de Resultados.
- La colección se mantiene compartida en `BooksState`.
- Las operaciones de SwiftData se realizan en `SavedBooksRepository` y no en las pantallas.
- Detalle se reutiliza desde Inicio, Resultados y Mis favoritos.
- Los componentes de interfaz se pueden reutilizar en distintas pantallas.
- La aplicación conserva favoritos entre aperturas y evita registrar dos veces el mismo libro.

### Lo que sigue pendiente

- Verificar la búsqueda remota en un dispositivo con conexión a internet.
- Revisar las consultas cuando falten datos de descripción o portada.
- Revisar de principio a fin la accesibilidad y el aspecto visual en diferentes tamaños y en ambos modos de apariencia.

Por ahora no necesitamos crear un ViewModel por cada pantalla. Preferimos mantener una organización clara con los archivos que realmente utiliza la aplicación.

---

Con esta organización, cada parte del proyecto tiene una función más clara. `SearchViewModel` resuelve las búsquedas, `BooksState` mantiene la colección compartida y `SavedBooksRepository` trabaja con SwiftData. Las vistas muestran información y comunican las acciones del usuario.

Inicio y Resultados utilizan información de Open Library y comparten la colección de libros. Los datos de muestra se mantienen solo para las pruebas, sin concentrar la comunicación HTTP en las vistas.

### Consulta remota

El endpoint es `https://openlibrary.org/search.json`. Se solicitan únicamente el identificador, título, autores, año, portada y temas, con un límite de 15 libros. No utilizamos claves privadas. La pantalla de resultados no construye URLs ni interpreta JSON.
