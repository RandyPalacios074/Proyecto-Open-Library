# Diseño de navegación y estado

Este documento define la organización de la navegación y el estado de OpenBooks y registra cómo estas decisiones se relacionan con la implementación actual del proyecto.

La propuesta parte del MVP del proyecto y busca dejar claro qué pantallas existen, cómo se relacionan entre sí, qué información utiliza cada una y dónde debería vivir cada dato para evitar duplicaciones o inconsistencias.

---

## 1. Mapa de navegación

Los flujos principales de OpenBooks son:

- Inicio → lista de libros → Detalle del libro.
- Buscar → Resultados → Detalle del libro.
- Mis libros → libro guardado → Detalle del libro.

A partir de esos flujos, el mapa de navegación propuesto es:

```text
OpenBooks
│
├── Inicio
│   │
│   ├── Seleccionar un libro
│   │   └── Detalle del libro
│   │       ├── Regresar → Inicio
│   │       └── Guardar libro → Mis libros
│   │
│   ├── Realizar búsqueda
│   │   └── Resultados
│   │       ├── Carga
│   │       ├── Contenido
│   │       │   └── Seleccionar un libro
│   │       │       └── Detalle del libro
│   │       │           ├── Regresar → Resultados
│   │       │           └── Guardar libro → Mis libros
│   │       ├── Sin resultados
│   │       └── Error
│   │
│   └── Ir a Mis libros
│       └── Mis libros
│
└── Mis libros
    │
    ├── Seleccionar un libro guardado
    │   └── Detalle del libro
    │       ├── Regresar → Mis libros
    │       └── Eliminar de Mis libros → Mis libros
    │
    └── Lista vacía
        └── Buscar libros
            └── Inicio
```

**Detalle del libro** se repite dentro de los distintos recorridos únicamente para mostrar desde dónde puede abrirse y a qué pantalla regresa. Corresponde a una misma pantalla reutilizable y no a una tercera sección principal de la aplicación.

Los estados **Carga**, **Sin resultados** y **Error** no se consideran pantallas independientes. Son estados de la pantalla **Resultados**.

De la misma forma, **Lista vacía** pertenece a **Mis libros** y **Sin portada** es una condición de presentación de un libro, no una pantalla adicional.

La navegación principal entre **Inicio** y **Mis libros** se mantiene mediante la barra inferior definida en el diseño del proyecto.

---

## 2. Información por pantalla

### Pantalla principal · Inicio

**Propósito:**  
Permitir al usuario comenzar una búsqueda, consultar la lista inicial de libros y acceder a Mis libros.

**Muestra:**

- Nombre de la aplicación.
- Campo de búsqueda.
- Lista inicial de libros.
- Título y autor de cada libro.
- Portada cuando esté disponible.
- Accesos a Inicio y Mis libros.

**Recibe:**

- El texto de búsqueda desde `ContentView`, que mantiene la fuente de verdad de este dato.
- Libros que se mostrarán en la lista inicial.

**Modifica:**

- El texto de búsqueda compartido cuando el usuario escribe en el campo de búsqueda mediante `@Binding`.

Las acciones de buscar, seleccionar un libro o entrar a Mis libros solicitan cambios de navegación a `ContentView`, que es donde actualmente se encuentra el estado que controla la pantalla mostrada.

**Necesita conservar:**

- El texto de búsqueda mientras el usuario pasa de Inicio a Resultados.

El texto de búsqueda pertenece a `ContentView`. Inicio recibe acceso de lectura y escritura mediante `@Binding`, por lo que no mantiene una segunda copia del dato.

Escribir en el campo únicamente modifica el texto de búsqueda. La búsqueda comienza cuando el usuario presiona el botón de la lupa.

---

### Resultados

**Propósito:**  
Mostrar el resultado de una búsqueda realizada en Open Library.

**Muestra:**

- Texto de la búsqueda.
- Lista de libros encontrados.
- Estado de carga.
- Estado sin resultados.
- Estado de error.
- Acción para volver a intentar la búsqueda.

**Recibe:**

- El mismo texto de búsqueda compartido cuya fuente de verdad se encuentra en `ContentView`.
- La colección de libros proporcionada por `ContentView`.
- El estado actual de la búsqueda proporcionado por `ContentView`.

