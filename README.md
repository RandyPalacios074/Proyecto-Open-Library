# OpenBooks

## Integrantes

- Romero Palacios Randy Rodrigo
- Villanueva García Emanuel

## Nombre del proyecto

**OpenBooks**

## Descripción del proyecto

OpenBooks es una aplicación para iOS desarrollada con Swift y SwiftUI. Permite explorar libros, consultar su información y administrar una colección personal de favoritos.

Por ahora utilizamos libros de prueba incluidos en el proyecto. La conexión con Open Library todavía está pendiente. Los favoritos sí se guardan localmente con SwiftData para que sigan disponibles cuando se cierre y se vuelva a abrir la aplicación.

## Objetivo

Permitir que el usuario encuentre libros, consulte su información y pueda agregarlos o quitarlos de sus favoritos. También buscamos que la aplicación sea sencilla de usar y que los libros guardados permanezcan disponibles al volver a abrirla.

## Funcionalidades del MVP

Las funciones que consideramos para el proyecto y su estado actual son:

- Una pantalla principal con una lista de libros.
- Búsqueda local con libros de prueba. La consulta a Open Library queda pendiente.
- Visualización de resultados de búsqueda.
- Visualización del detalle de cada libro.
- Portada del libro cuando esté disponible.
- Título del libro.
- Autor o autores.
- Año de publicación cuando esté disponible.
- Opción para agregar libros a Mis favoritos.
- Opción para quitar libros de Mis favoritos.
- Una sección llamada **Mis favoritos**.
- Persistencia local de los favoritos con SwiftData.
- Una vista de carga preparada para cuando se incorpore Open Library.
- Una vista de error preparada para cuando se incorpore Open Library.
- Manejo de búsquedas sin resultados.
- Manejo de libros sin portada.
- Manejo del estado de lista de libros guardados vacía.

## Flujo de usuario

La aplicación tiene dos secciones principales:

- **Inicio**
- **Mis favoritos**

Desde la pantalla principal, el usuario podrá seleccionar directamente un libro de la lista para consultar su detalle o tocar la lupa para abrir la vista Buscar.

En Buscar, el usuario podrá escribir el texto de su consulta. La búsqueda se ejecutará cuando presione Enter en el teclado.

En el prototipo actual, la búsqueda utiliza los libros de prueba definidos en `MockBooks.swift`. Todavía no se realizan consultas a Open Library.

Actualmente la búsqueda de prueba muestra resultados o el estado sin resultados. La carga de información desde Open Library se incorporará después.

Si se obtienen resultados, el usuario podrá seleccionar un libro para acceder a su detalle.

Si la búsqueda no devuelve coincidencias, se mostrará un estado sin resultados. El usuario podrá volver a abrir Buscar desde la lupa para escribir otra consulta.

El estado de error y la opción de intentar nuevamente ya tienen una vista preparada, pero todavía no se utilizan con una consulta real.

Desde el detalle del libro se puede consultar el autor, el año de publicación, el género, la sinopsis y los temas disponibles. También se puede guardar o quitar el libro de favoritos.

- Si el libro no está guardado, se mostrará la opción **Agregar a favoritos**.
- Si el libro ya está guardado, se mostrará la opción **Quitar de favoritos**.

La sección **Mis favoritos** mostrará los libros almacenados localmente. Desde esta sección el usuario también podrá seleccionar un libro para consultar su detalle.

Si todavía no existen libros guardados, se mostrará un estado de lista vacía que permitirá al usuario abrir Buscar y realizar una consulta.

Cuando un libro de prueba no tiene portada, mostramos «Sin portada». Algunas sugerencias incluyen ilustraciones locales, que todavía no provienen de Open Library.

De esta manera, utilizamos una sola pantalla de detalle y la misma colección de favoritos para los diferentes recorridos. SwiftData conserva los libros seleccionados al cerrar y reabrir OpenBooks.

### Flujo general

<img width="1448" height="1086" alt="07-flujo-usuario" src="https://github.com/user-attachments/assets/fa488ace-31df-4de5-bb4a-6094bfa4aee4" />

**Detalle del libro** y **Mis favoritos** se repiten en el diagrama para mostrar con mayor claridad los distintos recorridos, pero corresponden a las mismas pantallas de la aplicación.

