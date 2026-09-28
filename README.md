# OpenBooks

## Integrantes

- Romero Palacios Randy Rodrigo
- Villanueva García Emanuel

## Nombre del proyecto

**OpenBooks**

## Descripción del proyecto

OpenBooks es una aplicación iOS que permitirá buscar libros mediante Open Library, consultar la información básica de cada libro y administrar una colección personal de libros guardados.

La aplicación se desarrollará principalmente con SwiftUI.

## Objetivo

Permitir que el usuario explore y busque libros, consulte sus datos principales y pueda guardar o eliminar libros de una colección personal.

## Funcionalidades del MVP

La aplicación incluirá:

- Una pantalla principal con una lista de libros.
- Búsqueda de libros mediante Open Library.
- Visualización de resultados de búsqueda.
- Visualización del detalle de cada libro.
- Portada del libro cuando esté disponible.
- Título del libro.
- Autor o autores.
- Año de publicación cuando esté disponible.
- Opción para guardar libros.
- Opción para eliminar libros guardados.
- Una sección llamada **Mis libros**.
- Persistencia local de los libros guardados.
- Manejo de estados de carga.
- Manejo de errores.
- Manejo de búsquedas sin resultados.
- Manejo de libros sin portada.
- Manejo del estado de lista de libros guardados vacía.

## Flujo de usuario

La aplicación tendrá dos secciones principales:

- **Inicio**
- **Mis libros**

Desde la pantalla principal, el usuario podrá seleccionar directamente un libro de la lista para consultar su detalle o realizar una búsqueda.

Al realizar una búsqueda, la aplicación mostrará un estado de carga mientras obtiene la información de Open Library.

Si se obtienen resultados, el usuario podrá seleccionar un libro para acceder a su detalle.

Si la búsqueda no devuelve coincidencias, se mostrará un estado sin resultados y el usuario podrá modificar la búsqueda para intentarlo nuevamente.

Si ocurre un problema durante la consulta a Open Library, se mostrará un estado de error con la opción de volver a intentarlo.

Desde la pantalla de detalle, la aplicación comprobará si el libro ya se encuentra guardado.

- Si el libro no está guardado, se mostrará la opción **Guardar libro**.
- Si el libro ya está guardado, se mostrará la opción **Eliminar de Mis libros**.

La sección **Mis libros** mostrará los libros almacenados localmente. Desde esta sección el usuario también podrá seleccionar un libro para consultar su detalle.

Si todavía no existen libros guardados, se mostrará un estado de lista vacía que permitirá al usuario regresar a la búsqueda de libros.

Cuando un libro no tenga una portada disponible en Open Library, se mostrará un elemento visual sustituto en lugar de la imagen.

De esta manera, los diferentes flujos utilizan una misma pantalla de detalle y se conectan mediante el estado del libro y la navegación entre **Inicio** y **Mis libros**.

### Flujo general

<img width="1448" height="1086" alt="07-flujo-usuario" src="https://github.com/user-attachments/assets/fa488ace-31df-4de5-bb4a-6094bfa4aee4" />

**Detalle del libro** y **Mis libros** se repiten en el diagrama para mostrar con mayor claridad los distintos recorridos, pero corresponden a las mismas pantallas de la aplicación.

El diagrama representa los recorridos principales de navegación. Los estados de carga, error, búsqueda sin resultados, libro sin portada y lista de libros guardados vacía se muestran por separado en los wireframes.

## Wireframes

Los siguientes wireframes representan la estructura inicial de las principales pantallas de la aplicación y los estados necesarios para cubrir el MVP.

### Pantalla principal

La pantalla principal contiene el buscador, una lista inicial de libros y el acceso a la sección **Mis libros**.

<img width="941" height="1672" alt="01-pantalla-principal" src="https://github.com/user-attachments/assets/aeec5ced-9d0f-40c3-9ad7-566936d6f885" />

### Resultados de búsqueda

Muestra los libros encontrados después de realizar una búsqueda en Open Library.

<img width="941" height="1672" alt="02-resultados" src="https://github.com/user-attachments/assets/2832437b-cfa3-40a6-b506-cfcec5a5204c" />

### Detalle de un libro no guardado

Muestra la información del libro y permite guardarlo en la colección personal.

<img width="941" height="1672" alt="03-detalle-no-guardado" src="https://github.com/user-attachments/assets/29a59be6-227a-4ca1-865d-6f1440dba4d5" />

### Mis libros

Muestra los libros que el usuario ha guardado localmente.