**Modifica:**

- El texto de búsqueda compartido si el usuario escribe un nuevo valor mediante `@Binding`.

Resultados no modifica directamente el estado de la búsqueda. Cuando el usuario presiona el botón de la lupa o intenta nuevamente, la vista solicita una nueva búsqueda mediante la acción recibida desde `ContentView`. `ContentView` es quien ejecuta la búsqueda y actualiza el estado correspondiente.

Resultados tampoco crea una copia independiente del texto. Recibe acceso al mismo dato mediante `@Binding`.

Si el usuario cambia el texto, la nueva búsqueda no se realiza automáticamente. El texto queda actualizado y la búsqueda se ejecuta cuando el usuario presiona nuevamente el botón de la lupa.

**Necesita conservar:**

- Texto de búsqueda.
- Resultados obtenidos.
- Estado de la búsqueda mientras el usuario entra a un detalle y posteriormente regresa.

---

### Detalle del libro

**Propósito:**  
Mostrar la información del libro seleccionado y permitir guardarlo o eliminarlo de Mis libros.

**Muestra:**

- Título.
- Autor o autores.
- Portada cuando esté disponible.
- Año de publicación cuando esté disponible.
- Acción Guardar libro o Eliminar de Mis libros.

**Recibe:**

- Libro seleccionado.

**Modifica:**

- No modifica directamente los datos del libro como título, autor, año o portada.
- Cuando el usuario presiona Guardar libro o Eliminar de Mis libros, solicita a `ContentView` cambiar el estado `isSaved` del libro seleccionado.

`BookDetailView` muestra el libro recibido, pero la colección de libros y su estado de guardado pertenecen a `ContentView`.

La vista de detalle solicita el cambio mediante la acción `onSaveOrDelete`, y `ContentView` modifica el libro correspondiente dentro de la colección compartida.

**Necesita conservar:**

- La información del libro mientras el detalle permanezca abierto.
- El cambio realizado sobre la colección de libros guardados debe mantenerse al navegar a otras pantallas.

La pantalla de detalle no debe crear una segunda copia independiente del estado de guardado. El estado real debe provenir de la misma fuente de verdad utilizada por Mis libros.

---

### Mis libros

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
- La fuente de verdad de esta información se encuentra en `BooksState`, cuya instancia es mantenida por `ContentView`. Mis libros solamente recibe la colección y la muestra.
- Posteriormente, esta información deberá persistirse localmente para conservarse entre ejecuciones de la aplicación.

Mis libros no es la pantalla encargada de guardar o eliminar libros. Cuando el usuario realiza esa acción desde Detalle, `ContentView` modifica `isSaved` dentro de `booksState.books`. Mis libros recibe después el estado actualizado y muestra los libros correspondientes.

---

## 3. Organización del estado

No toda la información que aparece en una vista debe convertirse en estado. Los datos de un libro, como título, autor, año o disponibilidad de portada, forman parte del modelo. En cambio, los datos que pueden cambiar y modificar lo que muestra la interfaz sí deben organizarse como estado.

La organización propuesta es la siguiente:

| Dato | Quién lo utiliza | Quién lo modifica | Dónde debería vivir | Justificación |
| --- | --- | --- | --- | --- |
| Texto de búsqueda | Inicio y Resultados | Usuario desde Inicio o Resultados | `ContentView` | `ContentView` mantiene una sola fuente de verdad mediante `@State`. Inicio y Resultados acceden al mismo texto mediante `@Binding`, evitando crear copias diferentes. |
| Resultados de búsqueda | Resultados y Detalle | La lógica encargada de realizar la búsqueda | Estado compartido del flujo de búsqueda | Deben seguir disponibles si el usuario abre un detalle y después regresa a Resultados. |
| Estado de búsqueda: loading, content, noResults o error | Resultados | La lógica de búsqueda | Estado compartido del flujo de búsqueda | La interfaz de Resultados depende directamente de este valor. Al cambiar, cambia lo que se muestra. |
| Libros guardados | Mis libros y Detalle | `ContentView`, a partir de la acción solicitada desde Detalle | `BooksState` | Ambas vistas necesitan consultar el mismo estado. `BooksState` mantiene una sola fuente de verdad y `ContentView` actualiza el estado de guardado del libro seleccionado. |
| Estado de guardado de un libro | Detalle y Mis libros | `ContentView`, cuando Detalle solicita guardar o eliminar | Dentro de `booksState.books` | El valor `isSaved` pertenece al libro almacenado en la colección compartida. Detalle lo muestra y solicita su cambio, pero no mantiene una copia independiente. |
| Libro seleccionado | Detalle | La pantalla desde la que se selecciona el libro | Se pasa durante la navegación | Solo se necesita para abrir el detalle correspondiente; no es necesario mantener otra copia global permanente. |
| Sección principal activa: Inicio o Mis libros | Barra inferior y vista raíz | Usuario al cambiar de sección | Estado local de la vista que contiene ambas secciones | La vista raíz es la responsable de esta decisión de navegación. |
| Título, autor, año y portada | Inicio, Resultados, Detalle y Mis libros | Open Library o los datos locales de prueba | Modelo `Book` | Son datos propios del libro. Las vistas los reciben y los muestran, pero no necesitan crear una copia de estado por pantalla. |

