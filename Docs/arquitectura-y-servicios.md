# Arquitectura y servicios de OpenBooks

OpenBooks organiza la interfaz, el estado, los datos y las solicitudes externas en componentes separados. Esta estructura permite cambiar una pantalla sin mezclarla con las consultas a la API o con el guardado local.

## Estructura

- `Models/`: contiene `Book`, `SavedBook` y las estructuras que decodifican las respuestas JSON.
- `Services/`: contiene las consultas a Open Library y el acceso a SwiftData.
- `ViewModels/`: mantiene las colecciones de libros, los favoritos y los estados de búsqueda.
- `Views/`: contiene las pantallas y los componentes de SwiftUI.
- `Assets.xcassets/`: agrupa colores, ilustraciones y recursos gráficos.
- `OpenBooksTests/`: contiene las pruebas unitarias de los componentes principales.

## Búsqueda y sugerencias

`OpenLibraryBookSearchService` implementa `BookSearchService` y consulta `https://openlibrary.org/search.json` mediante `URLSession`, `async/await` y `JSONDecoder`. La petición incluye el texto en `q`, los campos requeridos en `fields` y un máximo de 15 resultados.

`OpenLibrarySearchResponse` contiene los documentos devueltos y `OpenLibraryBookDTO` transforma cada documento en un `Book` utilizado por la aplicación. El servicio comprueba que exista una URL válida, que la respuesta sea HTTP, que el código de estado indique éxito y que pueda decodificarse el JSON. Los fallos se comunican mediante `BookSearchError`.

En Inicio se consulta `subject:fiction` para mostrar sugerencias. La búsqueda del usuario utiliza la misma API, pero mantiene su estado independiente.

## Detalle de un libro

`OpenLibraryBookDetailsService` consulta `https://openlibrary.org/works/{workID}.json` para obtener, cuando están disponibles, una descripción, una lista de temas y una referencia de portada. `OpenLibraryWorkResponse` admite descripciones tanto en texto como en objetos JSON con un campo `value`.

El detalle muestra una indicación mientras descarga la descripción y presenta un mensaje distinto cuando no existe o cuando no se pudo recuperar. El año no se inventa: solo se muestra cuando Open Library lo proporciona. La descripción y los temas conservan el idioma original del catálogo.

## Portadas

`BookCoverArtworkView` obtiene las imágenes desde `https://covers.openlibrary.org/b/id/{coverID}-M.jpg?default=false`. Las portadas consultadas se reutilizan desde `NSCache` y desde un directorio temporal dentro de la caché de la aplicación.

Si no existe una portada o falla su descarga, la interfaz indica que no está disponible. Los recursos gráficos incluidos en la aplicación se mantienen en `Assets.xcassets`.

## Estados de interfaz

`SearchViewModel` representa cuatro situaciones mediante `SearchViewState`:

- `loading`: está en curso una consulta.
- `content`: hay resultados para mostrar.
- `noResults`: la consulta no encontró coincidencias.
- `error`: la solicitud falló y se informa el problema.

`ContentView` coordina la navegación y el inicio de las consultas. `BooksState` reúne los resultados por identificador, conserva la información recibida de cada obra y permite compartir los favoritos entre las pantallas.

## Persistencia

`SavedBook` es un modelo de SwiftData. `SavedBooksRepository` implementa `FavoriteBooksStore` y permite leer, guardar, quitar y actualizar los libros favoritos. `BooksState` únicamente confirma un cambio de favorito cuando la operación de almacenamiento termina correctamente.

Los favoritos permanecen después de cerrar y volver a abrir la aplicación. La caché de sugerencias en `UserDefaults` y la caché de imágenes son independientes de SwiftData.

## Decisiones técnicas

- Separar comunicación HTTP, estado y vistas para evitar duplicar lógica.
- Compartir una única colección de libros y favoritos para que Inicio, Resultados y Detalle muestren la misma información.
- Conservar el identificador de la obra de Open Library al guardar un favorito.
- Tratar año, descripción y portada como información opcional.
- Utilizar las herramientas de Swift y SwiftUI que ya forman parte del proyecto, sin depender de bibliotecas adicionales.

## Limitaciones

La disponibilidad de búsqueda, descripción y portada depende de Open Library. No todas las obras incluyen esos datos y algunos textos están en inglés. Los favoritos no se sincronizan con una cuenta. Es necesario comprobar por separado el comportamiento en dispositivos físicos y el recorrido completo con VoiceOver.

Consulta el [README](../README.md) para instalar y ejecutar OpenBooks.