El diagrama representa los recorridos principales de navegación. Los estados de carga, error, búsqueda sin resultados, libro sin portada y lista de libros guardados vacía se muestran por separado en los wireframes.

## Wireframes

Conservamos aquí los wireframes iniciales para mostrar cómo planteamos las pantallas y los estados del proyecto. Son imágenes del diseño original y no representan exactamente la interfaz actual.

### Pantalla principal

La pantalla principal del wireframe inicial contiene el buscador, una lista inicial de libros y el acceso a la sección **Mis favoritos**.

En la implementación actual, el campo de búsqueda ya no permanece visible en Inicio. La pantalla muestra una lupa que abre una vista Buscar dedicada antes de mostrar Resultados.

<img width="941" height="1672" alt="01-pantalla-principal" src="https://github.com/user-attachments/assets/aeec5ced-9d0f-40c3-9ad7-566936d6f885" />

### Resultados de búsqueda

El wireframe muestra cómo planteamos la pantalla de resultados. Actualmente se presentan libros de prueba; todavía no se consulta Open Library.

<img width="941" height="1672" alt="02-resultados" src="https://github.com/user-attachments/assets/2832437b-cfa3-40a6-b506-cfcec5a5204c" />

### Detalle de un libro no guardado

En el diseño original se muestra la información del libro y la opción para guardarlo. En la versión actual agregamos una ficha con año de publicación, género, sinopsis y temas principales.

<img width="941" height="1672" alt="03-detalle-no-guardado" src="https://github.com/user-attachments/assets/29a59be6-227a-4ca1-865d-6f1440dba4d5" />

### Mis favoritos

Muestra los libros que el usuario ha guardado localmente.

<img width="941" height="1672" alt="04-mis-libros" src="https://github.com/user-attachments/assets/d0d44fd2-88cc-4d64-907c-714b101020bf" />

### Detalle de un libro guardado

El wireframe muestra la opción de eliminar un libro guardado. Actualmente la acción se llama **Quitar de favoritos**.

<img width="941" height="1672" alt="05-detalle-guardado" src="https://github.com/user-attachments/assets/fc9a6265-71e6-4ee3-83da-af05aebe0d3d" />

### Mis favoritos vacío

Este estado aparece cuando el usuario todavía no tiene libros guardados.

<img width="941" height="1672" alt="06-mis-libros-vacio" src="https://github.com/user-attachments/assets/39c7128d-7280-4e08-bd93-36ec7da5010c" />

### Estados adicionales del MVP

Además de las pantallas principales, consideramos diferentes estados para las búsquedas. Por ahora, los datos son locales; la conexión a Open Library sigue pendiente.

#### Búsqueda sin resultados

Se muestra cuando la consulta no coincide con los libros de prueba. El usuario puede realizar otra búsqueda.

#### Carga de resultados

Esta vista está preparada, pero no se activa durante las búsquedas locales. La utilizaremos cuando se consulten datos externos.

#### Error en la búsqueda

Esta vista está preparada para mostrar problemas de consulta y permitir intentarlo de nuevo. Todavía no se activa con los datos locales.

#### Libro sin portada

Si un libro no tiene portada en los datos de prueba, la interfaz muestra un elemento sustituto en lugar de dejar el espacio vacío.

<img width="1536" height="1024" alt="08-estados-adicionales" src="https://github.com/user-attachments/assets/d4c5124b-5d78-457f-b252-ebaca66c3d95" />

## Tecnologías utilizadas y pendientes

- **Swift y SwiftUI:** utilizados para las pantallas, los componentes y la navegación.
- **Observation (`@Observable`):** utilizado para compartir los cambios de búsqueda y favoritos.
- **SwiftData:** utilizado para guardar y recuperar favoritos localmente.
- **XCTest:** utilizado para comprobar la búsqueda y las operaciones de favoritos.
- **Git y GitHub:** utilizados para mantener las versiones del proyecto.
- **Open Library y async/await:** considerados para la conexión con libros externos, pero todavía no implementados.

## Accesibilidad con VoiceOver

La accesibilidad se consideró desde el diseño de los wireframes y del flujo de usuario de OpenBooks.

En la aplicación se incluyen etiquetas descriptivas para la búsqueda, los botones y distintos elementos de las pantallas. Sin embargo, todavía falta revisar todo el recorrido usando VoiceOver en un dispositivo o simulador.

