# Organización MVVM

OpenBooks separa las vistas, la información del libro y las operaciones de red y persistencia. Esta organización mantiene la lógica de negocio fuera de los componentes que muestran la interfaz.

## Modelos

- `Book`: representa un libro dentro de la aplicación. Tiene identificador, título, autor y datos opcionales como año, portada, descripción y temas.
- `SavedBook`: modelo `@Model` de SwiftData para conservar favoritos.
- `OpenLibrarySearchResponse` y `OpenLibraryBookDTO`: decodifican y convierten respuestas de búsqueda.
- `OpenLibraryWorkResponse`: interpreta la información adicional de cada obra.

## Vistas

`HomeView`, `SearchView`, `SearchResultsView`, `BookDetailView` y `MyBooksView` muestran los datos y presentan las acciones disponibles. `ContentView` conserva la navegación. Los componentes reutilizables se agrupan en `Views/Components/`.

Las vistas no construyen solicitudes HTTP ni acceden directamente al contexto de SwiftData.

## ViewModels

- `SearchViewModel` controla el texto de búsqueda, el estado de la consulta y los índices de libros encontrados.
- `BooksState` reúne los libros por identificador, comparte sus datos entre las pantallas y administra los favoritos.
- `SearchViewState` distingue carga, contenido, ausencia de resultados y error.

`OpenBooksApp` prepara los servicios y proporciona a `ContentView` el estado compartido de los libros.

## Servicios

- `BookSearchService`: contrato para solicitar libros de una búsqueda.
- `OpenLibraryBookSearchService`: implementación que utiliza `URLSession` y `JSONDecoder`.
- `BookDetailsService`: contrato para consultar detalles de una obra.
- `OpenLibraryBookDetailsService`: implementación de los detalles de Open Library.
- `FavoriteBooksStore`: contrato para guardar y consultar favoritos.
- `SavedBooksRepository`: implementación de almacenamiento con SwiftData.

## Flujo de información

```text
SearchView → SearchViewModel → BookSearchService → Open Library
                                   ↓
                             BooksState
                                   ↓
                         SearchResultsView

BookDetailView → BooksState → FavoriteBooksStore → SwiftData
```

Los servicios se pueden sustituir por implementaciones controladas dentro de las pruebas, sin consultar la API real ni modificar favoritos guardados.

Consulta [Arquitectura y servicios](arquitectura-y-servicios.md) para conocer los endpoints y las decisiones técnicas.
