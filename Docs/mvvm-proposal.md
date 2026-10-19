# Propuesta de arquitectura MVVM

Este documento analiza la estructura actual de OpenBooks y la organización de sus responsabilidades mediante MVVM.

La intención es separar gradualmente el estado y la lógica de las vistas cuando sea necesario, sin modificar el funcionamiento de las pantallas que ya están implementadas.

## 1. Estructura actual del proyecto

Actualmente, OpenBooks está dividido principalmente en los siguientes archivos:

### `Book.swift`

Contiene el modelo `Book`, que representa la información de cada libro:

- Título.
- Autor.
- Año de publicación, cuando esté disponible.
- Disponibilidad de portada.
- Estado de guardado.

También contiene `SearchViewState`, que representa los estados de búsqueda, y `BooksState`, un objeto `@Observable` que mantiene la colección compartida de libros.

También incluye el método `toggleSaved(at:)`, encargado de cambiar el estado `isSaved` del libro seleccionado.

### `MockBooks.swift`

Contiene los datos locales utilizados para probar las pantallas y el funcionamiento del proyecto. Todavía no se realizan consultas a Open Library.

### `ContentView.swift`

Es la vista raíz de la aplicación.

Actualmente se encarga de:

- Mantener el `NavigationStack` y su ruta de navegación.
- Controlar el cambio entre Inicio y Mis libros.
- Mantener una instancia de `SearchViewModel` mediante `@State`.
- Mantener una instancia de `BooksState` mediante `@State`.
- Conectar Inicio, Buscar, Resultados, Detalle y Mis libros.
- Solicitar la búsqueda al ViewModel y navegar a Resultados.
- Solicitar a `BooksState` que guarde o elimine un libro y navegar a Mis libros.

La lógica que determina los resultados de búsqueda se encuentra en `SearchViewModel` y la modificación de `isSaved` se realiza mediante `BooksState`, evitando concentrar estas operaciones en la vista raíz.

### `HomeView.swift`

Representa la pantalla principal.

Muestra:

- El nombre de la aplicación.
- La lupa que permite abrir Buscar.
- La lista inicial de libros.
- El acceso a Mis libros.

También utiliza `NavigationLink` para abrir el detalle de un libro.

En el mismo archivo se encuentra `SearchView`, la vista donde el usuario escribe la consulta. Recibe el texto mediante `@Binding` y solicita ejecutar la búsqueda cuando se presiona Enter.

### `SearchResultsView.swift`

Representa la pantalla de resultados.

Actualmente recibe:

- Los índices de los libros seleccionados (`resultIndices`).
- La colección de libros.
- El estado actual de la búsqueda.

La vista muestra los resultados correspondientes a los índices recibidos. Ya no contiene condiciones para decidir qué libros aparecen según el texto de búsqueda.

También puede representar los estados de carga, contenido, sin resultados y error. Con los datos de prueba actuales, la búsqueda solo establece contenido o sin resultados; las vistas de carga y error están preparadas, pero no se activan.

### `ViewModels/SearchViewModel.swift`

Contiene `SearchViewModel`, definido mediante `@Observable`.

Se encarga de:

- Mantener el texto de búsqueda en `searchText`.
- Mantener el estado de la búsqueda en `state`.
- Determinar los índices de los libros que corresponden a la consulta en `resultIndices`.
- Ejecutar la lógica de búsqueda mediante `searchBooks()`.

Por ahora reconoce «Harry Potter» y «Orgullo y prejuicio» usando los libros de prueba. Para otras consultas establece el estado sin resultados. No realiza solicitudes a Open Library.

### `BookDetailView.swift`

Representa el detalle del libro seleccionado y muestra la opción de guardarlo o eliminarlo de Mis libros.

La vista solicita el cambio mediante `onSaveOrDelete`. `ContentView` recibe esa acción y llama a `booksState.toggleSaved(at:)`. De esta forma, el detalle no modifica por su cuenta la colección compartida.

### `MyBooksView.swift`

Representa la sección de libros guardados.

Recibe la colección compartida, muestra los libros con `isSaved` igual a `true` y determina cuándo presentar el estado de lista vacía.

### `OpenBooksApp.swift`

Es el punto de entrada de la aplicación y muestra `ContentView` como contenido principal.

---

## 2. Separación de responsabilidades

Dentro del proyecto existen tres tipos principales de responsabilidades:

### Interfaz

Corresponde a las vistas que muestran información y reciben las acciones del usuario.

Por ejemplo:

- `HomeView`.
- `SearchView`.
- `SearchResultsView`.
- `BookDetailView`.
- `MyBooksView`.

Su función principal es presentar información y comunicar lo que quiere hacer el usuario.

### Datos

Corresponden a la información con la que trabaja la aplicación.

El ejemplo principal es `Book`, que contiene los datos de cada libro. Actualmente esos datos provienen de `MockBooks.swift`.

### Estado y lógica

Corresponden a los valores que pueden cambiar y a las operaciones que determinan qué información se presenta.

En la implementación actual:

- `SearchViewModel` mantiene el texto, el estado y los resultados de búsqueda.
- `BooksState` mantiene la colección de libros y cambia `isSaved` mediante `toggleSaved(at:)`.
- `ContentView` mantiene la navegación y comunica las acciones a esos objetos.
- `MyBooksView` todavía revisa la colección recibida para mostrar los libros guardados y el estado vacío.

Con esto se redujeron las responsabilidades de `ContentView` y `SearchResultsView`, sin agregar capas que el proyecto todavía no necesita.

---

## 3. MVVM aplicado a OpenBooks

MVVM organiza la aplicación en tres partes principales:

### Model

Representa los datos de la aplicación.

En OpenBooks el modelo principal es `Book`. No decide cómo se muestra visualmente la información.

