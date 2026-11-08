# Diseño de navegación y estado

Este documento explica cómo organizamos la navegación de OpenBooks, qué información utiliza cada pantalla y dónde se guarda el estado. También incluye cómo se recuperan los favoritos con SwiftData cuando volvemos a abrir la aplicación.

La idea es que cada dato tenga un lugar definido y no tengamos varias copias que puedan mostrar información diferente.

---

## 1. Mapa de navegación

Los flujos principales de OpenBooks son:

- Inicio → lista de libros → Detalle del libro.
- Inicio → Buscar → Resultados → Detalle del libro.
- Resultados → Buscar → Resultados.
- Mis favoritos → libro guardado → Detalle del libro.
- Mis favoritos → Buscar → Resultados.

A partir de esos flujos, el mapa de navegación propuesto es:

```text
OpenBooks
│
├── Inicio
│   │
│   ├── Seleccionar un libro
│   │   └── Detalle del libro
│   │       ├── Regresar → Inicio
│   │       └── Agregar a favoritos → Mis favoritos
│   │
│   ├── Tocar lupa
│   │   └── Buscar
│   │       └── Escribir búsqueda y presionar Enter
│   │           └── Resultados
│   │               ├── Carga
│   │               ├── Contenido
│   │               │   └── Seleccionar un libro
│   │               │       └── Detalle del libro
│   │               │           ├── Regresar → Resultados
│   │               │           └── Agregar a favoritos → Mis favoritos
│   │               ├── Sin resultados
│   │               └── Error
│   │
│   └── Ir a Mis favoritos
│       └── Mis favoritos
│
├── Resultados
│   └── Tocar lupa
│       └── Buscar
│           └── Escribir búsqueda y presionar Enter
│               └── Resultados
│
└── Mis favoritos
    │
    ├── Seleccionar un libro guardado
    │   └── Detalle del libro
    │       ├── Regresar → Mis favoritos
    │       └── Quitar de favoritos → Mis favoritos
    │
    └── Lista vacía
        └── Buscar libros
            └── Buscar
                └── Escribir búsqueda y presionar Enter
                    └── Resultados
```

**Detalle del libro** se repite dentro de los distintos recorridos únicamente para mostrar desde dónde puede abrirse y a qué pantalla regresa. Corresponde a una misma pantalla reutilizable y no a una tercera sección principal de la aplicación.

Los estados **Carga**, **Sin resultados** y **Error** no se consideran pantallas independientes. Son estados de la pantalla **Resultados**. En el prototipo, el estado sin resultados ya se utiliza; las vistas de carga y error están preparadas, pero todavía no se activan durante la búsqueda.

De la misma forma, **Lista vacía** pertenece a **Mis favoritos** y **Sin portada** es una condición de presentación de un libro, no una pantalla adicional.

La navegación principal entre **Inicio** y **Mis favoritos** se mantiene mediante la barra inferior definida en el diseño del proyecto.

---

## 2. Información por pantalla

### Pantalla principal · Inicio

**Propósito:**
Permitir al usuario consultar la lista inicial de libros, abrir la búsqueda y acceder a Mis favoritos.

**Muestra:**

- Nombre de la aplicación.
- Botón de búsqueda representado por una lupa.
- Lista inicial de libros.
- Título y autor de cada libro.
- Portada cuando esté disponible.
- Accesos a Inicio y Mis favoritos.

**Recibe:**

- Libros que se mostrarán en la lista inicial.

**Modifica:**

- No modifica directamente el texto de búsqueda.
- Solicita cambios de navegación cuando el usuario abre Buscar, selecciona un libro o entra a Mis favoritos.

**Necesita conservar:**

- No necesita conservar una copia propia del texto de búsqueda.

Inicio ya no contiene un campo editable de búsqueda. La lupa funciona como una acción de navegación que abre Buscar. Además, su ilustración cambia según el modo claro u oscuro del sistema.

---

### Buscar

**Propósito:**
Permitir al usuario escribir una consulta antes de mostrar los resultados.

**Muestra:**

