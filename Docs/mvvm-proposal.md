# Propuesta de arquitectura MVVM

Este documento analiza la estructura actual de OpenBooks y propone una posible organización basada en MVVM.

La intención no es implementar todavía toda la arquitectura, sino identificar qué responsabilidades podrían salir de las vistas y cómo podría organizarse el proyecto conforme continúe creciendo.

## 1. Estructura actual del proyecto

Actualmente, OpenBooks está dividido principalmente en los siguientes archivos:

### `Book.swift`

Contiene el modelo `Book`, que representa la información de cada libro:

- Título.
- Autor.
- Año.
- Disponibilidad de portada.
- Estado de guardado.

También contiene `SearchViewState`, utilizado para representar los estados de la búsqueda, y `BooksState`, que mantiene la colección compartida de libros mediante `@Observable`.

### `MockBooks.swift`

Contiene los datos locales utilizados actualmente para probar las pantallas y el funcionamiento del proyecto antes de integrar la información real de Open Library.

### `ContentView.swift`

Funciona como la vista raíz de la aplicación.

Actualmente se encarga de:

- Mantener el `NavigationStack`.
- Controlar la navegación principal.
- Mantener el texto de búsqueda.
- Mantener el estado de la búsqueda.
- Mantener el estado compartido de los libros.
- Conectar las diferentes vistas.
- Ejecutar la lógica actual de búsqueda.
- Modificar el estado de guardado de un libro.

Por esta razón, es la vista que actualmente concentra la mayor cantidad de responsabilidades.

### `HomeView.swift`

Representa la pantalla principal.

Muestra:

- El nombre de la aplicación.
- El campo de búsqueda.
- La lista inicial de libros.
- El acceso a Mis libros.

También utiliza `NavigationLink` para navegar hacia el detalle de un libro.

### `SearchResultsView.swift`

Representa la pantalla de resultados.

Recibe el texto de búsqueda, los libros y el estado actual de la búsqueda.

Puede mostrar:

- Carga.
- Contenido.
- Sin resultados.
- Error.

### `BookDetailView.swift`

Representa el detalle de un libro.

Muestra la información del libro seleccionado y permite guardarlo o eliminarlo de Mis libros.

El cambio se realiza sobre el estado compartido de los libros, evitando mantener una segunda copia independiente.

### `MyBooksView.swift`

Representa la sección de libros guardados.

Muestra los libros cuyo estado indica que están guardados y también determina si debe mostrar el estado de lista vacía.

### `OpenBooksApp.swift`

Es el punto de entrada de la aplicación y muestra `ContentView` como contenido principal.

---

## 2. Separación de responsabilidades

Dentro del proyecto existen tres tipos principales de responsabilidades:

### Interfaz

Corresponde a las vistas que muestran información y permiten que el usuario interactúe con la aplicación.

Por ejemplo:

- `HomeView`.
- `SearchResultsView`.
- `BookDetailView`.
- `MyBooksView`.

Su responsabilidad principal debería ser presentar información y comunicar las acciones del usuario.

### Datos

Corresponden a la información con la que trabaja la aplicación.

El principal ejemplo es `Book`, que representa los datos de cada libro.

### Estado y lógica

Corresponde a la información que puede cambiar y a las acciones que modifican el funcionamiento de la aplicación.

Por ejemplo:

- Texto de búsqueda.
- Estado de la búsqueda.
- Libros guardados.
- Guardar o eliminar un libro.
- Determinar qué libros deben aparecer en Mis libros.

Actualmente parte de esta lógica se encuentra dentro de las vistas, principalmente en `ContentView`.

Si una vista concentra presentación, estado y lógica al mismo tiempo, puede volverse más difícil de entender y mantener conforme crezca el proyecto.

---

## 3. MVVM aplicado a OpenBooks

MVVM divide la aplicación en tres partes principales:

### Model

Representa los datos y conceptos principales de la aplicación.

En OpenBooks, el ejemplo principal es:

- `Book`.

El Model contiene la información del libro y no se encarga de decidir cómo se presenta visualmente.

### View

Representa la interfaz y la interacción con el usuario.

En OpenBooks las principales View son:

- `ContentView`.
- `HomeView`.
- `SearchResultsView`.
- `BookDetailView`.
- `MyBooksView`.

Las vistas muestran la información y reciben las acciones del usuario.

### ViewModel

Coordina el estado y la lógica necesaria para que las vistas puedan presentar la información.

