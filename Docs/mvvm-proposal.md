# Organización de la arquitectura MVVM

Este documento explica cómo organizamos el código de OpenBooks y por qué separamos las responsabilidades. La idea es mantener las pantallas sencillas y que los datos no tengan que modificarse desde varias vistas.

---

## 1. Estructura actual del proyecto

Actualmente los archivos Swift están repartidos en carpetas según su función.

### `Models/Book.swift`

Define la información de un libro: identificador, título, autor, año, disponibilidad de portada, estado de favorito, sinopsis, género y temas. También conserva algunos campos opcionales de información original, aunque esos campos no se muestran en la ficha actual.

### `Models/SavedBook.swift`

Define los datos que se guardan localmente con SwiftData. Cada favorito conserva su identificador, título, autor, año y disponibilidad de portada. El identificador sirve para reconocer un libro y evitar que se agregue dos veces.

### `Mocks/MockBooks.swift`

Contiene los libros utilizados por ahora para mostrar la interfaz, las sugerencias y los resultados de búsqueda. Estos datos todavía no llegan desde Open Library.

### `Views/ContentView.swift`

Es la vista principal. Controla la navegación entre Inicio, Buscar, Resultados, Detalle y Mis favoritos. Mantiene `SearchViewModel` y `BooksState`, y solicita las operaciones de guardado cuando el usuario toca el botón de favoritos. No decide qué libros coinciden con la búsqueda ni realiza directamente las operaciones de SwiftData.

### `Views/HomeView.swift`

Muestra la pantalla Inicio, las sugerencias y los accesos a Buscar y Mis favoritos. También utiliza el modo claro u oscuro del sistema para mostrar la ilustración correspondiente del gato, los libros y la lámpara. El botón «Ver todo» permite consultar las demás sugerencias de prueba.

### `Views/SearchView.swift`

Muestra el campo donde escribimos una consulta. El texto está conectado a `SearchViewModel` mediante un `@Binding` y la búsqueda se ejecuta cuando el usuario presiona Enter o Buscar.

### `Views/SearchResultsView.swift`

Recibe los índices y el estado de búsqueda que ya calculó `SearchViewModel`. Muestra los libros que corresponden a esos índices o los mensajes de los distintos estados. Las vistas de carga y error están preparadas, pero aún no se activan con las consultas locales.

### `Views/BookDetailView.swift`

Muestra la portada y la información del libro. La ficha incluye autor, año de publicación, género, sinopsis y temas cuando están disponibles. El contenido se puede desplazar y el botón Agregar/Quitar de favoritos permanece visible. La vista comunica esa acción a `ContentView` mediante `onSaveOrDelete`.

### `Views/MyBooksView.swift`

Representa Mis favoritos. Utiliza la colección compartida para mostrar los libros guardados o el mensaje de lista vacía. No necesita guardar por separado otra lista de favoritos.

### `Views/Components/`

Contiene partes reutilizables de las pantallas, como las filas, las portadas, la barra inferior y el estado vacío. Así evitamos repetirlas en varias vistas.

### `ViewModels/SearchViewModel.swift`

Guarda el texto, los índices de resultados y el estado de la búsqueda. Actualmente reconoce las consultas exactas «Harry Potter» y «Orgullo y prejuicio»; las demás no devuelven coincidencias.

### `ViewModels/BooksState.swift`

Mantiene la colección de libros que comparten las pantallas. Recupera los favoritos guardados y actualiza `isSaved` cuando cambia la colección persistente.

### `Services/SavedBooksRepository.swift`

Contiene las operaciones de SwiftData para consultar, guardar y eliminar favoritos. `BooksState` las utiliza sin colocar ese código dentro de las vistas.

### `OpenBooksApp.swift`

Es el punto de entrada. Crea `ContentView` y configura el contenedor de SwiftData para `SavedBook`.

---

## 2. Separación de responsabilidades

En OpenBooks separamos tres responsabilidades principales para que sea más sencillo entender el proyecto.

### Interfaz

Las vistas muestran información y reciben las acciones del usuario. Inicio muestra sugerencias, Buscar permite escribir, Resultados presenta coincidencias y Detalle deja agregar o quitar favoritos. No es necesario que estas pantallas conozcan cómo se guarda un registro en SwiftData.

### Datos

`Book` representa los datos que necesita la interfaz. `SavedBook` representa los datos de un favorito guardado. Aunque tienen información relacionada, no cumplen la misma función: uno se utiliza para mostrar libros y el otro para conservarlos localmente.

### Estado y lógica

- `SearchViewModel` mantiene la búsqueda y determina los resultados.
- `BooksState` mantiene la colección de libros y la actualiza cuando cambian los favoritos guardados.
- `SavedBooksRepository` realiza las operaciones de guardar, consultar y eliminar mediante SwiftData.
- `ContentView` se encarga de la navegación y coordina las acciones entre las pantallas.

Esta separación evita repetir condiciones de búsqueda u operaciones de almacenamiento dentro de varias vistas.

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
Determina los resultados locales
          ↓
SearchResultsView los presenta
```

`ContentView` utiliza `@Bindable` para conectar `searchText` con `SearchView`. Cuando se presiona Enter, llama a `searchBooks()` y abre Resultados. La búsqueda todavía no consulta Open Library.

El flujo de favoritos es diferente:

```text
Usuario toca Agregar o Quitar de favoritos
          ↓
