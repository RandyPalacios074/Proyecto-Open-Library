struct Book: Sendable {
    let id: String
    let title: String
    let author: String
    let year: String?
    let hasCover: Bool
    var isSaved: Bool
    let synopsis: String?
    let genre: String?
    let themes: [String]
    let coverID: Int?

    init(title: String, author: String, year: String?, hasCover: Bool,
         isSaved: Bool, synopsis: String? = nil, genre: String? = nil,
         themes: [String] = [], id: String? = nil, coverID: Int? = nil) {
        self.id = id ?? "\(author)|\(title)"
        self.title = title
        self.author = author
        self.year = year
        self.hasCover = hasCover
        self.isSaved = isSaved
        self.synopsis = synopsis
        self.genre = genre
        self.themes = themes
        self.coverID = coverID
    }
}