El criterio principal es que VoiceOver comunique la información necesaria para comprender y utilizar la aplicación, evitando anunciar de forma independiente elementos decorativos o información que ya esté representada mediante texto.

Las etiquetas de accesibilidad serán breves, claras y describirán directamente la información o acción relevante. No se utilizarán nombres internos de archivos, imágenes o iconos como descripciones para el usuario.

### Información accesible por pantalla

| Pantalla o estado | Información relevante para VoiceOver |
| --- | --- |
| Pantalla principal | OpenBooks, acción Buscar libros, Libros, título y autor de cada libro, Inicio y Mis favoritos. |
| Buscar | Acción para regresar, campo Buscar libros y texto actual de la consulta. |
| Resultados | Resultados, acción para regresar, acción Buscar libros y título y autor de cada resultado. |
| Detalle del libro | Acción para regresar, Detalle del libro, título, autor, año cuando esté disponible y Agregar a favoritos o Quitar de favoritos, según corresponda. |
| Mis favoritos | Mis favoritos, título y autor de cada libro guardado, Inicio y Mis favoritos. |
| Mis favoritos vacío | Mis favoritos, Todavía no tienes libros guardados, Busca un libro y guárdalo para verlo aquí y Buscar libros. |
| Carga | Buscando libros y Esto puede tardar unos segundos. |
| Sin resultados | No se encontraron libros e Intenta realizar otra búsqueda. |
| Error | No se pudieron cargar los libros, el mensaje correspondiente e Intentar nuevamente. |
| Libro sin portada | El libro se identificará mediante su título y autor sin depender de la portada. |

En las listas de libros se buscará presentar el título y el autor como información relacionada. Por ejemplo:

1984, George Orwell

De esta manera se evita que el usuario tenga que recorrer por separado varios elementos que pertenecen a una misma opción.

### Elementos visuales

Los elementos que sean únicamente decorativos o que repitan información disponible mediante texto no necesitarán anunciarse de forma independiente.

Esto incluye:

- La lupa que aparece dentro del campo de texto de la vista Buscar, porque es únicamente visual.
- Las flechas utilizadas como indicadores visuales.
- El icono utilizado en el estado Mis favoritos vacío.
- Las portadas cuando el libro ya pueda identificarse mediante su título y autor.

Por ejemplo, si una fila contiene una portada, el título 1984 y el autor George Orwell, la información relevante para VoiceOver será:

1984, George Orwell

Cuando Open Library no disponga de una portada, se mostrará un elemento visual sustituto, pero VoiceOver seguirá identificando el libro mediante su título y autor.

No se utilizarán nombres internos como cover_missing.png, book_placeholder o image01 como descripciones de accesibilidad.

Si en el futuro una imagen aporta información importante que no esté disponible mediante texto, deberá utilizarse una descripción breve que comunique únicamente la información necesaria para comprenderla.

### Etiquetas de accesibilidad

Las etiquetas creadas específicamente para accesibilidad serán concisas y describirán directamente la acción correspondiente.

Algunos ejemplos son:

- Buscar libros
- Agregar a favoritos
- Quitar de favoritos
- Intentar nuevamente

No se utilizarán descripciones extensas cuando una acción pueda expresarse de forma directa.

El detalle ya incluye sinopsis y temas principales cuando están disponibles. Como el contenido es texto de SwiftUI, también debemos comprobar su lectura y orden con VoiceOver.

## Documentación del proyecto

La documentación adicional del proyecto se encuentra en la carpeta `Docs`.

### Diseño de navegación y estado

El análisis de navegación y organización del estado de OpenBooks se encuentra en:

[`Docs/navigation-and-state.md`](Docs/navigation-and-state.md)

Este documento incluye:

- El mapa de navegación de las pantallas del MVP.
- La información que muestra, recibe, modifica y necesita conservar cada pantalla.
- La organización del estado y la definición de dónde debería vivir cada dato.
- La diferencia entre estado local y estado compartido.
- La definición de una sola fuente de verdad para los datos compartidos.
- La estrategia de navegación propuesta para SwiftUI.
- La relación entre la propuesta y el prototipo actual de OpenBooks.

### Propuesta de arquitectura MVVM