- Campo de búsqueda.
- Lupa como elemento visual dentro del campo.
- Texto de búsqueda actual cuando exista.

**Recibe:**

- El texto de búsqueda que mantiene `SearchViewModel`, conectado desde `ContentView` mediante `@Bindable`.

**Modifica:**

- El texto de búsqueda mediante `@Binding`.
- Solicita ejecutar la búsqueda cuando el usuario presiona Enter en el teclado.

**Necesita conservar:**

- El texto escrito hasta que se ejecute la búsqueda.

`ContentView` mantiene una instancia de `SearchViewModel` mediante `@State`. El texto pertenece a ese ViewModel y Buscar lo puede editar mediante `@Binding`, proporcionado desde `ContentView` con `@Bindable`. Así se conserva una sola fuente de verdad para la consulta.

Escribir únicamente modifica el texto. La búsqueda comienza cuando el usuario presiona Enter en el teclado.

---

### Resultados

**Propósito:**
Mostrar el resultado de una búsqueda. Actualmente se utilizan libros de prueba; la conexión con Open Library se realizará después.

**Muestra:**

- Título de la pantalla: Resultados.
- Lista de libros de prueba correspondiente a la consulta.
- Vista de carga preparada, todavía no activada por la búsqueda actual.
- Estado sin resultados.
- Vista de error preparada, todavía no activada por la búsqueda actual.
- Acción para volver a intentar la búsqueda, dentro de la vista de error.
- Botón de búsqueda representado por una lupa.

**Recibe:**

- Los índices de los libros encontrados (`resultIndices`) obtenidos de `SearchViewModel`.
- La colección de libros proporcionada desde `booksState.books`.
- El estado de búsqueda (`state`) que mantiene `SearchViewModel`.

Estos valores llegan a Resultados mediante `ContentView`.

**Modifica:**

- No modifica directamente el texto de búsqueda.
- Solicita volver a ejecutar la búsqueda cuando el usuario utiliza Intentar nuevamente.
- Solicita abrir Buscar cuando el usuario toca la lupa.
- Solicita navegación cuando el usuario selecciona un libro.

`SearchResultsView` ya no decide qué libros corresponden a la consulta. Recibe los índices que calculó `SearchViewModel` y muestra las filas de esos libros. Tampoco presenta el texto de la consulta como un encabezado independiente. Si el usuario quiere escribir otra búsqueda, vuelve a abrir Buscar mediante la lupa.

**Necesita conservar:**

- Los índices de resultados y el estado de búsqueda, que permanecen en `SearchViewModel` mientras el usuario navega.
- La colección compartida de libros, que se mantiene en `BooksState`. Por ahora no se descargan ni guardan resultados de una consulta externa.

---

### Detalle del libro

**Propósito:**
Mostrar la información del libro seleccionado y permitir agregarlo o quitarlo de Mis favoritos.

**Muestra:**

- Título.
- Autor o autores.
- Portada cuando esté disponible.
- Año de publicación cuando esté disponible.
- Acción Agregar a favoritos o Quitar de favoritos.

**Recibe:**

- Libro seleccionado.

**Modifica:**

- No modifica directamente los datos del libro como título, autor, año o portada.
- Cuando el usuario presiona Agregar a favoritos o Quitar de favoritos, comunica la acción a `ContentView`. Desde ahí se solicita el cambio a `BooksState`, que trabaja con `SavedBooksRepository`.

`BookDetailView` muestra el libro recibido. La colección compartida pertenece a `BooksState`, cuya instancia se crea en `OpenBooksApp` y se entrega a `ContentView`.

La vista de detalle solicita el cambio mediante `onSaveOrDelete`. Después, `ContentView` llama a `booksState.toggleSaved(at:)`. `BooksState` utiliza el servicio de favoritos para guardar el cambio y actualizar la colección antes de navegar hacia Mis favoritos.

**Necesita conservar:**

- La información del libro mientras el detalle permanezca abierto.
- El cambio realizado sobre la colección de libros guardados debe mantenerse al navegar a otras pantallas.