Por ejemplo, un ViewModel podría encargarse de:

- Ejecutar una búsqueda.
- Cambiar el estado de la búsqueda.
- Mantener los resultados.
- Guardar o eliminar libros.
- Determinar qué libros están guardados.

De forma general, el flujo sería:

```text
Usuario
   ↓
View
   ↓
ViewModel
   ↓
Model
```

Cuando cambia el estado, la View muestra la nueva información.

---

## 4. Propuesta para OpenBooks

No se considera necesario crear un ViewModel para cada pantalla.

Para el estado actual del proyecto, tendría sentido separar principalmente dos responsabilidades.

### `SearchViewModel`

Podría encargarse del flujo de búsqueda.

Sus responsabilidades serían:

- Mantener el texto de búsqueda.
- Mantener el estado de la búsqueda.
- Ejecutar la búsqueda.
- Mantener los resultados.
- Cambiar entre carga, contenido, sin resultados o error.

De esta forma, `HomeView` y `SearchResultsView` podrían concentrarse principalmente en mostrar la interfaz.

### `BooksViewModel`

Podría encargarse de la colección compartida de libros.

Sus responsabilidades serían:

- Mantener la colección de libros.
- Mantener una sola fuente de verdad.
- Guardar un libro.
- Eliminar un libro.
- Determinar cuáles libros están guardados.

El estado que actualmente mantiene `BooksState` podría servir como punto de partida para esta responsabilidad.

La organización propuesta sería:

```text
OpenBooks
│
├── Model
│   └── Book
│
├── View
│   ├── ContentView
│   ├── HomeView
│   ├── SearchResultsView
│   ├── BookDetailView
│   └── MyBooksView
│
└── ViewModel
    ├── SearchViewModel
    └── BooksViewModel
```

Esta estructura es solamente una propuesta para una futura refactorización.

### Estado local

Algunos datos pueden continuar perteneciendo a la vista raíz, por ejemplo:

- La ruta del `NavigationStack`.
- La selección entre Inicio y Mis libros.

Estos datos están directamente relacionados con la navegación principal.

### Estado compartido

Otros datos necesitan ser utilizados por diferentes vistas:

- Texto y estado de búsqueda.
- Resultados de búsqueda.
- Colección de libros.
- Estado de guardado.

Estos datos deben mantener una sola fuente de verdad para evitar que diferentes pantallas tengan valores distintos.

---

## 5. Primeros cambios propuestos

Si posteriormente se comienza a aplicar MVVM, los primeros cambios podrían ser:

1. Sacar de `ContentView` la lógica relacionada con la búsqueda y colocarla en `SearchViewModel`.

2. Organizar la colección compartida y la lógica de guardar o eliminar libros dentro de `BooksViewModel`.

3. Simplificar `MyBooksView` para que reciba la información que necesita mostrar sin encargarse de toda la lógica relacionada con la colección.

No sería necesario mover la parte visual de las vistas.

Elementos como layouts, botones, textos, imágenes, modifiers y `NavigationLink` pueden continuar dentro de las View.

### Beneficios

Esta propuesta permitiría:

- Reducir responsabilidades dentro de `ContentView`.
- Mantener las vistas más enfocadas en la interfaz.
- Organizar mejor la lógica de búsqueda.
- Mantener clara la lógica de libros guardados.
- Conservar una sola fuente de verdad.

### Complejidad adicional

También agregaría cierta complejidad:

- Existirían más archivos.
- Sería necesario decidir correctamente dónde vive cada estado.
- Las View tendrían que comunicarse con sus ViewModel.

Por esta razón, solamente se proponen los ViewModel que actualmente tienen una responsabilidad clara dentro del MVP.

---

## 6. Conclusión

OpenBooks ya cuenta con sus principales pantallas separadas, navegación mediante SwiftUI y un caso de estado compartido para los libros guardados.

Sin embargo, `ContentView` comienza a concentrar responsabilidades relacionadas con navegación, búsqueda y estado compartido.

Una propuesta basada en MVVM permitiría separar gradualmente estas responsabilidades.

`Book` continuaría representando los datos, las View se concentrarían principalmente en mostrar la interfaz y los ViewModel podrían coordinar la búsqueda y la colección compartida de libros.

Por el momento no es necesario implementar toda esta arquitectura.

La propuesta sirve como guía para los siguientes cambios del proyecto y permite identificar con claridad qué responsabilidades podrían salir de las vistas.