<img width="941" height="1672" alt="04-mis-libros" src="https://github.com/user-attachments/assets/d0d44fd2-88cc-4d64-907c-714b101020bf" />

### Detalle de un libro guardado

Muestra la información de un libro que ya pertenece a la colección del usuario y permite eliminarlo de **Mis libros**.

<img width="941" height="1672" alt="05-detalle-guardado" src="https://github.com/user-attachments/assets/fc9a6265-71e6-4ee3-83da-af05aebe0d3d" />

### Mis libros vacío

Este estado se mostrará cuando el usuario todavía no tenga libros guardados.

<img width="941" height="1672" alt="06-mis-libros-vacio" src="https://github.com/user-attachments/assets/39c7128d-7280-4e08-bd93-36ec7da5010c" />

### Estados adicionales del MVP

Además de las pantallas principales, la aplicación contempla diferentes estados necesarios para manejar correctamente las respuestas de Open Library.

#### Búsqueda sin resultados

Se mostrará cuando Open Library no devuelva libros que coincidan con la búsqueda realizada. El usuario podrá modificar su búsqueda para intentarlo nuevamente.

#### Carga de resultados

Se mostrará mientras la aplicación obtiene los resultados de una búsqueda desde Open Library.

#### Error en la búsqueda

Se mostrará cuando ocurra un problema al obtener los resultados desde Open Library. El usuario tendrá la opción de intentar nuevamente la consulta.

#### Libro sin portada

Cuando Open Library no tenga una portada disponible para un libro, se mostrará un elemento visual sustituto en lugar de dejar el espacio de la imagen vacío.

<img width="1536" height="1024" alt="08-estados-adicionales" src="https://github.com/user-attachments/assets/d4c5124b-5d78-457f-b252-ebaca66c3d95" />

## Tecnologías previstas

- Swift
- SwiftUI
- Open Library API
- Navegación con SwiftUI
- Programación asíncrona con async/await
- Persistencia local
- Git y GitHub

## Accesibilidad con VoiceOver

La accesibilidad se consideró desde el diseño de los wireframes y del flujo de usuario de OpenBooks.

El criterio principal es que VoiceOver comunique la información necesaria para comprender y utilizar la aplicación, evitando anunciar de forma independiente elementos decorativos o información que ya esté representada mediante texto.

Las etiquetas de accesibilidad serán breves, claras y describirán directamente la información o acción relevante. No se utilizarán nombres internos de archivos, imágenes o iconos como descripciones para el usuario.

### Información accesible por pantalla

| Pantalla o estado | Información relevante para VoiceOver |
| --- | --- |
| Pantalla principal | OpenBooks, Buscar libros, Libros, título y autor de cada libro, Inicio y Mis libros. |
| Resultados | Resultados, acción para regresar, Buscar libros, valor actual de la búsqueda y título y autor de cada resultado. |
| Detalle del libro | Acción para regresar, Detalle del libro, título, autor, año cuando esté disponible y Guardar libro o Eliminar de Mis libros, según corresponda. |
| Mis libros | Mis libros, título y autor de cada libro guardado, Inicio y Mis libros. |
| Mis libros vacío | Mis libros, Todavía no tienes libros guardados, Busca un libro y guárdalo para verlo aquí y Buscar libros. |
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

- La lupa del buscador.
- Las flechas utilizadas como indicadores visuales.
- El icono utilizado en el estado Mis libros vacío.
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
- Guardar libro
- Eliminar de Mis libros
- Intentar nuevamente

No se utilizarán descripciones extensas cuando una acción pueda expresarse de forma directa.

Si posteriormente se agrega contenido textual visible, como una sinopsis, este también deberá ser accesible mediante VoiceOver. Actualmente la sinopsis no forma parte del MVP.

## Estado actual del proyecto

Actualmente se encuentran desarrollados:

- El objetivo y alcance del proyecto.
- El MVP.
- El flujo principal de usuario.
- Los wireframes de las principales pantallas.
- Las vistas principales de la aplicación en SwiftUI.
- La navegación inicial entre Inicio, Resultados, Detalle del libro y Mis libros.
- La representación de los estados de carga, error, búsqueda sin resultados, libro sin portada y lista de libros guardados vacía.
- La planificación de accesibilidad mediante VoiceOver.

La integración con Open Library, la persistencia local y las demás funcionalidades del MVP se desarrollarán progresivamente durante el proyecto.

## Ejecución del proyecto

1. Clonar o descargar el repositorio.
2. Abrir `OpenBooks.xcodeproj` en Xcode.
3. Seleccionar un simulador de iOS.
4. Ejecutar el proyecto desde Xcode.