### Estado local y estado compartido

Se considera **estado local** cuando el dato pertenece a una sola vista y no necesita ser conocido por otras.

Se considera **estado compartido** cuando varias vistas necesitan leerlo o cuando una vista distinta de la propietaria necesita modificarlo.

Para OpenBooks:

- La colección de libros guardados debe ser compartida.
- Los resultados y el estado de una búsqueda deben mantenerse durante el flujo de búsqueda.
- El texto de búsqueda debe compartirse entre Inicio y Resultados.
- La selección de la sección principal puede pertenecer a la vista raíz.
- El libro seleccionado puede viajar como información de navegación hacia Detalle.

### Single Source of Truth

La aplicación debe evitar que un mismo dato tenga varios dueños.

El caso más importante es **Mis libros**. Si la lista de guardados y la pantalla de detalle mantuvieran copias diferentes de la información de guardado, podrían dejar de coincidir.

Por eso, la colección de libros guardados debe ser la fuente de verdad.

Actualmente, la colección compartida se encuentra organizada en `BooksState`, un objeto `@Observable`, lo que permite mantener una sola fuente de verdad para los libros utilizados por las diferentes vistas.

`ContentView` mantiene una instancia de `BooksState`. Cuando el usuario guarda o elimina un libro desde Detalle, se modifica `isSaved` dentro de `booksState.books`. Después, Mis libros utiliza esa misma colección actualizada.

De esta forma, Detalle y Mis libros trabajan con el mismo estado y no necesitan mantener copias independientes de la información de guardado.

La idea es que cada dato viva en el nivel más bajo desde el que pueda compartirse correctamente, sin duplicar la fuente de verdad.

### Persistencia

La colección de libros guardados deberá persistirse localmente porque forma parte del MVP.

La persistencia y el estado de la interfaz tienen responsabilidades diferentes:

- El estado compartido permite que las pantallas trabajen con la misma colección durante la ejecución.
- La persistencia local permite recuperar esa colección cuando la aplicación se vuelva a abrir.

La implementación concreta de persistencia se realizará posteriormente. En esta etapa solo se define dónde debe vivir la información y cómo debe compartirse.

---

## 4. Estrategia de navegación

Para el flujo de OpenBooks se utilizan los mecanismos de navegación de SwiftUI que mejor se ajustan a la estructura del proyecto.

### NavigationStack

`NavigationStack` puede actuar como contenedor del flujo de navegación de una sección.

Su función es mantener una pila de vistas. Cuando se abre una pantalla nueva, esta se agrega sobre la anterior y el usuario puede regresar a la pantalla previa.

Esto resulta adecuado para recorridos como:

- Inicio → Detalle.
- Inicio → Resultados → Detalle.
- Mis libros → Detalle.

Además, evita tener que guardar manualmente una copia de la pantalla anterior solo para saber a dónde regresar.

### NavigationLink

`NavigationLink` puede utilizarse cuando el usuario toca directamente un elemento para abrir otra vista.

En OpenBooks puede utilizarse para:

- Abrir el detalle de un libro desde Inicio.
- Abrir el detalle de un resultado.
- Abrir el detalle de un libro guardado.