### View

Representa la interfaz y recibe las acciones del usuario.

En OpenBooks, las principales vistas son `ContentView`, `HomeView`, `SearchView`, `SearchResultsView`, `BookDetailView` y `MyBooksView`.

### ViewModel

Mantiene el estado y la lógica que necesita la interfaz.

En OpenBooks, `SearchViewModel` se encarga del flujo de búsqueda. `BooksState` mantiene el estado compartido y contiene la operación de guardar o eliminar libros.

De manera sencilla, el flujo de búsqueda queda así:

```text
Usuario
   ↓
Buscar (View)
   ↓
SearchViewModel (ViewModel)
   ↓
Índices de libros de prueba
   ↓
Resultados (View)
```

Cuando el usuario escribe, `SearchView` modifica `searchText` mediante `@Binding`. `ContentView` utiliza `@Bindable` para conectar ese campo con el ViewModel.

Al presionar Enter, `ContentView` llama a `searchViewModel.searchBooks()` y después navega a Resultados. La vista Resultados recibe el estado y los índices calculados, junto con los libros de `BooksState`.

---

## 4. Organización de MVVM en OpenBooks

No se considera necesario crear un ViewModel para cada pantalla ni reorganizar todas las carpetas del proyecto.

### Búsqueda: `SearchViewModel`

El ViewModel mantiene una sola fuente de verdad para el texto, el estado y los índices de resultados. Las vistas no contienen las condiciones que deciden qué libros corresponden a una búsqueda.

Los índices siguen haciendo referencia a los libros de `MockBooks.swift` disponibles en `BooksState`. Por ahora, la búsqueda no se conecta a Open Library.

### Libros guardados: `BooksState`

`BooksState` ya mantenía la colección compartida mediante `@Observable`. Ahora también tiene el método `toggleSaved(at:)`, que cambia `isSaved` del libro seleccionado.

Antes `ContentView` modificaba directamente ese valor. Ahora solamente solicita el cambio y se encarga de navegar hacia Mis libros.

No se creó un archivo `BooksViewModel.swift`. El proyecto conserva `BooksState` porque ya cumple la función de mantener y modificar el estado compartido que necesitamos en esta etapa.

### Organización actual de los archivos

```text
OpenBooks/
├── Book.swift
├── MockBooks.swift
├── ContentView.swift
├── HomeView.swift
├── SearchResultsView.swift
├── BookDetailView.swift
├── MyBooksView.swift
├── OpenBooksApp.swift
└── ViewModels/
    └── SearchViewModel.swift
```

La carpeta `ViewModels` contiene por ahora solamente `SearchViewModel.swift`. Las vistas siguen en sus archivos existentes; no se crearon carpetas adicionales para Model y View.

### Estado local y estado compartido

La ruta de navegación (`path`) y la sección activa (`showingMyBooks`) continúan en `ContentView` mediante `@State` porque corresponden a la vista raíz.

El texto, el estado y los índices de búsqueda pertenecen a `SearchViewModel`. La colección de libros y su estado de guardado pertenecen a `BooksState`.

Así evitamos tener varias copias independientes de la misma información.

---

## 5. Organización actual y posibles mejoras

### Búsqueda

`SearchViewModel` mantiene el texto, el estado y los índices de resultados de búsqueda mediante `@Observable`.

`ContentView` conserva la navegación y utiliza `@Bindable` para conectar el texto editable de `SearchView` con el ViewModel. Cuando el usuario realiza una consulta, el ViewModel determina qué libros de prueba corresponden a la búsqueda y `SearchResultsView` presenta los resultados recibidos.

De esta forma, las condiciones de búsqueda no se repiten dentro de las vistas.

### Libros guardados

`BooksState` mantiene la colección compartida mediante `@Observable` y utiliza `toggleSaved(at:)` para modificar el estado de guardado de un libro.

`ContentView` solicita esta operación a `BooksState` y conserva la responsabilidad de navegación. Las pantallas utilizan la misma colección, sin mantener copias independientes del estado de guardado.

### Beneficios

Con estos cambios:

- `ContentView` conserva la navegación sin decidir qué libros corresponden a cada búsqueda.
- `SearchResultsView` muestra los resultados que recibe y ya no repite las condiciones de búsqueda.
- `BooksState` mantiene en un solo lugar la operación para guardar o eliminar libros.
- El código se puede comprender y modificar sin concentrar toda la lógica en las vistas.

### Consideraciones

La separación también requiere identificar correctamente quién mantiene cada dato y cómo se comparte con las vistas. Por eso se utilizó un ViewModel solo donde existía una responsabilidad clara y se conservó `BooksState` para la colección.

### Posibles mejoras posteriores

La organización podrá seguir mejorándose conforme se avance en el proyecto. Por ejemplo, se podría revisar la forma en que `MyBooksView` determina qué libros mostrar o valorar si conviene separar más responsabilidades de `BooksState`.

Estos cambios se valorarán conforme crezca el proyecto y exista una necesidad concreta. La conexión con Open Library y la persistencia todavía no están implementadas.

---

## 6. Conclusión

La organización basada en MVVM se está aplicando de manera progresiva en OpenBooks.

`SearchViewModel` reúne la lógica del flujo de búsqueda y `BooksState` se encarga de modificar el estado de guardado de los libros. `ContentView` conserva la navegación y coordina las acciones entre las vistas y los objetos que mantienen el estado.

Con estos cambios el código tiene responsabilidades más claras sin modificar el funcionamiento de las pantallas que ya estaban implementadas.

La aplicación todavía no utiliza una arquitectura MVVM completa. La conexión con Open Library, la persistencia y otras funciones pendientes se incorporarán en las etapas correspondientes del proyecto.