La pantalla de detalle no debe crear una segunda copia independiente del estado de guardado. El estado real debe provenir de la misma fuente de verdad utilizada por Mis favoritos.

---

### Mis favoritos

**Propósito:**
Mostrar los libros que el usuario ha marcado como guardados.

**Muestra:**

- Lista de libros guardados.
- Título y autor de cada libro.
- Portada cuando esté disponible.
- Estado de lista vacía.
- Acción Buscar libros cuando la lista esté vacía.

**Recibe:**

- La colección de libros compartida proporcionada desde `booksState.books`.
- A partir de esa colección muestra únicamente los libros cuyo estado `isSaved` indica que están guardados.

**Modifica:**

- No modifica directamente la colección de libros ni el estado `isSaved`.
- Únicamente solicita cambios de navegación cuando el usuario selecciona un libro, regresa a Inicio o utiliza la acción Buscar libros.

**Necesita conservar:**

- Necesita que la colección compartida y el estado de guardado de sus libros permanezcan disponibles mientras el usuario navega por la aplicación.
- La fuente de verdad de esta información se encuentra en `BooksState`, cuya instancia es creada por `OpenBooksApp` y compartida mediante `ContentView`. Mis favoritos solamente recibe la colección y la muestra.
- Los favoritos ya se guardan con SwiftData para conservarse entre ejecuciones de la aplicación.

Mis favoritos no guarda ni elimina registros directamente. Cuando se solicita el cambio desde Detalle, `ContentView` llama a `BooksState`, que utiliza el protocolo `FavoriteBooksStore` para comunicarse con `SavedBooksRepository`. Al terminar, la colección se actualiza y la vista muestra los libros cuyo estado `isSaved` sea verdadero.

---

### Información adicional en Detalle

La ficha actual presenta autor, año de publicación y género cuando están disponibles. También muestra sinopsis y temas principales. El usuario puede desplazarse para leerla sin perder de vista el botón Agregar o Quitar de favoritos. No utilizamos campos de idioma original ni título original en el modelo actual.

### Favoritos al volver a abrir OpenBooks

Al iniciar la aplicación, `OpenBooksApp` prepara el contenedor de SwiftData y crea `BooksState` con el servicio de favoritos. `ContentView` recibe esa instancia y solicita recuperar los libros guardados. Por eso la colección no depende únicamente de lo que permanezca en memoria durante una ejecución.

---

## 3. Organización del estado

No toda la información que aparece en una vista debe convertirse en estado. Los datos de un libro, como título, autor, año o disponibilidad de portada, forman parte del modelo. En cambio, los datos que pueden cambiar y modificar lo que muestra la interfaz sí deben organizarse como estado.

La organización propuesta es la siguiente:

| Dato | Quién lo utiliza | Quién lo modifica | Dónde debería vivir | Justificación |
| --- | --- | --- | --- | --- |
| Texto de búsqueda | Buscar; Resultados depende de la consulta ejecutada | Usuario desde Buscar, mediante `@Binding` | `SearchViewModel.searchText` | `SearchViewModel` mantiene una sola fuente de verdad; `ContentView` conecta Buscar mediante `@Bindable`. |
| Resultados de búsqueda | Resultados y Detalle | `SearchViewModel`, al ejecutar `searchBooks()` | `SearchViewModel.resultIndices` | El ViewModel determina los índices de los libros de prueba. Resultados recibe esos índices y la colección de `BooksState` para mostrar las filas. |
| Estado de búsqueda: loading, content, noResults o error | Resultados | `SearchViewModel`, mediante `searchBooks()` | `SearchViewModel.state` | Actualmente `searchBooks()` asigna `.content` o `.noResults`. Las vistas de carga y error existen, pero aún no se activan durante la búsqueda. |
| Libros guardados | Mis favoritos y Detalle | `SavedBooksRepository` realiza el guardado; `BooksState` actualiza la colección | `BooksState.books` | La misma colección se comparte entre las vistas; `BooksState` solicita la operación a `SavedBooksRepository` y vuelve a leer los favoritos guardados. |
| Estado de guardado de un libro | Detalle y Mis favoritos | `SavedBooksRepository` mediante `BooksState` | `isSaved` dentro de `booksState.books` | Detalle solicita la acción, pero no conserva una segunda copia del estado. |
| Libro seleccionado | Detalle | La pantalla desde la que se selecciona el libro | Índice `Int` durante la navegación | `NavigationLink` envía el índice; `ContentView` obtiene el `Book` de `booksState.books` y lo entrega a Detalle. |
| Sección principal activa: Inicio o Mis favoritos | Barra inferior y vista raíz | Usuario al cambiar de sección | `ContentView.showingMyBooks` | La vista raíz mantiene esta selección mediante `@State` porque controla las dos secciones principales. |
| Ruta de navegación | `ContentView` y destinos de navegación | Acciones del usuario coordinadas por `ContentView` | `ContentView.path` | `NavigationStack` utiliza esta ruta para abrir Buscar, Resultados y Detalle. |
| Título, autor, año y disponibilidad de portada | Inicio, Resultados, Detalle y Mis favoritos | Actualmente, datos locales de prueba; más adelante, Open Library | Modelo `Book` | Son datos propios del libro. `hasCover` indica si aparece un marcador provisional o el estado «Sin portada»; todavía no se descargan portadas reales. |