La información que necesita la pantalla siguiente debe viajar con la navegación. En estos casos, Detalle necesita recibir el libro seleccionado.

### navigationDestination

`navigationDestination` permite relacionar un valor o tipo de navegación con la vista que debe mostrarse.

Para OpenBooks resulta útil porque **Detalle del libro es una misma pantalla que puede abrirse desde diferentes lugares**: Inicio, Resultados y Mis libros.

En lugar de diseñar tres pantallas de detalle diferentes, se mantiene una sola pantalla y se le proporciona la información del libro seleccionado.

También puede utilizarse para organizar destinos del flujo de búsqueda cuando la navegación dependa del estado o de una acción realizada por el usuario.

### Navegación entre Inicio y Mis libros

Inicio y Mis libros son las dos secciones principales del proyecto.

La barra inferior definida en los wireframes puede cambiar entre ambas secciones. La sección activa debe pertenecer a la vista raíz porque es la vista que contiene y coordina esas dos opciones.

Este cambio de sección es diferente a abrir un detalle sobre una pantalla. Por eso, la selección de Inicio o Mis libros se mantiene como estado de la raíz, mientras que los recorridos hacia Resultados o Detalle pueden organizarse mediante `NavigationStack`.

### Regreso entre pantallas

Cuando el usuario abra Detalle mediante una navegación apilada, el regreso puede ser manejado por `NavigationStack`.

Los casos principales son:

- Inicio → Detalle → regresar a Inicio.
- Resultados → Detalle → regresar a Resultados.
- Mis libros → Detalle → regresar a Mis libros.

### Guardar o eliminar un libro

Cuando el usuario guarde o elimine un libro:

1. Detalle solicita guardar o eliminar el libro.
2. `ContentView` modifica `isSaved` del libro seleccionado dentro de `booksState.books`.
3. Mis libros utiliza ese mismo estado compartido.
4. La interfaz de Mis libros refleja el cambio.
5. De acuerdo con el flujo definido para el proyecto, el usuario puede continuar hacia Mis libros.

No se necesita crear una copia diferente del estado de guardado para cada pantalla.

---

## 5. Relación con la implementación actual

Las decisiones de navegación y organización del estado definidas anteriormente ya se encuentran aplicadas en el prototipo actual de OpenBooks.

La aplicación utiliza `NavigationStack` como contenedor del flujo principal y una ruta almacenada en `ContentView` para representar los destinos que se encuentran dentro de la pila de navegación.

Las filas de libros utilizan `NavigationLink` para abrir el detalle correspondiente y `navigationDestination` relaciona los valores de navegación con las pantallas de Resultados y Detalle.

El texto de búsqueda continúa compartiéndose mediante `@Binding` entre las vistas que necesitan leerlo o modificarlo.

Para la colección de libros se utiliza `BooksState`, definido como un objeto `@Observable`. `ContentView` mantiene una instancia de este estado y proporciona la misma colección a las vistas que la necesitan.

Cuando el usuario guarda o elimina un libro desde Detalle, se modifica `isSaved` dentro de `booksState.books`. Después, Mis libros utiliza esa misma colección actualizada.

De esta forma existe una sola fuente de verdad para el estado de guardado y el cambio realizado en una vista puede reflejarse en otra.

---

## 6. Decisiones principales

1. **Inicio será la pantalla inicial.**
2. **Resultados será una sola pantalla con diferentes estados**, no una pantalla diferente para carga, error o sin resultados.
3. **Detalle del libro será reutilizable** sin importar si se abre desde Inicio, Resultados o Mis libros.
4. **Mis libros vacío será un estado de Mis libros**, no una pantalla independiente.
5. **Sin portada será una condición del libro**, no una pantalla.
6. **Los libros guardados tendrán una sola fuente de verdad compartida**.
7. **El texto de búsqueda y los resultados deberán mantenerse durante el flujo de búsqueda**.
8. **El libro seleccionado viajará hacia Detalle como información de navegación**.
9. **`NavigationStack`, `NavigationLink` y `navigationDestination` son los mecanismos utilizados para organizar el flujo en SwiftUI**.
10. **Las decisiones de navegación y estado definidas en este documento ya se encuentran aplicadas en la implementación actual del proyecto**.