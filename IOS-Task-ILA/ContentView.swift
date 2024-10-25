import SwiftUI

struct ContentView: View {
    @State private var searchQuery = ""
    @State private var selectedLanguage: String?

    private var languageGroups: [[(name: String, icon: String)]] {
        let languages = (0..<60).map { index in
            let languageName = "Language \(index + 1)"
            let iconName = index % 2 == 0 ? "image4" : "image5"
            return (languageName, iconName)
        }

        var groupedLanguages: [[(name: String, icon: String)]] = []
        for i in stride(from: 0, to: languages.count, by: 20) {
            let group = Array(languages[i..<min(i + 20, languages.count)])
            groupedLanguages.append(group)
        }
        return groupedLanguages
    }

    @State private var currentPage = 0
    private let bannerImages = ["image1", "image2", "image3"]

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color("DarkPurple"), Color("LightPurple")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 16) {
                    BannerImageScrollView(imageNames: bannerImages, currentPage: $currentPage)
                        .frame(height: 220)
                        .padding(.top, 16)

                    PageControl(numberOfPages: bannerImages.count, currentPage: $currentPage)
                        .padding(.top, 8)

                    SearchBar(text: $searchQuery)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    LazyVStack {
                        ForEach(filteredLanguages, id: \.name) { language in
                            HStack {
                                Image(language.icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .padding(8)
                                    .background(Color("CardBackground"))
                                    .clipShape(Circle())

                                Text(language.name)
                                    .foregroundColor(.primary)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .center)

                                Spacer()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                            .onTapGesture {
                                selectedLanguage = language.name
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private var filteredLanguages: [(name: String, icon: String)] {
        let currentLanguages = languageGroups[currentPage]
        if searchQuery.isEmpty {
            return currentLanguages
        } else {
            return currentLanguages.filter { language in
                language.name.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }
}

struct BannerImageScrollView: View {
    let imageNames: [String]
    @Binding var currentPage: Int

    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $currentPage) {
                ForEach(0..<imageNames.count, id: \.self) { index in
                    Image(imageNames[index])
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .cornerRadius(12)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic)) // Show the page dots
        }
        .frame(height: 220)
    }
}

struct PageControl: UIViewRepresentable {
    var numberOfPages: Int
    @Binding var currentPage: Int

    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = numberOfPages
        control.currentPage = currentPage
        control.pageIndicatorTintColor = UIColor.gray
        control.currentPageIndicatorTintColor = UIColor.white
        return control
    }

    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
    }
}

struct SearchBar: UIViewRepresentable {
    @Binding var text: String

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        searchBar.placeholder = "Search languages"
        searchBar.barTintColor = UIColor.systemGray5
        searchBar.searchTextField.backgroundColor = UIColor.white
        searchBar.searchTextField.textColor = UIColor.black
        searchBar.tintColor = UIColor.black
        searchBar.layer.cornerRadius = 10
        searchBar.layer.masksToBounds = true
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
}