El análisis de separación de responsabilidades y la propuesta de organización basada en MVVM se encuentra en:

[`Docs/mvvm-proposal.md`](Docs/mvvm-proposal.md)

Este documento incluye:

- La revisión de la estructura actual del proyecto.
- La separación entre interfaz, datos y lógica.
- La relación entre Model, View y ViewModel.
- La organización de las responsabilidades de búsqueda mediante `SearchViewModel`.
- Las responsabilidades que ahora tiene `SearchViewModel`.
- La organización de la colección de libros mediante `BooksState`.
- La distinción entre estado local y estado compartido.
- Las mejoras que podrán realizarse después, sin adelantar funcionalidades del MVP.

### Pruebas y almacenamiento

Las comprobaciones de búsqueda y la forma en que se guardan los favoritos se explican en [`Docs/pruebas-y-persistencia.md`](Docs/pruebas-y-persistencia.md). Este documento describe las comprobaciones realizadas con XCTest y el almacenamiento local mediante SwiftData.

## Pantallas actuales

Conservamos las capturas originales en las mismas secciones del README. Son imágenes de una versión anterior y sirven para ver cómo comenzó el diseño. **No son capturas de la interfaz editorial actual**, que ahora incluye colores adaptados al modo claro y oscuro, sugerencias y una ficha de libro más completa.

En la aplicación actual, Inicio y Resultados muestran una lupa que abre Buscar. El campo de texto editable se encuentra únicamente en esa vista. Las capturas antiguas no deben confundirse con una verificación del diseño actual.

### Pantalla principal

Muestra el acceso a Buscar mediante una lupa, la lista inicial de libros y la navegación entre **Inicio** y **Mis favoritos**.

<table align="center">
  <tr>
    <td>
      <img width="260" alt="01-pantalla-principal" src="https://github.com/user-attachments/assets/9000cb2b-fc82-4a9f-9aa6-3ad09755adaf" />
    </td>
  </tr>
</table>

### Buscar

Es la vista dedicada para escribir una consulta. El usuario accede a ella desde la lupa, escribe el texto de búsqueda y presiona Enter para mostrar Resultados.

La captura de Buscar está pendiente de actualizarse. No hemos sustituido ni movido las imágenes originales de este documento.

### Resultados de búsqueda

Muestra los resultados de una búsqueda, permite seleccionar un libro para consultar su detalle y ofrece una lupa para abrir nuevamente Buscar.


<table align="center">
  <tr>
    <td>
      <img width="260" alt="02-resultados" src="https://github.com/user-attachments/assets/f4403735-70f6-4926-bfb7-46987f16e3d2" />
    </td>
  </tr>
</table>

### Detalle de un libro no guardado

Esta captura corresponde al diseño anterior. Actualmente Detalle muestra autor, año de publicación, género, sinopsis y temas, además del botón fijo **Agregar a favoritos**.

<table align="center">
  <tr>
    <td>
      <img width="260" alt="03-detalle-no-guardado" src="https://github.com/user-attachments/assets/205931c3-31c4-406b-a4e7-82029595fd97" />
    </td>
  </tr>
</table>

### Detalle de un libro guardado

Esta captura corresponde al diseño anterior. En la versión actual el botón se llama **Quitar de favoritos**.

<table align="center">
  <tr>
    <td>
      <img width="260" alt="05-detalle-guardado" src="https://github.com/user-attachments/assets/784b783f-d948-44a5-8bb1-91cb97f91c38" />
    </td>
  </tr>
</table>

### Mis favoritos

Muestra los libros que se encuentran guardados en la colección.

<table align="center">
  <tr>
    <td>
      <img width="260" alt="04-mis-libros" src="https://github.com/user-attachments/assets/b7568132-028e-44f4-be32-34d895bcfe1d" />
    </td>
  </tr>
</table>

### Mis favoritos vacío

Muestra el estado de la sección cuando todavía no existen libros guardados.

<table align="center">
  <tr>
    <td>
       <img width="260" alt="06-mis-libros-vacio" src="https://github.com/user-attachments/assets/7beac29c-e70e-4cd8-86a0-08563d5f0957" />
    </td>
  </tr>
</table>

## Estados de búsqueda

### Carga

Esta es una captura del estado de carga previsto. La vista está preparada, pero no se activa con las búsquedas locales.