### Estado local y estado compartido

Se considera **estado local** cuando el dato pertenece a una sola vista y no necesita ser conocido por otras.

Se considera **estado compartido** cuando varias vistas necesitan leerlo o cuando una vista distinta de la propietaria necesita modificarlo.

Para OpenBooks:

- La colección de libros guardados debe ser compartida.
- Los resultados y el estado de una búsqueda se mantienen en `SearchViewModel` durante el flujo de búsqueda.
- El texto de búsqueda se mantiene en `SearchViewModel` y Buscar lo modifica mediante `@Binding`.
- La selección de la sección principal puede pertenecer a la vista raíz.
- El libro seleccionado puede viajar como información de navegación hacia Detalle.

### Single Source of Truth

La aplicación debe evitar que un mismo dato tenga varios dueños.

El caso más importante es **Mis favoritos**. Si la lista de guardados y la pantalla de detalle mantuvieran copias diferentes de la información de guardado, podrían dejar de coincidir.

Por eso, la colección de libros guardados debe ser la fuente de verdad.

La colección que muestran las pantallas se mantiene en `BooksState`, un objeto `@Observable`. Para saber qué libros siguen guardados, utiliza los registros de SwiftData.

`OpenBooksApp` conserva la instancia de `BooksState` y la entrega a `ContentView`. Cuando el usuario agrega o quita un favorito desde Detalle, solicita el cambio con `booksState.toggleSaved(at:)`. `SavedBooksRepository` realiza el guardado o la eliminación y `BooksState` vuelve a consultar los registros para actualizar `isSaved`. Mis favoritos muestra esa misma colección.

De esta forma, Detalle y Mis favoritos trabajan con el mismo estado y no necesitan mantener copias independientes de la información de guardado.

La búsqueda sigue la misma idea: `ContentView` mantiene una instancia de `SearchViewModel` mediante `@State`, pero el texto, los índices y el estado de búsqueda pertenecen al ViewModel. Buscar modifica el texto con un `@Binding` sin crear otra copia.

La idea es que cada dato tenga un responsable claro y pueda compartirse sin duplicar su fuente de verdad.

### Persistencia

Los favoritos ya se guardan localmente con SwiftData para que permanezcan disponibles al volver a abrir OpenBooks.

La persistencia y el estado de la interfaz tienen responsabilidades diferentes:

- El estado compartido permite que las pantallas trabajen con la misma colección durante la ejecución.
- La persistencia local permite recuperar esa colección cuando la aplicación se vuelva a abrir.

Esta parte ya se implementó mediante `SavedBook`, `SavedBooksRepository` y `BooksState`. `OpenBooksApp` prepara el servicio y lo entrega a `BooksState`, que se comunica a través del protocolo `FavoriteBooksStore`. El repositorio consulta, guarda y elimina registros; `BooksState` vuelve a leerlos para actualizar `isSaved` y administra los posibles errores.