BookDetailView comunica la acción
          ↓
ContentView llama a BooksState
          ↓
SavedBooksRepository guarda o elimina con SwiftData
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
│   └── SavedBook.swift
├── Mocks/
│   └── MockBooks.swift
├── ViewModels/
│   ├── BooksState.swift
│   ├── SearchViewModel.swift
│   └── SearchViewState.swift
├── Views/
│   ├── Components/
│   ├── ContentView.swift
│   ├── HomeView.swift
│   ├── SearchView.swift
│   ├── SearchResultsView.swift
│   ├── BookDetailView.swift
│   └── MyBooksView.swift
├── Services/
│   └── SavedBooksRepository.swift
└── OpenBooksApp.swift
```

También contamos con recursos de imágenes y colores utilizados por las vistas, que cambian según la apariencia del sistema.

### Estado local y compartido

La ruta de navegación (`path`) y la sección seleccionada (`showingMyBooks`) pertenecen a `ContentView` porque son datos de navegación. `HomeView` tiene un estado local para mostrar más sugerencias.

El texto, los resultados y el estado de búsqueda pertenecen a `SearchViewModel`. Los libros y su estado de favorito se comparten mediante `BooksState`. No se necesita mantener otra copia de los favoritos en cada pantalla.

### Guardado local

`SavedBooksRepository` utiliza el contexto de SwiftData para consultar, agregar y eliminar libros guardados. `BooksState` consulta esos registros y actualiza `isSaved` en los libros que mostramos. Así, cuando se cierra OpenBooks y se vuelve a abrir, los favoritos pueden recuperarse.

---

### Cómo utilizamos los estados de SwiftUI

Para organizar la interfaz diferenciamos entre los valores que solo necesita una vista y los que deben compartirse.

**`@State` en `ContentView`**

Se utiliza para conservar la ruta de navegación, la sección principal que está abierta y las instancias de `SearchViewModel` y `BooksState`. No se trata de guardar dos veces los mismos libros: `ContentView` conserva los objetos que utilizan las demás vistas.

**`@State` en `HomeView`**

Se utiliza para mostrar u ocultar las sugerencias adicionales. Esta decisión solo afecta a Inicio, por eso no necesita estar en `BooksState`.

**`@Observable`**

Permite que `SearchViewModel` y `BooksState` comuniquen los cambios que necesita mostrar SwiftUI. Cuando cambia una búsqueda o el estado de favorito de un libro, la interfaz puede actualizarse con los datos nuevos.

**`@Binding` y `@Bindable`**

El texto escrito en Buscar pertenece a `SearchViewModel`. `ContentView` conecta ese valor mediante `@Bindable` y `SearchView` lo utiliza con `@Binding`. De esa forma, la pantalla de búsqueda no necesita crear una copia independiente del texto.

### Ejemplo de una búsqueda

Si escribimos «Harry Potter», el ViewModel selecciona cuatro índices de los libros locales y cambia el estado a contenido. `SearchResultsView` recibe esos índices y muestra los libros que corresponden.

Si escribimos una consulta diferente, establece el estado sin resultados y deja vacía la lista de índices. El resultado de una búsqueda anterior no permanece como si correspondiera a la consulta nueva.

Aunque tenemos vistas de carga y error, por ahora la búsqueda local no pasa por esos estados porque no existe una consulta de red.

### Ejemplo al guardar un libro

Cuando abrimos *1984* desde Inicio, vemos el botón Agregar a favoritos. Al tocarlo, `BookDetailView` comunica la acción a `ContentView`. Después, `BooksState` solicita el guardado a `SavedBooksRepository` y vuelve a leer los registros. Si el guardado fue correcto, la navegación abre Mis favoritos y *1984* aparece en la lista.

Si volvemos a abrir el libro desde Mis favoritos, aparece Quitar de favoritos. La eliminación sigue la misma ruta de comunicación. Al volver a entrar a la aplicación, `BooksState` consulta SwiftData para saber cuáles se encuentran guardados.

### Aspecto claro y oscuro

En Inicio, `HomeView` consulta `colorScheme` para decidir si muestra `HeroReferenceDay` o `HeroReferenceNight`. Los colores de las pantallas se toman de los recursos de color, que incluyen valores para el aspecto claro y oscuro. Esto ya está escrito en el código, pero todavía es necesario revisar en el simulador que el texto, los botones y las imágenes se vean bien en ambos modos.

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

- Consultar libros reales mediante Open Library.
- Obtener y mostrar información y portadas que vengan de esa consulta.
- Utilizar los estados de carga y error con una búsqueda real.
- Revisar de principio a fin la accesibilidad y el aspecto visual en diferentes tamaños y en ambos modos de apariencia.

Por ahora no necesitamos crear un ViewModel por cada pantalla. Preferimos mantener una organización clara con los archivos que realmente utiliza la aplicación.

---

Con esta organización, cada parte del proyecto tiene una función más clara. `SearchViewModel` resuelve las búsquedas, `BooksState` mantiene la colección compartida y `SavedBooksRepository` trabaja con SwiftData. Las vistas muestran información y comunican las acciones del usuario.

El proyecto sigue utilizando libros de prueba. La conexión a Open Library será un cambio posterior, sin necesidad de volver a concentrar toda la lógica en `ContentView`.