<table align="center">
  <tr>
    <td>
       <img width="260" alt="07-cargando" src="https://github.com/user-attachments/assets/f441b56a-8f55-4bcb-af79-4cd62969084e" />
    </td>
  </tr>
</table>

### Búsqueda sin resultados

Muestra el estado utilizado cuando no se encuentran libros que coincidan con la búsqueda.

<table align="center">
  <tr>
    <td>
       <img width="260" alt="08-no-resultados" src="https://github.com/user-attachments/assets/a80647df-3a93-47a4-bb42-9883a9712b98" />
    </td>
  </tr>
</table>

### Error en la búsqueda

Esta es una captura del estado de error previsto. La vista está preparada, pero todavía no se activa con las búsquedas locales.

<table align="center">
  <tr>
    <td>
       <img width="260" alt="09-error" src="https://github.com/user-attachments/assets/ac6c4726-265b-4c22-84cd-2c316f16477e" />
    </td>
  </tr>
</table>

### Libro sin portada

Esta captura corresponde a un estado de portada ausente. Actualmente se utilizan ilustraciones locales en algunas sugerencias y el texto «Sin portada» cuando el libro no tiene imagen disponible en los datos de prueba. No se descargan portadas de Open Library.

<table align="center">
  <tr>
    <td>
       <img width="260" alt="10-sin-portada" src="https://github.com/user-attachments/assets/7d89a443-d41a-4d5b-b5e3-a766f45defe6" />
    </td>
  </tr>
</table>

## Estado actual del proyecto

Actualmente tenemos implementado lo siguiente:

- Las pantallas **Inicio**, **Buscar**, **Resultados**, **Detalle** y **Mis favoritos** con SwiftUI.
- La navegación entre pantallas mediante `NavigationStack`, `NavigationLink` y `navigationDestination`.
- Un diseño editorial con colores que cambian según el modo claro u oscuro del sistema. En Inicio también cambia la ilustración del gato, los libros y la lámpara.
- Un conjunto de sugerencias y la opción **Ver todo** para mostrar más libros de prueba.
- Una vista Buscar que ejecuta la consulta al presionar Enter o Buscar en el teclado.
- Resultados de prueba para «Harry Potter» y «Orgullo y prejuicio», además de un estado sin resultados.
- Las vistas de carga y error preparadas para una consulta externa futura.
- El detalle del libro con autor, año de publicación, género, sinopsis y temas disponibles. El contenido puede desplazarse y el botón de favoritos permanece en la parte inferior.
- La sección Mis favoritos y su estado vacío, con acceso a Buscar.
- El guardado local de favoritos con SwiftData, incluida su recuperación al cerrar y reabrir OpenBooks.
- La prevención de libros duplicados al guardar el mismo favorito.
- La separación de modelos, vistas, estado de búsqueda y operaciones de favoritos en diferentes archivos.
- Etiquetas y encabezados de accesibilidad en varias pantallas. Falta comprobar el recorrido completo con VoiceOver.
- Ocho pruebas unitarias XCTest que cubren búsquedas y operaciones de favoritos.
- Los wireframes y las capturas originales de este README, conservados como registro del diseño inicial.

La búsqueda utiliza los libros definidos en `MockBooks.swift`. `SearchViewModel` mantiene el texto, el estado y los resultados; `BooksState` actualiza la colección que utilizan las pantallas y recupera los favoritos guardados mediante `SavedBooksRepository` y `SavedBook`.

**Pendiente:** conectar Open Library, obtener portadas y datos reales, verificar el recorrido completo de accesibilidad y revisar visualmente todas las pantallas tanto en modo claro como en modo oscuro. Las imágenes originales de este README no sustituyen esa comprobación visual.

## Ejecución del proyecto

1. Clonar o descargar el proyecto con sus archivos Swift y recursos gráficos.
2. Abrir el proyecto iOS actualizado en Xcode.
3. Seleccionar un simulador de iOS compatible con iOS 17 o posterior.
4. Ejecutar OpenBooks y revisar Inicio, Buscar, Detalle y Mis favoritos.
5. Para revisar los dos aspectos, cambiar el modo claro u oscuro desde **Configuración → Pantalla y brillo** del simulador y volver a OpenBooks. También se puede hacer desde Xcode en **Environment Overrides**, cuando esté disponible.