---

## 4. Estrategia de navegación

Para el flujo de OpenBooks se utilizan los mecanismos de navegación de SwiftUI que mejor se ajustan a la estructura del proyecto.

### NavigationStack

`NavigationStack` puede actuar como contenedor del flujo de navegación de una sección.

Su función es mantener una pila de vistas. Cuando se abre una pantalla nueva, esta se agrega sobre la anterior y el usuario puede regresar a la pantalla previa.

Esto resulta adecuado para recorridos como:

- Inicio → Detalle.
- Inicio → Buscar → Resultados → Detalle.
- Resultados → Buscar → Resultados.
- Mis favoritos → Detalle.
- Mis favoritos → Buscar → Resultados.

Además, evita tener que guardar manualmente una copia de la pantalla anterior solo para saber a dónde regresar.

### NavigationLink

`NavigationLink` puede utilizarse cuando el usuario toca directamente un elemento para abrir otra vista.

En OpenBooks puede utilizarse para:

- Abrir el detalle de un libro desde Inicio.
- Abrir el detalle de un resultado.
- Abrir el detalle de un libro guardado.

En la implementación actual, cada fila usa `NavigationLink` con un índice `Int` que identifica al libro. `ContentView` obtiene el elemento correspondiente de `booksState.books` y lo entrega a `BookDetailView` para mostrar el detalle.

### navigationDestination

`navigationDestination` permite relacionar un valor o tipo de navegación con la vista que debe mostrarse.

Para OpenBooks resulta útil porque **Detalle del libro es una misma pantalla que puede abrirse desde diferentes lugares**: Inicio, Resultados y Mis favoritos.

En lugar de diseñar tres pantallas de detalle diferentes, se mantiene una sola pantalla. `navigationDestination` recibe el índice y `ContentView` le proporciona el libro correspondiente a `BookDetailView`.

También se utiliza para organizar los destinos del flujo de búsqueda. En la implementación actual, la ruta puede abrir Buscar o Resultados según la acción realizada por el usuario.

### Navegación entre Inicio y Mis favoritos

Inicio y Mis favoritos son las dos secciones principales del proyecto.

La barra inferior definida en los wireframes puede cambiar entre ambas secciones. La sección activa debe pertenecer a la vista raíz porque es la vista que contiene y coordina esas dos opciones.

Este cambio de sección es diferente a abrir un detalle sobre una pantalla. Por eso, la selección de Inicio o Mis favoritos se mantiene como estado de la raíz, mientras que los recorridos hacia Resultados o Detalle pueden organizarse mediante `NavigationStack`.

### Regreso entre pantallas

Cuando el usuario abra Detalle mediante una navegación apilada, el regreso puede ser manejado por `NavigationStack`.

Los casos principales son:

- Inicio → Detalle → regresar a Inicio.
- Inicio → Buscar → regresar a Inicio si el usuario no realiza una búsqueda.
- Resultados → Buscar → regresar a Resultados si el usuario no realiza una nueva búsqueda.
- Resultados → Detalle → regresar a Resultados.
- Mis favoritos → Detalle → regresar a Mis favoritos.

### Guardar o eliminar un libro

Cuando el usuario guarde o elimine un libro:

1. Detalle solicita guardar o eliminar el libro.
2. `ContentView` solicita a `BooksState` el cambio mediante `toggleSaved(at:)`.
3. `SavedBooksRepository` guarda o elimina el registro con SwiftData.
4. `BooksState` consulta los registros actualizados y modifica `isSaved`.
5. La aplicación regresa a Mis favoritos, que muestra la colección actualizada.

No se necesita crear una copia diferente del estado de guardado para cada pantalla.

---

## 5. Relación con la implementación actual

Las decisiones de navegación y organización del estado definidas anteriormente ya se encuentran aplicadas en el prototipo actual de OpenBooks.

La aplicación utiliza `NavigationStack` como contenedor del flujo principal y una ruta almacenada en `ContentView` para representar los destinos que se encuentran dentro de la pila de navegación.

Las filas de libros utilizan `NavigationLink` para abrir el detalle correspondiente y `navigationDestination` relaciona los valores de navegación con las pantallas Buscar, Resultados y Detalle.

Inicio y Resultados muestran una lupa que abre la vista Buscar. El campo editable se encuentra únicamente en Buscar. El texto pertenece a `SearchViewModel`, que `ContentView` mantiene mediante `@State`. Buscar lo modifica con `@Binding`, conectado mediante `@Bindable`. Resultados recibe los índices de los libros seleccionados por el ViewModel, sin mostrar la consulta como un encabezado independiente.

Cuando el usuario presiona Enter desde Buscar, `ContentView` llama a `searchViewModel.searchBooks()` y actualiza la ruta para mostrar Resultados. El ViewModel reconoce las consultas «Harry Potter» y «Orgullo y prejuicio», establece los índices de los libros de prueba y asigna `.content` o `.noResults`. No realiza solicitudes a Open Library ni activa los estados de carga o error.

Para la colección de libros se utiliza `BooksState`, definido como un objeto `@Observable`. `OpenBooksApp` crea una instancia de este estado y `ContentView` proporciona la misma colección a las vistas que la necesitan.

Cuando el usuario agrega o quita un libro desde Detalle, `ContentView` utiliza `booksState.toggleSaved(at:)` y `BooksState` realiza la operación a través del protocolo `FavoriteBooksStore`, cuya implementación utiliza SwiftData. Al terminar, vuelve a consultar los favoritos y Mis favoritos recibe la colección actualizada.

De esta forma existe una sola fuente de verdad para el estado de guardado y el cambio realizado en una vista puede reflejarse en otra.

---

## 6. Decisiones principales

1. **Inicio será la pantalla inicial.**
2. **Buscar será una vista dedicada para escribir la consulta** y se abrirá desde la lupa de Inicio, Resultados o la acción Buscar libros de Mis favoritos.
3. **La búsqueda se ejecutará al presionar Enter en el teclado** desde la vista Buscar.
4. **Resultados será una sola pantalla con diferentes estados**, no una pantalla diferente para carga, error o sin resultados.
5. **Detalle del libro será reutilizable** sin importar si se abre desde Inicio, Resultados o Mis favoritos.
6. **Mis favoritos vacío será un estado de Mis favoritos**, no una pantalla independiente.
7. **Sin portada será una condición del libro**, no una pantalla.
8. **Los libros guardados tendrán una sola fuente de verdad compartida**.
9. **El texto y el estado de búsqueda pertenecen a `SearchViewModel`**; Buscar modifica el texto mediante `@Binding` y `ContentView` conserva la navegación.
10. **El libro seleccionado viajará hacia Detalle como información de navegación**.
11. **`NavigationStack`, `NavigationLink` y `navigationDestination` son los mecanismos utilizados para organizar el flujo en SwiftUI**.
12. **La organización de responsabilidades se realiza de forma gradual**: `SearchViewModel` concentra la búsqueda y `BooksState` solicita el guardado o la eliminación a `SavedBooksRepository`. La integración con Open Library sigue pendiente; la persistencia local con SwiftData ya está implementada.


## Organización del proyecto

Las pantallas se encuentran en `OpenBooks/Views`, y los controles visuales compartidos en `OpenBooks/Views/Components`. El modelo `Book` se mantiene en `OpenBooks/Models/Book.swift`. El estado observable de favoritos y la lógica de búsqueda están en `OpenBooks/ViewModels`. Los libros locales de demostración se encuentran en `OpenBooks/Mocks/MockBooks.swift`.

El detalle muestra la portada, el título, el autor y el año de publicación disponible. Cuando el modelo contiene datos, también presenta el género, una sinopsis y los temas principales. El botón de favoritos permanece visible fuera del área desplazable.

Estos campos adicionales provienen de los diez libros locales de demostración; no se consultan a Open Library ni representan todavía una integración con su API. Los temas y géneros son categorías descriptivas de prueba, no información extraída automáticamente.
